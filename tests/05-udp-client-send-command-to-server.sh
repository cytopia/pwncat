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
print_h1 "[05] UDP Client send command to Server (${PYVER})"


# -------------------------------------------------------------------------------------------------
# GLOBALS
# -------------------------------------------------------------------------------------------------

RHOST="localhost"
RPORT="${2:-4500}"
RUNS=2
SRV_WAIT=5
TRANS_WAIT=20


# -------------------------------------------------------------------------------------------------
# TEST FUNCTIONS
# -------------------------------------------------------------------------------------------------

# 1. Start server which pipes stdout into a fie
# 2. Run client with file input to be send to server
# 3. Compare file contents

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
	data="ls"
	expect="$( "${data}" )"
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
	###a
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
	print_info "Start Client"
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
	print_info "[Client Info] Client started in background with pid: ${cli_pid}"


	# --------------------------------------------------------------------------------
	# TRANSFER
	# --------------------------------------------------------------------------------
	echo;print_h2 "Transfer"

	###
	### Wait for data to be sent
	###
	print_info "Wait for data transfer"
	cnt=0
	while ! diff <(echo "${expect}") "${cli_stdout}" >/dev/null 2>&1; do
		printf "."
		cnt=$(( cnt + 1 ))
		if [ "${cnt}" -gt "${TRANS_WAIT}" ]; then
			echo
			print_file "SERVER STDERR" "${srv_stderr}"
			print_file "SERVER STDOUT" "${srv_stdout}"
			print_file "CLIENT STDERR" "${cli_stderr}"
			print_file "CLIENT STDOUT" "${cli_stdout}"
			print_data "EXPECT DATA" "${expect}"
			diff <(echo "${expect}") "${cli_stdout}" 2>&1 || true
			run "kill ${cli_pid} || true" 2>/dev/null
			run "kill ${srv_pid} || true" 2>/dev/null
			print_data "RECEIVED RAW" "$( echo "${cli_stdout}" | od -c )"
			print_data "EXPECTED RAW" "$( echo "${expect}" | od -c )"
			print_error "[Receive Error] Returned data on client does not match expected command output"
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
		run "kill ${cli_pid} || true" 2>/dev/null
		run "kill ${srv_pid} || true" 2>/dev/null
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

	###
	### Stop Client
	###
	print_info "Stop Client"
	run "kill ${cli_pid}"
	for i in {1..10}; do
		if ! pid_is_running "${cli_pid}"; then
			break
		fi
		printf "."
		sleep 1
	done
	[ "${i}" -gt "1" ] && echo

	###
	### Stop Client with force
	###
	if pid_is_running "${cli_pid}"; then
		print_info "Stop Client forcefully"
		run "kill -9 ${cli_pid}"
		for i in {1..10}; do
			if ! pid_is_running "${cli_pid}"; then
				break
			fi
			printf "."
			sleep 1
		done;
		[ "${i}" -gt "1" ] && echo
		if pid_is_running "${cli_pid}"; then
			print_error "[Meta] Could not kill client process"
			print_file "CLIENT STDERR" "${cli_stderr}"
			print_file "CLIENT STDOUT" "${cli_stdout}"
			exit 1
		fi
	fi

	###
	### Check Client for errors (again)
	###
	print_info "Check Client for errors (after stop)"
	if has_errors "${cli_stderr}"; then
		print_file "SERVER STDERR" "${srv_stderr}"
		print_file "SERVER STDOUT" "${srv_stdout}"
		print_file "CLIENT STDERR" "${cli_stderr}"
		print_file "CLIENT STDOUT" "${cli_stdout}"
		run "kill ${cli_pid} || true" 2>/dev/null
		run "kill ${srv_pid} || true" 2>/dev/null
		print_error "[Client Error] Errors found in stderr"
		exit 1
	fi


	# --------------------------------------------------------------------------------
	# POST CHECK: SERVER
	# --------------------------------------------------------------------------------
	echo;print_h2 "Post check Server"

	###
	### Check if Server is still running (In UDP it will stay open - no way of telling client has gone)
	###
	print_info "Check Server stayed alive"
	if ! pid_is_running "${srv_pid}"; then
		run "kill ${cli_pid} || true" 2>/dev/null
			print_file "CLIENT STDERR" "${cli_stderr}"
			print_file "CLIENT STDOUT" "${cli_stdout}"
			print_file "SERVER STDERR" "${srv_stderr}"
			print_file "SERVER STDOUT" "${srv_stdout}"
		print_error "[Server Error] Server went down"
			exit 1
		fi

	###
	### Check Server for errors (during quit phase)
	###
	print_info "Check Server for errors (during quit)"
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

	run_test "${RHOST}" "${RPORT}" "-u -e /bin/bash -vvvv" "-u -vvvv" "${i}" "1"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "-u -e /bin/bash -vvv " "-u -vvvv" "${i}" "2"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "-u -e /bin/bash -vv  " "-u -vvvv" "${i}" "3"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "-u -e /bin/bash -v   " "-u -vvvv" "${i}" "4"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "-u -e /bin/bash      " "-u -vvvv" "${i}" "5"
	RPORT=$(( RPORT + 1))

	run_test "${RHOST}" "${RPORT}" "-u -e /bin/bash -vvvv" "-u -vvv " "${i}" "6"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "-u -e /bin/bash -vvvv" "-u -vv  " "${i}" "7"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "-u -e /bin/bash -vvvv" "-u -v   " "${i}" "8"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "-u -e /bin/bash -vvvv" "-u      " "${i}" "9"
	RPORT=$(( RPORT + 1))

	run_test "${RHOST}" "${RPORT}" "-u -e /bin/bash -vvv " "-u -vvv " "${i}" "10"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "-u -e /bin/bash -vv  " "-u -vv  " "${i}" "11"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "-u -e /bin/bash -v   " "-u -v   " "${i}" "12"
	RPORT=$(( RPORT + 1))
	run_test "${RHOST}" "${RPORT}" "-u -e /bin/bash      " "-u      " "${i}" "13"
	RPORT=$(( RPORT + 1))
done
