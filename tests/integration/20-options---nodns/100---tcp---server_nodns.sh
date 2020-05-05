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
#TRANS_WAIT=10


# -------------------------------------------------------------------------------------------------
# TEST FUNCTIONS
# -------------------------------------------------------------------------------------------------
print_test_case "${PYVER}"

run_test() {
	local srv_opts="${1// / }"
	local curr_mutation="${2}"
	local total_mutation="${3}"
	local curr_round="${4}"
	local total_round="${5}"
	local data=

	print_h1 "[ROUND: ${curr_round}/${total_round}] (mutation: ${curr_mutation}/${total_mutation}) Starting Test Round (srv '${srv_opts}')"
	run "sleep 1"

	###
	### Create data and files
	###
	data="$(tmp_file)"
	printf "HEAD / HTTP/1.1\\n\\n" > "${data}"
	srv_stdout="$(tmp_file)"
	srv_stderr="$(tmp_file)"


	# --------------------------------------------------------------------------------
	# START: SERVER
	# --------------------------------------------------------------------------------
	print_h2 "(1/4) Start: Server"

	# Start Server
	print_info "Start Server"
	# shellcheck disable=SC2086
	if ! srv_pid="$( run_bg "cat ${data}" "${PYTHON}" "${BINARY}" ${srv_opts} "${srv_stdout}" "${srv_stderr}" )"; then
		printf ""
	fi

	# Wait until Server is up
	run "sleep ${STARTUP_WAIT}"

	# [SERVER] Ensure Server has quit automatically
	test_case_instance_is_stopped "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	# [SERVER] Ensure Server has errors
	test_case_instance_has_errors "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	# Ensure Server has no errors
	print_info "Checking for 'Resolve Error'"
	if ! run "grep \"Resolve Error\" ${srv_stderr}"; then
		print_file "SERVER STDERR" "${srv_stderr}"
		print_file "SERVER STDOUT" "${srv_stdout}"
		print_error "'Resolve Error' not found in error"
		exit 1
	fi
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for curr_round in $(seq "${RUNS}"); do
	run_test "-l ${RHOST} ${RPORT} -n -vvvv     "  "1" "10" "${curr_round}" "${RUNS}"
	#run_test "-l ${RHOST} ${RPORT} -n -vvv      "  "2" "10" "${curr_round}" "${RUNS}"
	#run_test "-l ${RHOST} ${RPORT} -n -vv       "  "3" "10" "${curr_round}" "${RUNS}"
	#run_test "-l ${RHOST} ${RPORT} -n -v        "  "4" "10" "${curr_round}" "${RUNS}"
	#run_test "-l ${RHOST} ${RPORT} -n           "  "5" "10" "${curr_round}" "${RUNS}"

	#run_test "-l ${RHOST} ${RPORT} --nodns -vvvv"  "6" "10" "${curr_round}" "${RUNS}"
	#run_test "-l ${RHOST} ${RPORT} --nodns -vvv "  "7" "10" "${curr_round}" "${RUNS}"
	#run_test "-l ${RHOST} ${RPORT} --nodns -vv  "  "8" "10" "${curr_round}" "${RUNS}"
	#run_test "-l ${RHOST} ${RPORT} --nodns -v   " " 9" "10" "${curr_round}" "${RUNS}"
	#run_test "-l ${RHOST} ${RPORT} --nodns      " "10" "10" "${curr_round}" "${RUNS}"
done
