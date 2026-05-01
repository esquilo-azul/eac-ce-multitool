#!/bin/bash

source "${BASH_TO_REQUIRE}"

function source_run() {
  "${PROGRAMEIRO_RUNNER}" w/avm source --path "$SOURCE_PATH" "$@"
}

SEGMENT_OPTION="$(cli_arg 1 '' "$@")"
SOURCE_PATH="$(cli_arg 2 '.' "$@")"

source_run bundler gemfile-local -w
source_run update-dependencies-requirements --all \
  --exclude rails --exclude bundler --exclude activesupport
if [ -n "$SEGMENT_OPTION" ]; then
  source_run version-bump --yes "$SEGMENT_OPTION"
fi
