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

RHOST="www.google.com"
RPORT="80"

LHOST="localhost"
LPORT="${2:-4444}"
RUNS=1
SRV_WAIT=2
TRANS_WAIT=2


# -------------------------------------------------------------------------------------------------
# TEST FUNCTIONS
# -------------------------------------------------------------------------------------------------

print_test_case "[400] Mode: (TCP) Forward: Client makes HTTP request (${PYVER})"

# 1. Start Forward Server in background
# 2. Run Client without proxy
# 3. Run Client through proxy
# 4. Run Client through proxy (see if server stays alive)
# 5. Compare data contents

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
	echo;print_h2 "(1/5) Start: Server"

	# Start Server
	print_info "Start Server"
	# shellcheck disable=SC2086
	srv_pid="$( run_bg "" "${PYTHON}" "${BINARY}" ${srv_opts} "--local" "${LHOST}:${LPORT}" "${RHOST}" "${RPORT}" "${srv_stdout}" "${srv_stderr}" )"

	# Wait until Server is up
	run "sleep ${SRV_WAIT}"

	# Ensure Server is started in background
	test_case_instance_is_started_in_bg "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	# Ensure Server has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"


	# --------------------------------------------------------------------------------
	# START: CLIENT-1 (NO PROXY)
	# --------------------------------------------------------------------------------
	echo;print_h2 "(2/5) Start: Client-1 (without Proxy)"

	# Start Client
	print_info "Start Client-1"
	# shellcheck disable=SC2086
	cli1_pid="$( run_bg "cat ${data}" "${PYTHON}" "${BINARY}" ${cli_opts} "${RHOST}" "${RPORT}" "${cli1_stdout}" "${cli1_stderr}" )"
	run "sleep ${TRANS_WAIT}"
	test_case_instance_is_started_in_bg "Client-1" "${cli1_pid}" "${cli1_stdout}" "${cli1_stderr}"
	test_case_instance_has_no_errors "Client-1" "${cli1_pid}" "${cli1_stdout}" "${cli1_stderr}"
	test_case_instance_is_running "Client-1" "${cli1_pid}" "${cli1_stdout}" "${cli1_stderr}"
	action_stop_instance "Client-1" "${cli1_pid}" "${cli1_stdout}" "${cli1_stderr}"


	# --------------------------------------------------------------------------------
	# START: CLIENT-2 (WITH PROXY)
	# --------------------------------------------------------------------------------
	echo;print_h2 "(3/5) Start: Client-2 (with Proxy)"

	# Start Client
	print_info "Start Client-2"
	# shellcheck disable=SC2086
	cli2_pid="$( run_bg "cat ${data}" "${PYTHON}" "${BINARY}" ${cli_opts} "${LHOST}" "${LPORT}" "${cli2_stdout}" "${cli2_stderr}" )"
	run "sleep ${TRANS_WAIT}"
	test_case_instance_is_started_in_bg "Client-2" "${cli2_pid}" "${cli2_stdout}" "${cli2_stderr}"
	test_case_instance_has_no_errors "Client-2" "${cli2_pid}" "${cli2_stdout}" "${cli2_stderr}"
	test_case_instance_is_running "Client-2" "${cli2_pid}" "${cli2_stdout}" "${cli2_stderr}"
	action_stop_instance "Client-2" "${cli2_pid}" "${cli2_stdout}" "${cli2_stderr}"


	# --------------------------------------------------------------------------------
	# START: CLIENT-3 (WITH PROXY)
	# --------------------------------------------------------------------------------
	echo;print_h2 "(4/5) Start: Client-3 (with Proxy)"

	# TODO: USE WAIT MODE HOERE
	# Start Client
	print_info "Start Client-3"
	# shellcheck disable=SC2086
	cli3_pid="$( run_bg "cat ${data}" "${PYTHON}" "${BINARY}" ${cli_opts} "${LHOST}" "${LPORT}" "${cli3_stdout}" "${cli3_stderr}" )"
	run "sleep ${TRANS_WAIT}"
	test_case_instance_is_started_in_bg "Client-2" "${cli3_pid}" "${cli3_stdout}" "${cli3_stderr}"
	test_case_instance_has_no_errors "Client-2" "${cli3_pid}" "${cli3_stdout}" "${cli3_stderr}"
	test_case_instance_is_running "Client-2" "${cli3_pid}" "${cli3_stdout}" "${cli3_stderr}"
	action_stop_instance "Client-2" "${cli3_pid}" "${cli3_stdout}" "${cli3_stderr}"


	# --------------------------------------------------------------------------------
	# COMPARE
	# --------------------------------------------------------------------------------
	echo;print_h2 "(5/5) Check and Compare results"

	test_case_instance_is_running "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"
	action_stop_instance "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	# Sanity check we have at least some data in the file
	print_info "Ensure we have some data in Client-1 available"
	if ! run "cat '${cli1_stdout}' | grep 'Set-Cookie' >/dev/null"; then
		print_file "CLIENT-1 STDERR" "${cli1_stderr}"
		print_file "CLIENT-1 STDOUT" "${cli1_stdout}"
		print_error "[Receive Error] Client-1 did not receive any data. Cannot compare results"
		exit 1
	fi

	# Client-1 vs Client-2
	print_info "Compare Client-1 and Client-2"
	if ! run "diff <(cat '${cli1_stdout}' | sed 's/^Set-Cookie:.*//g' | sed 's/^Date:.*//g') \
		           <(cat '${cli2_stdout}' | sed 's/^Set-Cookie:.*//g' | sed 's/^Date:.*//g')"; then
		print_file "CLIENT-1 STDERR" "${cli1_stderr}"
		print_file "CLIENT-1 STDOUT" "${cli1_stdout}"
		print_file "CLIENT-2 STDERR" "${cli2_stderr}"
		print_file "CLIENT-2 STDOUT" "${cli2_stdout}"
		print_file "SERVER STDERR" "${srv_stderr}"
		print_file "SERVER STDOUT" "${srv_stdout}"
		diff "${cli1_stdout}" "${cli2_stdout}" 2>&1 || true
		print_error "[Receive Error] Client-1 and Client-2 data don't match"
		exit 1
	fi

	# Client-2 vs Client-3
	print_info "Compare Client-2 and Client-3"
	if ! run "diff <(cat '${cli2_stdout}' | sed 's/^Set-Cookie:.*//g' | sed 's/^Date:.*//g') \
		           <(cat '${cli3_stdout}' | sed 's/^Set-Cookie:.*//g' | sed 's/^Date:.*//g')"; then
		print_file "CLIENT-1 STDERR" "${cli2_stderr}"
		print_file "CLIENT-1 STDOUT" "${cli2_stdout}"
		print_file "CLIENT-2 STDERR" "${cli3_stderr}"
		print_file "CLIENT-2 STDOUT" "${cli3_stdout}"
		print_file "SERVER STDERR" "${srv_stderr}"
		print_file "SERVER STDOUT" "${srv_stdout}"
		diff "${cli2_stdout}" "${cli3_stdout}" 2>&1 || true
		print_error "[Receive Error] Client-2 and Client-3 data don't match"
		exit 1
	fi

	# Show received data
	print_file "Client-1 received data" "${cli1_stdout}"
	print_file "Client-2 received data" "${cli2_stdout}"
	print_file "Client-3 received data" "${cli3_stdout}"
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for i in $(seq "${RUNS}"); do
	echo
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
