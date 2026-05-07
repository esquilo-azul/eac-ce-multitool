#!/bin/bash

source "${BASH_TO_REQUIRE}"

INSTANCE_ID="$1"
shift
"${PROGRAMEIRO_RUNNER}" s/eac-tools instance "${INSTANCE_ID}" entry "$@"
