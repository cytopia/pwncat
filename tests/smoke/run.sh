#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
SOURCEPATH="${SCRIPTPATH}/../.lib/conf.sh"
COMPOSEDIR="${SCRIPTPATH}/"
# shellcheck disable=SC1090
source "${SOURCEPATH}"


# -------------------------------------------------------------------------------------------------
# SETTINGS
# -------------------------------------------------------------------------------------------------
WAIT_STARTUP=6
WAIT_SHUTDOWN=6


# -------------------------------------------------------------------------------------------------
# FUNCTIONS
# -------------------------------------------------------------------------------------------------
print_usage() {
	echo "${0} <dir> [PYTHON-VERSION]"
	echo "Valid dirs:"
	echo
	find "${SCRIPTPATH}" -type d -exec basename {} \; | grep -E '^[0-9].*' | sort
}


# -------------------------------------------------------------------------------------------------
# CHECKS
# -------------------------------------------------------------------------------------------------

if [ "${#}" -lt "1" ]; then
	print_usage
	exit 1
fi

TEST_NAME="${1}"
PYTHON_VERSION="${2:-3.8}"

TEST_START="${SCRIPTPATH}/${TEST_NAME}/run.sh"

"${TEST_START}" "${PYTHON_VERSION}"
