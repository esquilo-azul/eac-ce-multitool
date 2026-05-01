#!/bin/bash

find . -iname '*.html.erb' -exec htmlbeautifier '{}' \;
