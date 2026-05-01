#!/bin/bash

source "${BASH_TO_REQUIRE}"

if [ $# -lt 1 ]; then
  >&2 echo "Usage: $0 <SOURCE>"
  >&2 echo "Example: $0 Downloads"
  exit 1
fi

PROTOCOL=sshfs
SOURCE="$1"
OPTIONS=''

if [ $# -gt 2 ]; then
  OPTIONS="$3"
fi

MOUNTED_DIR="$HOME/.mnt/$PROTOCOL/$(parameterize "$SOURCE")"

set +e
mount | grep "$MOUNTED_DIR" > /dev/null
MOUNTED=$?
set -e

infov "Mount dir" "$MOUNTED_DIR"
infov "Source" "$SOURCE"

if [ $MOUNTED -ne 0 ]; then
  mkdir -p "$MOUNTED_DIR" >&2
  sshfs "$SOURCE" "$MOUNTED_DIR/"
fi

echo "$MOUNTED_DIR"
