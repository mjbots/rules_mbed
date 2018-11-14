# mbed rules for Bazel #

This package provides bazel rules for building binaries for mbed-os
(https://github.com/ARMmbed/mbed-os) embedded targets.  It includes
bazel configuration for the ARM-GCC toolchain, as well as dedicated
bazel rules for building output binary files.  It supports multiple
distinct mbed targets within the same build, as well as host-based
automated tests using generic bazel rules such as `cc_test`.

## Usage ##

See https://github.com/mjbots/rules_mbed_example for a worked out
example:

In `WORKSPACE` add this:

```
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

RULES_MBED_COMMIT = "XXX"

http_archive(
    name = "rules_mbed",
    url = "https://github.com/mjbots/bazel_deps/{}.zip".format(RULES_MBED_COMMIT),
    sha256 = "XXX",
    strip_prefix = "rules_mbed-{}".format(commit),
)

load("@rules_mbed//:rules.bzl", "mbed_register")
mbed_register(config = {
    "mbed_target": "targets/TARGET_STM/TARGET_STM32F4/TARGET_STM32F411xE/TARGET_NUCLEO_F466ZE",
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
