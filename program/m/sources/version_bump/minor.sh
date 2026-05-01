#!/bin/bash

source "${BASH_TO_REQUIRE}"

"${PROGRAMEIRO_RUNNER}" w/avm source -C "$(cli_arg 1 . "$@")" version-bump --yes --minor
