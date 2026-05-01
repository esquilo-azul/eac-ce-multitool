#!/bin/bash

source "${BASH_TO_REQUIRE}"

if [ $# -lt 1 ]; then
  cliutils_usage '<TARGET>'
fi

TARGET="$1"
MESSAGE_TARGET="$TARGET"
if [ -d "$TARGET" ]; then
  MESSAGE_TARGET="${MESSAGE_TARGET}/"
fi
MESSAGE="${MESSAGE_TARGET}: remove não utilizado."

infom 'Removing...'
git rm -r "$TARGET"
infom 'Commiting...'
git commit -m "$MESSAGE" -- "$TARGET"
info_ok "Done!"

