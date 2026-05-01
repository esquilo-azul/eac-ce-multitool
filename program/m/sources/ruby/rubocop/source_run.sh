#!/bin/bash

source "${BASH_TO_REQUIRE}"

export BUNDLE_GEMFILE='Gemfile'
SELF_GEMFILE='SelfGemfile'
if [ -f "$SELF_GEMFILE" ]; then
  export BUNDLE_GEMFILE="$SELF_GEMFILE"
fi

BUNDLE_GEMFILE="$BUNDLE_GEMFILE" bundle exec rubocop --ignore-parent-exclusion "$@"
