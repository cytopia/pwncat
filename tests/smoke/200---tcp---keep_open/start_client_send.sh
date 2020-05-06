#!/bin/sh
set -e
set -u
set -x

RHOST="${1}"
RPORT="${2}"
printf "hi\\n" | /usr/bin/pwncat -vvvvv "${RHOST}" "${RPORT}"
