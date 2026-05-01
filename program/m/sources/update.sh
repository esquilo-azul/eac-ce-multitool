#!/bin/bash

source "${BASH_TO_REQUIRE}"

"${PROGRAMEIRO_RUNNER}" w/avm source update
"${PROGRAMEIRO_RUNNER}" m/sources/git/subrepo/update --all
