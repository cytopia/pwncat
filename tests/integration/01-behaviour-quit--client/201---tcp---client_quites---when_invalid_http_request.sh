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

PYTHON="python${2:-}"
PYVER="$( "${PYTHON}" -V 2>&1 | head -1 || true )"

RHOST="www.google.com"
RPORT="80"
RUNS=1
#STARTUP_WAIT=2
TRANS_WAIT=10


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
	printf "HEAD /\\n\\n" > "${data}"
	cli_stdout="$(tmp_file)"
	cli_stderr="$(tmp_file)"


	# --------------------------------------------------------------------------------
	# START: CLIENT
	# --------------------------------------------------------------------------------
	print_h2 "(1/3) Start: Client"

	# Start Client
	print_info "Start Client"
	# shellcheck disable=SC2086
	if ! cli_pid="$( run_bg "cat ${data}" "${PYTHON}" "${BINARY}" ${cli_opts} "${cli_stdout}" "${cli_stderr}" )"; then
		printf ""
	fi


	# --------------------------------------------------------------------------------
	# DATA TRANSFER
	# --------------------------------------------------------------------------------
	print_h2 "(2/3) Transfer: Client -> Google -> Client"

	# [SERVER] Wait for data
	print_info "Wait for data transfer"
	cnt=0
	while ! grep 'Bad Request' "${cli_stdout}" >/dev/null 2>&1; do
		printf "."
		cnt=$(( cnt + 1 ))
		if [ "${cnt}" -gt "${TRANS_WAIT}" ]; then
			echo
			print_file "CLIENT STDERR" "${cli_stderr}"
			print_file "CLIENT STDOUT" "${cli_stdout}"
			print_data "EXPECT DATA" "Bad Request"
			kill_pid "${cli_pid}" || true
			print_data "RECEIVED RAW" "$( od -c "${cli_stdout}" )"
			print_error "[Receive Error] Received data on Client does not match expected data from Google."
			exit 1
		fi
		sleep 1
	done
	echo
	print_file "Client received data" "${cli_stdout}"


	# --------------------------------------------------------------------------------
	# TEST: Client  shut down automatically
	# --------------------------------------------------------------------------------
	print_h2 "(3/3) Test: Client shut down automatically"

	# [CLIENT] Ensure Client has quit automatically
	test_case_instance_is_stopped "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

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
