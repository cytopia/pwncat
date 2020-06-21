#!/bin/sh
set -e
set -u
set -x

RHOST="${1}"
RPORT="${2}"

printf "hi\\n" | "python${PYTHON_VERSION}" /usr/bin/pwncat --no-shutdown -vvvvv "${RHOST}" "${RPORT}"
