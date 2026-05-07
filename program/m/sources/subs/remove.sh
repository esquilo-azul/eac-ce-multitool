#!/bin/bash

source "${BASH_TO_REQUIRE}"

for SUB_PATH in "$@"; do
  "${PROGRAMEIRO_RUNNER}" s/eac-tools source sub "$SUB_PATH" remove
done
