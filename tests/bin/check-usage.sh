#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"


README_PATH="${SCRIPTPATH}/../../README.md"
WEBSITE_PATH="${SCRIPTPATH}/../../docs/index.html"
BINARY_PATH="${SCRIPTPATH}/../../bin/pwncat"



validate_readme() {
	local bin="${1}"
	local readme="${2}"

	printf "[TEST] Checking README.md ... "
	# shellcheck disable=SC2002
	if diff --ignore-trailing-space \
		<($(which python2) "${bin}" -h) \
		<(cat "${readme}" | grep -E -A 10000 'usage:[[:space:]]' | grep -E -B 10000 '^[[:space:]]+\-V') \
		; then
		printf "%s\\n" "OK"
		return 0
	fi
	printf "%s\\n" "ERROR"
	return 1
}

_diff_website() {
	local curr_arg="${1}"
	local next_arg="${2}"

	if ! diff --ignore-trailing-space --ignore-blank-lines \
		<($(which python2) "${bin}" -h | grep "^${curr_arg}" -A 2000 | grep "^${next_arg}" -B 2000 | grep -v "^${next_arg}" ) \
		<(grep "^${curr_arg}" -A 2000 "${website}"  | grep "^${next_arg}" -B 2000 | grep -v "^${next_arg}" | grep -v '<pre' | grep -v '</pre>') \
		; then
		printf "%s\\n" "ERROR - usage"
		return 1
	fi
}
validate_website() {
	local bin="${1}"
	local website="${2}"
	local errors=0

	printf "[TEST] Checking Website (docs/index.html) ... "

	# [1/10] usage:
	if ! _diff_website "usage:" "positional arguments"; then
		errors=$(( errors + 1 ))
	fi
	# [2/10] positional arguments:
	if ! _diff_website "positional arguments" "mode arguments"; then
		errors=$(( errors + 1 ))
	fi
	# [3/10] mode arguments:
	if ! _diff_website "mode arguments" "optional arguments"; then
		errors=$(( errors + 1 ))
	fi
	# [4/10] optional arguments:
	if ! _diff_website "optional arguments" "protocol arguments"; then
		errors=$(( errors + 1 ))
	fi
	# [5/10] protocol arguments:
	if ! _diff_website "protocol arguments" "command & control arguments"; then
		errors=$(( errors + 1 ))
	fi
	# [6/10] command & control arguments:
	if ! _diff_website "command & control arguments" "pwncat scripting engine"; then
		errors=$(( errors + 1 ))
	fi
	# [7/10] pwncat scripting engine:
	if ! _diff_website "pwncat scripting engine" "zero-i/o mode arguments"; then
		errors=$(( errors + 1 ))
	fi
	# [8/10] zero-i/0 mode arguments:
	if ! _diff_website "zero-i/o mode arguments" "listen mode arguments"; then
		errors=$(( errors + 1 ))
	fi
	# [9/10] listen mode arguments:
	if ! _diff_website "listen mode arguments" "connect mode arguments"; then
		errors=$(( errors + 1 ))
	fi
	# [10/10] connect mode arguments:
	if ! _diff_website "connect mode arguments" "misc arguments"; then
		errors=$(( errors + 1 ))
	fi

	# [6/5] Check misc arguments:
	if ! diff --ignore-trailing-space --ignore-blank-lines \
		<($(which python2) "${bin}" -h | grep 'misc arguments' -A 2000 | grep '\-\-version' -B 2000) \
		<(grep 'misc arguments' -A 2000 "${website}" | grep '\-\-version' -B 2000) \
		; then
		printf "%s\\n" "ERROR - misc arguments"
		return 1
	fi

	if [ "${errors}" -eq "0" ]; then
		printf "%s\\n" "OK"
		return 0
	fi

	return 1
}

if ! validate_readme "${BINARY_PATH}" "${README_PATH}"; then
	exit 1
fi

if ! validate_website "${BINARY_PATH}" "${WEBSITE_PATH}"; then
	exit 1
fi
