#!/bin/bash

source "${BASH_TO_REQUIRE}"

"${PROGRAMEIRO_RUNNER}" s/eac-tools source update
"${PROGRAMEIRO_RUNNER}" m/sources/git/subrepo/update --all
