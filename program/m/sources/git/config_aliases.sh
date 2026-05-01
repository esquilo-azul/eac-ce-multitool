#!/bin/bash

source "${BASH_TO_REQUIRE}"

git config --global alias.avm-rebase 'rebase -i origin/master --autosquash --empty=drop'
git config --global alias.root-rebase 'rebase -i --root --autosquash --empty=drop'
