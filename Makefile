ifneq (,)
.error This Makefile requires GNU Make.
endif

# -------------------------------------------------------------------------------------------------
# Can be changed
# -------------------------------------------------------------------------------------------------
# This can be adjusted
PYTHON_VERSION = 2.7


# -------------------------------------------------------------------------------------------------
# Default configuration
# -------------------------------------------------------------------------------------------------
.PHONY: help lint code test smoke autoformat docs pipeline build deploy clean

BINPATH = bin/
MANPATH = man/
DOCPATH = docs/
INTPATH = tests/integration/
BINNAME = pwncat

FL_VERSION = 0.4
FL_IGNORES = .git/,.github/,$(BINNAME).egg-info,docs/$(BINNAME).api.html,docs/,data/,.mypy_cache/,rtfm/venv,rtfm/_build

UID := $(shell id -u)
GID := $(shell id -g)


# -------------------------------------------------------------------------------------------------
# Default Target
# -------------------------------------------------------------------------------------------------
help:
	@echo " ██▓███   █     █░ ███▄    █  ▄████▄   ▄▄▄      ▄▄▄█████▓"
	@echo "▓██░  ██▒▓█░ █ ░█░ ██ ▀█   █ ▒██▀ ▀█  ▒████▄    ▓  ██▒ ▓▒"
	@echo "▓██░ ██▓▒▒█░ █ ░█ ▓██  ▀█ ██▒▒▓█    ▄ ▒██  ▀█▄  ▒ ▓██░ ▒░"
	@echo "▒██▄█▓▒ ▒░█░ █ ░█ ▓██▒  ▐▌██▒▒▓▓▄ ▄██▒░██▄▄▄▄██ ░ ▓██▓ ░ "
	@echo "▒██▒ ░  ░░░██▒██▓ ▒██░   ▓██░▒ ▓███▀ ░ ▓█   ▓██▒  ▒██▒ ░ "
	@echo "▒▓▒░ ░  ░░ ▓░▒ ▒  ░ ▒░   ▒ ▒ ░ ░▒ ▒  ░ ▒▒   ▓▒█░  ▒ ░░   "
	@echo "░▒ ░       ▒ ░ ░  ░ ░░   ░ ▒░  ░  ▒     ▒   ▒▒ ░    ░    "
	@echo "░░         ░   ░     ░   ░ ░ ░          ░   ▒     ░      "
	@echo "             ░             ░ ░ ░            ░  ░         "
	@echo "                             ░                           "
	@echo
	@echo "lint             Lint repository"
	@echo "code             Lint source code"
	@echo "test             Run integration tests"
	@echo "smoke            Run smokke tests (dockerized)"
	@echo "autoformat       Autoformat code according to Python black"
	@echo
	@echo "docs             Update code documentation"
	@echo "pipeline         Update GitHub action workflow pipelines"
	@echo
	@echo "build            Build Python pkg, source and binary dist"
	@echo "deploy           Deploy pip package"
	@echo "clean            Clean the Build"


# -------------------------------------------------------------------------------------------------
# Lint Targets
# -------------------------------------------------------------------------------------------------
lint: _lint-files
lint: _lint-version
lint: _lint-usage
lint: _lint-docs
lint: _lint-man
lint: _lint-pipeline

.PHONY: _lint-version
_lint-version:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Check version config"
	@echo "# -------------------------------------------------------------------- #"
	@VERSION_PWNCAT=$$( grep -E '^VERSION = "[.0-9]+(-\w+)?"' bin/pwncat | awk -F'"' '{print $$2}' || true ); \
	VERSION_SETUP=$$( grep version= setup.py | awk -F'"' '{print $$2}' || true ); \
	VERSION_CHANGE=$$( grep -E '## Release [.0-9]+(-\w+)?$$' CHANGELOG.md | head -1 | sed 's/.*[[:space:]]//g' || true ); \
	if [ "$${VERSION_PWNCAT}" != "$${VERSION_SETUP}" ] || [ "$${VERSION_SETUP}" != "$${VERSION_CHANGE}" ]; then \
		echo "[ERROR] Version mismatch"; \
		echo "bin/pwncat:   $${VERSION_PWNCAT}"; \
		echo "setup.py:     $${VERSION_SETUP}"; \
		echo "CHANGELOG.md: $${VERSION_CHANGE}    # Looking for latest entry with regex format: '## Release [.0-9]+(\w+)?$$'" ; \
		exit 1; \
	else \
		echo "[OK] Version match"; \
		echo "bin/pwncat:   $${VERSION_PWNCAT}"; \
		echo "setup.py:     $${VERSION_SETUP}"; \
		echo "CHANGELOG.md: $${VERSION_CHANGE}"; \
		exit 0; \
	fi \

.PHONY: _lint-usage
_lint-usage: SHELL := /bin/bash
_lint-usage:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Lint usage"
	@echo "# -------------------------------------------------------------------- #"
	$(PWD)/tests/bin/check-usage.sh

.PHONY: _lint-files
_lint-files:
	@echo "# --------------------------------------------------------------------"
	@echo "# Lint files"
	@echo "# -------------------------------------------------------------------- #"
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-cr --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-crlf --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-trailing-single-newline --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-trailing-space --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-utf8 --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-utf8-bom --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) git-conflicts --text --ignore '$(FL_IGNORES)' --path .

.PHONY: _lint-docs
_lint-docs:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Lint docs"
	@echo "# -------------------------------------------------------------------- #"
	@$(MAKE) --no-print-directory docs
	git diff --quiet -- $(DOCPATH) || { echo "Build Changes"; git diff | cat; git status; false; }

.PHONY: _lint-man
_lint-man:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Lint man page"
	@echo "# -------------------------------------------------------------------- #"
	@$(MAKE) --no-print-directory man
	git diff --quiet -- $(DOCPATH) $(MANPATH) || { echo "Build Changes"; git diff | cat; git status; false; }

.PHONY: _lint-pipeline
_lint-pipeline:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Lint Pipelines"
	@echo "# -------------------------------------------------------------------- #"
	@$(MAKE) --no-print-directory pipeline
	git diff --quiet -- .github/workflows || { echo "Build Changes"; git diff | cat; git status; false; }


# -------------------------------------------------------------------------------------------------
# Code Style Targets
# -------------------------------------------------------------------------------------------------
code: _code-pycodestyle
code: _code-pydocstyle
code: _code-pylint
code: _code-black
code: _code-mypy

.PHONY: _code-pycodestyle
_code-pycodestyle:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Check pycodestyle"
	@echo "# -------------------------------------------------------------------- #"
	docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data --entrypoint= cytopia/pycodestyle sh -c ' \
		mkdir -p /tmp \
		&& cp $(BINPATH)$(BINNAME) /tmp/$(BINNAME).py \
		&& pycodestyle --config=setup.cfg /tmp/$(BINNAME).py'

.PHONY: _code-pydocstyle
_code-pydocstyle:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Check pycodestyle"
	@echo "# -------------------------------------------------------------------- #"
	docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data --entrypoint= cytopia/pydocstyle sh -c ' \
		mkdir -p /tmp \
		&& cp $(BINPATH)$(BINNAME) /tmp/$(BINNAME).py \
		&& pydocstyle --explain --config=setup.cfg /tmp/$(BINNAME).py'

.PHONY: _code-pylint
_code-pylint:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Check pylint"
	@echo "# -------------------------------------------------------------------- #"
	docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/pylint --rcfile=setup.cfg $(BINPATH)$(BINNAME)

.PHONY: _code-black
_code-black:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Check Python Black"
	@echo "# -------------------------------------------------------------------- #"
	docker run --rm $$(tty -s && echo "-it" || echo) -v ${PWD}:/data cytopia/black -l 100 --check --diff $(BINPATH)$(BINNAME)

.PHONY: _code-mypy
_code-mypy:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Check mypy"
	@echo "# -------------------------------------------------------------------- #"
	docker run --rm $$(tty -s && echo "-it" || echo) -v ${PWD}:/data cytopia/mypy --config-file setup.cfg $(BINPATH)$(BINNAME)


# -------------------------------------------------------------------------------------------------
# Smoke Targets
# -------------------------------------------------------------------------------------------------
smoke: _smoke-keep_open-kill_srv-before_send
smoke: _smoke-keep_open-kill_srv-send_data
smoke: _smoke-tcp_port_scan-no_banner
smoke: _smoke-tcp_port_scan-with_banner
smoke: _smoke-udp_port_scan-no_banner
smoke: _smoke-udp_port_scan-with_banner

.PHONY:
_smoke-keep_open-kill_srv-before_send:
	@# It's sometimes a race-condition, so we run it five times
	tests/smoke/run.sh "200---tcp---keep_open---kill_server---no_send" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "200---tcp---keep_open---kill_server---no_send" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "200---tcp---keep_open---kill_server---no_send" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "200---tcp---keep_open---kill_server---no_send" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "200---tcp---keep_open---kill_server---no_send" "$(PYTHON_VERSION)"

_smoke-keep_open-kill_srv-send_data:
	@# It's sometimes a race-condition, so we run it five times
	tests/smoke/run.sh "201---tcp---keep_open---kill_server---send_data" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "201---tcp---keep_open---kill_server---send_data" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "201---tcp---keep_open---kill_server---send_data" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "201---tcp---keep_open---kill_server---send_data" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "201---tcp---keep_open---kill_server---send_data" "$(PYTHON_VERSION)"

_smoke-tcp_port_scan-no_banner:
	@# It's sometimes a race-condition, so we run it five times
	tests/smoke/run.sh "300---tcp---port_scan---no_banner" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "300---tcp---port_scan---no_banner" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "300---tcp---port_scan---no_banner" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "300---tcp---port_scan---no_banner" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "300---tcp---port_scan---no_banner" "$(PYTHON_VERSION)"

_smoke-tcp_port_scan-with_banner:
	@# It's sometimes a race-condition, so we run it five times
	tests/smoke/run.sh "301---tcp---port_scan---with_banner" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "301---tcp---port_scan---with_banner" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "301---tcp---port_scan---with_banner" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "301---tcp---port_scan---with_banner" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "301---tcp---port_scan---with_banner" "$(PYTHON_VERSION)"

_smoke-udp_port_scan-no_banner:
	@# It's sometimes a race-condition, so we run it five times
	tests/smoke/run.sh "302---udp---port_scan---no_banner" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "302---udp---port_scan---no_banner" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "302---udp---port_scan---no_banner" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "302---udp---port_scan---no_banner" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "302---udp---port_scan---no_banner" "$(PYTHON_VERSION)"

_smoke-udp_port_scan-with_banner:
	@# It's sometimes a race-condition, so we run it five times
	tests/smoke/run.sh "303---udp---port_scan---with_banner" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "303---udp---port_scan---with_banner" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "303---udp---port_scan---with_banner" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "303---udp---port_scan---with_banner" "$(PYTHON_VERSION)"
	tests/smoke/run.sh "303---udp---port_scan---with_banner" "$(PYTHON_VERSION)"


# -------------------------------------------------------------------------------------------------
# Test Targets
# -------------------------------------------------------------------------------------------------
TEST_PWNCAT_HOST=localhost
TEST_PWNCAT_PORT=4444
TEST_PWNCAT_WAIT=2
TEST_PWNCAT_RUNS=1
test: _test-behaviour-quit--client
test: _test-behaviour-quit--server
test: _test-behaviour-base--file_transfer
test: _test-mode--local_forward
test: _test-mode--remote_forward
test: _test-options--nodns
test: _test-options--crlf
test: _test-options--keep_open
test: _test-options--reconn
test: _test-options--ping_intvl
test: _test-options--ping_word
test: _test-cnc--inject_shell

.PHONY: _test-behaviour-quit--client
#_test-behaviour-quit--client:
#	tests/integration/run.sh "01-behaviour-quit--client" \
#		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)"
_test-behaviour-quit--client: __test-behaviour-quit--client-000
_test-behaviour-quit--client: __test-behaviour-quit--client-001
_test-behaviour-quit--client: __test-behaviour-quit--client-002
_test-behaviour-quit--client: __test-behaviour-quit--client-003
_test-behaviour-quit--client: __test-behaviour-quit--client-004
_test-behaviour-quit--client: __test-behaviour-quit--client-100
_test-behaviour-quit--client: __test-behaviour-quit--client-101
_test-behaviour-quit--client: __test-behaviour-quit--client-102
_test-behaviour-quit--client: __test-behaviour-quit--client-103
_test-behaviour-quit--client: __test-behaviour-quit--client-200
_test-behaviour-quit--client: __test-behaviour-quit--client-201
__test-behaviour-quit--client-000:
	$(INTPATH)01-behaviour-quit--client/000---tcp---client_quits---when_server_is_killed---client_default---before_send.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--client-001:
	$(INTPATH)01-behaviour-quit--client/001---tcp---client_quits---when_server_is_killed---client_default---after_client_sent_data.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--client-002:
	$(INTPATH)01-behaviour-quit--client/002---tcp---client_quits---when_server_is_killed---client_default---after_server_sent_data.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--client-003:
	$(INTPATH)01-behaviour-quit--client/003---tcp---client_quits---when_server_is_killed---client_command---before_send.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--client-004:
	$(INTPATH)01-behaviour-quit--client/004---tcp---client_quits---when_server_is_killed---client_command---after_server_sent_command.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--client-100:
	$(INTPATH)01-behaviour-quit--client/100---udp---client_stays---when_server_is_killed---client_default---before_send.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--client-101:
	$(INTPATH)01-behaviour-quit--client/101---udp---client_stays---when_server_is_killed---client_default---after_client_sent_data.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--client-102:
	$(INTPATH)01-behaviour-quit--client/102---udp---client_stays---when_server_is_killed---client_default---after_server_sent_data.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--client-103:
	$(INTPATH)01-behaviour-quit--client/103---udp---client_stays---when_server_is_killed---client_command---before_send.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--client-200:
	$(INTPATH)01-behaviour-quit--client/200---tcp---client_stays---when_valid_http_request.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--client-201:
	$(INTPATH)01-behaviour-quit--client/201---tcp---client_quites---when_invalid_http_request.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"

.PHONY: _test-behaviour-quit--server
#_test-behaviour-quit--server:
#	tests/integration/run.sh "02-behaviour-quit--server" \
#		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)"
_test-behaviour-quit--server: __test-behaviour-quit--server-000
_test-behaviour-quit--server: __test-behaviour-quit--server-001
_test-behaviour-quit--server: __test-behaviour-quit--server-002
_test-behaviour-quit--server: __test-behaviour-quit--server-003
_test-behaviour-quit--server: __test-behaviour-quit--server-004
_test-behaviour-quit--server: __test-behaviour-quit--server-100
_test-behaviour-quit--server: __test-behaviour-quit--server-101
_test-behaviour-quit--server: __test-behaviour-quit--server-103
_test-behaviour-quit--server: __test-behaviour-quit--server-104
_test-behaviour-quit--server: __test-behaviour-quit--server-200
_test-behaviour-quit--server: __test-behaviour-quit--server-201
__test-behaviour-quit--server-000:
	$(INTPATH)02-behaviour-quit--server/000---tcp---server_quits---when_client_is_killed---server_default---before_send.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--server-001:
	$(INTPATH)02-behaviour-quit--server/001---tcp---server_quits---when_client_is_killed---server_default---after_client_sent_data.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--server-002:
	$(INTPATH)02-behaviour-quit--server/002---tcp---server_quits---when_client_is_killed---server_default---after_server_sent_data.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--server-003:
	$(INTPATH)02-behaviour-quit--server/003---tcp---server_quits---when_client_is_killed---server_command---before_send.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--server-004:
	$(INTPATH)02-behaviour-quit--server/004---tcp---server_quits---when_client_is_killed---server_command---after_client_sent_command.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--server-100:
	$(INTPATH)02-behaviour-quit--server/100---udp---server_stays---when_client_is_killed---server_default---before_send.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--server-101:
	$(INTPATH)02-behaviour-quit--server/101---udp---server_stays---when_client_is_killed---server_default---after_client_sent_data.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--server-103:
	$(INTPATH)02-behaviour-quit--server/103---udp---server_stays---when_client_is_killed---server_command---before_send.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--server-104:
	$(INTPATH)02-behaviour-quit--server/104---udp---server_stays---when_client_is_killed---server_command---after_client_sends_command.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--server-200:
	$(INTPATH)02-behaviour-quit--server/200---udp---server_reacc---when_client_is_killed---server_default---after_client_sent_data.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-behaviour-quit--server-201:
	$(INTPATH)02-behaviour-quit--server/201---udp---server_reacc---when_client_is_killed---server_command---after_client_sent_command.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"

.PHONY: _test-behaviour-base--file_transfer
_test-behaviour-base--file_transfer:
	tests/integration/run.sh "03-behaviour-base--file_transfer" \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"

.PHONY: _test-mode--local_forward
_test-mode--local_forward:
	tests/integration/run.sh "10-mode---local_forward" \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"

.PHONY: _test-mode--remote_forward
_test-mode--remote_forward:
	tests/integration/run.sh "11-mode---remote_forward" \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"

.PHONY: _test-options--nodns
_test-options--nodns:
	tests/integration/run.sh "20-options---nodns" \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"

.PHONY: _test-options--crlf
_test-options--crlf:
	tests/integration/run.sh "21-options---crlf" \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"

.PHONY: _test-options--keep_open
#_test-options--keep_open:
#	tests/integration/run.sh "22-options---keep_open" \
#		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)"
_test-options--keep_open:
_test-options--keep_open: __test-options--keep_open-000
_test-options--keep_open: __test-options--keep_open-001
_test-options--keep_open: __test-options--keep_open-002
_test-options--keep_open: __test-options--keep_open-100
_test-options--keep_open: __test-options--keep_open-101
_test-options--keep_open: __test-options--keep_open-200
_test-options--keep_open: __test-options--keep_open-201
_test-options--keep_open: __test-options--keep_open-202
__test-options--keep_open-000:
	$(INTPATH)22-options---keep_open/000---tcp---server_reacc---three_clients---server_default---cli_nosend-cli_nosend-cli_send.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-options--keep_open-001:
	$(INTPATH)22-options---keep_open/001---tcp---server_reacc---three_clients---server_default---cli_nosend-cli_send-cli_send.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-options--keep_open-002:
	$(INTPATH)22-options---keep_open/002---tcp---server_reacc---three_clients---server_default---cli_send-cli_send-cli_send.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-options--keep_open-100:
	$(INTPATH)22-options---keep_open/100---tcp---server_reacc---three_clients---server_default---srv_send-cli_nosend-cli_send.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-options--keep_open-101:
	$(INTPATH)22-options---keep_open/101---tcp---server_reacc---three_clients---server_default---srv_send-cli_send-cli_send.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-options--keep_open-200:
	$(INTPATH)22-options---keep_open/200---tcp---server_reacc---three_clients---server_command---cli_nosend-cli_nosend-cli_send.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-options--keep_open-201:
	$(INTPATH)22-options---keep_open/201---tcp---server_reacc---three_clients---server_command---cli_nosend-cli_send-cli_send.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-options--keep_open-202:
	$(INTPATH)22-options---keep_open/202---tcp---server_reacc---three_clients---server_command---cli_send-cli_send-cli_send.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"

.PHONY: _test-options--reconn
#_test-options--reconn:
#	tests/integration/run.sh "23-options---reconn" \
#		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)"
_test-options--reconn: __test-options--reconn-000
_test-options--reconn: __test-options--reconn-001
_test-options--reconn: __test-options--reconn-002
__test-options--reconn-000:
	$(INTPATH)23-options---reconn/000---tcp---client_reconn---three_servers---server_default---srv_down_cli_send-srv_nosend-srv_nosend-srv_send.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-options--reconn-001:
	$(INTPATH)23-options---reconn/001---tcp---client_reconn---three_servers---server_default---srv_down_cli_send-srv_nosend-srv_send-srv_send.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-options--reconn-002:
	$(INTPATH)23-options---reconn/002---tcp---client_reconn---three_servers---server_default---srv_down_cli_send-srv_send-srv_send-srv_send.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"

.PHONY: _test-options--ping_init
_test-options--ping_intvl:
	tests/integration/run.sh "25-options---ping_intvl" \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"

.PHONY: _test-options--ping_word
_test-options--ping_word:
	tests/integration/run.sh "26-options---ping_word" \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"

.PHONY: _test-cnc--inject_shell
_test-cnc--inject_shell:
_test-cnc--inject_shell: __test-cnc--inject_shell-pwncat
_test-cnc--inject_shell: __test-cnc--inject_shell-revshelll-multi_btye-banner-suffix
_test-cnc--inject_shell: __test-cnc--inject_shell-revshelll-single_btye-banner-suffix
__test-cnc--inject_shell-pwncat:
	$(INTPATH)30-cnc---self_inject/000---tcp---pwncat_as_rev_shell.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-cnc--inject_shell-revshelll-multi_btye-banner-suffix:
	$(INTPATH)30-cnc---self_inject/001---tcp---revshell-multi_btye-banner-suffix.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"
__test-cnc--inject_shell-revshelll-single_btye-banner-suffix:
	$(INTPATH)30-cnc---self_inject/002---tcp---revshell-single_btye-banner-suffix.sh \
		"$(TEST_PWNCAT_HOST)" "$(TEST_PWNCAT_PORT)" "$(TEST_PWNCAT_WAIT)" "$(TEST_PWNCAT_RUNS)" "$(TEST_PYTHON_VERSION)"


# -------------------------------------------------------------------------------------------------
# Documentation
# -------------------------------------------------------------------------------------------------
docs: _docs-man
docs: _docs-api
docs: _docs-mypy_type_coverage

.PHONY: _docs-man
_docs-man: $(BINPATH)$(BINNAME)
	docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data -w /data -e UID=$(UID) -e GID=${GID} python:3-alpine sh -c ' \
		apk add help2man \
		&& help2man -n $(BINNAME) --no-info --source=https://github.com/cytopia/pwncat -s 1 -o $(MANPATH)$(BINNAME).1 $(BINPATH)$(BINNAME) \
		&& chown $${UID}:$${GID} $(MANPATH)$(BINNAME).1'
	docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data -w /data -e UID=$(UID) -e GID=${GID} python:3-alpine sh -c ' \
		apk add groff \
		&& cat $(MANPATH)$(BINNAME).1 | groff -mandoc -Thtml | sed "s/.*CreationDate:.*//g" > $(DOCPATH)$(BINNAME).man.html \
		&& chown $${UID}:$${GID} $(DOCPATH)$(BINNAME).man.html'

.PHONY: _docs-api
_docs-api:
	@# Generate pdoc API page
	docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data -w /data -e UID=$(UID) -e GID=${GID} python:3-alpine sh -c ' \
		pip install pdoc3 \
		&& mkdir -p /tmp \
		&& cp $(BINPATH)$(BINNAME) /tmp/$(BINNAME).py \
		&& pdoc3 -f -o $(DOCPATH) --html --config show_inherited_members=False /tmp/$(BINNAME).py \
		&& mv $(DOCPATH)$(BINNAME).html $(DOCPATH)$(BINNAME).api.html \
		&& chown $${UID}:$${GID} $(DOCPATH)$(BINNAME).api.html'

.PHONY: _docs-mypy_type_coverage
_docs-mypy_type_coverage:
	@# Generate mypy code coverage page
	docker run --rm $$(tty -s && echo "-it" || echo) -v ${PWD}:/data -w /data -e UID=$(UID) -e GID=${GID} --entrypoint= cytopia/mypy sh -c ' \
		mypy --config-file setup.cfg --html-report tmp $(BINPATH)$(BINNAME) \
		&& cp -f tmp/mypy-html.css docs/css/mypy.css \
		&& cat tmp/index.html \
			| sed "s|mypy-html.css|css/mypy.css|g" \
			| sed "s|<a.*</a>|bin/pwncat|g" \
			> docs/pwncat.type.html \
		&& cat tmp/html/bin/pwncat.html \
			| sed "s|../../mypy-html.css|mypy.css|g" \
			| sed "s|__main__|pwncat|g" \
			>> docs/pwncat.type.html \
		&& chown $${UID}:$${GID} docs/pwncat.type.html \
		&& chown $${UID}:$${GID} docs/css/mypy.css \
		&& rm -r tmp/'
	@# Update code coverage in README.md
	docker run --rm $$(tty -s && echo "-it" || echo) -v ${PWD}:/data -w /data python:3-alpine sh -c ' \
		apk add bc \
		&& percent=$$(grep "% imprecise" docs/pwncat.type.html | grep "th" | grep -Eo "[.0-9]+") \
		&& coverage=$$(echo "100 - $${percent}" | bc) \
		&& sed -i "s/fully typed: \([.0-9]*\)/fully typed: $${coverage}/g" README.md'


# -------------------------------------------------------------------------------------------------
# Generate GitHub Action workflow pipelines
# -------------------------------------------------------------------------------------------------
pipeline:
	$(PWD)/tests/pipelines/run.sh


# -------------------------------------------------------------------------------------------------
# Build Targets
# -------------------------------------------------------------------------------------------------
build: clean
build: _lint-version
build: _build-source_dist
build: _build-binary_dist
build: _build-python_package
build: _build-check_python_package

.PHONY: _build_source_dist
_build-source_dist:
	@echo "Create source distribution"
	docker run \
		--rm \
		$$(tty -s && echo "-it" || echo) \
		-v $(PWD):/data \
		-w /data \
		-u $$(id -u):$$(id -g) \
		python:$(PYTHON_VERSION)-alpine \
		python setup.py sdist

.PHONY: _build_binary_dist
_build-binary_dist:
	@echo "Create binary distribution"
	docker run \
		--rm \
		$$(tty -s && echo "-it" || echo) \
		-v $(PWD):/data \
		-w /data \
		-u $$(id -u):$$(id -g) \
		python:$(PYTHON_VERSION)-alpine \
		python setup.py bdist_wheel --universal

.PHONY: _build_python_package
_build-python_package:
	@echo "Build Python package"
	docker run \
		--rm \
		$$(tty -s && echo "-it" || echo) \
		-v $(PWD):/data \
		-w /data \
		-u $$(id -u):$$(id -g) \
		python:$(PYTHON_VERSION)-alpine \
		python setup.py build

.PHONY: _build_check_python_package
_build-check_python_package:
	@echo "Check Python package"
	docker run \
		--rm \
		$$(tty -s && echo "-it" || echo) \
		-v $(PWD):/data \
		-w /data \
		python:$(PYTHON_VERSION)-alpine \
		sh -c "pip install twine \
		&& twine check dist/*"


# -------------------------------------------------------------------------------------------------
# Publish Targets
# -------------------------------------------------------------------------------------------------
deploy:
	docker run \
		--rm \
		$$(tty -s && echo "-it" || echo) \
		-v $(PWD):/data \
		-w /data \
		python:$(PYTHON_VERSION)-alpine \
		sh -c "pip install twine \
		&& twine upload dist/*"


# -------------------------------------------------------------------------------------------------
# Misc Targets
# -------------------------------------------------------------------------------------------------
autoformat:
	docker run \
		--rm \
		$$(tty -s && echo "-it" || echo) \
		-v $(PWD):/data \
		-w /data \
		cytopia/black -l 100 $(BINPATH)$(BINNAME)

clean:
	-rm -rf $(BINNAME).egg-info/
	-rm -rf dist/
	-rm -rf build/
