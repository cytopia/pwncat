#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

TPL_NAME="template-test.yml.tpl"
TPL_PATH="${SCRIPT_PATH}/${TPL_NAME}"
FLW_PATH="${SCRIPT_PATH}/../../.github/workflows"


escape_for_sed() {
	local data="${1}"
	data="${data//\\/\\\\}"
	data="${data//\"/\\\"}"
	data="${data//\'/\\\'}"
	data="${data//\(/\\\(}"
	data="${data//\)/\\\)}"
	data="${data//\{/\\\{}"
	data="${data//\}/\\\}}"
	data="${data//\$/\\\$}"
	data="${data//\*/\\\*}"
	data="${data//\;/\\\;}"
	data="$( printf "%s" "${data}" | sed 's/$/__NL__/g' | tr -d '\n' )"
	echo "${data}"
}

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

DISABLE_CRLF=(
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
### Replace with all
###
RETRY_FUNCTION="$(cat <<-'END_HEREDOC'
          retry() {
            _make=${1}
            _target=${2}
            _host=${3:-localhost}
            _port=${4:-4444}
            _wait=${5:-5}
            _runs=${6:-1}
            for n in $(seq ${RETRIES}); do
              _port=$(( _port + n ))
              echo "[${n}/${RETRIES}] make ${_target} ${_host} ${_port} ${_wait} ${_runs}";
              if "${_make}" "${_target}" "TEST_PWNCAT_HOST=${_host}" "TEST_PWNCAT_PORT=${_port}" "TEST_PWNCAT_WAIT=${_wait}" "TEST_PWNCAT_RUNS=${_runs}"; then
                return 0;
              fi;
              sleep 10;
            done;
            return 1;
          }
END_HEREDOC
)"
RETRY_FUNCTION="$( escape_for_sed "${RETRY_FUNCTION}" )"


###
### Ensure new flows are created
###
for v in "${VERSION_MATRIX[@]}"; do
	arch="${v//--*/}"
	os="${v//${arch}--/}"
	os="${os//--*/}"
	py="${v//*--}"

	flw_file="${FLW_PATH}/test-${arch}-${os}-${py}.yml"
	flw_name="${os:0:3}-${py//pypy/py}"
	job_name="[${arch}] [${os}] python-${py}"

	printf "%s\\n" "-----------------------------------------------------------"
	printf "file:      %s\\n" "${flw_file}"
	printf "flw name:  %s\\n" "${flw_name}"
	printf "job name:  %s\\n" "${job_name}"
	printf "OS:        %s\\n" "${os}-latest"
	printf "Arch:      %s\\n" "${arch}"
	printf "Python:    %s\\n" "${py}"

	# Add custom jobs
	if [ "${os}" == "ubuntu" ]; then
		linux_jobs=""
		macos_jobs=""
		windows_jobs=""
	fi
	if [ "${os}" == "macos" ]; then
		linux_jobs=""
		macos_jobs=""
		windows_jobs=""
	fi
	if [ "${os}" == "windows" ]; then
		linux_jobs=""
		macos_jobs=""
		windows_jobs="$(cat <<-'END_HEREDOC'
      - name: Add bash to the Path
        run: |
          echo "::add-path::c:\msys64\mingw32\bin"
          echo "::add-path::c:\msys64\usr\bin"
END_HEREDOC
)"
		windows_jobs="$( escape_for_sed "${windows_jobs}" )"
		windows_jobs=""
	fi


	if [ "${os}" == "ubuntu" ]; then
		os="${os}-16.04"
	else
		os="${os}-latest"
	fi

	retry_func_crlf="${RETRY_FUNCTION}"
	# Disable comments for specific combinations
	crlf_comment=""
	# shellcheck disable=SC2076,SC2199
	if [[ " ${DISABLE_CRLF[@]} " =~ " ${v} " ]]; then
		crlf_comment="#"
		retry_func_crlf=""
	fi

	# shellcheck disable=SC2002
	cat "${TPL_PATH}" \
		| sed "s/__DISABLE_CRLF__/${crlf_comment}/g" \
		| sed "s|__RETRY_FUNCTION_CRLF__|${retry_func_crlf}|g" \
		| sed "s|__RETRY_FUNCTION__|${RETRY_FUNCTION}|g" \
		| sed "s/__WORKFLOW_NAME__/${flw_name}/g" \
		| sed "s/__OS__/${os}/g" \
		| sed "s/__PYTHON_VERSION__/${py}/g" \
		| sed "s/__JOB_NAME__/${job_name}/g" \
		| sed "s/__ARCHITECTURE__/${arch}/g" \
		| sed "s#__LINUX_JOBS__#${linux_jobs}#g" \
		| sed "s#__MACOS_JOBS__#${macos_jobs}#g" \
		| sed "s#__WINDOWS_JOBS__#${windows_jobs}#g" \
		| sed "s/__NL__/\\n/g" \
		> "${flw_file}"
done
