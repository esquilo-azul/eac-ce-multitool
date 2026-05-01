#!/bin/bash

source "${BASH_TO_REQUIRE}"

function run_bundle() {
  if [ -n "$BUNDLER_VERSION" ]; then
    BUNDLE_GEMFILE="$GEMFILE_PATH" bundle "_${BUNDLER_VERSION}_" "$@"
  else
    BUNDLE_GEMFILE="$GEMFILE_PATH" bundle "$@"
  fi
}

GEMFILE_PATH="$(cli_arg 1 'Gemfile' "$@")"
GEMFILE_LOCK_PATH="${GEMFILE_PATH}.lock"

if var_blank_r 'BUNDLER_VERSION'; then
  BUNDLER_VERSION=''
fi

infov 'Gemfile path' "$GEMFILE_PATH"
infov 'Gemfile.lock path' "$GEMFILE_LOCK_PATH"

git reset HEAD -- "$GEMFILE_LOCK_PATH"
rm -f "$GEMFILE_LOCK_PATH"
run_bundle update --local
run_bundle --local
git add "$GEMFILE_LOCK_PATH"
GIT_EDITOR=true git rc
