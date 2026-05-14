#!/bin/bash

source "${BASH_TO_REQUIRE}"

function start_banner() {
  infov 'Source directory' "$SOURCE_DIR"
  infov 'Output URL' "$OUTPUT_URL"
}

function build() {
  export BUILDED_DIR="$("${PROGRAMEIRO_RUNNER}" a/php/doc_build "$SOURCE_DIR")"
  infov 'Build directory' "$BUILDED_DIR"
}

function deploy() {
  "${PROGRAMEIRO_RUNNER}" f/sync --delete -vr --yes --target-mkdirp "$BUILDED_DIR" "$OUTPUT_URL"
}

if [ $# -lt 2 ]; then
  cliutils_usage "<SOURCE_DIR>" "<OUTPUT_URL>"
fi

export SOURCE_DIR="$1"
export OUTPUT_URL="$2"
cliutils_run_jobs start_banner build deploy
