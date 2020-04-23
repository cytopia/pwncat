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

print_test_case "[111] UDP Socket REUSEADDR (${PYVER})"

# 1. Start Server in background
# 2. Start Client in background
# 3. Wait until data has arrived
# 4. Kill the Server and Client (random order)
# --> REPEAT 1-4 with same port

# This tests the ability of "setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)"
# Without this option an error will pop up as the socket is still in wait state:
# "[Errno 98] Address already in use"

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
	echo;print_h2 "(1/4) Start: Server"

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
	echo;print_h2 "(2/4) Start: Client"

	# Start Client
	print_info "Start Client"
	# shellcheck disable=SC2086
	cli_pid="$( run_bg "echo ${data}" "${PYTHON}" "${BINARY}" ${cli_opts} "${host}" "${port}" "${cli_stdout}" "${cli_stderr}" )"

	# Ensure Client is started in background
	test_case_instance_is_started_in_bg "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# Ensure Client has no errors
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"


	# --------------------------------------------------------------------------------
	# TRANSFER
	# --------------------------------------------------------------------------------
	echo;print_h2 "(3/4) Transfer"

	###
	### Wait random time for data to be sent or quit earlier if send already
	###
	WAIT="$(( RANDOM % TRANS_WAIT + 1 ))"
	print_info "Wait random time for data transfer: ${WAIT} sec"
	cnt=0
	while ! diff <(echo "${data}") "${srv_stdout}" >/dev/null 2>&1; do
		printf "."
		cnt=$(( cnt + 1 ))
		if [ "${cnt}" -gt "${WAIT}" ]; then
			break
		fi
		sleep 1
	done
	echo


	# --------------------------------------------------------------------------------
	# Stop Server and Client
	# --------------------------------------------------------------------------------
	echo;print_h2 "(4/4) Stop: Server or Client"

	###
	### Stop Server
	###
	if [ "$(( RANDOM % 2 + 1 ))" -eq "2" ]; then
		# Manually stop the Server
		action_stop_instance "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"
		action_stop_instance "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	###
	### Stop Client
	###
	else
		action_stop_instance "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"
		action_stop_instance "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"
	fi
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for i in $(seq "${RUNS}"); do
	echo

	# We want to check if the Server is able to bind at the same address
	# again, that's why we do not increment the port numer here.
	run_test "${RHOST}" "${RPORT}" "-u -vvvv" "-u -vvvv" "${i}" "1"
	run_test "${RHOST}" "${RPORT}" "-u -vvv " "-u -vvvv" "${i}" "2"
	run_test "${RHOST}" "${RPORT}" "-u -vv  " "-u -vvvv" "${i}" "3"
	run_test "${RHOST}" "${RPORT}" "-u -v   " "-u -vvvv" "${i}" "4"
	run_test "${RHOST}" "${RPORT}" "-u      " "-u -vvvv" "${i}" "5"

	run_test "${RHOST}" "${RPORT}" "-u -vvvv" "-u -vvv " "${i}" "6"
	run_test "${RHOST}" "${RPORT}" "-u -vvvv" "-u -vv  " "${i}" "7"
	run_test "${RHOST}" "${RPORT}" "-u -vvvv" "-u -v   " "${i}" "8"
	run_test "${RHOST}" "${RPORT}" "-u -vvvv" "-u      " "${i}" "9"

	run_test "${RHOST}" "${RPORT}" "-u -vvv " "-u -vvv " "${i}" "10"
	run_test "${RHOST}" "${RPORT}" "-u -vv  " "-u -vv  " "${i}" "11"
	run_test "${RHOST}" "${RPORT}" "-u -v   " "-u -v   " "${i}" "12"
	run_test "${RHOST}" "${RPORT}" "-u      " "-u      " "${i}" "13"
done
