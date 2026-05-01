#!/bin/bash

source "${BASH_TO_REQUIRE}"

git reset HEAD db/schema.rb
git checkout db/schema.rb
"${PROGRAMEIRO_RUNNER}" m/sources/ruby/rails/remigrate
git add db/schema.rb
git rebase --continue
