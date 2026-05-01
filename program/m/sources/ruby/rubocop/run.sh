#!/bin/bash

source "${BASH_TO_REQUIRE}"

"${PROGRAMEIRO_RUNNER}" w/avm eac-ruby-base1 rubocop -- --ignore-parent-exclusion -- "$@"
