# -*- python -*-

# Copyright 2018-2019 Josh Pieper, jjp@pobox.com.
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

def mbed_binary(enable_wrappers=True,
                **kwargs):
    '''enable_wrappers if true, wraps all the standard library functions
    so that the mbed provided versions will be used instead.  This may
    be disabled if you want to wrap them yourselves, or don't need all
    of them.
    '''
    deps = kwargs.pop("deps", [])[:]

    linker_override = kwargs.pop("linker_script", None)

    deps += [
        Label("//:mbed"),
    ]

    srcs = kwargs.pop("srcs", [])[:]
    linkopts = kwargs.pop("linkopts", [])[:]

    linkopts += [
        "-L$(GENDIR)",
    ]

    # We always provide the mbed_script as a dependency, in case
    # someone wants to include it.
    mbed_script = Label("//:linker_script.ld")
    deps += [mbed_script]
    linkopts += ["-L$(GENDIR)"]

    if linker_override:
        script = linker_override
        linkopts += ["-T $(location {})".format(script)]
        deps += [script]
    else:
        # We need the linker script to be properly expanded when passed to
        # ld's "-T" option.  bazel claims it will do that, but it doesn't
        # seem to work properly, maybe due to spanning an external
        # repository boundary?  So for now, we just manually expand the
        # pieces using GENDIR to get to the right place.
        linkopts += [
            "-T $(GENDIR)/{}/{}".format(mbed_script.workspace_root,
                                        mbed_script.name),
        ]

    if enable_wrappers:
        linkopts += [
            # This will cause the mbed allocation wrapper object to not be
            # dropped on the floor.  (the mbed toolchain links everything as .o
            # files, with no intermediate .a files, so this isn't a problem
            # there).
            "-Wl,--undefined=__wrap__free_r",

            # Hook in the mbed allocation wrappers.
            "-Wl,--wrap,main",
            "-Wl,--wrap,_malloc_r",
            "-Wl,--wrap,_free_r",
            "-Wl,--wrap,_realloc_r",
            "-Wl,--wrap,_memalign_r",
            "-Wl,--wrap,_calloc_r",
            "-Wl,--wrap,exit",
            "-Wl,--wrap,atexit",
        ]

    copts = kwargs.pop("copts", [])[:]

    # The mbed headers can't handle these warnings.
    copts += [
        "-Wno-register",
        "-Wno-unused-parameter",
    ]

    name = kwargs.pop("name")

    native.cc_binary(
        name = "{}.elf".format(name),
        deps = deps,
        linkopts = linkopts,
        srcs = srcs,
        copts = copts,
        linkstatic = 1,
        **kwargs
    )

    native.genrule(
        name = name,
        srcs = ["{}.elf".format(name)],
        outs = ["{}.bin".format(name)],
        tools = ["@com_arm_developer_gcc//:objcopy"],
        cmd = "$(location @com_arm_developer_gcc//:objcopy) -O binary $< $@",
        output_to_bindir = True
    )
