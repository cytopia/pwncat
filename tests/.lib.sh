#!/usr/bin/env bash
set -e
set -u
set -o pipefail

tmp_file() {
	# TODO: OS independent
	mktemp
}


# -------------------------------------------------------------------------------------------------
# PRINT HEADLINES
# -------------------------------------------------------------------------------------------------

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
	printf -- '*%.0s' {1..80}; echo
	printf -- '* %s\n' "${1}"
	printf -- '*%.0s' {1..80}; echo
}

print_h3() {
	printf -- '-%.0s' {1..60}; echo
	printf -- '- %s\n' "${1}"
	printf -- '-%.0s' {1..60}; echo
}


# -------------------------------------------------------------------------------------------------
# PRINT INFO
# -------------------------------------------------------------------------------------------------

print_info() {
	local info="${1}"
	local clr_blue="\\033[0;34m"  # Blue
	local clr_rst="\\033[m"       # Reset to normal
	>&2 printf "${clr_blue}%s${clr_rst}\\n" "${info}"
}

print_file() {
	local name="${1}"
	local file="${2}"
	print_h3 "[${name}]: ${file}"
	echo "########## START OF FILE ##########"
	cat "${file}"
	echo "########## END OF FILE ##########"
	echo
}

print_data() {
	local name="${1}"
	local data="${2}"
	print_h3 "[${name}]"
	echo "########## START OF FILE ##########"
	echo "${data}"
	echo "########## END OF FILE ##########"
	echo
}


# -------------------------------------------------------------------------------------------------
# RUN FUNCTIONS
# -------------------------------------------------------------------------------------------------

run() {
	local cmd="${1}"

	local clr_cmd="\\033[0;33m"  # Yellow
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
