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

PYTHON="python${1:-}"
PYVER="$( "${PYTHON}" -V 2>&1 | head -1 || true )"

RHOST="localhost"
RPORT="${2:-4444}"
RUNS=1
STARTUP_WAIT=2
TRANS_WAIT=10


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
	printf "abcdefghijklmnopqrstuvwxyz1234567890\\n" > "${data}"
	expect="abcdefghijklmnopqrstuvwxyz1234567890\\r\\n"
	srv_stdout="$(tmp_file)"
	srv_stderr="$(tmp_file)"
	cli_stdout="$(tmp_file)"
	cli_stderr="$(tmp_file)"


	# --------------------------------------------------------------------------------
	# START: SERVER
	# --------------------------------------------------------------------------------
	print_h2 "(1/4) Start: Server"

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
	print_h2 "(2/4) Start: Client"

	# Start Client
	print_info "Start Client"
	# shellcheck disable=SC2086
	if ! cli_pid="$( run_bg "cat ${data}" "${PYTHON}" "${BINARY}" ${cli_opts} "${cli_stdout}" "${cli_stderr}" )"; then
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
	print_h2 "(3/4) Transfer: Client -> Server"

	# [SERVER] Wait for data
	print_info "Wait for data transfer"
	cnt=0
	# shellcheck disable=SC2059
	while ! diff <(printf "${expect}" | od -c) <(od -c "${srv_stdout}") >/dev/null 2>&1; do
		printf "."
		cnt=$(( cnt + 1 ))
		if [ "${cnt}" -gt "${TRANS_WAIT}" ]; then
			echo
			print_file "CLIENT STDERR" "${cli_stderr}"
			print_file "CLIENT STDOUT" "${cli_stdout}"
			print_file "SERVER STDERR" "${srv_stderr}"
			print_file "SERVER STDOUT" "${srv_stdout}"
			print_data "EXPECT DATA" "${expect}"
			diff <(printf "${expect}" | od -c) <(od -c "${srv_stdout}") 2>&1 || true
			kill_pid "${cli_pid}" || true
			kill_pid "${srv_pid}" || true
			print_data "RECEIVED RAW" "$( od -c "${srv_stdout}" )"
			print_data "EXPECTED RAW" "$( printf "${expect}" | od -c )"
			print_error "[Receive Error] Received data on Server does not match send data from Client"
			exit 1
		fi
		sleep 1
	done
	echo
	print_file "Server received data" "${srv_stdout}"
	print_data "Client received data" "$( od -c "${srv_stdout}" )"


	# --------------------------------------------------------------------------------
	# TEST: Errors
	# --------------------------------------------------------------------------------
	print_h2 "(4/4) Test: Errors"

	# [SERVER] Ensure Server has has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# [CLIENT] Ensure Client has no errors
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	kill_pid "${cli_pid}"
	kill -9 "${srv_pid}" >/dev/null 2>/dev/null || true
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for curr_round in $(seq "${RUNS}"); do
	echo
	#         server opts         client opts
	run_test "-l ${RPORT} --crlf -vvvv" "${RHOST} ${RPORT} --crlf -vvvv"  "1" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --crlf -vvv " "${RHOST} ${RPORT} --crlf -vvvv"  "2" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --crlf -vv  " "${RHOST} ${RPORT} --crlf -vvvv"  "3" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --crlf -v   " "${RHOST} ${RPORT} --crlf -vvvv"  "4" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --crlf      " "${RHOST} ${RPORT} --crlf -vvvv"  "5" "13" "${curr_round}" "${RUNS}"

	#run_test "-l ${RPORT} --crlf -vvvv" "${RHOST} ${RPORT} --crlf -vvv "  "6" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --crlf -vvvv" "${RHOST} ${RPORT} --crlf -vv  "  "7" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --crlf -vvvv" "${RHOST} ${RPORT} --crlf -v   "  "8" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --crlf -vvvv" "${RHOST} ${RPORT} --crlf      "  "9" "13" "${curr_round}" "${RUNS}"

	#run_test "-l ${RPORT} --crlf -vvv " "${RHOST} ${RPORT} --crlf -vvv " "10" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --crlf -vv  " "${RHOST} ${RPORT} --crlf -vv  " "11" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --crlf -v   " "${RHOST} ${RPORT} --crlf -v   " "12" "13" "${curr_round}" "${RUNS}"
	#run_test "-l ${RPORT} --crlf      " "${RHOST} ${RPORT} --crlf      " "13" "13" "${curr_round}" "${RUNS}"
done
