#!/bin/bash

source "${BASH_TO_REQUIRE}"

THE_ARGS=()
if [ $# -gt 0 ]; then
  THE_ARGS+=( "$@" )
else
  THE_ARGS+=('--dirty')
fi

"${PROGRAMEIRO_RUNNER}" s/eac-tools source auto-commit -f -r new "${THE_ARGS[@]}"
