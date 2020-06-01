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
	local data_or=

	print_h1 "[ROUND: ${curr_round}/${total_round}] (mutation: ${curr_mutation}/${total_mutation}) Starting Test Round (srv '${srv_opts}' vs cli '${cli_opts}')"
	run "sleep 1"

	###
	### Create data and files
	###
	data="abcdefghijklmnopqrstuvwxyz1234567890\\n"
	data_or="abcdefghijklmnopqrstuvwxyz1234567890\\r\\n"
	srv_stdout="$(tmp_file)"
	srv_stderr="$(tmp_file)"
	cli_stdout="$(tmp_file)"
	cli_stderr="$(tmp_file)"


	# --------------------------------------------------------------------------------
	# START: CLIENT
	# --------------------------------------------------------------------------------
	print_h2 "(1/4) Start: Server"

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
	print_h2 "(2/4) Start: Client"

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
	# [ROUND-2: SRV-SEND] DATA TRANSFER
	# --------------------------------------------------------------------------------
	print_h2 "(3/4) Transfer: Server -> Client (round 2)"

	# [SERVER -> Client]
	wait_for_data_transferred "" "${data}" "${data_or}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"


	# --------------------------------------------------------------------------------
	# STOP: SERVER/CLIENT
	# --------------------------------------------------------------------------------
	print_h2 "(4/4) Stop: Server/Client"

	# [SERVER] Manually stop the Server
	action_stop_instance "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# [Client] Manually stop the Client
	action_stop_instance "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	# [SERVER] Ensure Server still has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# [CLIENT] Ensure Client still has no errors
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for curr_round in $(seq "${RUNS}"); do
	echo
	#         server opts         client opts
	run_test "-l ${RPORT} --no-shutdown -u -vvvv" "${RHOST} ${RPORT} --no-shutdown --ping-intvl 1 -u -vvvv"  "1" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --no-shutdown -u -vvv " "${RHOST} ${RPORT} --no-shutdown --ping-intvl 1 -u -vvvv"  "2" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --no-shutdown -u -vv  " "${RHOST} ${RPORT} --no-shutdown --ping-intvl 1 -u -vvvv"  "3" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --no-shutdown -u -v   " "${RHOST} ${RPORT} --no-shutdown --ping-intvl 1 -u -vvvv"  "4" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --no-shutdown -u      " "${RHOST} ${RPORT} --no-shutdown --ping-intvl 1 -u -vvvv"  "5" "13" "${curr_round}" "${RUNS}"

	#run_test "-l ${RPORT} --no-shutdown -u -vvvv" "${RHOST} ${RPORT} --no-shutdown --ping-intvl 1 -u -vvv "  "6" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --no-shutdown -u -vvvv" "${RHOST} ${RPORT} --no-shutdown --ping-intvl 1 -u -vv  "  "7" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --no-shutdown -u -vvvv" "${RHOST} ${RPORT} --no-shutdown --ping-intvl 1 -u -v   "  "8" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --no-shutdown -u -vvvv" "${RHOST} ${RPORT} --no-shutdown --ping-intvl 1 -u      "  "9" "13" "${curr_round}" "${RUNS}"

	#run_test "-l ${RPORT} --no-shutdown -u -vvv " "${RHOST} ${RPORT} --no-shutdown --ping-intvl 1 -u -vvv " "10" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --no-shutdown -u -vv  " "${RHOST} ${RPORT} --no-shutdown --ping-intvl 1 -u -vv  " "11" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --no-shutdown -u -v   " "${RHOST} ${RPORT} --no-shutdown --ping-intvl 1 -u -v   " "12" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --no-shutdown -u      " "${RHOST} ${RPORT} --no-shutdown --ping-intvl 1 -u      " "13" "13" "${curr_round}" "${RUNS}"
done
