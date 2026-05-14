#!/bin/bash

source "${BASH_TO_REQUIRE}"

function run_not_stdout() {
  if [ $# -lt 1 ]; then
    cliutils_usage "<SOURCE_DIR>" "[<OUTPUT_DIR>]"
  fi

  export SOURCE_DIR="$1"
  export SOURCE_DIR_ID="$(parameterize "$SOURCE_DIR")"
  export CACHE_DIR="$HOME/.cache/$SOURCE_DIR_ID/doc"
  export DEFAULT_OUTPUT_DIR="$BUILD_DIR/$SOURCE_DIR_ID/doc"
  export OUTPUT_DIR="$(cli_arg 2 "$DEFAULT_OUTPUT_DIR" "$@")"
  cliutils_run_jobs start_banner build
}

function start_banner() {
  infov 'Source directory' "$SOURCE_DIR"
  infov 'Cache directory' "$CACHE_DIR"
  infov 'Output directory' "$OUTPUT_DIR"
}

function build() {
  phpDocumentor --directory "$SOURCE_DIR" --target "$OUTPUT_DIR" \
    --cache-folder "$CACHE_DIR"
}

function run_stdout() {
  printf "%b\n" "$OUTPUT_DIR"
}

>&2 run_not_stdout "$@"
run_stdout
