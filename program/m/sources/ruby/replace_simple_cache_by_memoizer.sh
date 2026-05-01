#!/bin/bash

source "${BASH_TO_REQUIRE}"

function replace_pattern() {
  local TARGET_FILE="$1"
  local FROM="$2"
  local TO="$3"

  sed -i "s|${FROM}|${TO}|g" "$TARGET_FILE"
}

function replace_patterns() {
  local TARGET_FILE="$1"

  replace_pattern "$TARGET_FILE" 'include \(::\)\?EacRubyUtils::SimpleCache' 'enable_memoized'
  replace_pattern "$TARGET_FILE" 'enable_simple_cache' 'enable_memoized'
  replace_pattern "$TARGET_FILE" 'def\s\+\(.\+\)_uncached' 'memoize def \1'
}

while read -r TARGET_FILE; do
  replace_patterns "$TARGET_FILE"
done < <(find . -type f -not -path '*/.git/*')
