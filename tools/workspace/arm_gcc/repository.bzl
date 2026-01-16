# -*- python -*-

# Copyright 2023 mjbots Robotic Systems, LLC.  info@mjbots.com
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

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")


def arm_gcc_repository(name):
    http_archive(
        name = name,
        urls = [
            "https://armkeil.blob.core.windows.net/developer/files/downloads/gnu/15.2.rel1/binrel/arm-gnu-toolchain-15.2.rel1-x86_64-arm-none-eabi.tar.xz",
        ],
        sha256 = "597893282ac8c6ab1a4073977f2362990184599643b4c5ee34870a8215783a16",
        strip_prefix = "arm-gnu-toolchain-15.2.rel1-x86_64-arm-none-eabi",
        build_file = Label("//tools/workspace/arm_gcc:package.BUILD"),
    )
