#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

print_usage() {
	echo "Error, Usage: ${0} <dir>"
	echo "Valid dirs:"
	echo
	find "${SCRIPTPATH}" -type d -exec basename {} \; | grep -E '^[0-9].*' | sort
}


###
### Validate command line argument is present
###
if [ "${#}" -ne "1" ]; then
	print_usage
	exit 1
fi


###
### Validate command line argument is correct directory
###
if [ ! -d "${SCRIPTPATH}/${1}" ]; then
	echo "Error, Usage: ${0} <dir>"
	echo "Valid dirs:"
	echo
	find "${SCRIPTPATH}" -type d -exec basename {} \; | grep -E '^[0-9].*' | sort
	exit 1
fi


###
### Run the tests from a directory
###
TESTDIR="${SCRIPTPATH}/${1}"
find "${TESTDIR}" -name '*.sh' -type f | sort | while read -r -d $'\n' file; do
	"${file}"
done
