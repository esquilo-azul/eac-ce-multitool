#!/bin/bash

source "${BASH_TO_REQUIRE}"

function file_basename() {
  s="$1"
  s="${s##*/}"
  s="${s%.*}"
  printf "$s\n"
}

function file_unused() {
  BASENAME="$(file_basename "$1")"
  if grep "$BASENAME" * -r > /dev/null; then
    return 1
  else
    return 0
  fi
}

function check_file() {
  if file_unused "$1"; then
    printf "$1\n"
  fi
}

find -type f -not -path './.git/*' | while read FILE; do
  check_file "$FILE"
done
