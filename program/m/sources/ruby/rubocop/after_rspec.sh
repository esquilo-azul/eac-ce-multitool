#!/bin/bash

source "${BASH_TO_REQUIRE}"

bundle exec rspec --fail-fast --format doc -P "$@"
bundle exec rubocop -a --ignore-parent-exclusion "$@"
