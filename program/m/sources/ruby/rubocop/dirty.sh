#!/bin/bash

set -e
set +u
REPOS_DIR=$1
if [ -z "$REPOS_DIR" ]; then
  REPOS_DIR='.'
fi
REPOS_DIR=$(readlink -f "$REPOS_DIR")
set -u

function dirty_ruby_files {
  ${PROGRAMEIRO_RUNNER} a/git/dirty-files "$REPOS_DIR" | grep '\(^Gemfile\|\.\(rb\|rake\|gemspec\)\)$' | while read x; do
    if [ -f "$x" ] && [ "$(basename "$x")" != 'schema.rb' ]; then
      printf " '$x'"
    fi
  done
}

FILES=$(dirty_ruby_files)
INNER_RUBOCOP="'${PROGRAMEIRO_RUNNER}' m/sources/ruby/rubocop/run --ignore-parent-exclusion"

>&2 echo "Rubocop command: $INNER_RUBOCOP"
>&2 echo "Repository: \"$REPOS_DIR\""
>&2 echo "Dirty files: $FILES"
if [ -n "$FILES" ]; then
  eval $INNER_RUBOCOP -aD $FILES
fi
