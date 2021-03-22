#!/bin/sh

# `$*` expands the `args` supplied in an `array` individually
# or splits `args` in a string separated by whitespace.
sh -c "echo $*"

SCAN_FOLDER=$1

echo "Starting license_finder in folder ${SCAN_FOLDER}"

bash -lc "cd /LicenseFinder && bundle config set no-cache 'true' && bundle exec license_finder action_items --enabled-package-managers=yarn --project-path=${SCAN_FOLDER}"