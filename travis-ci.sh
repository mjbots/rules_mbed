#!/bin/sh

set -ev

./tools/bazel build --config=stm32f4 //...
./tools/bazel build //example:common
