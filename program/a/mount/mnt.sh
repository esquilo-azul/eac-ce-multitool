#!/bin/bash

source "${BASH_TO_REQUIRE}"

if [ $# -lt 2 ]; then
  >&2 echo "Usage: $0 <PROTOCOL> <SOURCE> [OPTIONS]"
  >&2 echo "Example: $0 Downloads"
  exit 1
fi

PROTOCOL="$1"
SOURCE="$2"
OPTIONS=''

if [ $# -gt 2 ]; then
  OPTIONS="$3"
fi

MOUNTED_DIR="/mnt/$PROTOCOL/$(parameterize "$SOURCE")"

set +e
mount | grep "$MOUNTED_DIR" > /dev/null
MOUNTED=$?
set -e

if [ $MOUNTED -ne 0 ]; then
  sudo mkdir -p "$MOUNTED_DIR" >&2
  sudo mount -t "$PROTOCOL" -o "$OPTIONS" "$SOURCE" "$MOUNTED_DIR"  >&2
fi

echo "$MOUNTED_DIR"
