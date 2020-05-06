#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
SOURCEPATH="${SCRIPTPATH}/../../.lib/conf.sh"
BINARY="${SCRIPTPATH}/../../../bin/pwncat"
# shellcheck disable=SC1090
source "${SOURCEPATH}"


# -------------------------------------------------------------------------------------------------
# GLOBALS
# -------------------------------------------------------------------------------------------------

RHOST="localhost"
RPORT="${1:-4444}"

PYTHON="python${2:-}"
PYVER="$( "${PYTHON}" -V 2>&1 | head -1 || true )"

RUNS=1
STARTUP_WAIT=4


# -------------------------------------------------------------------------------------------------
# TEST FUNCTIONS
# -------------------------------------------------------------------------------------------------
print_test_case "${PYVER}"

run_test() {
	local cli_opts="${1// / }"
	local curr_mutation="${2}"
	local total_mutation="${3}"
	local curr_round="${4}"
	local total_round="${5}"
	local data=

	print_h1 "[ROUND: ${curr_round}/${total_round}] (mutation: ${curr_mutation}/${total_mutation}) Starting Test Round (cli '${cli_opts}')"
	run "sleep 1"

	###
	### Create data and files
	###
	data="$(tmp_file)"
	printf "HEAD / HTTP/1.1\\n\\n" > "${data}"
	cli_stdout="$(tmp_file)"
	cli_stderr="$(tmp_file)"


	# --------------------------------------------------------------------------------
	# START: CLIENT
	# --------------------------------------------------------------------------------
	print_h2 "(2/4) Start: Client"

	# Start Client
	print_info "Start Client and hope it fails"
	# shellcheck disable=SC2086
	if ! cli_pid="$( run_bg "cat ${data}" "${PYTHON}" "${BINARY}" ${cli_opts} "${cli_stdout}" "${cli_stderr}" )"; then
		printf ""
	fi

	# Wait until Client is up
	run "sleep ${STARTUP_WAIT}"

	# [CLIENT] Ensure Client has quit automatically
	test_case_instance_is_stopped "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# [CLIENT] Ensure Client has errors
	test_case_instance_has_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# Ensure Client has no errors
	print_info "Checking for 'Resolve Error'"
	if ! run "grep \"Resolve Error\" ${cli_stderr}"; then
		print_file "CLIENT STDERR" "${cli_stderr}"
		print_file "CLIENT STDOUT" "${cli_stdout}"
		print_error "'Resolve Error' not found in error"
		exit 1
	fi
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for curr_round in $(seq "${RUNS}"); do
	run_test "${RHOST} ${RPORT} -u -n -vvvv     "  "1" "10" "${curr_round}" "${RUNS}"
	#run_test "${RHOST} ${RPORT} -u -n -vvv      "  "2" "10" "${curr_round}" "${RUNS}"
	#run_test "${RHOST} ${RPORT} -u -n -vv       "  "3" "10" "${curr_round}" "${RUNS}"
	#run_test "${RHOST} ${RPORT} -u -n -v        "  "4" "10" "${curr_round}" "${RUNS}"
	#run_test "${RHOST} ${RPORT} -u -n           "  "5" "10" "${curr_round}" "${RUNS}"

	#run_test "${RHOST} ${RPORT} -u --nodns -vvvv"  "6" "10" "${curr_round}" "${RUNS}"
	#run_test "${RHOST} ${RPORT} -u --nodns -vvv "  "7" "10" "${curr_round}" "${RUNS}"
	#run_test "${RHOST} ${RPORT} -u --nodns -vv  "  "8" "10" "${curr_round}" "${RUNS}"
	#run_test "${RHOST} ${RPORT} -u --nodns -v   " " 9" "10" "${curr_round}" "${RUNS}"
	#run_test "${RHOST} ${RPORT} -u --nodns      " "10" "10" "${curr_round}" "${RUNS}"
done
