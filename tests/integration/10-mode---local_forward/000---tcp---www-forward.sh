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

THOST="www.google.com"
TPORT="80"


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
	data="$(tmp_file)"
	printf "HEAD / HTTP/1.1\\n\\n" > "${data}"
	srv_stdout="$(tmp_file)"
	srv_stderr="$(tmp_file)"

	cli1_stdout="$(tmp_file)"
	cli1_stderr="$(tmp_file)"
	cli2_stdout="$(tmp_file)"
	cli2_stderr="$(tmp_file)"
	cli3_stdout="$(tmp_file)"
	cli3_stderr="$(tmp_file)"


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
	# START: CLIENT-1
	# --------------------------------------------------------------------------------
	print_h2 "(2/5) Start: Client-1 (without Proxy)"

	# Start Client
	print_info "Start Client-1"
	# shellcheck disable=SC2086
	if ! cli_pid="$( run_bg "cat ${data}" "${PYTHON}" "${BINARY}" ${cli_opts} "${THOST}" "${TPORT}" "${cli1_stdout}" "${cli1_stderr}" )"; then
		printf ""
	fi
	test_case_instance_is_running "Client-1" "${cli_pid}" "${cli1_stdout}" "${cli1_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"
	wait_for_data_transferred "^Content-Type:" "" "" "Client-1" "${cli_pid}" "${cli1_stdout}" "${cli1_stderr}"
	wait_for_data_transferred "^Set-Cookie:" "" "" "Client-1" "${cli_pid}" "${cli1_stdout}" "${cli1_stderr}"
	test_case_instance_has_no_errors "Client-1" "${cli_pid}" "${cli1_stdout}" "${cli1_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"
	action_stop_instance "Client-1" "${cli_pid}" "${cli1_stdout}" "${cli1_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"


	# --------------------------------------------------------------------------------
	# START: CLIENT-2
	# --------------------------------------------------------------------------------
	print_h2 "(3/5) Start: Client-2 (with Proxy)"

	# Start Client
	print_info "Start Client-2"
	# shellcheck disable=SC2086
	if ! cli_pid="$( run_bg "cat ${data}" "${PYTHON}" "${BINARY}" ${cli_opts} "${RHOST}" "${RPORT}" "${cli2_stdout}" "${cli2_stderr}" )"; then
		printf ""
	fi
	test_case_instance_is_running "Client-2" "${cli_pid}" "${cli2_stdout}" "${cli2_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"
	wait_for_data_transferred "^Content-Type:" "" "" "Client-2" "${cli_pid}" "${cli2_stdout}" "${cli2_stderr}"
	wait_for_data_transferred "^Set-Cookie:" "" "" "Client-1" "${cli_pid}" "${cli2_stdout}" "${cli2_stderr}"
	test_case_instance_has_no_errors "Client-2" "${cli_pid}" "${cli2_stdout}" "${cli2_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"
	action_stop_instance "Client-2" "${cli_pid}" "${cli2_stdout}" "${cli2_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"


	# --------------------------------------------------------------------------------
	# START: CLIENT-3
	# --------------------------------------------------------------------------------
	print_h2 "(4/5) Start: Client-3 (with Proxy)"

	# Start Client
	print_info "Start Client-3"
	# shellcheck disable=SC2086
	if ! cli_pid="$( run_bg "cat ${data}" "${PYTHON}" "${BINARY}" ${cli_opts} "${RHOST}" "${RPORT}" "${cli3_stdout}" "${cli3_stderr}" )"; then
		printf ""
	fi
	test_case_instance_is_running "Client-3" "${cli_pid}" "${cli3_stdout}" "${cli3_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"
	wait_for_data_transferred "^Content-Type:" "" "" "Client-3" "${cli_pid}" "${cli3_stdout}" "${cli3_stderr}"
	wait_for_data_transferred "^Set-Cookie:" "" "" "Client-1" "${cli_pid}" "${cli3_stdout}" "${cli3_stderr}"
	test_case_instance_has_no_errors "Client-3" "${cli_pid}" "${cli3_stdout}" "${cli3_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"
	action_stop_instance "Client-3" "${cli_pid}" "${cli3_stdout}" "${cli3_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"


	# --------------------------------------------------------------------------------
	# STOP: SERVER
	# --------------------------------------------------------------------------------
	print_h2 "(5/5) Stop: Server"

	action_stop_instance "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for curr_round in $(seq "${RUNS}"); do
	#         server opts         client opts
	run_test "--local ${RHOST}:${RPORT} --no-shutdown ${THOST} ${TPORT} -vvvv" "--no-shutdown -vvvv"  "1" "13" "${curr_round}" "${RUNS}"
	#run_test "--local ${RHOST}:${RPORT} --no-shutdown ${THOST} ${TPORT} -vvv " "--no-shutdown -vvvv"  "2" "13" "${curr_round}" "${RUNS}"
	#run_test "--local ${RHOST}:${RPORT} --no-shutdown ${THOST} ${TPORT} -vv  " "--no-shutdown -vvvv"  "3" "13" "${curr_round}" "${RUNS}"
	#run_test "--local ${RHOST}:${RPORT} --no-shutdown ${THOST} ${TPORT} -v   " "--no-shutdown -vvvv"  "4" "13" "${curr_round}" "${RUNS}"
	#run_test "--local ${RHOST}:${RPORT} --no-shutdown ${THOST} ${TPORT}      " "--no-shutdown -vvvv"  "5" "13" "${curr_round}" "${RUNS}"

	#run_test "--local ${RHOST}:${RPORT} --no-shutdown ${THOST} ${TPORT} -vvvv" "--no-shutdown -vvv "  "6" "13" "${curr_round}" "${RUNS}"
	#run_test "--local ${RHOST}:${RPORT} --no-shutdown ${THOST} ${TPORT} -vvvv" "--no-shutdown -vv  "  "7" "13" "${curr_round}" "${RUNS}"
	#run_test "--local ${RHOST}:${RPORT} --no-shutdown ${THOST} ${TPORT} -vvvv" "--no-shutdown -v   "  "8" "13" "${curr_round}" "${RUNS}"
	#run_test "--local ${RHOST}:${RPORT} --no-shutdown ${THOST} ${TPORT} -vvvv" "--no-shutdown      "  "9" "13" "${curr_round}" "${RUNS}"

	#run_test "--local ${RHOST}:${RPORT} --no-shutdown ${THOST} ${TPORT} -vvv " "--no-shutdown -vvv " "10" "13" "${curr_round}" "${RUNS}"
	#run_test "--local ${RHOST}:${RPORT} --no-shutdown ${THOST} ${TPORT} -vv  " "--no-shutdown -vv  " "11" "13" "${curr_round}" "${RUNS}"
	#run_test "--local ${RHOST}:${RPORT} --no-shutdown ${THOST} ${TPORT} -v   " "--no-shutdown -v   " "12" "13" "${curr_round}" "${RUNS}"
	#run_test "--local ${RHOST}:${RPORT} --no-shutdown ${THOST} ${TPORT}      " "--no-shutdown      " "13" "13" "${curr_round}" "${RUNS}"
done
