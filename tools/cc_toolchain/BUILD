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

package(default_visibility = ["//visibility:public"])

cc_toolchain_suite(
    name = "toolchain",
    toolchains = {
        "k8|gcc": "cc_toolchain_linux",
        "stm32f4|gcc": "cc_toolchain_armeabihf_stm32f4",
    },
)

filegroup(
    name = "empty",
    srcs = [],
)

filegroup(
    name = "everything",
    srcs = [
        "@com_arm_developer_gcc//:everything",
    ] + glob(["wrapper/arm-none-eabi-*"]),
)

cc_toolchain(
    name = "cc_toolchain_linux",
    all_files = ":empty",
    compiler_files = ":empty",
    cpu = "k8",
    dwp_files = ":empty",
    dynamic_runtime_libs = [":empty"],
    linker_files = ":empty",
    objcopy_files = ":empty",
    static_runtime_libs = [":empty"],
    strip_files = ":empty",
    supports_param_files = 0,
    toolchain_identifier = "local_linux",
)

cc_toolchain(
    name = "cc_toolchain_armeabihf_stm32f4",
    all_files = ":everything",
    compiler_files = ":everything",
    cpu = "armeabihf",
    dwp_files = ":empty",
    dynamic_runtime_libs = [":empty"],
    linker_files = ":everything",
    objcopy_files = ":empty",
    static_runtime_libs = [":empty"],
    strip_files = ":empty",
    supports_param_files = 0,
    toolchain_identifier = "gcc-armeabihf-stm32f4",
)
