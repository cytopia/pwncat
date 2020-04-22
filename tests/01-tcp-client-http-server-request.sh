#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
BINARY="${SCRIPTPATH}/../bin/pwncat"
# shellcheck disable=SC1090
source "${SCRIPTPATH}/.lib.sh"

PYTHON="python${1:-}"
PYVER="$( eval "${PYTHON} -V" 2>&1 | head -1 )"
print_h1 "[01] TCP Client request Web Server (${PYVER})"


# -------------------------------------------------------------------------------------------------
# GLOBALS
# -------------------------------------------------------------------------------------------------

BINARY="${SCRIPTPATH}/../bin/pwncat"
RHOST="www.google.com"
RPORT="80"
RUNS=10

PWNCAT_OPTS="${RHOST} ${RPORT}"


# -------------------------------------------------------------------------------------------------
# TEST FUNCTIONS
# -------------------------------------------------------------------------------------------------

# 1. Connect to www.google.com:80
# 2. Check for errors in err file
# 3. Check for valid response in out file

run_test() {
	local opts="${1}"
	local ret=0
	stdout="$(tmp_file)"
	stderr="$(tmp_file)"
	ret=0

	print_h2 "Starting Test Round (connect: ${RHOST}:${RPORT}) (cli '${opts}')"

	###
	### Runt Client
	###
	cmd="echo 'HEAD /' | ${PYTHON} ${BINARY} ${opts} > ${stdout} 2> ${stderr}"
	if ! run "${cmd}"; then
		print_error "Error, failed to execute eval command."
		ret=1
	fi

	###
	### Check Client for errors
	###
	if has_errors "${stderr}"; then
		print_error "Errors found in stderr"
		ret=1
	fi

	###
	### Check if Client has received data
	###
	if ! grep -E '^HTTP/' "${stdout}" >/dev/null; then
		print_error "Error, no expected content in stdout"
		ret=1
	fi
	if ! grep -E '^Content' "${stdout}" >/dev/null; then
		print_error "Error, no expected content in stdout"
		ret=1
	fi

	###
	### Print logs
	###
	print_file "STDOUT" "${stdout}"
	print_file "STDERR" "${stderr}"

	###
	### Determine Exit code
	###
	if [ "${ret}" -eq "1" ]; then
		print_error "[FAILED]"
		exit 1
	fi
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for i in $(seq "${RUNS}"); do
	echo
	print_h1 "ITERATION: ${i}/${RUNS}"
	run_test "${PWNCAT_OPTS}"
	run_test "-vvvv  ${PWNCAT_OPTS}"
	run_test "-vvv   ${PWNCAT_OPTS}"
	run_test "-vv    ${PWNCAT_OPTS}"
	run_test "-v     ${PWNCAT_OPTS}"
	run_test "       ${PWNCAT_OPTS}"
done
