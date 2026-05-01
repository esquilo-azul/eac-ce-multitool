#!/bin/bash

if [ $# -lt 1 ]; then
  >&2 echo "Usage: $0 <SHARE_NAME>"
  >&2 echo "Example: $0 Downloads"
  exit 1
fi

"${PROGRAMEIRO_RUNNER}" a/mount/mnt vboxsf "$1" "uid=$UID,gid=$(id -g),rw"
