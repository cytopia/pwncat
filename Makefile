ifneq (,)
.error This Makefile requires GNU Make.
endif

# -------------------------------------------------------------------------------------------------
# Default configuration
# -------------------------------------------------------------------------------------------------
.PHONY: help lint test pycodestyle pydocstyle black version lint-files lint-docs lint-usage docs dist sdist bdist build checkbuild deploy autoformat clean

VERSION = 2.7
BINPATH = bin/
MANPATH = man/
DOCPATH = docs/
BINNAME = pwncat

FL_VERSION = 0.3
FL_IGNORES = .git/,.github/,$(BINNAME).egg-info,docs/$(BINNAME).api.html

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
	@echo "lint             Lint source code"
	@echo "test             Run integration tests"
	@echo "autoformat       Autoformat code according to Python black"
	@echo
	@echo "man              Generate man page"
	@echo "docs             Generate docs"
	@echo
	@echo "build            Build Python package"
	@echo "dist             Create source and binary distribution"
	@echo "sdist            Create source distribution"
	@echo "bdist            Create binary distribution"
	@echo "clean            Clean the Build"


# -------------------------------------------------------------------------------------------------
# Lint Targets
# -------------------------------------------------------------------------------------------------

lint: pycodestyle pydocstyle black version lint-files lint-docs lint-usage


pycodestyle:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Check pydocstyle"
	@echo "# -------------------------------------------------------------------- #"
	docker run --rm -v $(PWD):/data cytopia/pycodestyle --show-source --show-pep8 $(BINPATH)$(BINNAME)

pydocstyle:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Check pycodestyle"
	@echo "# -------------------------------------------------------------------- #"
	docker run --rm -v $(PWD):/data cytopia/pydocstyle $(BINPATH)$(BINNAME)

black:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Check Python Black"
	@echo "# -------------------------------------------------------------------- #"
	docker run --rm -v ${PWD}:/data cytopia/black -l 100 --check --diff $(BINPATH)$(BINNAME)

version:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Check version config"
	@echo "# -------------------------------------------------------------------- #"
	if [ "$$(grep version= setup.py | awk -F'"' '{print $$2}')" != "$$(grep 'VERSION ' $(BINPATH)$(BINNAME) | awk -F'"' '{print $$2}')" ]; then \
		echo "Version mismatch in setup.py and $(BINPATH)$(BINNAME)"; \
		exit 1; \
	fi

lint-files:
	@echo "# --------------------------------------------------------------------"
	@echo "# Lint files"
	@echo "# -------------------------------------------------------------------- #"
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-cr --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-crlf --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-trailing-single-newline --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-trailing-space --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-utf8 --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-utf8-bom --text --ignore '$(FL_IGNORES)' --path .

lint-man:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Lint man page"
	@echo "# -------------------------------------------------------------------- #"
	@$(MAKE) --no-print-directory man
	git diff --quiet -- $(DOCPATH) $(MANPATH) || { echo "Build Changes"; git diff | cat; git status; false; }

lint-docs:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Lint docs"
	@echo "# -------------------------------------------------------------------- #"
	@$(MAKE) --no-print-directory docs
	git diff --quiet -- $(DOCPATH) || { echo "Build Changes"; git diff | cat; git status; false; }

lint-usage: SHELL := /bin/bash
lint-usage:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Lint usage"
	@echo "# -------------------------------------------------------------------- #"
	diff --ignore-trailing-space \
		<($(BINPATH)$(BINNAME) -h) \
		<(cat README.md | grep -E -A 10000 'usage:[[:space:]]' | grep -E -B 10000 '^[[:space:]]+\-V')


# -------------------------------------------------------------------------------------------------
# Test Targets
# -------------------------------------------------------------------------------------------------
test: test-behaviour-tcp_client_exits_and_server_hangs_up
test: test-behaviour-udp_client_exits_and_server_stays_alive
test: test-behaviour-tcp_server_exits_and_hangs_up
test: test-behaviour-udp_server_exits_and_client_stays_alive
test: test-behaviour-tcp_socket_reuseaddr
test: test-behaviour-udp_socket_reuseaddr
test: test-basics-client-tcp_make_http_request
test: test-basics-client-tcp_send_text_to_server
test: test-basics-client-udp_send_text_to_server
test: test-basics-client-tcp_send_file_to_server
test: test-basics-client-udp_send_file_to_server
test: test-basics-client-tcp_send_comand_to_server
test: test-basics-client-udp_send_comand_to_server
test: test-options-client-tcp_nodns
test: test-options-client-udp_nodns
test: test-options-tcp_server_keep_open


# -------------------------------------------------------------------------------------------------
# Test Targets: Behaviour
# -------------------------------------------------------------------------------------------------
test-behaviour-tcp_client_exits_and_server_hangs_up:
	tests/100-behaviour-tcp_client_exits_and_server_hangs_up.sh ""

test-behaviour-udp_client_exits_and_server_stays_alive:
	tests/101-behaviour-udp_client_exits_and_server_stays_alive.sh ""

test-behaviour-tcp_server_exits_and_hangs_up:
	tests/102-behaviour-tcp_server_exits_and_hangs_up.sh ""

test-behaviour-udp_server_exits_and_client_stays_alive:
	tests/103-behaviour-udp_server_exits_and_client_stays_alive.sh ""

test-behaviour-tcp_socket_reuseaddr:
	tests/110-behaviour-tcp_socket_reuseaddr.sh ""

test-behaviour-udp_socket_reuseaddr:
	tests/111-behaviour-udp_socket_reuseaddr.sh ""


# -------------------------------------------------------------------------------------------------
# Test Targets: Basics
# -------------------------------------------------------------------------------------------------
test-basics-client-tcp_make_http_request:
	tests/200-basics-client-tcp_make_http_request.sh ""

test-basics-client-tcp_send_text_to_server:
	tests/202-basics-client-tcp_send_text_to_server.sh ""

test-basics-client-udp_send_text_to_server:
	tests/203-basics-client-udp_send_text_to_server.sh ""

test-basics-client-tcp_send_file_to_server:
	tests/204-basics-client-tcp_send_file_to_server.sh ""

test-basics-client-udp_send_file_to_server:
	tests/205-basics-client-udp_send_file_to_server.sh ""

test-basics-client-tcp_send_comand_to_server:
	tests/206-basics-client-tcp_send_comand_to_server.sh ""

test-basics-client-udp_send_comand_to_server:
	tests/207-basics-client-udp_send_comand_to_server.sh ""


# -------------------------------------------------------------------------------------------------
# Test Targets: Options
# -------------------------------------------------------------------------------------------------
test-options-client-tcp_nodns:
	tests/300-options-client-tcp_nodns.sh ""

test-options-client-udp_nodns:
	tests/301-options-client-udp_nodns.sh ""

test-options-tcp_server_keep_open:
	tests/302-options-tcp_server_keep_open.sh ""


# -------------------------------------------------------------------------------------------------
# Documentation
# -------------------------------------------------------------------------------------------------
.PHONY: man
man: $(BINPATH)$(BINNAME)
	docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data -w /data -e UID=$(UID) -e GID=${GID} python:3-alpine sh -c ' \
		apk add help2man \
		&& help2man -n $(BINNAME) --no-info --source=https://github.com/cytopia/pwncat -s 1 -o $(MANPATH)$(BINNAME).1 $(BINPATH)$(BINNAME) \
		&& chown $${UID}:$${GID} $(MANPATH)$(BINNAME).1'
	docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data -w /data -e UID=$(UID) -e GID=${GID} python:3-alpine sh -c ' \
		apk add groff \
		&& cat $(MANPATH)$(BINNAME).1 | groff -mandoc -Thtml > $(DOCPATH)$(BINNAME).man.html \
		&& chown $${UID}:$${GID} $(DOCPATH)$(BINNAME).man.html'

docs:
	docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data -w /data -e UID=$(UID) -e GID=${GID} python:3-alpine sh -c ' \
		pip install pdoc \
		&& pdoc --overwrite --external-links --html --html-dir $(DOCPATH) $(BINPATH)$(BINNAME) $(BINNAME) \
		&& mv $(DOCPATH)$(BINNAME).m.html $(DOCPATH)$(BINNAME).api.html \
		&& chown $${UID}:$${GID} $(DOCPATH)$(BINNAME).api.html'


# -------------------------------------------------------------------------------------------------
# Build Targets
# -------------------------------------------------------------------------------------------------

dist: sdist bdist

sdist:
	docker run \
		--rm \
		$$(tty -s && echo "-it" || echo) \
		-v $(PWD):/data \
		-w /data \
		-u $$(id -u):$$(id -g) \
		python:$(VERSION)-alpine \
		python setup.py sdist

bdist:
	docker run \
		--rm \
		$$(tty -s && echo "-it" || echo) \
		-v $(PWD):/data \
		-w /data \
		-u $$(id -u):$$(id -g) \
		python:$(VERSION)-alpine \
		python setup.py bdist_wheel --universal

build:
	docker run \
		--rm \
		$$(tty -s && echo "-it" || echo) \
		-v $(PWD):/data \
		-w /data \
		-u $$(id -u):$$(id -g) \
		python:$(VERSION)-alpine \
		python setup.py build

checkbuild:
	docker run \
		--rm \
		$$(tty -s && echo "-it" || echo) \
		-v $(PWD):/data \
		-w /data \
		python:$(VERSION)-alpine \
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
		python:$(VERSION)-alpine \
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
