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
	data="abcdefghijklmnopqrstuvwxyz1234567890\\n"

	srv1_stdout="$(tmp_file)"
	srv1_stderr="$(tmp_file)"
	srv2_stdout="$(tmp_file)"
	srv2_stderr="$(tmp_file)"
	srv3_stdout="$(tmp_file)"
	srv3_stderr="$(tmp_file)"

	cli_stdout="$(tmp_file)"
	cli_stderr="$(tmp_file)"


	###
	###
	### 1/x START CLIENT (SEND DATA)
	###
	###

	# --------------------------------------------------------------------------------
	# START: CLIENT
	# --------------------------------------------------------------------------------
	print_h2 "(1/11) Start: Client (round 1)"

	# Start Client
	print_info "Start Client (sends data to Server)"
	# shellcheck disable=SC2086
	if ! cli_pid="$( run_bg "printf ${data}" "${PYTHON}" "${BINARY}" ${cli_opts} "${cli_stdout}" "${cli_stderr}" )"; then
		printf ""
	fi

	# Wait until Client is up
	run "sleep ${STARTUP_WAIT}"

	# [CLIENT] Ensure Client is running
	test_case_instance_is_running "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# [CLIENT] Ensure Client has no errors
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "" "" "" "" "Connection refused"


	###
	###
	### ROUND-1 START SERVER (NO SEND)
	###
	###

	# --------------------------------------------------------------------------------
	# [ROUND-1 SRV-NOSEND] START: SERVER
	# --------------------------------------------------------------------------------
	print_h2 "(2/11) Start: Server (round 1)"

	# Start Server
	print_info "Start Server"
	# shellcheck disable=SC2086
	if ! srv_pid="$( run_bg "" "${PYTHON}" "${BINARY}" ${srv_opts} "${srv1_stdout}" "${srv1_stderr}" )"; then
		printf ""
	fi

	# Wait until Server is up
	run "sleep ${STARTUP_WAIT}"

	# [SERVER] Ensure Server is running
	test_case_instance_is_running "Server" "${srv_pid}" "${srv1_stdout}" "${srv1_stderr}"

	# [SERVER] Ensure Server has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv1_stdout}" "${srv1_stderr}"

	# [CLIENT] Ensure Client is still is running
	test_case_instance_is_running "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv1_stdout}" "${srv1_stderr}"

	# [CLIENT] Ensure Client still has no errors
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv1_stdout}" "${srv1_stderr}" "Connection refused"


	# --------------------------------------------------------------------------------
	# [ROUND-1: SRV-NOSEND] DATA TRANSFER
	# --------------------------------------------------------------------------------
	print_h2 "(3/11) Transfer: Client -> Server (round 1)"

	# [CLIENT -> SERVER]
	wait_for_data_transferred "" "${data}" "Server" "${srv_pid}" "${srv1_stdout}" "${srv1_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"


	# --------------------------------------------------------------------------------
	# [ROUND-1]: SRV-NOSEND] STOP: SERVER
	# --------------------------------------------------------------------------------
	print_h2 "(4/11) Stop: Server (round 1)"

	# [SERVER] Manually stop the Server
	action_stop_instance "Server" "${srv_pid}" "${srv1_stdout}" "${srv1_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# [SERVER] Ensure Server has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv1_stdout}" "${srv1_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# [CLIENT] Ensure Client still has no errors
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv1_stdout}" "${srv1_stderr}" "Connection refused"


	###
	###
	### ROUND-2 START SERVER (NO SEND)
	###
	###

	# --------------------------------------------------------------------------------
	# [ROUND-2 SRV-SEND] START: SERVER
	# --------------------------------------------------------------------------------
	print_h2 "(5/11) Start: Server (round 2) (sends data to Client)"

	# Start Server
	print_info "Start Server"
	# shellcheck disable=SC2086
	if ! srv_pid="$( run_bg "printf ${data}" "${PYTHON}" "${BINARY}" ${srv_opts} "${srv2_stdout}" "${srv2_stderr}" )"; then
		printf ""
	fi

	# Wait until Server is up
	run "sleep ${STARTUP_WAIT}"

	# [SERVER] Ensure Server is running
	test_case_instance_is_running "Server" "${srv_pid}" "${srv2_stdout}" "${srv2_stderr}"

	# [SERVER] Ensure Server has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv2_stdout}" "${srv2_stderr}"

	# [CLIENT] Ensure Client is still is running
	test_case_instance_is_running "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv2_stdout}" "${srv2_stderr}"

	# [CLIENT] Ensure Client still has no errors
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv2_stdout}" "${srv2_stderr}" "Connection refused"


	# --------------------------------------------------------------------------------
	# [ROUND-2: SRV-SEND] DATA TRANSFER
	# --------------------------------------------------------------------------------
	print_h2 "(6/11) Transfer: Server -> Client (round 2)"

	# [SERVER -> CLIENT]
	wait_for_data_transferred "" "${data}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv2_stdout}" "${srv2_stderr}"


	# --------------------------------------------------------------------------------
	# [ROUND-2]: SRV-SEND] STOP: SERVER
	# --------------------------------------------------------------------------------
	print_h2 "(7/11) Stop: Server (round 2)"

	# [SERVER] Manually stop the Server
	action_stop_instance "Server" "${srv_pid}" "${srv2_stdout}" "${srv2_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# [SERVER] Ensure Server has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv2_stdout}" "${srv2_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# [CLIENT] Ensure Client still has no errors
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv2_stdout}" "${srv2_stderr}" "Connection refused"


	###
	###
	### ROUND-3 START SERVER (SEND)
	###
	###

	# --------------------------------------------------------------------------------
	# [ROUND-3 SRV-SEND] START: SERVER
	# --------------------------------------------------------------------------------
	print_h2 "(8/11) Start: Server (round 3) (sends data to Client)"

	# Start Server
	print_info "Start Server"
	# shellcheck disable=SC2086
	if ! srv_pid="$( run_bg "printf ${data}" "${PYTHON}" "${BINARY}" ${srv_opts} "${srv3_stdout}" "${srv3_stderr}" )"; then
		printf ""
	fi

	# Wait until Server is up
	run "sleep ${STARTUP_WAIT}"

	# [SERVER] Ensure Server is running
	test_case_instance_is_running "Server" "${srv_pid}" "${srv3_stdout}" "${srv3_stderr}"

	# [SERVER] Ensure Server has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv3_stdout}" "${srv3_stderr}"

	# [CLIENT] Ensure Client is still is running
	test_case_instance_is_running "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv3_stdout}" "${srv3_stderr}"

	# [CLIENT] Ensure Client still has no errors
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv3_stdout}" "${srv3_stderr}" "Connection refused"


	# --------------------------------------------------------------------------------
	# [ROUND-3: SRV-SEND] DATA TRANSFER
	# --------------------------------------------------------------------------------
	print_h2 "(9/11) Transfer: Server -> Client (round 3)"

	# [SERVER -> CLIENT]
	wait_for_data_transferred "" "${data}${data}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv3_stdout}" "${srv3_stderr}"


	# --------------------------------------------------------------------------------
	# [ROUND-3]: SRV-SEND] STOP: SERVER
	# --------------------------------------------------------------------------------
	print_h2 "(10/11) Stop: Server (round 3)"

	# [SERVER] Manually stop the Server
	action_stop_instance "Server" "${srv_pid}" "${srv3_stdout}" "${srv3_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# [SERVER] Ensure Server has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv3_stdout}" "${srv3_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# [CLIENT] Ensure Client still has no errors
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv3_stdout}" "${srv3_stderr}" "Connection refused"


	###
	###
	### STOP CLIENT
	###
	###

	# --------------------------------------------------------------------------------
	# STOP: CLIENT
	# --------------------------------------------------------------------------------
	print_h2 "(11/11) Stop: Client"

	# [CLIENT] Manually stop the Client
	action_stop_instance "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv3_stdout}" "${srv3_stderr}"
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for curr_round in $(seq "${RUNS}"); do
	echo
	#         server opts         client opts
	run_test "-l ${RPORT} -vvvv" "${RHOST} ${RPORT} --reconn -1 -vvvv"  "1" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} -vvv " "${RHOST} ${RPORT} --reconn -1 -vvvv"  "2" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} -vv  " "${RHOST} ${RPORT} --reconn -1 -vvvv"  "3" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} -v   " "${RHOST} ${RPORT} --reconn -1 -vvvv"  "4" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT}      " "${RHOST} ${RPORT} --reconn -1 -vvvv"  "5" "13" "${curr_round}" "${RUNS}"

	#run_test "-l ${RPORT} -vvvv" "${RHOST} ${RPORT} --reconn -1 -vvv "  "6" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} -vvvv" "${RHOST} ${RPORT} --reconn -1 -vv  "  "7" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} -vvvv" "${RHOST} ${RPORT} --reconn -1 -v   "  "8" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} -vvvv" "${RHOST} ${RPORT} --reconn -1      "  "9" "13" "${curr_round}" "${RUNS}"

	#run_test "-l ${RPORT} -vvv " "${RHOST} ${RPORT} --reconn -1 -vvv " "10" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} -vv  " "${RHOST} ${RPORT} --reconn -1 -vv  " "11" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} -v   " "${RHOST} ${RPORT} --reconn -1 -v   " "12" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT}      " "${RHOST} ${RPORT} --reconn -1      " "13" "13" "${curr_round}" "${RUNS}"
done
