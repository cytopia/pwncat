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


BANNER="banner\n"
PREFIX1=""
PREFIX2=""
SUFFIX1="[0] cytopia at hostname in ~/tmp/pwncat (☿ pwncat.git release-0.1.0+)\n"
SUFFIX2="tmux:>bash> "


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
	data="whoami\\n"
	expect="$(whoami)\\n"
	expect_or="$(whoami)\\r\\n"
	srv_stdout="$(tmp_file)"
	srv_stderr="$(tmp_file)"
	cli_stdout="$(tmp_file)"
	cli_stderr="$(tmp_file)"
	srv2_stdout="$(tmp_file)"
	srv2_stderr="$(tmp_file)"


	# --------------------------------------------------------------------------------
	# START: SERVER
	# --------------------------------------------------------------------------------
	print_h2 "(1/8) Start: Server"

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
	print_h2 "(2/8) Start: Client"

	# Start Client
	print_info "Start Client"
	# shellcheck disable=SC2086
	if ! cli_pid="$( run_bg "" "${PYTHON}" ${SCRIPTPATH}/revshell.py ${RHOST} ${RPORT} "${BANNER}" "${PREFIX1}" "${PREFIX2}" "${SUFFIX1}" "${SUFFIX2}" "${cli_stdout}" "${cli_stderr}" )"; then
		printf ""
	fi

	# Wait until Client is done
	run "sleep ${STARTUP_WAIT}"


	# --------------------------------------------------------------------------------
	# TEST: Inject shell is running
	# --------------------------------------------------------------------------------
	print_h2 "(3/8) Test: Inject shell is running"
	CURR=0
	TRIES=20
	# shellcheck disable=SC2009
	while [ "$(ps auxw | grep -v grep | grep reconn-wait | awk '{print $2}' | wc -l)" -ne "1" ]; do
		printf "."
		sleep 1
		CURR=$(( CURR + 1 ))
		if [ "${CURR}" -gt "${TRIES}" ]; then
			kill_pid "${srv_pid}" || true
			kill_pid "${cli_pid}" || true
			print_file "SERVER] - [/dev/stderr" "${srv_stderr}"
			print_file "CLIENT] - [/dev/stderr" "${cli_stderr}"
			print_file "SERVER] - [/dev/stdout" "${srv_stdout}"
			print_file "CLIENT] - [/dev/stdout" "${cli_stdout}"
			print_error "Inject shell is not running"
			exit 1
		fi
	done


	# --------------------------------------------------------------------------------
	# STOP: INSTANCES
	# --------------------------------------------------------------------------------
	print_h2 "(4/8) Stop: Instances"

	run "kill -9 ${cli_pid} || true"
	run "kill ${srv_pid} || true"


	# --------------------------------------------------------------------------------
	# START: SERVER
	# --------------------------------------------------------------------------------
	print_h2 "(5/8) Start: Server"

	# Start Server
	print_info "Start Server"
	# shellcheck disable=SC2086
	if ! srv_pid="$( run_bg "printf ${data}" "${PYTHON}" "${BINARY}" -l ${RPORT} -vvvv "${srv2_stdout}" "${srv2_stderr}" )"; then
		printf ""
	fi


	# --------------------------------------------------------------------------------
	# DATA TRANSFER
	# --------------------------------------------------------------------------------
	print_h2 "(6/8) Transfer: Server -> Client -> Server"

	# [CLIENT -> SERVER -> CLIENT]
	wait_for_data_transferred "" "${expect}" "${expect_or}" "Server" "${srv_pid}" "${srv2_stdout}" "${srv2_stderr}"


	# --------------------------------------------------------------------------------
	# TEST: Server shut down automatically
	# --------------------------------------------------------------------------------
	print_h2 "(7/8) Test: Server shut down automatically"

	# [SERVER] Ensure Server has quit automatically
	test_case_instance_is_stopped "Server" "${srv_pid}" "${srv2_stdout}" "${srv_stderr}"

	# [SERVER] Ensure Server has no errors
	test_case_instance_has_no_errors "Server" "${srv_pid}" "${srv2_stdout}" "${srv2_stderr}"


	# --------------------------------------------------------------------------------
	# CLEANUP
	# --------------------------------------------------------------------------------
	print_h2 "(8/8) Cleanup"

	run "ps auxw | grep -v grep | grep reconn-wait | awk '{print \$2}' | xargs kill"

	print_file "SERVER] - [/dev/stdout" "${srv_stdout}"
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for curr_round in $(seq "${RUNS}"); do
	#         server opts            client opts
	# BIND ON ANY
	run_test "-l ${RPORT} --self-inject /bin/sh:${RHOST}:${RPORT}    -vvvv" "${RHOST} ${RPORT} -e /bin/sh    -vvvv"  "1" "1" "${curr_round}" "${RUNS}"
done