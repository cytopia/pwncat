#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
BINARY="${SCRIPTPATH}/../bin/pwncat"
# shellcheck disable=SC1090
source "${SCRIPTPATH}/.lib.sh"


# -------------------------------------------------------------------------------------------------
# GLOBALS
# -------------------------------------------------------------------------------------------------

PYTHON="python${1:-}"
PYVER="$( eval "${PYTHON} -V" 2>&1 | head -1 )"

RHOST="www.google.com"
RPORT="80"
RUNS=10

PWNCAT_OPTS="${RHOST} ${RPORT}"


# -------------------------------------------------------------------------------------------------
# TEST FUNCTIONS
# -------------------------------------------------------------------------------------------------

print_test_case "[300] TCP Client --nodns (${PYVER})"

# 1. Connect to www.google.com:80 and fail
# 2. Validate error
run_test() {
	local cli_opts="${1}"
	local tround="${2}"
	local sround="${3}"

	echo;echo
	print_h1 "[${tround}/${RUNS}] (${sround}/6) Starting Test Round (connect: ${RHOST}:${RPORT}) (cli '${cli_opts}')"

	kill_process "pwncat" >/dev/null 2>&1 || true

	###
	### Create data and files
	###
	cli_stdout="$(tmp_file)"
	cli_stderr="$(tmp_file)"


	# --------------------------------------------------------------------------------
	# START: CLIENT
	# --------------------------------------------------------------------------------
	echo;print_h2 "(1/2) Start: Client"

	###
	### Runt Client
	###
	print_info "Run Client and fail"
	cmd="echo 'HEAD /' | ${PYTHON} ${BINARY} ${cli_opts} > ${cli_stdout} 2> ${cli_stderr}"
	if ! run_fail "${cmd}"; then
		print_file "CLIENT STDERR" "${cli_stderr}"
		print_file "CLIENT STDOUT" "${cli_stdout}"
		print_error "Run should have failed."
		exit 1
	fi


	# --------------------------------------------------------------------------------
	# POST CHECK: VALIDATE ERROR
	# --------------------------------------------------------------------------------
	echo;print_h2 "(2/2) Check: Validate error"

	# Ensure Client has no errors
	print_info "Checking for 'Resolve Error'"
	if ! grep "Resolve Error" "${cli_stderr}"; then
		print_file "CLIENT STDERR" "${cli_stderr}"
		print_file "CLIENT STDOUT" "${cli_stdout}"
		print_error "'Resolve Error' not found in error"
		exit 1
	fi
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for i in $(seq "${RUNS}"); do
	echo
	run_test "-n        ${PWNCAT_OPTS}" "${i}" "1"
	run_test "-n -vvvv  ${PWNCAT_OPTS}" "${i}" "2"
	run_test "-n -vvv   ${PWNCAT_OPTS}" "${i}" "3"
	run_test "-n -vv    ${PWNCAT_OPTS}" "${i}" "4"
	run_test "-n -v     ${PWNCAT_OPTS}" "${i}" "5"
	run_test "-n        ${PWNCAT_OPTS}" "${i}" "6"
done
