#!/bin/bash

source "${BASH_TO_REQUIRE}"

function gem_perform() {
  DIR="$1"
  GEMFILE="${DIR}/Gemfile"
  infov 'Directory' "$DIR"
  (cd "$DIR"; bundle || bundle update)
}

SUBS_ROOT="$(cli_arg 1 'sub' "$@")"
FAILED_FOR=()

for G in $(ls "${SUBS_ROOT}"/*/Gemfile); do
  if ! gem_perform "$(dirname "$G")"  ; then
    FAILED_FOR+=("$G")
  fi
done

infov 'Failed for' "${#FAILED_FOR[@]}"
for G in "${FAILED_FOR[@]}"; do
  infov '  * ' "$G"
done
