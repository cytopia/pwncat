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

RHOST="localhost"
RPORT="${2:-4444}"
RUNS=2
SRV_WAIT=2
TRANS_WAIT=5


# -------------------------------------------------------------------------------------------------
# TEST FUNCTIONS
# -------------------------------------------------------------------------------------------------

print_test_case "[202] Basics: (TCP) Client send data to Server (${PYVER})"

# 1. Start Server in background
# 2. Start Client in background
# 3. Compare data contents

run_test() {
	local host="${1}"
	local port="${2}"
	local srv_opts="${3:-}"
	local cli_opts="${4:-}"
	local tround="${5}"
	local sround="${6}"
	local data=

	echo;echo
	print_h1 "[${tround}/${RUNS}] (${sround}/13) Starting Test Round (${host}:${port}) (cli '${cli_opts}' vs srv '${srv_opts}')"

	kill_process "pwncat" >/dev/null 2>&1 || true

	###
	### Create data and files
	###
	data='abcdefghijklmnopqrstuvwxyz1234567890_-+*[](){}#'
	srv_stdout="$(tmp_file)"
	srv_stderr="$(tmp_file)"
	cli_stdout="$(tmp_file)"
	cli_stderr="$(tmp_file)"


	# --------------------------------------------------------------------------------
	# START: SERVER
	# --------------------------------------------------------------------------------
	echo;print_h2 "(1/5) Start: Server"

	# Start Server
	print_info "Start Server"
	# shellcheck disable=SC2086
	srv_pid="$( run_bg "" "${PYTHON}" "${BINARY}" ${srv_opts} "-l" "${host}" "${port}" "${srv_stdout}" "${srv_stderr}" )"

	# Ensure Server is started in background
	test_case_instance_is_started_in_bg "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"
	# Wait until Server is up
	run "sleep ${SRV_WAIT}"

	# Ensure Server has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"


	# --------------------------------------------------------------------------------
	# START: CLIENT
	# --------------------------------------------------------------------------------
	echo;print_h2 "(2/5) Start: Client"

	# Start Client
	print_info "Start Client"
	# shellcheck disable=SC2086
	cli_pid="$( run_bg "echo ${data}" "${PYTHON}" "${BINARY}" ${cli_opts} "${host}" "${port}" "${cli_stdout}" "${cli_stderr}" )"

	# Ensure Client is started in background
	test_case_instance_is_started_in_bg "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"


	# --------------------------------------------------------------------------------
	# TRANSFER
	# --------------------------------------------------------------------------------
	echo;print_h2 "(3/5) Transfer"

	###
	### Wait for data to be sent
	###
	print_info "Wait for data transfer"
	cnt=0
	while ! diff <(echo "${data}") "${srv_stdout}" >/dev/null 2>&1; do
		printf "."
		cnt=$(( cnt + 1 ))
		if [ "${cnt}" -gt "${TRANS_WAIT}" ]; then
			echo
			print_file "CLIENT STDERR" "${cli_stderr}"
			print_file "CLIENT STDOUT" "${cli_stdout}"
			print_file "SERVER STDERR" "${srv_stderr}"
			print_file "SERVER STDOUT" "${srv_stdout}"
			print_data "EXPECT DATA" "${data}"
			diff <(echo "${data}") "${srv_stdout}" 2>&1 || true
			run "kill ${cli_pid} || true" 2>/dev/null
			run "kill ${srv_pid} || true" 2>/dev/null
			print_data "RECEIVED RAW" "$( od -c "${srv_stdout}" )"
			print_data "EXPECTED RAW" "$( echo "${data}" | od -c )"
			print_error "[Receive Error] Received data on Server does not match send data from Client"
			exit 1
		fi
		sleep 1
	done
	echo
	print_file "Server received data" "${srv_stdout}"


	# --------------------------------------------------------------------------------
	# POST CHECK: CLIENT
	# --------------------------------------------------------------------------------
	echo;print_h2 "(4/5) Post Check: Client"

	# Ensure Client has no errors (before stop)
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# Ensure Client is still running
	test_case_instance_is_running "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# Manually stop the Client
	action_stop_instance "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# Ensure Client has no errors (after stop)
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"


	# --------------------------------------------------------------------------------
	# POST CHECK: SERVER
	# --------------------------------------------------------------------------------
	echo;print_h2 "(5/5) Post Check: Server"

	# Ensure Server has quit automatically (as it should, if Client disconnects)
	test_case_instance_is_stopped "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	# Ensure Server has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for i in $(seq "${RUNS}"); do
	echo

	run_test "${RHOST}" "${RPORT}" "-vvvv" "-vvvv" "${i}" "1"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "-vvv " "-vvvv" "${i}" "2"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "-vv  " "-vvvv" "${i}" "3"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "-v   " "-vvvv" "${i}" "4"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "     " "-vvvv" "${i}" "5"
	RPORT=$(( RPORT + 1))

	run_test "${RHOST}" "${RPORT}" "-vvvv" "-vvv " "${i}" "6"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "-vvvv" "-vv  " "${i}" "7"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "-vvvv" "-v   " "${i}" "8"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "-vvvv" "     " "${i}" "9"
	RPORT=$(( RPORT + 1))

	run_test "${RHOST}" "${RPORT}" "-vvv " "-vvv " "${i}" "10"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "-vv  " "-vv  " "${i}" "11"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "-v   " "-v   " "${i}" "12"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "     " "     " "${i}" "13"
	RPORT=$(( RPORT + 1))
done
