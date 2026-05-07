#!/bin/bash

source "${BASH_TO_REQUIRE}"

"$PROGRAMEIRO_RUNNER" /m/sources/ruby/gems/exe_wrapper eac_tools "$EAC_TOOLS_DEV_INSTALL_PATH" eac "$@"
