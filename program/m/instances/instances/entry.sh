#!/bin/bash

source "${BASH_TO_REQUIRE}"

INSTANCE_ID="$1"
shift
"${PROGRAMEIRO_RUNNER}" w/avm instance "${INSTANCE_ID}" entry "$@"
