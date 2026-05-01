#!/bin/bash

source "${BASH_TO_REQUIRE}"

if [ $# -lt 1 ]; then
  cliutils_usage '<INSTANCE_ID> [<TEST_ADDRESS>]'
fi

INSTANCE_ID="$1"
TEST_ADDRESS="$(cli_arg 2 'https://rubygems.org' "$@")"

function start_banner() {
  infov 'Instance ID' "$INSTANCE_ID"
  infov 'Test address' "$TEST_ADDRESS"
}

function ssh_uri() {
  USERNAME="$("${PROGRAMEIRO_RUNNER}" m/instances/entry "$INSTANCE_ID" 'install.username')"
  HOSTNAME="$("${PROGRAMEIRO_RUNNER}" m/instances/entry "$INSTANCE_ID" 'install.hostname')"
  PORT="$("${PROGRAMEIRO_RUNNER}" m/instances/entry "$INSTANCE_ID" 'install.port')"

  RESULT="ssh://${USERNAME}@${HOSTNAME}"
  if [ -n "$PORT" ]; then
    RESULT="${RESULT}:$PORT"
  fi
  printf -- '%b' "${RESULT}"
}

function run_test() {
  ssh "$(ssh_uri)" \
    wget --timeout 5 -O /dev/null "$TEST_ADDRESS"
}

start_banner

infov 'SSH URI' "$(ssh_uri)"

if run_test; then
  info_ok 'Internet ok'
else
  fatal_error 'Internet failed'
fi
