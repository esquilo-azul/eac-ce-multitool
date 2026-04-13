#!/bin/bash

source "${BASH_TO_REQUIRE}"

function debug_exec() {
  if bool_pr 'WRAPPER_DEBUG'; then
    "$@"
  fi
}

if [ $# -lt 3 ]; then
  cliutils_usage "<GEM_NAME> <LOCAL_INSTALL_PATH> <EXE_NAME>"
fi

GEM_NAME="$1"
LOCAL_INSTALL_PATH="$2"
EXE_NAME="$3"
shift
shift
shift

if var_blank_r 'USE_GEM'; then
  USE_GEM='FALSE'
fi
debug_exec infov 'Use gem' "$(bool_s "$USE_GEM")"

if [ -d "$LOCAL_INSTALL_PATH" ] && ! bool_r "$USE_GEM" ; then
  debug_exec infom "Running \"$EXE_NAME\" from \"$LOCAL_INSTALL_PATH\"..."
  BUNDLE_GEMFILE="$LOCAL_INSTALL_PATH/Gemfile" "${PROGRAMEIRO_RUNNER}" a/ruby/bundle/exec "$EXE_NAME" "$@"
else
  debug_exec infom "Running \"$EXE_NAME\" from \$PATH..."
  package_assert ruby "$GEM_NAME"
  "${PROGRAMEIRO_RUNNER}" y/log_file_if "$EXE_NAME" "$@"
fi
