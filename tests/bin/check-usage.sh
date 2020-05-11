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
		<("${bin}" -h) \
		<(cat "${readme}" | grep -E -A 10000 'usage:[[:space:]]' | grep -E -B 10000 '^[[:space:]]+\-V') \
		; then
		printf "%s\\n" "OK"
		return 0
	fi
	printf "%s\\n" "ERROR"
	return 1
}

validate_website() {
	local bin="${1}"
	local website="${2}"

	printf "[TEST] Checking Website (docs/index.html) ... "

	# [1/5] usage:
	if ! diff --ignore-trailing-space --ignore-blank-lines \
		<("${bin}" -h | grep '^positional arguments' -B 2000 | grep -v 'positional arguments') \
		<(grep '^positional arguments' -B 2000 "${website}" | grep -v 'positional arguments' | grep '^usage:' -A 2000 | grep -v '<pre' | grep -v '</pre>') \
		; then
		printf "%s\\n" "ERROR - usage"
		return 1
	fi

	# [2/5] positional arguments:
	if ! diff --ignore-trailing-space --ignore-blank-lines \
		<("${bin}" -h | grep '^positional arguments' -A 2000 | grep '^mode arguments' -B 2000 | grep -v 'mode arguments') \
		<(grep '^positional arguments' -A 2000 "${website}" | grep '^mode arguments' -B 2000 | grep -v 'mode arguments' | grep -v '<pre' | grep -v '</pre>') \
		; then
		printf "%s\\n" "ERROR - positional arguments"
		return 1
	fi

	# [3/5] mode arguments:
	if ! diff --ignore-trailing-space --ignore-blank-lines \
		<("${bin}" -h | grep '^mode arguments' -A 2000 | grep '^optional arguments' -B 2000 | grep -v 'optional arguments') \
		<(grep '^mode arguments' -A 2000 "${website}" | grep '^optional arguments' -B 2000 | grep -v 'optional arguments' | grep -v '<pre' | grep -v '</pre>') \
		; then
		printf "%s\\n" "ERROR - mode arguments"
		return 1
	fi

	# [3/5] optional arguments:
	if ! diff --ignore-trailing-space --ignore-blank-lines \
		<("${bin}" -h | grep '^optional arguments' -A 2000 | grep '^advanced arguments' -B 2000 | grep -v 'advanced arguments') \
		<(grep '^optional arguments' -A 2000 "${website}" | grep '^advanced arguments' -B 2000 | grep -v 'advanced arguments' | grep -v '<pre' | grep -v '</pre>') \
		; then
		printf "%s\\n" "ERROR - optional arguments"
		return 1
	fi

	# [3/5] advanced arguments:
	if ! diff --ignore-trailing-space --ignore-blank-lines \
		<("${bin}" -h | grep '^advanced arguments' -A 2000 | grep '^misc arguments' -B 2000 | grep -v 'misc arguments') \
		<(grep '^advanced arguments' -A 2000 "${website}" | grep '^misc arguments' -B 2000 | grep -v 'misc arguments' | grep -v '<pre' | grep -v '</pre>') \
		; then
		printf "%s\\n" "ERROR - advanced arguments"
		return 1
	fi

	# [6/5] Check misc arguments:
	if ! diff --ignore-trailing-space --ignore-blank-lines \
		<("${bin}" -h | grep 'misc arguments' -A 2000 | grep '\-\-version' -B 2000) \
		<(grep 'misc arguments' -A 2000 "${website}" | grep '\-\-version' -B 2000) \
		; then
		printf "%s\\n" "ERROR - misc arguments"
		return 1
	fi


	printf "%s\\n" "OK"
	return 0
}

if ! validate_readme "${BINARY_PATH}" "${README_PATH}"; then
	exit 1
fi

if ! validate_website "${BINARY_PATH}" "${WEBSITE_PATH}"; then
	exit 1
fi
