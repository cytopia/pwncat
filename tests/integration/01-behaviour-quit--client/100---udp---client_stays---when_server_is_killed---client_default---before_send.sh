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

RHOST="${1:-localhost}"
RPORT="${2:-4444}"

STARTUP_WAIT="${3:-4}"
RUNS="${4:-1}"

PYTHON="python${5:-}"
PYVER="$( "${PYTHON}" -V 2>&1 | head -1 || true )"


# -------------------------------------------------------------------------------------------------
# TEST FUNCTIONS
# -------------------------------------------------------------------------------------------------
print_test_case "${PYVER}"

run_test() {
	local srv_opts="${1// / }"
	local cli_opts="${2// / }"
	local curr_mutation="${3}"
	local total_mutation="${4}"
	local curr_round="${5}"
	local total_round="${6}"
	#local data=
	#local data_or=

	print_h1 "[ROUND: ${curr_round}/${total_round}] (mutation: ${curr_mutation}/${total_mutation}) Starting Test Round (srv '${srv_opts}' vs cli '${cli_opts}')"
	run "sleep 1"

	###
	### Create data and files
	###
	#data="abcdefghijklmnopqrstuvwxyz1234567890\\n"
	#data="abcdefghijklmnopqrstuvwxyz1234567890\\r\\n"
	srv_stdout="$(tmp_file)"
	srv_stderr="$(tmp_file)"
	cli_stdout="$(tmp_file)"
	cli_stderr="$(tmp_file)"


	# --------------------------------------------------------------------------------
	# START: SERVER
	# --------------------------------------------------------------------------------
	print_h2 "(1/5) Start: Server"

	# Start Server
	print_info "Start Server"
	# shellcheck disable=SC2086
	if ! srv_pid="$( run_bg "" "${PYTHON}" "${BINARY}" ${srv_opts} "${srv_stdout}" "${srv_stderr}" )"; then
		printf ""
	fi

	# Wait until Server is up
	run "sleep ${STARTUP_WAIT}"

	# [SERVER] Ensure Server is running
	test_case_instance_is_running "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	# [SERVER] Ensure Server has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"


	# --------------------------------------------------------------------------------
	# START: CLIENT
	# --------------------------------------------------------------------------------
	print_h2 "(2/5) Start: Client"

	# Start Client
	print_info "Start Client"
	# shellcheck disable=SC2086
	if ! cli_pid="$( run_bg "" "${PYTHON}" "${BINARY}" ${cli_opts} "${cli_stdout}" "${cli_stderr}" )"; then
		printf ""
	fi

	# Wait until Client is up
	run "sleep ${STARTUP_WAIT}"

	# [CLIENT] Ensure Client is running
	test_case_instance_is_running "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	# [CLIENT] Ensure Client has no errors
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	# [SERVER] Ensure Server is still is running
	test_case_instance_is_running "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# [SERVER] Ensure Server still has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"


	# --------------------------------------------------------------------------------
	# STOP: SERVER
	# --------------------------------------------------------------------------------
	print_h2 "(3/5) Stop: Server"

	# [SERVER] Manually stop the Server
	action_stop_instance "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# [SERVER] Ensure Server still has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"


	# --------------------------------------------------------------------------------
	# TEST: Client stays alive
	# --------------------------------------------------------------------------------
	print_h2 "(4/5) Test: Client stays alive"
	run "sleep 2"

	# [CLIENT] Ensure Client has no errors
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	# [CLIENT] Ensure Client is still running
	test_case_instance_is_running "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"


	# --------------------------------------------------------------------------------
	# STOP: Client
	# --------------------------------------------------------------------------------
	print_h2 "(5/5) Stop: Client"

	# [CLIENT] Manually stop the Client
	action_stop_instance "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	# [CLIENT] Ensure Client has no errors
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for curr_round in $(seq "${RUNS}"); do
	#         server opts            client opts
	# BIND ON ANY
	run_test "-l ${RPORT} --no-shutdown    -u -vvvv" "${RHOST} ${RPORT} --no-shutdown    -u -vvvv"  "1" "16" "${curr_round}" "${RUNS}"
	run_test "-l ${RPORT} --no-shutdown    -u -vvvv" "${RHOST} ${RPORT} --no-shutdown -4 -u -vvvv"  "2" "16" "${curr_round}" "${RUNS}"
	run_test "-l ${RPORT} --no-shutdown    -u -vvvv" "${RHOST} ${RPORT} --no-shutdown -6 -u -vvvv"  "3" "16" "${curr_round}" "${RUNS}"

	run_test "-l ${RPORT} --no-shutdown -4 -u -vvvv" "${RHOST} ${RPORT} --no-shutdown    -u -vvvv"  "4" "16" "${curr_round}" "${RUNS}"
	run_test "-l ${RPORT} --no-shutdown -4 -u -vvvv" "${RHOST} ${RPORT} --no-shutdown -4 -u -vvvv"  "5" "16" "${curr_round}" "${RUNS}"

	run_test "-l ${RPORT} --no-shutdown -6 -u -vvvv" "${RHOST} ${RPORT} --no-shutdown    -u -vvvv"  "6" "16" "${curr_round}" "${RUNS}"
	run_test "-l ${RPORT} --no-shutdown -6 -u -vvvv" "${RHOST} ${RPORT} --no-shutdown -6 -u -vvvv"  "7" "16" "${curr_round}" "${RUNS}"
	# no verbosity
	run_test "-l ${RPORT} --no-shutdown    -u      " "${RHOST} ${RPORT} --no-shutdown    -u      "  "8" "16" "${curr_round}" "${RUNS}"

	# BIND ON SPECIFIC
	run_test "-l ${RHOST} ${RPORT} --no-shutdown    -u -vvvv" "${RHOST} ${RPORT} --no-shutdown    -u -vvvv"   "9" "16" "${curr_round}" "${RUNS}"
	run_test "-l ${RHOST} ${RPORT} --no-shutdown    -u -vvvv" "${RHOST} ${RPORT} --no-shutdown -4 -u -vvvv"  "10" "16" "${curr_round}" "${RUNS}"
	run_test "-l ${RHOST} ${RPORT} --no-shutdown    -u -vvvv" "${RHOST} ${RPORT} --no-shutdown -6 -u -vvvv"  "11" "16" "${curr_round}" "${RUNS}"

	run_test "-l ${RHOST} ${RPORT} --no-shutdown -4 -u -vvvv" "${RHOST} ${RPORT} --no-shutdown    -u -vvvv"  "12" "16" "${curr_round}" "${RUNS}"
	run_test "-l ${RHOST} ${RPORT} --no-shutdown -4 -u -vvvv" "${RHOST} ${RPORT} --no-shutdown -4 -u -vvvv"  "13" "16" "${curr_round}" "${RUNS}"

	run_test "-l ${RHOST} ${RPORT} --no-shutdown -6 -u -vvvv" "${RHOST} ${RPORT} --no-shutdown    -u -vvvv"  "14" "16" "${curr_round}" "${RUNS}"
	run_test "-l ${RHOST} ${RPORT} --no-shutdown -6 -u -vvvv" "${RHOST} ${RPORT} --no-shutdown -6 -u -vvvv"  "15" "16" "${curr_round}" "${RUNS}"
	# no verbosity
	run_test "-l ${RHOST} ${RPORT} --no-shutdown    -u      " "${RHOST} ${RPORT} --no-shutdown    -u      "  "16" "16" "${curr_round}" "${RUNS}"
done
