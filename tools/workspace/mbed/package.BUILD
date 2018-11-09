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


# Yay, The mbed source is full of circular dependencies.  About the
# best we can do is lump everything into one giant cc_library and suck
# up the recompilation time.
cc_library(
    name = "mbed",
    hdrs = glob(
        @HDR_GLOBS@
    ),
    srcs = glob(
        @SRC_GLOBS@
    ),
    includes =
        @INCLUDES@
    ,
    copts =
        @COPTS@
    ,
    defines = [
        "_RTE_",
        "__MBED__",
        "__FPU_PRESENT",
        "__CMSIS_RTOS",
        "__CORTEX_M4",
        "__MBED_CMSIS_RTOS_CM",
        "ARM_MATH_CM4",
        "TOOLCHAIN_GCC",
        "TOOLCHAIN_GCC_ARM",

        # TODO(jpieper): Configure the following defines based on
        # target.
        "TARGET_RTOS_M4_M7",
        "TARGET_STM32F4",
        "TARGET_STM32F446xE",
        "TARGET_CORTEX_M",
        "TARGET_LIKE_CORTEX_M4",
        "TARGET_M4",
        "TARGET_CORTEX",
        "TARGET_STM32F446ZE",

        "TARGET_FAMILY_STM32",
        "TARGET_FF_MORPHO",
        "TARGET_FF_ARDUINO",
        "TARGET_STM",
        "TARGET_RELEASE",
        "TARGET_NUCLEO_F446ZE",
        "TARGET_LIKE_MBED",

        "USBHOST_OTHER",
        "USB_STM_HAL",

        "DEVICE_ANALOGIN",
        "DEVICE_ANALOGOUT",
        "DEVICE_CAN",
        "DEVICE_FLASH",
        "DEVICE_I2C",
        "DEVICE_I2CSLAVE",
        "DEVICE_INTERRUPTIN",
        "DEVICE_LPTICKER",
        "DEVICE_PORTIN",
        "DEVICE_PORTINOUT",
        "DEVICE_PORTOUT",
        "DEVICE_PWMOUT",
        "DEVICE_RTC",
        "DEVICE_SERIAL",
        "DEVICE_SERIAL_ASYNCH",
        "DEVICE_SLEEP",
        "DEVICE_SPI",
        "DEVICE_SPISLAVE",
        "DEVICE_SPI_ASYNCH",
        "DEVICE_STDIO_MESSAGES",
        "DEVICE_USTICKER",
    ],
)

filegroup(
    name = "linker_script",
    srcs = [
        @LINKER_SCRIPT@
    ]
)
