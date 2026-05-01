#!/bin/bash

source "${BASH_TO_REQUIRE}"

"${PROGRAMEIRO_RUNNER}" m/sources/ruby/rubocop/run -f files | xargs -i printf "'{}' "
printf "\n"
