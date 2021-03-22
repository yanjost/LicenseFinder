#!/bin/sh

# `$*` expands the `args` supplied in an `array` individually
# or splits `args` in a string separated by whitespace.
sh -c "echo $*"

echo "Starting license_finder"

license_finder action_items --enabled-package-managers=yarn