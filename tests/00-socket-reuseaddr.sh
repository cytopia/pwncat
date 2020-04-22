#!/usr/bin/env bash

set -e
set -u
set -o pipefail


SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
BINARY="${SCRIPTPATH}/../bin/pwncat"
# shellcheck disable=SC1090
source "${SCRIPTPATH}/.lib.sh"

PYTHON="python${1:-}"
PYVER="$( eval "${PYTHON} -V" 2>&1 | head -1 )"
print_h1 "[03] TCP Client send data to Server (${PYVER})"


# -------------------------------------------------------------------------------------------------
# GLOBALS
# -------------------------------------------------------------------------------------------------

RHOST="localhost"
RPORT="${2:-4000}"
RUNS=2
SRV_WAIT=5
TRANS_WAIT=20


# -------------------------------------------------------------------------------------------------
# TEST FUNCTIONS
# -------------------------------------------------------------------------------------------------

# 1. Start server in background which pipes stdout into a fie
# 2. Start client in background with text input to be send to server
# 3. Wait until data has arrived
# 4. Kill the server
# 5. Ensure the client is killed as well (should be behaviour)
# 6. Rebind the server

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
	echo;print_h2 "Start Server"

	###
	### Start Server
	###
	print_info "Start Server"
	# shellcheck disable=SC2086
	${PYTHON} "${BINARY}" ${srv_opts} -l "${host}" "${port}" > "${srv_stdout}" 2> "${srv_stderr}" &
	srv_pid="${!:-}"

	###
	### Check PID
	###
	print_info "Check pid"
	if [ -z "${srv_pid}" ]; then
		print_file "SERVER STDERR" "${srv_stderr}"
		print_file "SERVER STDOUT" "${srv_stdout}"
		print_error "[Server Error] Failed to start Server in background"
		exit 1
	fi
	print_info "Server started in background with pid: ${srv_pid}"
	sleep "${SRV_WAIT}"  # Wait until server is up

	###
	### Check Server for errors
	###
	print_info "Check Server for Errors"
	if has_errors "${srv_stderr}"; then
		print_file "SERVER STDERR" "${srv_stderr}"
		print_file "SERVER STDOUT" "${srv_stdout}"
		run "kill ${srv_pid} || true" 2>/dev/null
		print_error "[Server Error] Errors found in stderr"
		exit 1
	fi


	# --------------------------------------------------------------------------------
	# START: CLIENT
	# --------------------------------------------------------------------------------
	echo;print_h2 "Start Client"

	###
	### Run client
	###
	print_info "Start Client and send data"
	# shellcheck disable=SC2086
	echo "${data}" | ${PYTHON} "${BINARY}" ${cli_opts} "${host}" "${port}" > "${cli_stdout}" 2> "${cli_stderr}" &
	cli_pid="${!:-}"

	###
	### Check PID
	###
	print_info "Check pid"
	if [ -z "${cli_pid}" ]; then
		print_file "SERVER STDERR" "${srv_stderr}"
		print_file "SERVER STDOUT" "${srv_stdout}"
		print_file "CLIENT STDERR" "${cli_stderr}"
		print_file "CLIENT STDOUT" "${cli_stdout}"
		print_error "[Client Error] Failed to start Client in background"
		run "kill ${srv_pid} || true" 2>/dev/null
		exit 1
	fi
	print_info "Client started in background with pid: ${cli_pid}"


	# --------------------------------------------------------------------------------
	# TRANSFER
	# --------------------------------------------------------------------------------
	echo;print_h2 "Transfer"

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
			print_data "RECEIVED RAW" "$( echo "${srv_stdout}" | od -c )"
			print_data "EXPECTED RAW" "$( echo "${data}" | od -c )"
			print_error "[Receive Error] Received data on server does not match send data from Client"
			exit 1
		fi
		sleep 1
	done
	echo


	# --------------------------------------------------------------------------------
	# POST CHECK: CLIENT
	# --------------------------------------------------------------------------------
	echo;print_h2 "Post check Client"

	###
	### Check Client for errors
	###
	print_info "Check Client for errors (before stop)"
	if has_errors "${cli_stderr}"; then
		print_file "SERVER STDERR" "${srv_stderr}"
		print_file "SERVER STDOUT" "${srv_stdout}"
		print_file "CLIENT STDERR" "${cli_stderr}"
		print_file "CLIENT STDOUT" "${cli_stdout}"
		run "kill ${cli_pid} || true " 2>/dev/null
		run "kill ${srv_pid} || true " 2>/dev/null
		print_error "[Client Error] Errors found in stderr"
		exit 1
	fi

	###
	### Check Client is still running
	###
	print_info "Check Client is still running"
	if ! pid_is_running "${cli_pid}"; then
		print_file "SERVER STDERR" "${srv_stderr}"
		print_file "SERVER STDOUT" "${srv_stdout}"
		print_file "CLIENT STDERR" "${cli_stderr}"
		print_file "CLIENT STDOUT" "${cli_stdout}"
		print_error "[Client Error] Client is not running anymore"
		run "kill ${srv_pid} || true" 2>/dev/null
		exit 1
	fi


	# --------------------------------------------------------------------------------
	# Stop Server
	# --------------------------------------------------------------------------------
	echo;print_h2 "Stop Server"

	###
	### Stop Server
	###
	print_info "Stop Server"
	run "kill ${srv_pid}"
	for i in {1..10}; do
		if ! pid_is_running "${srv_pid}"; then
			break
		fi
		printf "."
		sleep 1
	done;

	###
	### Stop Server with force
	###
	if pid_is_running "${srv_pid}"; then
		print_info "Stop Server forcefully"
		run "kill -9 ${srv_pid}"
		for i in {1..10}; do
			if ! pid_is_running "${srv_pid}"; then
				break
			fi
			printf "."
			sleep 1
		done
		if pid_is_running "${srv_pid}"; then
			print_error "[Meta] Could not kill server process"
			print_file "CLIENT STDERR" "${cli_stderr}"
			print_file "CLIENT STDOUT" "${cli_stdout}"
			exit 1
		fi
	fi

	###
	### Check Server for errors
	###
	print_info "Check Server for Errors"
	if has_errors "${srv_stderr}"; then
		print_file "SERVER STDERR" "${srv_stderr}"
		print_file "SERVER STDOUT" "${srv_stdout}"
		run "kill ${srv_pid} || true" 2>/dev/null
		print_error "[Server Error] Errors found in stderr"
		exit 1
	fi


	# --------------------------------------------------------------------------------
	# POST CHECK: CLIENT
	# --------------------------------------------------------------------------------
	echo;print_h2 "Post check Client"

	###
	### Check if Server has quit (as it should, if client disconnects)
	###
	print_info "Check Client quitted automatically"
	cnt=0
	tot=20
	while pid_is_running "${cli_pid}"; do
		printf "."
		cnt=$(( cnt + 1 ))
		if [ "${cnt}" -gt "${tot}" ]; then
			echo
			print_error "[Client Error] Still running. Need to kil itl manually by pid: ${cli_pid}"
			run "kill ${cli_pid} || true" 2>/dev/null
			print_file "CLIENT STDERR" "${cli_stderr}"
			print_file "CLIENT STDOUT" "${cli_stdout}"
			print_file "SERVER STDERR" "${srv_stderr}"
			print_file "SERVER STDOUT" "${srv_stdout}"
			print_error "[Client Error] Client did not finish after ${tot} sec"
			exit 1
		fi
		sleep 1
	done;
	[ "${cnt}" -gt "0" ] && echo

	###
	### Check Client for errors (during quit phase)
	###
	print_info "Check Client for errors (during quit)"
	if has_errors "${srv_stderr}"; then
		print_file "SERVER STDERR" "${srv_stderr}"
		print_file "SERVER STDOUT" "${srv_stdout}"
		run "kill ${srv_pid} || true" 2>/dev/null
		print_error "[Server Error] Errors found in stderr"
		exit 1
	fi
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for i in $(seq "${RUNS}"); do
	echo

	# We want to check if the server is able to bind at the same address
	# again, that's why we do not increment the port numer here.
	run_test "${RHOST}" "${RPORT}" "-vvvv" "-vvvv" "${i}" "1"
	run_test "${RHOST}" "${RPORT}" "-vvv " "-vvvv" "${i}" "2"
	run_test "${RHOST}" "${RPORT}" "-vv  " "-vvvv" "${i}" "3"
	run_test "${RHOST}" "${RPORT}" "-v   " "-vvvv" "${i}" "4"
	run_test "${RHOST}" "${RPORT}" "     " "-vvvv" "${i}" "5"

	run_test "${RHOST}" "${RPORT}" "-vvvv" "-vvv " "${i}" "6"
	run_test "${RHOST}" "${RPORT}" "-vvvv" "-vv  " "${i}" "7"
	run_test "${RHOST}" "${RPORT}" "-vvvv" "-v   " "${i}" "8"
	run_test "${RHOST}" "${RPORT}" "-vvvv" "     " "${i}" "9"

	run_test "${RHOST}" "${RPORT}" "-vvv " "-vvv " "${i}" "10"
	run_test "${RHOST}" "${RPORT}" "-vv  " "-vv  " "${i}" "11"
	run_test "${RHOST}" "${RPORT}" "-v   " "-v   " "${i}" "12"
	run_test "${RHOST}" "${RPORT}" "     " "     " "${i}" "13"
done
