#!/bin/sh

# `$*` expands the `args` supplied in an `array` individually
# or splits `args` in a string separated by whitespace.
sh -c "echo $*"

SCAN_FOLDER=$1

echo "Starting license_finder in folder ${SCAN_FOLDER}"

cd ${SCAN_FOLDER}

license_finder action_items --enabled-package-managers=yarn