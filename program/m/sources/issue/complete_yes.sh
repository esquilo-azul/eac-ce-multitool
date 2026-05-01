#!/bin/bash

source "${BASH_TO_REQUIRE}"

set +e
"${PROGRAMEIRO_RUNNER}" m/sources/issue/complete --yes "$@"
set -e

"${PROGRAMEIRO_RUNNER}" e/ehbrs/ehbrs_ubuntu_base0/alert_sound
