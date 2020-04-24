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

print_test_case "[200] TCP Client HTTP request to Web Server (${PYVER})"

# 1. Connect to www.google.com:80
# 2. Check for errors in err file
# 3. Check for valid response in out file
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
	echo;print_h2 "(1/3) Start: Client"

	###
	### Runt Client
	###
	print_info "Run Client"
	cmd="echo 'HEAD /' | ${PYTHON} ${BINARY} ${cli_opts} > ${cli_stdout} 2> ${cli_stderr}"
	if ! run "${cmd}"; then
		print_file "CLIENT STDERR" "${cli_stderr}"
		print_file "CLIENT STDOUT" "${cli_stdout}"
		print_error "[Meta] Failed to execute eval command."
		exit 1
	fi


	# --------------------------------------------------------------------------------
	# POST CHECK: CLIENT
	# --------------------------------------------------------------------------------
	echo;print_h2 "(2/3) Check: Client"

	# Ensure Client has no errors
	test_case_instance_has_no_errors "Client" "" "${cli_stdout}" "${cli_stderr}"


	# --------------------------------------------------------------------------------
	# TEST: Client received response
	# --------------------------------------------------------------------------------
	echo;print_h2 "(3/3) Test: Client received response"

	###
	### Check if Client has received data
	###
	print_info "Check Client has received '^HTTP/'"
	if ! grep -E '^HTTP/' "${cli_stdout}" >/dev/null; then
		print_file "CLIENT STDERR" "${cli_stderr}"
		print_file "CLIENT STDOUT" "${cli_stdout}"
		print_error "Error, no expected content in stdout"
		exit 1
	fi
	print_info "Check Client has received '^Content'"
	if ! grep -E '^Content' "${cli_stdout}" >/dev/null; then
		print_file "CLIENT STDERR" "${cli_stderr}"
		print_file "CLIENT STDOUT" "${cli_stdout}"
		print_error "Error, no expected content in stdout"
		exit 1
	fi
	print_info "Check Client has received '^Date'"
	if ! grep -E '^Date' "${cli_stdout}" >/dev/null; then
		print_file "CLIENT STDERR" "${cli_stderr}"
		print_file "CLIENT STDOUT" "${cli_stdout}"
		print_error "Error, no expected content in stdout"
		exit 1
	fi
	print_file "Client received data" "${cli_stdout}"
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for i in $(seq "${RUNS}"); do
	echo
	run_test "       ${PWNCAT_OPTS}" "${i}" "1"
	run_test "-vvvv  ${PWNCAT_OPTS}" "${i}" "2"
	run_test "-vvv   ${PWNCAT_OPTS}" "${i}" "3"
	run_test "-vv    ${PWNCAT_OPTS}" "${i}" "4"
	run_test "-v     ${PWNCAT_OPTS}" "${i}" "5"
	run_test "       ${PWNCAT_OPTS}" "${i}" "6"
done
