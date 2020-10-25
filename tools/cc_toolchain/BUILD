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

package(default_visibility = ["//visibility:public"])

load(":cc_toolchain_config.bzl", "cc_toolchain_config_stm32")
load("@rules_cc//cc:defs.bzl", "cc_toolchain")

# We keep this around so that users can work around
# https://github.com/bazelbuild/bazel/issues/12036 by specifying an
# otherwise unused crosstool_top.
cc_toolchain_suite(
    name = "toolchain",
    toolchains = {
        "stm32g4|compiler": "gcc-stm32g4",
        "stm32f4|compiler": "gcc-stm32f4",
        "stm32f0|compiler": "gcc-stm32f0",
    },
)

filegroup(
    name = "empty",
    srcs = [],
)

filegroup(
    name = "arm_everything",
    srcs = [
        "@com_arm_developer_gcc//:everything",
    ] + glob(["wrapper/arm-none-eabi-*"]),
)

cc_toolchain_config_stm32(
    name = "gcc-stm32f0-config",
    cpu = "stm32f0",
    toolchain_identifier = "gcc-stm32f0",
    host_compiler_prefix = "wrapper",
    host_compiler_path = "wrapper/arm-none-eabi-g++",
    builtin_include_directories = [
        "external/com_arm_developer_gcc/arm-none-eabi/include/",
        "external/com_arm_developer_gcc/arm-none-eabi/include/sys/",
    ],
)

cc_toolchain(
    name = "gcc-stm32f0",
    all_files = ":arm_everything",
    compiler_files = ":arm_everything",
    dwp_files = ":arm_everything",
    linker_files = ":arm_everything",
    objcopy_files = ":arm_everything",
    strip_files = ":arm_everything",
    ar_files = ":arm_everything",
    as_files = ":arm_everything",
    supports_param_files = 0,
    toolchain_config = ":gcc-stm32f0-config",
)

toolchain(
    name = "cc_toolchain_stm32f0",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "//cpu:stm32f0",
    ],
    toolchain = ":gcc-stm32f0",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

cc_toolchain_config_stm32(
    name = "gcc-stm32f4-config",
    cpu = "stm32f4",
    toolchain_identifier = "gcc-stm32f4",
    host_compiler_prefix = "wrapper",
    host_compiler_path = "wrapper/arm-none-eabi-g++",
    builtin_include_directories = [
        "external/com_arm_developer_gcc/arm-none-eabi/include/",
        "external/com_arm_developer_gcc/arm-none-eabi/include/sys/",
    ],
)

cc_toolchain(
    name = "gcc-stm32f4",
    all_files = ":arm_everything",
    compiler_files = ":arm_everything",
    dwp_files = ":arm_everything",
    linker_files = ":arm_everything",
    objcopy_files = ":arm_everything",
    strip_files = ":arm_everything",
    ar_files = ":arm_everything",
    as_files = ":arm_everything",
    supports_param_files = 0,
    toolchain_config = ":gcc-stm32f4-config",
)

toolchain(
    name = "cc_toolchain_stm32f4",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "//cpu:stm32f4",
    ],
    toolchain = ":gcc-stm32f4",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

cc_toolchain_config_stm32(
    name = "gcc-stm32g4-config",
    cpu = "stm32g4",
    toolchain_identifier = "gcc-stm32g4",
    host_compiler_prefix = "wrapper",
    host_compiler_path = "wrapper/arm-none-eabi-g++",
    builtin_include_directories = [
        "external/com_arm_developer_gcc/arm-none-eabi/include/",
        "external/com_arm_developer_gcc/arm-none-eabi/include/sys/",
    ],
)

cc_toolchain(
    name = "gcc-stm32g4",
    all_files = ":arm_everything",
    compiler_files = ":arm_everything",
    dwp_files = ":arm_everything",
    linker_files = ":arm_everything",
    objcopy_files = ":arm_everything",
    strip_files = ":arm_everything",
    ar_files = ":arm_everything",
    as_files = ":arm_everything",
    supports_param_files = 0,
    toolchain_config = ":gcc-stm32g4-config",
)

toolchain(
    name = "cc_toolchain_stm32g4",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "//cpu:stm32g4",
    ],
    toolchain = ":gcc-stm32g4",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)
