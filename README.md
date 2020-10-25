# mbed rules for Bazel #

This package provides bazel (https://bazel.build) rules for building
binaries for mbed-os (https://github.com/ARMmbed/mbed-os) embedded
targets.  It includes bazel configuration for the ARM-GCC toolchain,
as well as dedicated bazel rules for building output binary files.  It
supports multiple distinct mbed targets within the same build.

* License: Apache 2.0
* travis-ci [![Build Status](https://travis-ci.org/mjbots/rules_mbed.svg?branch=master)](https://travis-ci.org/mjbots/rules_mbed)
* Processors: STM32F0, STM32F4, and STM32G4 family processors

## Usage ##

In `WORKSPACE` add this:

```
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

RULES_MBED_COMMIT = "XXX"

http_archive(
    name = "rules_mbed",
    url = "https://github.com/mjbots/bazel_deps/{}.zip".format(RULES_MBED_COMMIT),
    sha256 = "XXX",
    strip_prefix = "rules_mbed-{}".format(RULES_MBED_COMMIT),
)

load("@rules_mbed//:rules.bzl", "mbed_register")
mbed_register(config = {
    "mbed_target": "targets/TARGET_STM/TARGET_STM32F4/TARGET_STM32F411xE/TARGET_NUCLEO_F411RE",
    "mbed_config": None,
  }
)
```

Then in a BUILD file you can use:

```
load("@com_github_ARMmbed_mbed-os//:rules.bzl", "mbed_binary")

mbed_binary(
  name = "example",
  srcs = ["example.cc"],
)
```

And in your bazelrc you can list:

```
build --incompatible_enable_cc_toolchain_resolution
build --platforms=@rules_mbed//:stm32f4
```
