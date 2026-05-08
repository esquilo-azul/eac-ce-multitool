#!/bin/bash

source "${BASH_TO_REQUIRE}"

sed 's/\x1b\[[0-9;]*m//g' "$@" <&0
