#!/usr/bin/env bash
set -e
set -u
set -o pipefail

# SOURCEPATH must be set by script sourcing me
# shellcheck disable=SC2034
SOURCEDIR="$( dirname "${SOURCEPATH}" )"


# -------------------------------------------------------------------------------------------------
# GLOBALS
# -------------------------------------------------------------------------------------------------


# Show newline characters as they are
cat_raw() {
	local file="${1}"
	# shellcheck disable=SC2020
	cat -ev "${1}" \
		| sed 's/\^M^M\$$/\\r\\r\\n/g' \
		| sed 's/\^M\$$/\\r\\n/g' \
		| sed 's/\$$/\\n/g' \
		| sed 's/\^M$/\\r/g' \
		| tr -d '\r\r\n' \
		| tr -d '\r\n' \
		| tr -d '\n' \
		| tr -d '\r'
}

# -------------------------------------------------------------------------------------------------
# PRINT HEADLINES
# -------------------------------------------------------------------------------------------------

print_test_case() {
	local clr_clr="\\033[0;32m"   # Green
	local clr_rst="\\033[m"       # Reset to normal

	local python="${1:-}"

	local filename=
	local filenum=
	local filedesc=

	local dirname=
	local dirnum=
	local dirmode=
	local dirtype=
	echo "${filename}"

	dirname="$( cd "$(dirname "${0}")" >/dev/null || true; basename "$(pwd -P)" || true )"
	dirnum="$( echo "${dirname}" | grep -Eo '^[0-9]+' || true )"
	dirmode="$( echo "${dirname}" | sed 's/--.*//g' | sed 's/[0-9]*-//g' || true )"
	dirtype="${dirname//*--/}"

	filename="$( basename "${0}" || true )"
	filenum="$( echo "${filename}" | grep -Eo '^[0-9]+' || true )"
	fileproto="$( echo "${filename}" | grep -Eo '\-(tcp|udp)\-' | grep -Eo 'tcp|udp' || true )"
	filedesc="$( echo "${filename}" | sed 's/.*[0-9]*-\(tcp\|udp\)---//g' | sed 's/\.sh$//g' | sed 's/---/   /g' | sed 's/_/ /g' || true )"

	# shellcheck disable=SC2059
	printf "${clr_clr}"
	printf '#%.0s' {1..120}; echo
	printf '#%.0s' {1..120}; echo
	printf '#%.0s' {1..120}; echo
	printf '######\n'
	printf '######\n'
	printf '###### [%s] [%s]: %s  -  (%s)\n' "${dirnum}" "${dirmode}" "${dirtype}" "${python}"
	printf '######\n'
	printf '######\n'
	printf '###### [%s] (%s):   %s\n' "${filenum}" "${fileproto}" "${filedesc}"
	printf '######\n'
	printf '######\n'
	printf '#%.0s' {1..120}; echo
	printf '#%.0s' {1..120}; echo
	printf '#%.0s' {1..120}; echo
	# shellcheck disable=SC2059
	printf "${clr_rst}"
}

print_h1() {
	echo;echo;
	printf '#%.0s' {1..100}; echo
	printf '#%.0s' {1..100}; echo
	printf '###\n'
	printf '### %s\n' "${1}"
	printf '###\n'
	printf '#%.0s' {1..100}; echo
	printf '#%.0s' {1..100}; echo
}

print_h2() {
	echo
	local clr_clr="\\033[0;34m"   # Blue
	local clr_rst="\\033[m"       # Reset to normal

	# shellcheck disable=SC2059
	printf "${clr_clr}"
	printf -- '*%.0s' {1..80}; echo
	printf -- '* %s\n' "${1}"
	printf -- '*%.0s' {1..80}; echo
	# shellcheck disable=SC2059
	printf "${clr_rst}"
}

print_h3() {
	local clr_clr="\\033[0;34m"   # Blue
	local clr_rst="\\033[m"       # Reset to normal

	# shellcheck disable=SC2059
	printf "${clr_clr}"
	printf -- '-%.0s' {1..60}; echo
	printf -- '%s\n' "${1}"
	printf -- '-%.0s' {1..60}; echo
	# shellcheck disable=SC2059
	printf "${clr_rst}"
}


# -------------------------------------------------------------------------------------------------
# PRINT INFO
# -------------------------------------------------------------------------------------------------

print_info() {
	local message="${1}"
	#local clr_info="\\033[0;34m" # Blue
	#local clr_rst="\\033[m"      # Reset to normal
	printf "[INFO] %s\\n" "${message}"
}

print_warn() {
	local message="${1}"
	local clr_warn="\\033[0;33m" # Yello
	local clr_rst="\\033[m"      # Reset to normal
	printf "[WARN] %s\\n" "${message}"
	printf "${clr_warn}[WARN] %s${clr_rst}\\n" "${message}"
}

print_error() {
	local message="${1}"
	local clr_err="\\033[0;31m"  # Red
	local clr_rst="\\033[m"      # Reset to normal
	printf "${clr_err}[ERR]  %s${clr_rst}\\n" "${message}"
}

print_file() {
	local name="${1}"
	local file="${2}"
	local add_str="${3:-}"       # Append some string (to compensate for missing newline)
	local clr_div="\\033[0;33m"  # Yellow
	local clr_rst="\\033[m"      # Reset to normal

	print_h3 "[${name}] Filename: ${file}"
	printf "${clr_div}############################## %s ##############################${clr_rst}\\n" "START OF FILE"
	cat "${file}"
	# shellcheck disable=SC2059
	printf "${add_str}"
	printf "${clr_div}############################### %s ###############################${clr_rst}\\n" "END OF FILE"
	printf "\\n"
}

print_data() {
	local name="${1}"
	local data="${2}"
	local add_str="${3:-}"       # Append some string (to compensate for missing newline)
	local clr_div="\\033[0;33m"  # Yellow
	local clr_rst="\\033[m"      # Reset to normal

	print_h3 "[${name}]"
	printf "${clr_div}############################## %s ##############################${clr_rst}\\n" "START OF DATA"
	# shellcheck disable=SC2059
	printf "${data}"
	# shellcheck disable=SC2059
	printf "${add_str}"
	printf "${clr_div}############################### %s ###############################${clr_rst}\\n" "END OF DATA"
	printf "\\n"
}

print_file_raw() {
	local name="${1}"
	local file="${2}"
	local quote="${3:-0}"
	local clr_div="\\033[0;33m"  # Yellow
	local clr_rst="\\033[m"      # Reset to normal

	print_h3 "[${name}] Filename: ${file}"
	printf "${clr_div}############################ %s ############################${clr_rst}\\n" "START OF FILE (RAW) "
	if [ "${quote}" == "1"  ]; then
		printf "'%s'\\n" "$(cat_raw "${file}")"
	else
		printf "%s\\n" "$(cat_raw "${file}")"
	fi
	printf "${clr_div}############################ %s ###########################${clr_rst}\\n" "START OF FILE (CTRL) "
	if [ "${quote}" == "1"  ]; then
		printf "'%s'\\n" "$(cat -ev "${file}")"
	else
		printf "%s\\n" "$(cat -ev "${file}")"
	fi
	printf "${clr_div}############################### %s ###############################${clr_rst}\\n" "END OF FILE"
	printf "\\n"
}

print_data_raw() {
	local name="${1}"
	local data="${2}"
	local quote="${3:-0}"
	local add_str="${3:-}"       # Append some string (to compensate for missing newline)
	local clr_div="\\033[0;33m"  # Yellow
	local clr_rst="\\033[m"      # Reset to normal

	print_h3 "[${name}]"
	printf "${clr_div}############################## %s ##############################${clr_rst}\\n" "START OF DATA"
	if [ "${quote}" == "1"  ]; then
		printf "'%s'\\n" "${data}"
	else
		printf "%s\\n" "${data}"
	fi
	printf "${clr_div}############################### %s ###############################${clr_rst}\\n" "END OF DATA"
	printf "\\n"
}


readonly PRINT_TEST_DATETIME_INIT_START_SEC="$( date '+%s' )"  # The first test started
PRINT_TEST_DATETIME_TEST_START_SEC=0
PRINT_TEST_DATETIME_TEST_COUNT_NUM=0
print_test_datetime() {
	local now_date=
	local now_sec=0
	local curr_round=0   # time in seconds for current round
	local all_rounds=0   # time in seconds for all rounds

	now_date="$( date )"
	now_sec="$( date '+%s' )"

	>&2 printf -- '-%.0s' {1..80}

	# Test starte
	if [ "$(( PRINT_TEST_DATETIME_TEST_COUNT_NUM % 2 ))" -eq "0" ]; then
		PRINT_TEST_DATETIME_TEST_START_SEC="${now_sec}"
		>&2 printf "[TEST START]: %s" "${now_date}"
	# Test finished
	else
		curr_round=$(( now_sec - PRINT_TEST_DATETIME_TEST_START_SEC ))
		all_rounds=$(( now_sec - PRINT_TEST_DATETIME_INIT_START_SEC ))
		>&2 printf "[TEST DONE]:  %s (curr: %s sec) (total: %s sec)" "${now_date}" "${curr_round}" "${all_rounds}"
	fi
	>&2 echo
	PRINT_TEST_DATETIME_TEST_COUNT_NUM=$(( PRINT_TEST_DATETIME_TEST_COUNT_NUM + 1 ))
}

readonly PRINT_RUN_DATETIME_INIT_START_SEC="$( date '+%s' )"  # The first test started
PRINT_RUN_DATETIME_TEST_START_SEC=0
PRINT_RUN_DATETIME_TEST_COUNT_NUM=0
print_run_datetime() {
	local now_date=
	local now_sec=0
	local curr_round=0   # time in seconds for current round
	local all_rounds=0   # time in seconds for all rounds

	now_date="$( date )"
	now_sec="$( date '+%s' )"

	>&2 printf -- '.%.0s' {1..60}

	# Test starte
	if [ "$(( PRINT_RUN_DATETIME_TEST_COUNT_NUM % 2 ))" -eq "0" ]; then
		PRINT_RUN_DATETIME_TEST_START_SEC="${now_sec}"
		>&2 printf "[RUN START]"
	# Test finished
	else
		curr_round=$(( now_sec - PRINT_RUN_DATETIME_TEST_START_SEC ))
		all_rounds=$(( now_sec - PRINT_RUN_DATETIME_INIT_START_SEC ))
		>&2 printf "[RUN DONE] (%s sec)" "${curr_round}"
	fi
	>&2 echo
	PRINT_RUN_DATETIME_TEST_COUNT_NUM=$(( PRINT_RUN_DATETIME_TEST_COUNT_NUM + 1 ))
}

# -------------------------------------------------------------------------------------------------
# LOW LEVEL FUNCTIONS
# -------------------------------------------------------------------------------------------------

###
### Check file for errors
###
has_errors() {
	local stderr="${1}"
	local reg_ignore_err="${2:-}"

	local errors=0

	if [ ! -f "${stderr}" ]; then
		>&2 echo "[Assert Error] 'has_errors()' did not receive a valid file: ${stderr}"
		exit 1
	fi

	# Stuff the Python logging.Logger is producing
	if [ -n "${reg_ignore_err}" ]; then
		if ! run_fail "grep -Eiv '${reg_ignore_err}' '${stderr}' | grep -E 'FATAL|ERROR' >/dev/null"; then
			return 0  # Successful return means it has errors
		fi
	else
		if ! run_fail "grep -E 'FATAL|ERROR' ${stderr} >/dev/null"; then
			return 0  # Successful return means it has errors
		fi
	fi

	# Other stuff that might pop up. Note that greping for 'Error' case-insensitive
	# might yield false positives due to all the caught exception messages that may
	# contain the word 'Error' or a combination of it.
	if [ -n "${reg_ignore_err}" ]; then
		if ! run_fail "grep -Eiv '${reg_ignore_err}' '${stderr}' | grep -Ei 'Traceback|Exception|Segfaul|Fatal|Syntax' ${stderr} >/dev/null"; then
			return 0  # Successful return means it has errors
		fi
	else
		if ! run_fail "grep -Ei 'Traceback|Exception|Segfaul|Fatal|Syntax' ${stderr} >/dev/null"; then
			return 0  # Successful return means it has errors
		fi
	fi
	return 1
}

###
### Check file has no errors
###
has_no_errors() {
	local stderr="${1}"
	local errors=0

	if [ ! -f "${stderr}" ]; then
		>&2 echo "[Assert Error] 'has_errors()' did not receive a valid file: ${stderr}"
		exit 1
	fi

	# Stuff the Python logger is producing
	if ! run_fail "grep -E 'FATAL|ERROR' ${stderr} >/dev/null"; then
		errors=$(( errors + 1 ))
	fi

	# Other stuff that might pop up. Note that greping for 'Error' case-insensitive
	# might yield false positives due to all the caught exception messages that may
	# contain the word 'Error' or a combination of it.
	if ! run_fail "grep -Ei 'Traceback|Exception|Segfaul|Fatal|Syntax' ${stderr} >/dev/null"; then
		errors=$(( errors + 1 ))
	fi
	return ${errors}
}

###
### Check if pid is running
###
pid_is_running() {
	local pid="${1}"

	if [ -z "${pid}" ]; then
		>&2 echo "[Assert Error] 'pid_is_running()' function did not receive a pid value"
		exit 1
	fi

	# Try different methods to determine if it is running
	if run "kill -0 ${pid}"; then
		return 0
	fi
	if run "ps -p ${pid}"; then
		return 0
	fi
	return 1
}

###
### Check if pid is running
###
pid_is_not_running() {
	local pid="${1}"
	local running=0

	if [ -z "${pid}" ]; then
		>&2 echo "[Assert Error] 'pid_is_running()' function did not receive a pid value"
		exit 1
	fi

	# Both methods should not succeed (in case on does not exist anyway)

	# Command not found or "not running"
	if run_fail "kill -0 ${pid}"; then
		running=$(( running + 1 ))
	fi
	# Command not found or "not running"
	if run_fail "ps -p ${pid}"; then
		running=$(( running + 1 ))
	fi

	# Two confirmations
	if [ "${running}" == "2" ]; then
		return 0
	fi

	return 1
}

###
### Stop pid gracefully
###
stop_pid() {
	local pid="${1}"

	if [ -z "${pid}" ]; then
		>&2 echo "[Assert Error] 'stop_pid()' function did not receive a pid value"
		exit 1
	fi

	if ! run "kill ${pid}"; then
		return 1
	fi

	# Ensure it was really stopped
	if pid_is_not_running "${pid}"; then
		return 0
	fi

	# Give it some time to shutdown gracefully
	for i in {1..10}; do
		if pid_is_not_running "${pid}"; then
			return 0
		fi
		sleep 1
	done

	# Nope, still running
	return 1
}

###
### Kill pid with force
###
kill_pid() {
	local pid="${1}"

	if [ -z "${pid}" ]; then
		>&2 echo "[Assert Error] 'kill_pid()' function did not receive a pid value"
		exit 1
	fi

	if ! run "kill -9 ${pid}"; then
		return 1
	fi

	# Ensure it was really stopped
	if ! pid_is_running "${pid}"; then
		return 0
	fi

	# Give it some time to shutdown gracefully
	# shellcheck disable=SC2034
	for i in {1..10}; do
		if ! pid_is_running "${pid}"; then
			return 0
		fi
		run "kill -9 ${pid} || true"
		sleep 1
	done

	# Nope, still running
	return 1
}

###
### Create tmpfile wrapper
###
tmp_file() {
	# Just in case it needs to be adjusted everywhere
	mktemp
}


# -------------------------------------------------------------------------------------------------
# RUN FUNCTIONS
# -------------------------------------------------------------------------------------------------

###
### Run a command in foreground
###
run() {
	print_run_datetime
	local cmd="${1}"

	local clr_cmd="\\033[0;35m"   # Purple
	local clr_ok="\\033[0;32m"    # Green
	local clr_fail="\\033[0;31m"  # Red
	local clr_rst="\\033[m"       # Reset to normal

	printf "${clr_cmd}%s${clr_rst}\\n" "${cmd}"
	if eval "${cmd}"; then
		printf "${clr_ok}%s${clr_rst}\\n" "[OK]"
		print_run_datetime
		return 0
	fi
	printf "${clr_fail}%s${clr_rst}\\n" "[FAIL]"
	print_run_datetime
	return 1
}

###
### Run a command in foreground and ensure it failed
###
run_fail() {
	print_run_datetime
	local cmd="${1}"

	local clr_cmd="\\033[0;35m"   # Purple
	local clr_ok="\\033[0;32m"    # Green
	local clr_fail="\\033[0;31m"  # Red
	local clr_rst="\\033[m"       # Reset to normal

	>&2 printf "${clr_cmd}%s${clr_rst}\\n" "${cmd}"
	if ! eval "${cmd}"; then
		>&2 printf "${clr_ok}%s${clr_rst}\\n" "[OK] (failed - was supposed to fail)"
		print_run_datetime
		return 0
	fi
	>&2 printf "${clr_fail}%s${clr_rst}\\n" "[FAIL] (succeeded - was supposed to fail)"
	print_run_datetime
	return 1
}

###
### Run a command in background and return its pid
###
run_bg() {
	print_test_datetime
	local pipe="${1}"
	shift
	local index_stdout=$(( ${#} - 2 ))
	local index_stderr=$(( ${#} - 1 ))

	local stdout=
	local stderr=
	local cnt=0
	for arg in "${@}"; do
		if [ "${cnt}" -eq "${index_stdout}" ]; then
			stdout="${arg}"
		fi
		if [ "${cnt}" -eq "${index_stderr}" ]; then
			stderr="${arg}"
		fi
		cnt=$(( cnt + 1 ))
	done

	# Remove last two arguments
	set -- "${@:1:$(($#-1))}"
	set -- "${@:1:$(($#-1))}"

	local clr_cmd="\\033[0;35m"   # Purple
	local clr_ok="\\033[0;32m"    # Green
	local clr_fail="\\033[0;31m"  # Red
	local clr_rst="\\033[m"       # Reset to normal
	local pid

	# Piped command
	if [ -n "${pipe}" ]; then
		>&2 printf "${clr_cmd}%s | %s${clr_rst}\\n" "${pipe}" "${*} > ${stdout} 2> ${stderr}"
		${pipe} | "${@}"  > "${stdout}" 2> "${stderr}" &
		pid="${!:-}"
	# Normal command
	else
		>&2 printf "${clr_cmd}%s${clr_rst}\\n" "${*} > ${stdout} 2> ${stderr}"
		"${@}" > "${stdout}" 2> "${stderr}" &
		pid="${!:-}"
	fi

	# Check PID
	if [ -z "${pid}" ]; then
		>&2 printf "${clr_fail}%s${clr_rst}\\n" "[FAIL]"
		print_test_datetime
		return 1
	fi

	>&2 printf "${clr_ok}%s${clr_rst}\\n" "[OK]"
	echo "${pid}"
	print_test_datetime
	return 0
}


# -------------------------------------------------------------------------------------------------
# HIGH LEVEL CHECK FUNCTIONS    -    they will automatically exit the script!!!
# -------------------------------------------------------------------------------------------------

###
###
###
wait_for_data_transferred() {
	print_test_datetime
	local expect_regex="${1}"
	local expect_data="${2}"
	# If not empty, will be OR'ed with expect_data. This is useful/required
	# to overcome different newlines on OS \n vs \r\n. So when not testing against
	# newlines, we will OR the data to ignore newline changes.
	local expect_data_or="${3}"

	local recv_name="${4}"
	local recv_pid="${5}"
	local recv_file_stdout="${6}"
	local recv_file_stderr="${7}"

	local send_name="${8:-}"
	local send_pid="${9:-}"
	local send_file_stdout="${10:-}"
	local send_file_stderr="${11:-}"

	# ASSERTS
	if [ -n "${send_name}" ]; then
		if [ -z "${send_pid}" ] || [ -z "${send_file_stdout}" ] || [ -z "${send_file_stderr}" ]; then
			print_error "[Meta] (wait_for_data_transferred(): send_pid, send_file_stdout or send_file_stderr  not specified."
			print_test_datetime
			exit 1
		fi
	fi

	if [ -n "${send_name}" ]; then
		print_info "Wait for data transferred (${send_name} -> ${recv_name})"
	else
		print_info "Wait for data transferred on ${recv_name}"
	fi

	local cnt=0
	local retry=20

	# 1/2 Validate transfer against regex
	if [ -n "${expect_regex}" ]; then
		while ! grep -E "${expect_regex}" "${recv_file_stdout}" >/dev/null; do
			printf "."
			cnt=$(( cnt + 1 ))
			if [ "${cnt}" -gt "${retry}" ]; then
				echo
				if [ -n "${send_name}" ]; then
					print_file "SENDER] [${send_name}] - [/dev/stdout" "${send_file_stdout}"
					print_file "SENDER] [${send_name}] - [/dev/stderr" "${send_file_stderr}"
				fi
				print_file "RECVER] [${recv_name}] - [/dev/stderr" "${recv_file_stderr}"
				echo
				print_data "EXPECT] [${recv_name}] - [REG" "${expect_regex}"
				print_file "RECVER] [${recv_name}] - [RAW" "${recv_file_stdout}"
				print_data "RECVER] [${recv_name}] - [HEX" "$( od -c "${recv_file_stdout}" )" "\\n"
				echo
				if [ -n "${send_name}" ]; then
					print_error "[Receive Error] Received data on ${recv_name} does not match send data from ${send_name}."
				else
					print_error "[Receive Error] Received data on ${recv_name} does not match expected data."
				fi
				kill_pid "${send_pid}" || true
				kill_pid "${recv_pid}" || true
				print_test_datetime
				exit 1
			fi
			sleep 1
		echo
		done
	# 2/3 Check against exact match or exact other match of expected vs received (\r\n vs \n)
	elif [ -n "${expect_data_or}" ]; then
	# 3/3 Check against exact match of expected vs received
		# shellcheck disable=SC2059
		while ! diff  \
			<(printf "${expect_data}" | od -c) \
			<(od -c "${recv_file_stdout}") >/dev/null \
			&& ! diff \
			<(printf "${expect_data_or}" | od -c) \
			<(od -c "${recv_file_stdout}") >/dev/null; do
			printf "."
			cnt=$(( cnt + 1 ))
			if [ "${cnt}" -gt "${retry}" ]; then
				echo
				if [ -n "${send_name}" ]; then
					print_file "SENDER] [${send_name}] - [/dev/stdout" "${send_file_stdout}"
					print_file "SENDER] [${send_name}] - [/dev/stderr" "${send_file_stderr}"
				fi
				print_file "RECVER] [${recv_name}] - [/dev/stderr" "${recv_file_stderr}"
				echo
				print_data_raw "EXPCT1] [${recv_name}] - [RAW" "${expect_data}" 1
				print_data_raw "EXPCT2] [${recv_name}] - [RAW" "${expect_data_or}" 1
				print_file_raw "RECVER] [${recv_name}] - [RAW" "${recv_file_stdout}" 1
				echo
				print_data_raw "EXPCT1] [${recv_name}] - [HEX" "$( printf "${expect_data}" | od -c )"
				print_data_raw "EXPCT2] [${recv_name}] - [HEX" "$( printf "${expect_data_or}" | od -c )"
				print_data_raw "RECVER] [${recv_name}] - [HEX" "$( od -c "${recv_file_stdout}" )"
				# Show some diff's
				echo '---------- diff <(printf expect | od -c) <(cat file_stdout | od -c) ----------'
				# shellcheck disable=SC2002
				diff <(printf "${expect_data}" | od -c) <(cat "${recv_file_stdout}" | od -c) || true

				echo '---------- diff <(printf expect_or | od -c) <(cat file_stdout | od -c) ----------'
				# shellcheck disable=SC2002
				diff <(printf "${expect_data_or}" | od -c) <(cat "${recv_file_stdout}" | od -c) || true

				echo '---------- diff <(printf expect | od -c) <(od -c file_stdout) ----------'
				diff <(printf "${expect_data}" | od -c) <(od -c "${recv_file_stdout}") || true

				echo '---------- diff <(printf expect_or | od -c) <(od -c file_stdout) ----------'
				diff <(printf "${expect_data_or}" | od -c) <(od -c "${recv_file_stdout}") || true

				echo '---------- diff <(printf expect) file_stdout ----------'
				diff <(printf "${expect_data}") "${recv_file_stdout}" || true

				echo '---------- diff <(printf expect_or) file_stdout ----------'
				diff <(printf "${expect_data_or}") "${recv_file_stdout}" || true

				echo
				if [ -n "${send_name}" ]; then
					print_error "[Receive Error] Received data on ${recv_name} does not match send data from ${send_name}."
				else
					print_error "[Receive Error] Received data on ${recv_name} does not match expected data."
				fi
				kill_pid "${send_pid}" || true
				kill_pid "${recv_pid}" || true
				print_test_datetime
				exit 1
			fi
			sleep 1
		done
		print_data_raw "EXPCT1] [${recv_name}] - [RAW" "${expect_data}" 1
		print_data_raw "EXPCT2] [${recv_name}] - [RAW" "${expect_data_or}" 1
		# shellcheck disable=SC2059
		print_data_raw "EXPCT1] [${recv_name}] - [HEX" "$( printf "${expect_data}" | od -c )"
		# shellcheck disable=SC2059
		print_data_raw "EXPCT2] [${recv_name}] - [HEX" "$( printf "${expect_data_or}" | od -c )"
		echo
	else
		# shellcheck disable=SC2059
		while ! diff  \
			<(printf "${expect_data}" | od -c) \
			<(od -c "${recv_file_stdout}") >/dev/null; do
			printf "."
			cnt=$(( cnt + 1 ))
			if [ "${cnt}" -gt "${retry}" ]; then
				echo
				if [ -n "${send_name}" ]; then
					print_file "SENDER] [${send_name}] - [/dev/stdout" "${send_file_stdout}"
					print_file "SENDER] [${send_name}] - [/dev/stderr" "${send_file_stderr}"
				fi
				print_file "RECVER] [${recv_name}] - [/dev/stderr" "${recv_file_stderr}"
				echo
				print_data_raw "EXPECT] [${recv_name}] - [RAW" "${expect_data}" 1
				print_file_raw "RECVER] [${recv_name}] - [RAW" "${recv_file_stdout}" 1
				echo
				print_data_raw "EXPECT] [${recv_name}] - [HEX" "$( printf "${expect_data}" | od -c )"
				print_data_raw "RECVER] [${recv_name}] - [HEX" "$( od -c "${recv_file_stdout}" )"
				# Show some diff's
				echo '---------- diff <(printf expect | od -c) <(cat file_stdout | od -c) ----------'
				# shellcheck disable=SC2002
				diff <(printf "${expect_data}" | od -c) <(cat "${recv_file_stdout}" | od -c) || true
				echo '---------- diff <(printf expect | od -c) <(od -c file_stdout) ----------'
				diff <(printf "${expect_data}" | od -c) <(od -c "${recv_file_stdout}") || true
				echo '---------- diff <(printf expect) file_stdout ----------'
				diff <(printf "${expect_data}") "${recv_file_stdout}" || true

				echo
				if [ -n "${send_name}" ]; then
					print_error "[Receive Error] Received data on ${recv_name} does not match send data from ${send_name}."
				else
					print_error "[Receive Error] Received data on ${recv_name} does not match expected data."
				fi
				kill_pid "${send_pid}" || true
				kill_pid "${recv_pid}" || true
				print_test_datetime
				exit 1
			fi
			sleep 1
		done
		print_data_raw "EXPECT] [${recv_name}] - [RAW" "${expect_data}" 1
		# shellcheck disable=SC2059
		print_data_raw "EXPECT] [${recv_name}] - [HEX" "$( printf "${expect_data}" | od -c )"
		echo
	fi
	print_file     "RECVER] [${recv_name}] - [/dev/stderr" "${recv_file_stderr}"
	print_file_raw "RECVER] [${recv_name}] received - [RAW" "${recv_file_stdout}" 1
	print_data_raw "RECVER] [${recv_name}] received - [HEX" "$( od -c "${recv_file_stdout}" )"
	# shellcheck disable=SC2002
	print_data_raw "RECVER] [${recv_name}] received - [HEX" "$( cat "${recv_file_stdout}" | od -c )"
	print_test_datetime
}



###
### Stop instance gratefully, or kill and exit
###
action_stop_instance() {
	print_test_datetime
	local name="${1}"
	local pid="${2}"
	local file_stdout="${3}"
	local file_stderr="${4}"
	# Optional
	local name2="${5:-}"
	local pid2="${6:-}"
	local file_stdout2="${7:-}"
	local file_stderr2="${8:-}"

	# ASSERTS
	if [ -n "${name2}" ]; then
		if [ -z "${pid2}" ] || [ -z "${file_stdout2}" ] || [ -z "${file_stderr2}" ]; then
			print_error "[Meta] (action_stop_instance(): pid2, stdout2 or stderr2  not specified."
			print_test_datetime
			exit 1
		fi
	fi

	# (1/3) Normal stop
	print_info "Stopping ${name} gracefully (pid: ${pid})..."
	if stop_pid "${pid}"; then
		print_test_datetime
		return 0
	fi

	# (2/3) Show info after graceful stop attempt
	if [ -n "${name2}" ]; then
		print_file "${name2} STDERR" "${file_stderr2}"
		print_file "${name2} STDOUT" "${file_stdout2}"
	fi
	print_file "${name} STDERR" "${file_stderr}"
	print_file "${name} STDOUT" "${file_stdout}"
	print_error "[Meta] Could not stop ${name} process with pid: ${pid}"

	# (3/3) Kill with force and cleanup
	kill_pid "${pid}" || true
	if [ -n "${name2}" ]; then
		kill_pid "${pid2}" || true
		print_file "${name2} STDERR" "${file_stderr2}"
		print_file "${name2} STDOUT" "${file_stdout2}"
	fi
	print_file "${name} STDERR" "${file_stderr}"
	print_file "${name} STDOUT" "${file_stdout}"
	print_error "[Meta] Could not stop ${name} gracefully process with pid: ${pid}"
	print_test_datetime
	exit 1
}


###
### Ensure instance is running
###
test_case_instance_is_running() {
	print_test_datetime
	local name="${1}"
	local pid="${2}"
	local file_stdout="${3}"
	local file_stderr="${4}"
	# Optional
	local name2="${5:-}"
	local pid2="${6:-}"
	local file_stdout2="${7:-}"
	local file_stderr2="${8:-}"

	# ASSERTS
	if [ -n "${name2}" ]; then
		if [ -z "${pid2}" ] || [ -z "${file_stdout2}" ] || [ -z "${file_stderr2}" ]; then
			print_error "[Meta] (test_case_instance_is_running(): pid2, stdout2 or stderr2  not specified."
			print_test_datetime
			exit 1
		fi
	fi

	print_info "Check ${name} is running (pid: ${pid}) ..."

	if pid_is_running "${pid}"; then
		print_info "${name} is running with pid: ${pid}"
		print_test_datetime
		return 0
	fi

	if [ -n "${name2}" ]; then
		print_file "${name2} STDERR" "${file_stderr2}"
		print_file "${name2} STDOUT" "${file_stdout2}"
	fi
	print_file "${name} STDERR" "${file_stderr}"
	print_file "${name} STDOUT" "${file_stdout}"
	print_error "[${name} Error] Failed to start ${name} in background"

	# cleanup
	if [ -n "${name2}" ]; then
		kill_pid "${pid2}" || true
	fi
	print_test_datetime
	exit 1
}


###
### Ensure instance is stopped
###
test_case_instance_is_stopped() {
	print_test_datetime
	local name="${1}"
	local pid="${2}"
	local file_stdout="${3}"
	local file_stderr="${4}"
	# Optional
	local name2="${5:-}"
	local pid2="${6:-}"
	local file_stdout2="${7:-}"
	local file_stderr2="${8:-}"

	# ASSERTS
	if [ -n "${name2}" ]; then
		if [ -z "${pid2}" ] || [ -z "${file_stdout2}" ] || [ -z "${file_stderr2}" ]; then
			print_error "[Meta] (test_case_instance_is_stopped(): pid2, stdout2 or stderr2  not specified."
			print_test_datetime
			exit 1
		fi
	fi

	print_info "Check ${name} has stopped (pid: ${pid}) ..."

	# Give it some time to shutdown gracefully
	# shellcheck disable=SC2034
	for i in {1..10}; do
		if pid_is_not_running "${pid}"; then
			print_test_datetime
			return 0
		fi
		sleep 1
	done

	# Show logs
	if [ -n "${name2}" ]; then
		print_file "${name2} STDERR" "${file_stderr2}"
		print_file "${name2} STDOUT" "${file_stdout2}"
	fi
	print_file "${name} STDERR" "${file_stderr}"
	print_file "${name} STDOUT" "${file_stdout}"
	print_error "[${name} Error] ${name} is not stopped"

	# cleanup
	kill_pid "${pid}" || true
	if [ -n "${name2}" ]; then
		kill_pid "${pid2}" || true
	fi
	print_test_datetime
	exit 1
}


###
### Ensure instance has no errors
###
test_case_instance_has_no_errors() {
	print_test_datetime
	# This is a mysterious bash error. We need to somehow use these parameters
	# in case only 1,2,3,4 and 9 are specified... no idea why. But this way the 9th
	# parameter will have a value as it is supposed to be
	set +u
	echo "1: ${1}"  >/dev/null
	echo "2: ${2}"  >/dev/null
	echo "3: ${3}"  >/dev/null
	echo "4: ${4}"  >/dev/null
	echo "5: ${5}"  >/dev/null
	echo "6: ${6}"  >/dev/null
	echo "7: ${7}"  >/dev/null
	echo "8: ${8}"  >/dev/null
	echo "9: ${9}"  >/dev/null
	set -u

	local name="${1}"
	local pid="${2:-}"
	local file_stdout="${3}"
	local file_stderr="${4}"
	# Optional
	local name2="${5:-}"
	local pid2="${6:-}"
	local file_stdout2="${7:-}"
	local file_stderr2="${8:-}"

	local reg_ignore_err="${9:-}"


	# ASSERTS
	if [ -n "${name2}" ]; then
		if [ -z "${pid2}" ] || [ -z "${file_stdout2}" ] || [ -z "${file_stderr2}" ]; then
			print_error "[Meta] (test_case_instance_has_no_errors(): pid2, stdout2 or stderr2  not specified."
			print_test_datetime
			exit 1
		fi
	fi

	if [ -n "${reg_ignore_err}" ]; then
		print_info "Check ${name} for errors (except: '${reg_ignore_err}')"
	else
		print_info "Check ${name} for errors"
	fi

	if ! has_errors "${file_stderr}" "${reg_ignore_err}"; then
		print_test_datetime
		return 0
	fi

	if [ -n "${name2}" ]; then
		print_file "${name2} STDERR" "${file_stderr2}"
		print_file "${name2} STDOUT" "${file_stdout2}"
	fi
	print_file "${name} STDERR" "${file_stderr}"
	print_file "${name} STDOUT" "${file_stdout}"
	print_error "[${name} Error] Errors found in stderr"

	# cleanup
	kill_pid "${pid}" || true
	if [ -n "${name2}" ]; then
		kill_pid "${pid2}" || true
	fi
	print_test_datetime
	exit 1
}

###
### Ensure instance does have errors
###
test_case_instance_has_errors() {
	print_test_datetime
	local name="${1}"
	local pid="${2:-}"
	local file_stdout="${3}"
	local file_stderr="${4}"
	# Optional
	local name2="${5:-}"
	local pid2="${6:-}"
	local file_stdout2="${7:-}"
	local file_stderr2="${8:-}"

	# ASSERTS
	if [ -n "${name2}" ]; then
		if [ -z "${pid2}" ] || [ -z "${file_stdout2}" ] || [ -z "${file_stderr2}" ]; then
			print_error "[Meta] (test_case_instance_has_errors(): pid2, stdout2 or stderr2  not specified."
			print_test_datetime
			exit 1
		fi
	fi

	print_info "Check ${name} for errors"

	if ! has_no_errors "${file_stderr}"; then
		print_test_datetime
		return 0
	fi

	if [ -n "${name2}" ]; then
		print_file "${name2} STDERR" "${file_stderr2}"
		print_file "${name2} STDOUT" "${file_stdout2}"
	fi
	print_file "${name} STDERR" "${file_stderr}"
	print_file "${name} STDOUT" "${file_stdout}"
	print_error "[${name} Error] Errors found in stderr"

	# cleanup
	kill_pid "${pid}" || true
	if [ -n "${name2}" ]; then
		kill_pid "${pid2}" || true
	fi
	print_test_datetime
	exit 1
}
