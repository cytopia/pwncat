#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

TPL_NAME="template-smoke.yml.tpl"
TPL_PATH="${SCRIPT_PATH}/${TPL_NAME}"
FLW_PATH="${SCRIPT_PATH}/../../.github/workflows"


###
### Build Matrix
###
VERSION_MATRIX=(
	"2.7"
	"3.5"
	"3.6"
	"3.7"
	"3.8"
)


###
### Ensure old flows are removed
###
rm -f "${FLW_PATH}/smoke-"*


###
### Ensure new flows are created
###
for v in "${VERSION_MATRIX[@]}"; do
	py="${v}"

	flw_file="${FLW_PATH}/smoke-${py}.yml"
	flw_name="smoke-${py}"
	job_name="[smoke] python-${py}"

	printf "%s\\n" "-----------------------------------------------------------"
	printf "file:      %s\\n" "${flw_file}"
	printf "flw name:  %s\\n" "${flw_name}"
	printf "job name:  %s\\n" "${job_name}"
	printf "Python:    %s\\n" "${py}"

	# shellcheck disable=SC2002
	cat "${TPL_PATH}" \
		| sed "s/__WORKFLOW_NAME__/${flw_name}/g" \
		| sed "s/__PYTHON_VERSION__/${py}/g" \
		| sed "s/__JOB_NAME__/${job_name}/g" \
		> "${flw_file}"
done
