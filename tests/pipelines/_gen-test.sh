#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

TPL_NAME="template-test.tpl"
TPL_PATH="${SCRIPT_PATH}/${TPL_NAME}"
FLW_PATH="${SCRIPT_PATH}/../../.github/workflows"


###
### Build Matrix
###
VERSION_MATRIX=(
	"x64--ubuntu--x64--2.7"
	"x64--ubuntu--3.5"
	"x64--ubuntu--3.6"
	"x64--ubuntu--3.7"
	"x64--ubuntu--3.8"
	"x64--ubuntu--pypy2"
	"x64--ubuntu--pypy3"
	"x64--macos--2.7"
	"x64--macos--3.5"
	"x64--macos--3.6"
	"x64--macos--3.7"
	"x64--macos--3.8"
	"x64--macos--pypy2"
	"x64--macos--pypy3"
	"x64--windows--2.7"
	"x64--windows--3.5"
	"x64--windows--3.6"
	"x64--windows--3.7"
	"x64--windows--3.8"
	"x64--windows--pypy2"
	"x64--windows--pypy3"
)


###
### Ensure old flows are removed
###
rm -f "${FLW_PATH}/test-"*


###
### Ensure new flows are created
###
for v in "${VERSION_MATRIX[@]}"; do
	arch="${v//--*/}"
	os="${v//${arch}--/}"
	os="${os//--*/}"
	py="${v//*--}"

	flw_file="${FLW_PATH}/test-${arch}-${os}-${py}.yml"
	flw_name="${os:0:3}-${py}"
	job_name="[${arch}] [${os}] python-${py}"

	printf "%s\\n" "-----------------------------------------------------------"
	printf "file:      %s\\n" "${flw_file}"
	printf "flw name:  %s\\n" "${flw_name}"
	printf "job name:  %s\\n" "${job_name}"
	printf "OS:        %s\\n" "${os}-latest"
	printf "Arch:      %s\\n" "${arch}"
	printf "Python:    %s\\n" "${py}"

	# shellcheck disable=SC2002
	cat "${TPL_PATH}" \
		| sed "s/__WORKFLOW_NAME__/${flw_name}/g" \
		| sed "s/__OS__/${os}-latest/g" \
		| sed "s/__PYTHON_VERSION__/${py}/g" \
		| sed "s/__JOB_NAME__/${job_name}/g" \
		| sed "s/__ARCHITECTURE__/${arch}/g" \
		> "${flw_file}"
done
