#!/bin/bash

source "$MYSELF_LIB/bash/init.sh"

"$PROGRAMEIRO_RUNNER" /eac/m/sources/ruby/gems/exe_wrapper eac_tools "$EAC_TOOLS_DEV_INSTALL_PATH" eac "$@"
