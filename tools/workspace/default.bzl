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

load("//tools/workspace/arm_gcc:repository.bzl", "arm_gcc_repository")
load("//tools/workspace/mbed:repository.bzl", "mbed_repository")


DEFAULT_CONFIG = {
    "mbed_target": "targets/TARGET_STM/TARGET_STM32F4/TARGET_STM32F446xE/TARGET_NUCLEO_F446ZE",
    "mbed_config": None,
}

def add_default_repositories(*, config = DEFAULT_CONFIG, excludes = []):
    if "arm_gcc" not in excludes:
        arm_gcc_repository(name = "com_arm_developer_gcc")
    if "mbed" not in excludes:
        mbed_repository(name = "com_github_ARMmbed_mbed-os",
                        target = config["mbed_target"],
                        config = config["mbed_config"])
