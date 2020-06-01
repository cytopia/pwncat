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
	local data=

	print_h1 "[ROUND: ${curr_round}/${total_round}] (mutation: ${curr_mutation}/${total_mutation}) Starting Test Round (srv '${srv_opts}' vs cli '${cli_opts}')"
	run "sleep 1"

	###
	### Create data and files
	###
	data="whoami\\n"
	expect="$(whoami)\\n"
	expect_or="$(whoami)\\r\\n"
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
	if ! srv_pid="$( run_bg "printf ${data}" "${PYTHON}" "${BINARY}" ${srv_opts} "${srv_stdout}" "${srv_stderr}" )"; then
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
	# DATA TRANSFER
	# --------------------------------------------------------------------------------
	print_h2 "(3/5) Transfer: Server -> Client -> Server"

	# CLIENT] -> [SERVER]
	wait_for_data_transferred "" "${expect}" "${expect_or}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"


	# --------------------------------------------------------------------------------
	# STOP: SERVER
	# --------------------------------------------------------------------------------
	print_h2 "(4/5) Stop: Server"

	# [SERVER] Manually stop the Server
	action_stop_instance "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# [SERVER] Ensure Server still has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"


	# --------------------------------------------------------------------------------
	# TEST: Client  shut down automatically
	# --------------------------------------------------------------------------------
	print_h2 "(5/5) Test: Client shut down automatically"

	# [CLIENT] Ensure Client has quit automatically
	test_case_instance_is_stopped "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	# [CLIENT] Ensure Client has no errors
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for curr_round in $(seq "${RUNS}"); do
	#         server opts            client opts
	# BIND ON ANY
	run_test "-l ${RPORT} --no-shutdown    -vvvv" "${RHOST} ${RPORT} --no-shutdown    -e /bin/sh -vvvv"  "1" "14" "${curr_round}" "${RUNS}"
	run_test "-l ${RPORT} --no-shutdown    -vvvv" "${RHOST} ${RPORT} --no-shutdown -4 -e /bin/sh -vvvv"  "2" "14" "${curr_round}" "${RUNS}"
	run_test "-l ${RPORT} --no-shutdown    -vvvv" "${RHOST} ${RPORT} --no-shutdown -6 -e /bin/sh -vvvv"  "3" "14" "${curr_round}" "${RUNS}"

	run_test "-l ${RPORT} --no-shutdown -4 -vvvv" "${RHOST} ${RPORT} --no-shutdown    -e /bin/sh -vvvv"  "4" "14" "${curr_round}" "${RUNS}"
	run_test "-l ${RPORT} --no-shutdown -4 -vvvv" "${RHOST} ${RPORT} --no-shutdown -4 -e /bin/sh -vvvv"  "5" "14" "${curr_round}" "${RUNS}"

	run_test "-l ${RPORT} --no-shutdown -6 -vvvv" "${RHOST} ${RPORT} --no-shutdown    -e /bin/sh -vvvv"  "6" "14" "${curr_round}" "${RUNS}"
	run_test "-l ${RPORT} --no-shutdown -6 -vvvv" "${RHOST} ${RPORT} --no-shutdown -6 -e /bin/sh -vvvv"  "7" "14" "${curr_round}" "${RUNS}"

	# BIND ON SPECIFIC
	run_test "-l ${RHOST} ${RPORT} --no-shutdown    -vvvv" "${RHOST} ${RPORT} --no-shutdown    -e /bin/sh -vvvv"   "8" "14" "${curr_round}" "${RUNS}"
	run_test "-l ${RHOST} ${RPORT} --no-shutdown    -vvvv" "${RHOST} ${RPORT} --no-shutdown -4 -e /bin/sh -vvvv"   "9" "14" "${curr_round}" "${RUNS}"
	run_test "-l ${RHOST} ${RPORT} --no-shutdown    -vvvv" "${RHOST} ${RPORT} --no-shutdown -6 -e /bin/sh -vvvv"  "10" "14" "${curr_round}" "${RUNS}"

	run_test "-l ${RHOST} ${RPORT} --no-shutdown -4 -vvvv" "${RHOST} ${RPORT} --no-shutdown    -e /bin/sh -vvvv"  "11" "14" "${curr_round}" "${RUNS}"
	run_test "-l ${RHOST} ${RPORT} --no-shutdown -4 -vvvv" "${RHOST} ${RPORT} --no-shutdown -4 -e /bin/sh -vvvv"  "12" "14" "${curr_round}" "${RUNS}"

	run_test "-l ${RHOST} ${RPORT} --no-shutdown -6 -vvvv" "${RHOST} ${RPORT} --no-shutdown    -e /bin/sh -vvvv"  "13" "14" "${curr_round}" "${RUNS}"
	run_test "-l ${RHOST} ${RPORT} --no-shutdown -6 -vvvv" "${RHOST} ${RPORT} --no-shutdown -6 -e /bin/sh -vvvv"  "14" "14" "${curr_round}" "${RUNS}"
done
