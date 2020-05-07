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

RHOST="www.google.com"
RPORT="80"

#STARTUP_WAIT="${3:-4}"
RUNS="${4:-1}"

PYTHON="python${5:-}"
PYVER="$( "${PYTHON}" -V 2>&1 | head -1 || true )"


# -------------------------------------------------------------------------------------------------
# TEST FUNCTIONS
# -------------------------------------------------------------------------------------------------
print_test_case "${PYVER}"

run_test() {
	local cli_opts="${1// / }"
	local curr_mutation="${2}"
	local total_mutation="${3}"
	local curr_round="${4}"
	local total_round="${5}"
	local data=

	print_h1 "[ROUND: ${curr_round}/${total_round}] (mutation: ${curr_mutation}/${total_mutation}) Starting Test Round (cli '${cli_opts}')"

	###
	### Create data and files
	###
	data="$(tmp_file)"
	printf "HEAD / HTTP/1.1\\n\\n" > "${data}"
	cli_stdout="$(tmp_file)"
	cli_stderr="$(tmp_file)"


	# --------------------------------------------------------------------------------
	# START: CLIENT
	# --------------------------------------------------------------------------------
	print_h2 "(1/4) Start: Client"

	# Start Client
	print_info "Start Client"
	# shellcheck disable=SC2086
	if ! cli_pid="$( run_bg "cat ${data}" "${PYTHON}" "${BINARY}" ${cli_opts} "${cli_stdout}" "${cli_stderr}" )"; then
		printf ""
	fi


	# --------------------------------------------------------------------------------
	# DATA TRANSFER
	# --------------------------------------------------------------------------------
	print_h2 "(2/4) Transfer: Client -> Google -> Client"

	# [CLIENT] -> [GOOGLE] -> CLIENT]
	wait_for_data_transferred "^Set-Cookie:" "" "" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"


	# --------------------------------------------------------------------------------
	# TEST: Client stays alive
	# --------------------------------------------------------------------------------
	print_h2 "(3/4) Test: Client stays alive"
	run "sleep 2"

	# [CLIENT] Ensure Client has no errors
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# [CLIENT] Ensure Client is still running
	test_case_instance_is_running "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"


	# --------------------------------------------------------------------------------
	# STOP: Client
	# --------------------------------------------------------------------------------
	print_h2 "(4/4) Stop: Client"

	# [CLIENT] Manually stop the Client
	action_stop_instance "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# [CLIENT] Ensure Client has no errors
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for curr_round in $(seq "${RUNS}"); do
	run_test "${RHOST} ${RPORT} -vvvv" "1" "5" "${curr_round}" "${RUNS}"
	#run_test "${RHOST} ${RPORT} -vvv " "2" "5" "${curr_round}" "${RUNS}"
	#run_test "${RHOST} ${RPORT} -vv  " "3" "5" "${curr_round}" "${RUNS}"
	#run_test "${RHOST} ${RPORT} -v   " "4" "5" "${curr_round}" "${RUNS}"
	#run_test "${RHOST} ${RPORT}      " "5" "5" "${curr_round}" "${RUNS}"
done
