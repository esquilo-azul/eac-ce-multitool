#!/bin/bash

source "${BASH_TO_REQUIRE}"

ROOT="$(cli_arg 1 '.' "$@")"

function bundle_gemfile() {
  export BUNDLE_GEMFILE="$1"
  infom 'Bundling' "$BUNDLE_GEMFILE"
  bundle
}

infov 'Root' "$ROOT"

for GEMFILE in $(ls "${ROOT}/sub/"*'/Gemfile'); do
  bundle_gemfile "$GEMFILE"
done
bundle_gemfile "${ROOT}/Gemfile"
