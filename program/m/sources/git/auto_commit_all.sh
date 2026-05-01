#!/bin/bash

source "${BASH_TO_REQUIRE}"

THE_ARGS=()
if [ $# -gt 0 ]; then
  THE_ARGS+=( "$@" )
else
  THE_ARGS+=('--dirty')
fi

"${PROGRAMEIRO_RUNNER}" w/avm source auto-commit -f -r unique -r manual -r new "${THE_ARGS[@]}"
