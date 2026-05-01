#!/bin/bash

source "${BASH_TO_REQUIRE}"

export DISABLE_DATABASE_ENVIRONMENT_CHECK=1

bundle exec rake db:drop db:create
bundle exec rake db:migrate
