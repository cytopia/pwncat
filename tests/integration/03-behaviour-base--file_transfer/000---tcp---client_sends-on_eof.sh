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
	#local data=
	#local data_or=

	print_h1 "[ROUND: ${curr_round}/${total_round}] (mutation: ${curr_mutation}/${total_mutation}) Starting Test Round (srv '${srv_opts}' vs cli '${cli_opts}')"
	run "sleep 1"

	###
	### Create data and files
	###
	srv_stdout="$(tmp_file)"
	srv_stderr="$(tmp_file)"
	cli_stdout="$(tmp_file)"
	cli_stderr="$(tmp_file)"


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
	# START: CLIENT
	# --------------------------------------------------------------------------------
	print_h2 "(2/5) Start: Client"

	# Start Client
	print_info "Start Client"
	# shellcheck disable=SC2086
	if ! cli_pid="$( run_bg "cat /bin/ls" "${PYTHON}" "${BINARY}" ${cli_opts} "${cli_stdout}" "${cli_stderr}" )"; then
		printf ""
	fi

	# Wait until Client is done
	run "sleep ${STARTUP_WAIT}"

	# Give some time for transfer
	run "sleep 10"

	# [CLIENT] Ensure Client has no errors
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	# [SERVER] Ensure Server still has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"


	# --------------------------------------------------------------------------------
	# DATA TRANSFER
	# --------------------------------------------------------------------------------
	print_h2 "(3/5) Transfer: Client -> Server"

	# [CLIENT -> SERVER]
	if ! run "diff /bin/ls ${srv_stdout}"; then
		kill_pid "${srv_pid}" || true
		kill_pid "${cli_pid}" || true
		print_error "Transferred files differ"
		print_file "SERVER] - [/dev/stderr" "${srv_stderr}"
		print_file "CLIENT] - [/dev/stderr" "${cli_stderr}"
		exit 1
	fi

	# --------------------------------------------------------------------------------
	# TEST: Server shut down automatically
	# --------------------------------------------------------------------------------
	print_h2 "(4/5) Test: Server shut down automatically"

	# [SERVER] Ensure Server has quit automatically
	test_case_instance_is_stopped "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# [SERVER] Ensure Server still has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}" "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"


	# --------------------------------------------------------------------------------
	# TEST: Client  shut down automatically
	# --------------------------------------------------------------------------------
	print_h2 "(5/5) Test: Client shut down automatically"

	# [CLIENT] Ensure Client has quit automatically
	test_case_instance_is_stopped "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	# [CLIENT] Ensure Client has no errors
	test_case_instance_has_no_errors "Client" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "Server" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for curr_round in $(seq "${RUNS}"); do
	#         server opts            client opts
	# BIND ON ANY
	run_test "-l ${RPORT}    -vvvv" "${RHOST} ${RPORT} --send-on-eof    -vvvv"  "1" "16" "${curr_round}" "${RUNS}"
	run_test "-l ${RPORT}    -vvvv" "${RHOST} ${RPORT} --send-on-eof -4 -vvvv"  "2" "16" "${curr_round}" "${RUNS}"
	run_test "-l ${RPORT}    -vvvv" "${RHOST} ${RPORT} --send-on-eof -6 -vvvv"  "3" "16" "${curr_round}" "${RUNS}"

	run_test "-l ${RPORT} -4 -vvvv" "${RHOST} ${RPORT} --send-on-eof    -vvvv"  "4" "16" "${curr_round}" "${RUNS}"
	run_test "-l ${RPORT} -4 -vvvv" "${RHOST} ${RPORT} --send-on-eof -4 -vvvv"  "5" "16" "${curr_round}" "${RUNS}"

	run_test "-l ${RPORT} -6 -vvvv" "${RHOST} ${RPORT} --send-on-eof    -vvvv"  "6" "16" "${curr_round}" "${RUNS}"
	run_test "-l ${RPORT} -6 -vvvv" "${RHOST} ${RPORT} --send-on-eof -6 -vvvv"  "7" "16" "${curr_round}" "${RUNS}"
	# no verbosity
	run_test "-l ${RPORT}         " "${RHOST} ${RPORT} --send-on-eof         "  "8" "16" "${curr_round}" "${RUNS}"

	# BIND ON SPECIFIC
	run_test "-l ${RHOST} ${RPORT}    -vvvv" "${RHOST} ${RPORT} --send-on-eof    -vvvv"   "9" "16" "${curr_round}" "${RUNS}"
	run_test "-l ${RHOST} ${RPORT}    -vvvv" "${RHOST} ${RPORT} --send-on-eof -4 -vvvv"  "10" "16" "${curr_round}" "${RUNS}"
	run_test "-l ${RHOST} ${RPORT}    -vvvv" "${RHOST} ${RPORT} --send-on-eof -6 -vvvv"  "11" "16" "${curr_round}" "${RUNS}"

	run_test "-l ${RHOST} ${RPORT} -4 -vvvv" "${RHOST} ${RPORT} --send-on-eof    -vvvv"  "12" "16" "${curr_round}" "${RUNS}"
	run_test "-l ${RHOST} ${RPORT} -4 -vvvv" "${RHOST} ${RPORT} --send-on-eof -4 -vvvv"  "13" "16" "${curr_round}" "${RUNS}"

	run_test "-l ${RHOST} ${RPORT} -6 -vvvv" "${RHOST} ${RPORT} --send-on-eof    -vvvv"  "14" "16" "${curr_round}" "${RUNS}"
	run_test "-l ${RHOST} ${RPORT} -6 -vvvv" "${RHOST} ${RPORT} --send-on-eof -6 -vvvv"  "15" "16" "${curr_round}" "${RUNS}"
	# no verbosity
	run_test "-l ${RHOST} ${RPORT}         " "${RHOST} ${RPORT} --send-on-eof         "  "16" "16" "${curr_round}" "${RUNS}"
done
