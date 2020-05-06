#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
SOURCEPATH="${SCRIPTPATH}/../.lib/conf.sh"
COMPOSEDIR="${SCRIPTPATH}/"
# shellcheck disable=SC1090
source "${SOURCEPATH}"


print_usage() {
	echo "${0} <dir> <compose-server-name> <compose-client-name>"
	echo "Valid dirs:"
	echo
	find "${SCRIPTPATH}" -type d -exec basename {} \; | grep -E '^[0-9].*' | sort
}


# -------------------------------------------------------------------------------------------------
# CHECKS
# -------------------------------------------------------------------------------------------------

if [ "${#}" -ne "3" ]; then
	print_usage
	exit 1
fi

COMPOSE="${1}"
SERVER="${2}"
CLIENT="${3}"
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


print_test_case ""


# -------------------------------------------------------------------------------------------------
# GET ARTIFACTS
# -------------------------------------------------------------------------------------------------
print_h2 "(1/5) Get artifacts"

cd "${COMPOSEDIR}"
while sleep 1; do
	if run "docker-compose pull"; then
		break
	fi
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
run "docker-compose up -d ${SERVER} ${CLIENT}"
run "sleep 5"


# -------------------------------------------------------------------------------------------------
# VALIDATE
# -------------------------------------------------------------------------------------------------
print_h2 "(3/5) Validate running"

if ! run "docker-compose ps --filter 'status=running' --services | grep ${SERVER}"; then
	print_error "Server is not running"
	run "docker-compose logs"
	run "docker-compose kill  || true 2>/dev/null"
	run "docker-compose rm -f || true 2>/dev/null"
	exit 1
fi
if ! run "docker-compose ps --filter 'status=running' --services | grep ${CLIENT}"; then
	print_error "Client is not running"
	run "docker-compose logs"
	run "docker-compose kill  || true 2>/dev/null"
	run "docker-compose rm -f || true 2>/dev/null"
	exit 1
fi


# -------------------------------------------------------------------------------------------------
# TEST
# -------------------------------------------------------------------------------------------------
print_h2 "(4/5) Test"

run "docker-compose exec ${SERVER} kill -2 1"
run "sleep 5"


if ! run_fail "docker-compose ps --filter 'status=running' --services | grep ${SERVER}"; then
	run "docker-compose logs"
	run "docker-compose kill  || true 2>/dev/null"
	run "docker-compose rm -f || true 2>/dev/null"
	print_error "Server was supposed to stop, it is running"
	exit 1
fi

if ! run_fail "docker-compose ps --filter 'status=running' --services | grep ${CLIENT}"; then
	run "docker-compose logs"
	run "docker-compose kill  || true 2>/dev/null"
	run "docker-compose rm -f || true 2>/dev/null"
	print_error "Client was supposed to stop, it is running"
	exit 1
fi


# -------------------------------------------------------------------------------------------------
# CLEAN UP
# -------------------------------------------------------------------------------------------------
print_h2 "(5/5) Stopping Docker Compose"

run "docker-compose logs ${SERVER}"
run "docker-compose logs ${CLIENT}"
run "docker-compose kill  || true 2>/dev/null"
run "docker-compose rm -f || true 2>/dev/null"
