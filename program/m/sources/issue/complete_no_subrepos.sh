#!/bin/bash

source "${BASH_TO_REQUIRE}"

"${PROGRAMEIRO_RUNNER}" m/sources/issue/complete_yes -a '-s git_subrepos' "$@"
