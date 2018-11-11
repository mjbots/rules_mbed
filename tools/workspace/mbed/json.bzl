# -*- python -*-

# Copyright 2018 Josh Pieper, jjp@pobox.com.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# bazel and starlark, in their infinite wisdom, do not allow use of
# the python standard library, or even recursion.  (I think this
# limitation was made before repository rules were a thing).  Thus, I
# get to reimplement a crude form of json parsing here purely
# iteratively.

_TYPE_OBJECT_KEY = 1
_TYPE_OBJECT_POST_KEY = 2
_TYPE_OBJECT_VALUE = 3
_TYPE_OBJECT_POST_VALUE = 4
_TYPE_ARRAY = 5
_TYPE_ARRAY_POST_VALUE = 6
_TYPE_STRING = 7
_TYPE_NUMBER = 8
_TYPE_TRUE = 9
_TYPE_FALSE = 10
_TYPE_NULL = 11

_WHITESPACE = [' ', '\r', '\n', '\t']
_DIGITS = ['0', '1', '2', '3', '4',
           '5', '6', '7', '8', '9', '.', 'e', 'E', '-', '+']


def _require_next(result, element, expected_total):
    """We are parsing a literal.  Require that the next character exactly
    match the next character in the literal."""

    current = result[-1][1]
    expected_char = expected_total[len(current)]
    if element != expected_char:
        fail("unexpected '" + element + "' when reading: " + expected_total)

    result[-1][1] = result[-1][1] + element


def _incorporate_value(result):
    """The top value of the stack is complete.  Merge it into its
    parent."""

    latest_value = result[-1][1]
    latest_type = result[-1][0]
    result.pop()

    if latest_type == _TYPE_TRUE:
        latest_value = True
    elif latest_type == _TYPE_FALSE:
        latest_value = False
    elif latest_type == _TYPE_NULL:
        latest_value = None
    elif latest_type == _TYPE_NUMBER:
        # Starlark does not support floating point numbers.  We'll
        # just leave these as strings for now.
        #
        # We would like to do: latest_value = float(latest_value)
        pass

    if len(result) == 0:
        fail("value with no parent type")

    current_type = result[-1][0]

    if current_type == _TYPE_OBJECT_KEY:
        if len(result[-1]) != 2:
            fail("unexpected object length")
        result[-1].append(latest_value)
        result[-1][0] = _TYPE_OBJECT_POST_KEY
    elif current_type == _TYPE_OBJECT_VALUE:
        if len(result[-1]) != 3:
            fail("unexpected object length")
        this_obj = result[-1][1]
        this_obj[result[-1][2]] = latest_value
        result[-1].pop()
        result[-1][0] = _TYPE_OBJECT_POST_VALUE
    elif current_type == _TYPE_ARRAY:
        result[-1][1].append(latest_value)
        result[-1][0] = _TYPE_ARRAY_POST_VALUE
    else:
        fail("unexpected parent of value")


def parse_json(text):
    """Given JSON formatted text, parse it into a python dictionary and
    return the result.  The top level entity *must* be a JSON object.

    This is not very efficient, but it is just intended to be used
    within bazel repository rules for one time configuration.

    It just follows the BNF described at json.org
    """

    begin = True

    # Yay.  Starlark doesn't let us have classes or anything else
    # nice.  So, this stack will be just a perl style list of lists of
    # lists of stuff.
    #
    # The stack describes the current parse tree:
    #   [ parent,
    #     child,
    #     grandchild,
    #     .... etc ...
    #
    # Each element is a list of the form:
    #  [ TYPE, CURRENT_DATA ] + (maybe more things)
    #
    # The "maybe more things" is type specific:
    #  _TYPE_OBJECT_POST_KEY/_TYPE_OBJECT_POST_VALUE:
    #     Here the extra is the key string which has already been parsed.
    #  _TYPE_STRING
    #     If None is here, that means we are processing an escape
    #     sequence.  If the list is only 2 long, ([type, data]), then we
    #     are not processing an escape.
    result_stack = []

    for index in range(len(text)):
        element = text[index]
        if begin:
            # Skip until we get the first open brace.
            if element != '{':
                continue
            result_stack.append([_TYPE_OBJECT_KEY, {}])
            begin = False
            continue

        current_type = result_stack[-1][0]

        if current_type == _TYPE_OBJECT_KEY:
            if element != '"':
                continue
            result_stack.append([_TYPE_STRING, ""])
            continue
        elif current_type == _TYPE_OBJECT_POST_KEY:
            if element in _WHITESPACE:
                continue
            elif element == ':':
                result_stack[-1][0] = _TYPE_OBJECT_VALUE
            else:
                fail("unexpected value after key: " + element)
        elif current_type == _TYPE_STRING:
            if len(result_stack[-1]) > 2:
                # We have an outstanding escape backslash.  For now,
                # we only support single escape sequences (no
                # unicode).
                result_stack[-1].pop()
                c = None
                if element == '"':
                    c = '"'
                elif element == '\\':
                    c = '\\'
                elif element == '/':
                    c = '/'
                elif element == 'b':
                    fail("starlark does not support \\b")
                elif element == 'f':
                    fail("starlark does not support \\f")
                elif element == 'n':
                    c = '\n'
                elif element == 'r':
                    c = '\r'
                elif element == 't':
                    c = '\t'
                elif element == 'u':
                    fail("unicode is not supported")
                else:
                    fail("unsupported escape: " + element)
                result_stack[-1][1] = result_stack[-1][1] + c
            else:
                if element == '"':
                    # This ends our string, strings are always a part of a
                    # parent.
                    _incorporate_value(result_stack)
                elif element == '\\':
                    result_stack[-1].append(None)
                else:
                    result_stack[-1][1] = result_stack[-1][1] + element
        elif current_type == _TYPE_NUMBER:
            # Numbers are special, in that they can end directly with
            # another token.  So our state machine is constructed that
            # if we are here, then the element *must* be a number
            # already.
            if element not in _DIGITS:
                fail("logic error")

            result_stack[-1][1] = result_stack[-1][1] + element

            # And then we look *ahead* to see if we should stop
            # processing the number.  This way when we go through the
            # loop the next time, we can properly process the next
            # token.
            if text[index + 1] not in _DIGITS:
                # This ends our number.
                _incorporate_value(result_stack)
        elif current_type == _TYPE_TRUE:
            _require_next(result_stack, element, "true")
            if result_stack[-1][1] == "true":
                _incorporate_value(result_stack)
        elif current_type == _TYPE_FALSE:
            _require_next(result_stack, element, "false")
            if result_stack[-1][1] == "false":
                _incorporate_value(result_stack)
        elif current_type == _TYPE_NULL:
            _require_next(result_stack, element, "null")
            if result_stack[-1][1] == "null":
                _incorporate_value(result_stack)
        elif current_type == _TYPE_OBJECT_VALUE or current_type == _TYPE_ARRAY:
            # We are looking for the beginning of a new value.
            if element in _WHITESPACE:
                pass
            elif element == '"':
                result_stack.append([_TYPE_STRING, ""])
            elif element == '[':
                result_stack.append([_TYPE_ARRAY, []])
            elif element == '{':
                result_stack.append([_TYPE_OBJECT_KEY, {}])
            elif element == 't':
                result_stack.append([_TYPE_TRUE, "t"])
            elif element == 'f':
                result_stack.append([_TYPE_FALSE, "f"])
            elif element == 'n':
                result_stack.append([_TYPE_NULL, "n"])
            elif element in _DIGITS:
                result_stack.append([_TYPE_NUMBER, element])
                # This might be the sole digit.
                if text[index + 1] not in _DIGITS:
                    _incorporate_value(result_stack)
            elif element == ']' and current_type == _TYPE_ARRAY:
                _incorporate_value(result_stack)
            else:
                fail("Unexpected character: " + element)
        elif current_type == _TYPE_OBJECT_POST_VALUE:
            if element in _WHITESPACE:
                pass
            elif element == '}':
                if len(result_stack) == 1:
                    # We're done!
                    return result_stack[0][1]
                _incorporate_value(result_stack)
            elif element == ',':
                result_stack[-1][0] = _TYPE_OBJECT_KEY
            else:
                fail("Unexpected character: " + element)
        elif current_type == _TYPE_ARRAY_POST_VALUE:
            if element in _WHITESPACE:
                pass
            elif element == ']':
                _incorporate_value(result_stack)
            elif element == ',':
                result_stack[-1][0] = _TYPE_ARRAY
            else:
                fail("Unexpected character: " + element)
