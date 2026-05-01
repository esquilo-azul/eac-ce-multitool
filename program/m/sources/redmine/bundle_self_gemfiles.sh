#!/bin/bash

source "${BASH_TO_REQUIRE}"

function root_version() {
  "${SOURCE_PATH}/plugins/redmine_installer/installer/programeiro.sh" /rails/bundler_version
}

function self_gemfiles() {
  find "${SOURCE_PATH}/plugins" -name 'SelfGemfile'
}

function process_gemfile() {
  GEMFILE="$1"
  GEMFILE_LOCK="${GEMFILE}.lock"
  PLUGIN_DIR="$(dirname "$GEMFILE")"
  infov 'Plugin' "$PLUGIN_DIR"

  if BUNDLE_GEMFILE="$GEMFILE" bundle "_${ROOT_VERSION}_"; then
    return
  fi

  infom "Bundle failed. Removing lock and trying again..."
  rm -f "$GEMFILE_LOCK"
  BUNDLE_GEMFILE="$GEMFILE" bundle "_${ROOT_VERSION}_"
}

if [ $# -lt 1 ]; then
  cliutils_usage '<SOURCE_PATH>'
fi

SOURCE_PATH="$1"
infov 'Source path' "$SOURCE_PATH"

export ROOT_VERSION="$(root_version)"
infov 'Root version' "$ROOT_VERSION"

self_gemfiles | while read GEMFILE; do
  process_gemfile "$GEMFILE"
done
