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

load("@bazel_tools//tools/build_defs/repo:utils.bzl", "patch")

DEFAULT_CONFIG = {
    "CLOCK_SOURCE": "USE_PLL_HSE_EXTC|USE_PLL_HSI",
    "LPTICKER_DELAY_TICKS": "1",
    "MBED_CONF_DRIVERS_UART_SERIAL_RXBUF_SIZE": "256",
    "MBED_CONF_DRIVERS_UART_SERIAL_TXBUF_SIZE": "256",
    "MBED_CONF_EVENTS_SHARED_DISPATCH_FROM_APPLICATION": "1",
    "MBED_CONF_EVENTS_SHARED_EVENTSIZE": "256",
    "MBED_CONF_EVENTS_SHARED_HIGHPRIO_EVENTSIZE": "256",
    "MBED_CONF_EVENTS_SHARED_HIGHPRIO_STACKSIZE": "1024",
    "MBED_CONF_EVENTS_SHARED_STACKSIZE": "1024",
    "MBED_CONF_EVENTS_USE_LOWPOWER_TIMER_TICKER": "0",
    "MBED_CONF_PLATFORM_DEFAULT_SERIAL_BAUD_RATE": "9600",
    "MBED_CONF_PLATFORM_ERROR_ALL_THREADS_INFO": "0",
    "MBED_CONF_PLATFORM_ERROR_DECODE_HTTP_URL_STR": "\"\"",
    "MBED_CONF_PLATFORM_ERROR_FILENAME_CAPTURE_ENABLED": "0",
    "MBED_CONF_PLATFORM_ERROR_HIST_ENABLED": "0",
    "MBED_CONF_PLATFORM_ERROR_HIST_SIZE": "4",
    "MBED_CONF_PLATFORM_FORCE_NON_COPYABLE_ERROR": "0",
    "MBED_CONF_PLATFORM_MAX_ERROR_FILENAME_LEN": "16",
    "MBED_CONF_PLATFORM_POLL_USE_LOWPOWER_TIMER": "0",
    "MBED_CONF_PLATFORM_STDIO_BAUD_RATE": "9600",
    "MBED_CONF_PLATFORM_STDIO_BUFFERED_SERIAL": "0",
    "MBED_CONF_PLATFORM_STDIO_CONVERT_NEWLINES": "0",
    "MBED_CONF_PLATFORM_STDIO_FLUSH_AT_EXIT": "1",
    "MBED_CONF_RTOS_IDLE_THREAD_STACK_SIZE": "512",
    "MBED_CONF_RTOS_MAIN_THREAD_STACK_SIZE": "4096",
    "MBED_CONF_RTOS_PRESENT" : "1",
    "MBED_CONF_RTOS_THREAD_STACK_SIZE": "4096",
    "MBED_CONF_RTOS_TIMER_THREAD_STACK_SIZE": "768",
    "MBED_CONF_TARGET_LPUART_CLOCK_SOURCE": "USE_LPUART_CLK_LSE|USE_LPUART_CLK_PCLK1",
    "MBED_CONF_TARGET_LSE_AVAILABLE": "1",
    "MEM_ALLOC": "malloc",
    "MEM_FREE": "free",
}


def _render_list(data):
    result = "[\n"
    for item in data:
        result += ' "{}",\n'.format(item)
    result += "]\n"
    return result


def _impl(repository_ctx):
    PREFIX = "external/{}".format(repository_ctx.name)

    repository_ctx.download_and_extract(
        url = [
            "https://github.com/ARMmbed/mbed-os/archive/mbed-os-5.10.3.tar.gz",
        ],
        sha256 = "4bac626fe1a3c9d0134a8763d5d30bb33abe02cc33c51ef98ae1c2f41bc8f8e8",
        stripPrefix = "mbed-os-mbed-os-5.10.3",
    )
    patch(repository_ctx)

    defines = '\n'.join(["#define {} {}".format(key, value)
                         for key, value in repository_ctx.attr.config.items()])
    mbed_config = """
#ifndef __MBED_CONFIG_DATA__
#define __MBED_CONFIG_DATA__

{}

#endif
""".format(defines)

    repository_ctx.file("mbed_config.h", mbed_config, executable=False)

    # Since mbed is full of circular dependencies, we just construct
    # the full set of headers and sources here, then pass it down into
    # the BUILD file verbatim for using in a single bazel label.

    target = repository_ctx.attr.target

    hdr_globs = [
        "mbed.h",
        "platform/*.h",
        "drivers/*.h",
        "cmsis/*.h",
        "cmsis/TARGET_CORTEX_M/*.h",
        "hal/*.h",
        "mbed_config.h",
        "rtos/*.h",
        "rtos/TARGET_CORTEX/**/*.h",
    ]

    src_globs = [
        "platform/*.c",
        "platform/*.cpp",
        "drivers/*.cpp",
        "cmsis/TARGET_CORTEX_M/*.c",
        "hal/*.c",
        "rtos/TARGET_CORTEX/*.c",
        "rtos/TARGET_CORTEX/*.cpp",
        "rtos/TARGET_CORTEX/rtx5/RTX/Source/*.c",
        "rtos/TARGET_CORTEX/rtx5/Source/*.c",
        "rtos/TARGET_CORTEX/TOOLCHAIN_GCC_ARM/*.c",
        "rtos/*.cpp",
    ]

    includes = [
        # ".",
        # "platform",
        # "drivers",
        # "cmsis/TARGET_CORTEX_M",
    ]
    copts = [
        "-Wno-unused-parameter",
        "-Wno-missing-field-initializers",
        "-Wno-register",
        "-Wno-deprecated-declarations",

        # We put these in here instead of 'includes' until we get an
        # ARM GCC that has correct "NO_IMPLICIT_EXTERN_C" behavior.
        "-I{}".format(PREFIX),
        "-I{}/platform".format(PREFIX),
        "-I{}/drivers".format(PREFIX),
        "-I{}/cmsis".format(PREFIX),
        "-I{}/cmsis/TARGET_CORTEX_M".format(PREFIX),
        "-I{}/hal".format(PREFIX),
        "-I{}/rtos".format(PREFIX),
        "-I{}/rtos/TARGET_CORTEX".format(PREFIX),
        "-I{}/rtos/TARGET_CORTEX/rtx4".format(PREFIX),
        "-I{}/rtos/TARGET_CORTEX/rtx5/Include".format(PREFIX),
        "-I{}/rtos/TARGET_CORTEX/rtx5/Source".format(PREFIX),
        "-I{}/rtos/TARGET_CORTEX/rtx5/RTX/Include".format(PREFIX),
        "-I{}/rtos/TARGET_CORTEX/rtx5/RTX/Source".format(PREFIX),
        "-I{}/rtos/TARGET_CORTEX/rtx5/RTX/Config".format(PREFIX),
        "-include mbed_config.h",
    ]

    linker_script = ""

    # Walk up the target path adding directories as we go.
    remaining_target = target
    for i in range(1000):
        hdr_globs += [
            "{}/*.h".format(remaining_target),
            "{}/device/*.h".format(remaining_target),
        ]
        src_globs += [
            "{}/*.c".format(remaining_target),
            "{}/*.cpp".format(remaining_target),
            "{}/device/*.c".format(remaining_target),
            "{}/device/TOOLCHAIN_GCC_ARM/*.S".format(remaining_target),
        ]
        copts += [
            "-I{}/{}".format(PREFIX, remaining_target),
            "-I{}/{}/device".format(PREFIX, remaining_target),
        ]

        # Does this directory contain the linker script?

        linker_search_path = "{}/device/TOOLCHAIN_GCC_ARM/".format(remaining_target)
        find_result = repository_ctx.execute(["find", linker_search_path, '-name', '*.ld'])
        if find_result.return_code == 0 and len(find_result.stdout) > 0:
            linker_script = find_result.stdout.strip()

        items = remaining_target.rsplit('/', 1)
        if len(items) == 1:
            break

        remaining_target = items[0]

    substitutions = {
        '@HDR_GLOBS@' : _render_list(hdr_globs),
        '@SRC_GLOBS@' : _render_list(src_globs),
        '@INCLUDES@' : _render_list(includes),
        '@COPTS@' : _render_list(copts),
    }

    repository_ctx.template(
        'BUILD',
        repository_ctx.attr.build_file_template,
        substitutions = substitutions,
    )

    repository_ctx.symlink(linker_script, "linker_script.ld.in")

_mbed_repository = repository_rule(
    implementation = _impl,
    attrs = {
        "build_file_template" : attr.label(allow_single_file = True),
        "target" : attr.string(),
        "config" : attr.string_dict(),
        "patches": attr.label_list(default = []),
        "patch_tool": attr.string(default = "patch"),
        "patch_args": attr.string_list(default = ["-p0"]),
        "patch_cmds": attr.string_list(default = []),
    }
)

def mbed_repository(
        name,
        target = "targets/TARGET_STM/TARGET_STM32F4/TARGET_STM32F446xE/TARGET_NUCLEO_F446ZE",
        config = None):

    _mbed_repository(
        name= name,
        build_file_template = Label("//tools/workspace/mbed:package.BUILD"),
        target = target,
        config = config or DEFAULT_CONFIG,
    )
