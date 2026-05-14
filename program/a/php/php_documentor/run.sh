#!/bin/bash

source "${BASH_TO_REQUIRE}"

docker run --rm -v "${PWD}:/data" phpdoc/phpdoc:3 "$@"