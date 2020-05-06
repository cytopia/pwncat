#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"



bash "${SCRIPTPATH}/_gen-test.sh"
bash "${SCRIPTPATH}/_gen-smoke.sh"
