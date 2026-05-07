#!/bin/bash

source "${BASH_TO_REQUIRE}"

function find_url_by_subpath() {
  GITREPO="$SUBPATH/.gitrepo"
  if [ -f "$GITREPO" ]; then
    git config --file "$GITREPO" --get subrepo.remote
  fi
}

function banner() {
  infov 'Subpath' "$SUBPATH"
  infov "URL" "$URL"
  infov 'Branch' "$BRANCH"
}

function subrepo_remove() {
  infom 'Removing subrepo...'
  git rm "$SUBPATH" -r
  git commit -m "Remove subrepo \"$SUBPATH\"."
  git clean -df
}

function subrepo_clone() {
  infom 'Cloning subrepo...'
  CLONE_ARGS=("$URL" "$SUBPATH")
  if [ -n "$BRANCH" ]; then
    CLONE_ARGS+=(--branch "$BRANCH")
  fi
  "${PROGRAMEIRO_RUNNER}" s/eac-tools git subrepo clone "${CLONE_ARGS[@]}"
}

function validate() {
  if [ ! -d "$SUBPATH" ]; then
    fatal_error "\"$SUBPATH\" is not a directory\""
  fi

  if [ -z "$URL" ]; then
    fatal_error "URL not found"
  fi
}

if [ $# -lt 1 ]; then
  >&2 echo "Usage: $0 <SUBPATH> [REMOTE_URL] [BRANCH]"
  exit 1
fi

SUBPATH="$1"
URL="$(cli_arg 2 "$(find_url_by_subpath "$SUBPATH")" "$@")"
BRANCH="$(cli_arg 3 '' "$@")"

banner
validate
subrepo_remove
subrepo_clone
info_ok 'Done!'
