#!/bin/bash

source "${BASH_TO_REQUIRE}"

function find_php_files() {
  find -not -path '*/.git/*' -not -path '*/vendor/*' -iname '*.php' "$@"
}

function sot_replace() {
  FILE="$1"
  infov 'File' "$FILE"
  sed -i -zr 's/<\?(\s)/<\?php\1/gi' "$FILE"
  sed -i -zr 's/<\?echo/<\?php echo/gi' "$FILE"
  sed -i -zr 's/<\?([^px]|$)/<\?php\1/gi' "$FILE"
}

if [ $# -ge 1 ]; then
  for FILE in "$@"; do
    sot_replace "$FILE"
  done
else
  find_php_files | while read FILE; do
    sot_replace "$FILE"
  done
fi
