#!/bin/bash

source "${BASH_TO_REQUIRE}"

"${PROGRAMEIRO_RUNNER}" s/eac-tools eac-ruby-base1 rubocop -- --ignore-parent-exclusion -- "$@"
