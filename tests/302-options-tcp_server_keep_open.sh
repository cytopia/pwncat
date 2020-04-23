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

print_test_case "[100] Behaviour: (TCP) Server hangs up automatically after Client quits (${PYVER})"

# 1. Start Server in background
# 2. Start Client in background
# 3. Wait random time for transfer (between 1 and $TRANS_WAIT seconds)
# 4. Stop Client
# 5. Ensure Server is still running
# 6. Wait random time for transfer (between 1 and $TRANS_WAIT seconds)
# 7. Stop Client
# 8. Ensure Server is still running
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
	echo;print_h2 "(1/8) Start: Server"

	# Start Server
	print_info "Start Server"
	# shellcheck disable=SC2086
	srv_pid="$( run_bg "" "${PYTHON}" "${BINARY}" ${srv_opts} "-l" "${host}" "${port}" "${srv_stdout}" "${srv_stderr}" )"

	# Wait until Server is up
	run "sleep ${SRV_WAIT}"

	# Ensure Server is started in background
	test_case_instance_is_started_in_bg "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	# Ensure Server has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"


	# --------------------------------------------------------------------------------
	# START: CLIENT
	# --------------------------------------------------------------------------------
	echo;print_h2 "(2/8) Start: Client (1st round)"

	# Start Client
	print_info "Start Client"
	# shellcheck disable=SC2086
	cli_pid="$( run_bg "echo ${data}" "${PYTHON}" "${BINARY}" ${cli_opts} "${host}" "${port}" "${cli_stdout}" "${cli_stderr}" )"

	# Ensure Client is started in background
	test_case_instance_is_started_in_bg "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"


	# --------------------------------------------------------------------------------
	# TRANSFER
	# --------------------------------------------------------------------------------
	echo;print_h2 "(3/8) Transfer (1st round)"

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
			echo
			print_info "Data not send after ${cnt} sec. Breaking anyway, we're testing exit behaviour"
			break
		fi
		sleep 1
	done
	[ "${cnt}" -gt "0" ] && echo


	# --------------------------------------------------------------------------------
	# STOP: CLIENT
	# --------------------------------------------------------------------------------
	echo;print_h2 "(4/8) Stop: Client (1st round)"

	# Ensure Client has no errors (before stop)
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# Ensure Client is still running
	test_case_instance_is_running "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# Manually stop the Client
	action_stop_instance "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# Ensure Client has no errors (after stop)
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"


	# --------------------------------------------------------------------------------
	# TEST: Ensure Server is still running
	# --------------------------------------------------------------------------------
	echo;print_h2 "(5/8) Test: Ensure server is still running (1st round)"

	# Give it some time
	run "sleep 1"

	# Ensure Server has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	# Ensure Server is still running
	test_case_instance_is_running "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"


	###
	### 2nd round
	###

	# --------------------------------------------------------------------------------
	# START: CLIENT (2nd round)
	# --------------------------------------------------------------------------------
	echo;print_h2 "(6/8) Start: Client (2nd round)"

	# Start Client
	print_info "Start Client"
	# shellcheck disable=SC2086
	cli_pid="$( run_bg "echo ${data}" "${PYTHON}" "${BINARY}" ${cli_opts} "${host}" "${port}" "${cli_stdout}" "${cli_stderr}" )"

	# Ensure Client is started in background
	test_case_instance_is_started_in_bg "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"


	# --------------------------------------------------------------------------------
	# TRANSFER (2nd round)
	# --------------------------------------------------------------------------------
	echo;print_h2 "(7/8) Transfer (2nd round)"

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
			echo
			print_info "Data not send after ${cnt} sec. Breaking anyway, we're testing exit behaviour"
			break
		fi
		sleep 1
	done
	[ "${cnt}" -gt "0" ] && echo


	# --------------------------------------------------------------------------------
	# STOP: CLIENT (2nd round)
	# --------------------------------------------------------------------------------
	echo;print_h2 "(8/8) Stop: Client (2nd round)"

	# Ensure Client has no errors (before stop)
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# Ensure Client is still running
	test_case_instance_is_running "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# Manually stop the Client
	action_stop_instance "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# Ensure Client has no errors (after stop)
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"


	# --------------------------------------------------------------------------------
	# TEST: Ensure Server is still running
	# --------------------------------------------------------------------------------
	echo;print_h2 "(9/9) Test: Ensure server is still running (2nd round)"

	# Give it some time
	run "sleep 1"

	# Ensure Server has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	# Ensure Server is still running
	test_case_instance_is_running "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for i in $(seq "${RUNS}"); do
	echo

	# We want to check if the Server is able to bind at the same address
	# again, that's why we do not increment the port numer here.
	run_test "${RHOST}" "${RPORT}" "-k -vvvv" "-vvvv" "${i}" "1"
	run_test "${RHOST}" "${RPORT}" "-k -vvv " "-vvvv" "${i}" "2"
	run_test "${RHOST}" "${RPORT}" "-k -vv  " "-vvvv" "${i}" "3"
	run_test "${RHOST}" "${RPORT}" "-k -v   " "-vvvv" "${i}" "4"
	run_test "${RHOST}" "${RPORT}" "-k      " "-vvvv" "${i}" "5"

	run_test "${RHOST}" "${RPORT}" "-k -vvvv" "-vvv " "${i}" "6"
	run_test "${RHOST}" "${RPORT}" "-k -vvvv" "-vv  " "${i}" "7"
	run_test "${RHOST}" "${RPORT}" "-k -vvvv" "-v   " "${i}" "8"
	run_test "${RHOST}" "${RPORT}" "-k -vvvv" "     " "${i}" "9"

	run_test "${RHOST}" "${RPORT}" "-k -vvv " "-vvv " "${i}" "10"
	run_test "${RHOST}" "${RPORT}" "-k -vv  " "-vv  " "${i}" "11"
	run_test "${RHOST}" "${RPORT}" "-k -v   " "-v   " "${i}" "12"
	run_test "${RHOST}" "${RPORT}" "-k      " "     " "${i}" "13"
done
