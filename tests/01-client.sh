#!/usr/bin/env bash

set -e
set -u
set -o pipefail


SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
BINARY="${SCRIPTPATH}/../bin/pwncat"

###
### 2 or 3
###
PYTHON="${1}"
python -V

# -------------------------------------------------------------------------------------------------
# ENTRYPOINT
# -------------------------------------------------------------------------------------------------

run() {
	local verbosity="${1}"
	stdout="$(mktemp)"
	stderr="$(mktemp)"
	ret=0

	command="echo 'HEAD /' | python${PYTHON} ${BINARY} ${verbosity} www.google.de 80 > ${stdout} 2> ${stderr}"

	echo "################################################################################"
	echo "################################################################################"
	echo "###"
	echo "### ${command}"
	echo "###"
	echo "################################################################################"
	echo "################################################################################"
	echo
	echo
	if ! eval "${command}"; then
		echo "Failed to execute eval command"
		ret=1
	fi

	echo "# ----------------------------------------------------------"
	echo "# STDOUT"
	echo "# ----------------------------------------------------------"
	cat "${stdout}"
	echo

	echo "# ----------------------------------------------------------"
	echo "# STDERR"
	echo "# ----------------------------------------------------------"
	cat "${stderr}"
	echo

	if grep -Ei 'Traceback|Exception' "${stderr}" >/dev/null; then
		ret=1
	fi

	if [ "${ret}" -eq "1" ]; then
		exit 1
	fi
}


VERBOSITY=""
run "${VERBOSITY}"

VERBOSITY="-v"
run "${VERBOSITY}"

VERBOSITY="-vv"
run "${VERBOSITY}"

VERBOSITY="-vvv"
run "${VERBOSITY}"

VERBOSITY="-vvvv"
run "${VERBOSITY}"

VERBOSITY="-vvvvv"
run "${VERBOSITY}"
