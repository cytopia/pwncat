#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
SOURCEPATH="${SCRIPTPATH}/../../.lib/conf.sh"
COMPOSEDIR="${SCRIPTPATH}/"
# shellcheck disable=SC1090
source "${SOURCEPATH}"


# -------------------------------------------------------------------------------------------------
# SETTINGS
# -------------------------------------------------------------------------------------------------
WAIT_STARTUP=7
WAIT_SHUTDOWN=20
NAME1="scanner"

# -------------------------------------------------------------------------------------------------
# CHECKS
# -------------------------------------------------------------------------------------------------

COMPOSE=""
PYTHON_VERSION="${1:-3.8}"
COMPOSEDIR="${SCRIPTPATH}/${COMPOSE}"

if [ ! -f "${COMPOSEDIR}/docker-compose.yml" ]; then
	print_error "docker-compose.yml not found in: ${COMPOSEDIR}/docker-compose.yml."
	exit 1
fi
if ! command -v docker >/dev/null 2>&1; then
	print_error "docker binary not found, but required."
	exit 1
fi
if ! command -v docker-compose >/dev/null 2>&1; then
	print_error "docker-compose binary not found, but required."
	exit 1
fi


# -------------------------------------------------------------------------------------------------
# APPLY VERSION
# -------------------------------------------------------------------------------------------------

echo "PYTHON_VERSION=${PYTHON_VERSION}" > "${COMPOSEDIR}/.env"
print_test_case "Python ${PYTHON_VERSION}"


# -------------------------------------------------------------------------------------------------
# GET ARTIFACTS
# -------------------------------------------------------------------------------------------------
print_h2 "(1/5) Get artifacts"

cd "${COMPOSEDIR}"

# shellcheck disable=SC2050
while [ "1" -eq "1" ]; do
	if run "docker-compose pull"; then
		break
	fi
	sleep 1
done


# -------------------------------------------------------------------------------------------------
# CLEAN UP
# -------------------------------------------------------------------------------------------------
print_h2 "(1/5) Stopping Docker Compose"

run "docker-compose kill || true 2>/dev/null"
run "docker-compose rm -f || true 2>/dev/null"


# -------------------------------------------------------------------------------------------------
# START
# -------------------------------------------------------------------------------------------------
print_h2 "(2/5) Starting compose"

cd "${COMPOSEDIR}"
run "docker-compose up -d"
run "sleep ${WAIT_STARTUP}"


# -------------------------------------------------------------------------------------------------
# VALIDATE
# -------------------------------------------------------------------------------------------------
print_h2 "(3/5) Validate running"

if ! run "docker-compose ps --filter 'status=running' --services | grep ${NAME1}"; then
	run "docker-compose logs"
	run "docker-compose ps"
	run "docker-compose exec $( tty -s && echo || echo '-T' ) ${NAME1} ps || true"
	run "docker-compose kill  || true 2>/dev/null"
	run "docker-compose rm -f || true 2>/dev/null"
	print_error "Server is not running"
	exit 1
fi

run "docker-compose exec $( tty -s && echo || echo '-T' ) ${NAME1} ps || true"


# -------------------------------------------------------------------------------------------------
# TEST
# -------------------------------------------------------------------------------------------------
print_h2 "(4/5) Test"

if ! run "docker-compose exec $( tty -s && echo || echo '-T' ) ${NAME1} kill -2 1"; then
	run "docker-compose logs"
	run "docker-compose ps"
	run "docker-compose exec $( tty -s && echo || echo '-T' ) ${NAME1} ps || true"
	run "docker-compose kill  || true 2>/dev/null"
	run "docker-compose rm -f || true 2>/dev/null"
	print_error "Kill command not successful"
	exit 1
fi

run "sleep ${WAIT_SHUTDOWN}"
run "docker-compose exec $( tty -s && echo || echo '-T' ) ${NAME1} ps || true"



if ! run_fail "docker-compose ps --filter 'status=running' --services | grep ${NAME1}"; then
	run "docker-compose logs"
	run "docker-compose ps"
	run "docker-compose exec $( tty -s && echo || echo '-T' ) ${NAME1} ps || true"
	run "docker-compose kill  || true 2>/dev/null"
	run "docker-compose rm -f || true 2>/dev/null"
	print_error "Server was supposed to stop, it is running"
	exit 1
fi


# -------------------------------------------------------------------------------------------------
# CLEAN UP
# -------------------------------------------------------------------------------------------------
print_h2 "(5/5) Stopping Docker Compose"

run "docker-compose logs"
run "docker-compose ps"
run "docker-compose kill  || true 2>/dev/null"
run "docker-compose rm -f || true 2>/dev/null"
