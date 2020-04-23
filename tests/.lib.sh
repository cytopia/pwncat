#!/usr/bin/env bash
set -e
set -u
set -o pipefail


# -------------------------------------------------------------------------------------------------
# PRINT HEADLINES
# -------------------------------------------------------------------------------------------------

print_test_case() {
	local clr_clr="\\033[0;32m"   # Green
	local clr_rst="\\033[m"       # Reset to normal

	# shellcheck disable=SC2059
	printf "${clr_clr}"
	printf '#%.0s' {1..120}; echo
	printf '#%.0s' {1..120}; echo
	printf '#%.0s' {1..120}; echo
	printf '######\n'
	printf '######\n'
	printf '###### %s\n' "${1}"
	printf '######\n'
	printf '######\n'
	printf '#%.0s' {1..120}; echo
	printf '#%.0s' {1..120}; echo
	printf '#%.0s' {1..120}; echo
	# shellcheck disable=SC2059
	printf "${clr_rst}"
}

print_h1() {
	printf '#%.0s' {1..100}; echo
	printf '#%.0s' {1..100}; echo
	printf '###\n'
	printf '### %s\n' "${1}"
	printf '###\n'
	printf '#%.0s' {1..100}; echo
	printf '#%.0s' {1..100}; echo
}

print_h2() {
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
	#local clr_info="\\033[0;34m"  # Blue
	#local clr_rst="\\033[m"       # Reset to normal
	>&2 printf "[INFO] %s\\n" "${message}"
}

print_warn() {
	local message="${1}"
	local clr_warn="\\033[0;33m"  # Yello
	local clr_rst="\\033[m"       # Reset to normal
	>&2 printf "[WARN] %s\\n" "${message}"
	>&2 printf "${clr_warn}[WARN] %s${clr_rst}\\n" "${message}"
}

print_error() {
	local message="${1}"
	local clr_err="\\033[0;31m"  # Red
	local clr_rst="\\033[m"       # Reset to normal
	>&2 printf "${clr_err}[ERR]  %s${clr_rst}\\n" "${message}"
}

print_file() {
	local name="${1}"
	local file="${2}"
	local clr_div="\\033[0;33m"   # Yellow
	local clr_rst="\\033[m"       # Reset to normal

	print_h3 "[${name}] Filename: ${file}"
	printf "${clr_div}############################## %s ##############################${clr_rst}\\n" "START OF FILE"
	cat "${file}"
	printf "${clr_div}############################### %s ###############################${clr_rst}\\n" "END OF FILE"
	echo
}

print_data() {
	local name="${1}"
	local data="${2}"
	local clr_div="\\033[0;33m"  # Yellow
	local clr_rst="\\033[m"       # Reset to normal

	print_h3 "[${name}]"
	printf "${clr_div}########## %s ##########${clr_rst}\\n" "START OF DATA"
	echo "${data}"
	printf "${clr_div}########## %s ##########${clr_rst}\\n" "End OF DATA"
	echo
}


# -------------------------------------------------------------------------------------------------
# RUN FUNCTIONS
# -------------------------------------------------------------------------------------------------

run() {
	local cmd="${1}"

	local clr_cmd="\\033[0;35m"   # Purple
	local clr_ok="\\033[0;32m"    # Green
	local clr_fail="\\033[0;31m"  # Red
	local clr_rst="\\033[m"       # Reset to normal

	>&2 printf "${clr_cmd}%s${clr_rst}\\n" "${cmd}"
	if eval "${cmd}"; then
		>&2 printf "${clr_ok}%s${clr_rst}\\n" "[OK]"
		return 0
	fi
	>&2 printf "${clr_fail}%s${clr_rst}\\n" "[FAIL]"
	return 1
}

run_fail() {
	local cmd="${1}"

	local clr_cmd="\\033[0;35m"   # Purple
	local clr_ok="\\033[0;32m"    # Green
	local clr_fail="\\033[0;31m"  # Red
	local clr_rst="\\033[m"       # Reset to normal

	>&2 printf "${clr_cmd}%s${clr_rst}\\n" "${cmd}"
	if ! eval "${cmd}"; then
		>&2 printf "${clr_ok}%s${clr_rst}\\n" "[OK] (failed)"
		return 0
	fi
	>&2 printf "${clr_fail}%s${clr_rst}\\n" "[FAIL] (succeeded)"
	return 1
}

run_bg() {
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
		return 1
	fi

	>&2 printf "${clr_ok}%s${clr_rst}\\n" "[OK]"
	echo "${pid}"
	return 0
}


# -------------------------------------------------------------------------------------------------
# MISC FUNCTIONS
# -------------------------------------------------------------------------------------------------

has_errors() {
	local stderr="${1}"
	if grep -Ei 'Traceback|Exception|Error|Segfaul' "${stderr}" >/dev/null; then
		return 0
	fi
	return 1
}

kill_process() {
	local name="${1}"
	local pid=
	# shellcheck disable=SC2050
	while [ "1" -eq "1" ]; do
		# shellcheck disable=SC2009
		pid="$( ps auxw | grep -vE ' n?vim? ' | grep -v grep | grep "${name}" | head -1 | awk '{print $2}' )"
		if [ -n "${pid}" ]; then
			run "kill ${pid}"
		else
			return
		fi
	done
}

pid_is_running() {
	local the_pid="${1}"
	local out=
	# shellcheck disable=SC2009
	if [ -z "${the_pid}" ]; then
		>&2 echo "Error, 'pid_is_running()' function did not receive a pid value"
		exit 1
	fi
	# shellcheck disable=SC2009
	out="$( ps auxw | awk '{print $2}' | grep -E "^${the_pid}\$" )"
	if [ -z "${out}" ]; then
		return 1
	fi
	if [ "${the_pid}" != "${out}" ]; then
		>&2 echo "Error, 'pid_is_running()' function found a running pid different to input"
		>&2 echo "Error, input pid = ${the_pid}  != output pid = ${out}"
		exit 1
	fi
}


tmp_file() {
	# TODO: OS independent (if doesn't work on Windows)
	mktemp
}


# -------------------------------------------------------------------------------------------------
# HIGH LEVEL CHECK FUNCTIONS
# -------------------------------------------------------------------------------------------------

action_stop_instance() {
	local name="${1}"
	local pid="${2}"
	local file_stdout="${3}"
	local file_stderr="${4}"
	# Optional
	local name2="${5:-}"
	local file_stdout2="${6:-}"
	local file_stderr2="${7:-}"

	# Normal stop
	print_info "Stop ${name}"
	if ! run "kill ${pid}"; then
		if [ -n "${name2}" ]; then
			print_file "${name2} STDERR" "${file_stderr2}"
			print_file "${name2} STDOUT" "${file_stdout2}"
		fi
		print_file "${name} STDERR" "${file_stderr}"
		print_file "${name} STDOUT" "${file_stdout}"
		print_error "[Meta] Could not kill ${name} process with pid: ${pid}"
		exit 1
	fi
	for i in {1..10}; do
		if ! pid_is_running "${pid}"; then
			break
		fi
		printf "."
		sleep 1
	done
	if [ "${i}" -gt "1" ]; then
		echo
	fi

	# Stop with force
	if pid_is_running "${pid}"; then
		print_info "Stop ${name} forcefully"
		if ! run "kill -9 ${pid}"; then
			if [ -n "${name2}" ]; then
				print_file "${name2} STDERR" "${file_stderr2}"
				print_file "${name2} STDOUT" "${file_stdout2}"
			fi
			print_file "${name} STDERR" "${file_stderr}"
			print_file "${name} STDOUT" "${file_stdout}"
			print_error "[Meta] Could not kill ${name} process with pid: ${pid}"
			exit 1
		fi
		for i in {1..10}; do
			if ! pid_is_running "${pid}"; then
				break
			fi
			printf "."
			sleep 1
		done;
		if [ "${i}" -gt "1" ]; then
			echo
		fi
		if pid_is_running "${pid}"; then
			print_file "${name} STDERR" "${file_stderr}"
			print_file "${name} STDOUT" "${file_stdout}"
			print_error "[Meta] Could not kill ${name} process"
			exit 1
		fi
	fi
	return 0
}

###
### Ensure instance is started in background
###
test_case_instance_is_started_in_bg() {
	local name="${1}"
	local pid="${2}"
	local file_stdout="${3}"
	local file_stderr="${4}"
	# Optional
	local name2="${5:-}"
	local file_stdout2="${6:-}"
	local file_stderr2="${7:-}"

	print_info "Check pid"

	if [ -z "${pid}" ]; then
		if [ -n "${name2}" ]; then
			print_file "${name2} STDERR" "${file_stderr2}"
			print_file "${name2} STDOUT" "${file_stdout2}"
		fi
		print_file "${name} STDERR" "${file_stderr}"
		print_file "${name} STDOUT" "${file_stdout}"
		print_error "[${name} Error] Failed to start ${name} in background"
		exit 1
	fi

	print_info "${name} started in background with pid: ${pid}"
	return 0
}


###
### Ensure instance is still running
###
test_case_instance_is_running() {
	local name="${1}"
	local pid="${2}"
	local file_stdout="${3}"
	local file_stderr="${4}"
	# Optional
	local name2="${5:-}"
	local file_stdout2="${6:-}"
	local file_stderr2="${7:-}"

	print_info "Check ${name} is still running"

	if ! pid_is_running "${pid}"; then
		if [ -n "${name2}" ]; then
			print_file "${name2} STDERR" "${file_stderr2}"
			print_file "${name2} STDOUT" "${file_stdout2}"
		fi
		print_file "${name} STDERR" "${file_stderr}"
		print_file "${name} STDOUT" "${file_stdout}"
		print_error "[${name} Error] ${name} is not running anymore"
		run "kill ${pid} || true" 2>/dev/null
		exit 1
	fi
	return 0
}


###
### Ensure instance is stopped
###
test_case_instance_is_stopped() {
	local name="${1}"
	local pid="${2}"
	local file_stdout="${3}"
	local file_stderr="${4}"
	# Optional
	local name2="${5:-}"
	local file_stdout2="${6:-}"
	local file_stderr2="${7:-}"

	print_info "Check ${name} quitted automatically"

	local cnt=0
	local tot=10
	while pid_is_running "${pid}"; do
		printf "."
		cnt=$(( cnt + 1 ))
		if [ "${cnt}" -gt "${tot}" ]; then
			echo
			print_error "[${name} Error] Still running. Need to kill it manually by pid: ${pid}"
			run "kill ${pid} || true" 2>/dev/null
			if [ -n "${name2}" ]; then
				print_file "${name2} STDERR" "${file_stderr2}"
				print_file "${name2} STDOUT" "${file_stdout2}"
			fi
			print_file "${name} STDERR" "${file_stderr}"
			print_file "${name} STDOUT" "${file_stdout}"
			print_error "[${name} Error] ${name} did not finish after ${tot} sec"
			exit 1
		fi
		sleep 1
	done
	if [ "${cnt}" -gt "0" ]; then
		echo
	fi
	return 0
}


###
### Ensure instance has no errors
###
test_case_instance_has_no_errors() {
	local name="${1}"
	local pid="${2:-}"
	local file_stdout="${3}"
	local file_stderr="${4}"
	# Optional
	local name2="${5:-}"
	local file_stdout2="${6:-}"
	local file_stderr2="${7:-}"

	print_info "Check ${name} for errors"

	if has_errors "${file_stderr}"; then
		if [ -n "${name2}" ]; then
			print_file "${name2} STDERR" "${file_stderr2}"
			print_file "${name2} STDOUT" "${file_stdout2}"
		fi
		print_file "${name} STDERR" "${file_stderr}"
		print_file "${name} STDOUT" "${file_stdout}"
		if [ -n "${pid}" ]; then
			run "kill ${pid} || true" 2>/dev/null
		fi
		print_error "[${name} Error] Errors found in stderr"
		exit 1
	fi
}
