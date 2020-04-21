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
	git diff --quiet || { echo "Build Changes"; git diff|cat; git status; false; }

lint-docs:
	@echo "# -------------------------------------------------------------------- #"
	@echo "# Lint docs"
	@echo "# -------------------------------------------------------------------- #"
	@$(MAKE) --no-print-directory docs
	git diff --quiet || { echo "Build Changes"; git diff|cat; git status; false; }

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

test: test-tcp-client-http
test: test-tcp-client-echo
test: test-udp-client-echo
test: test-tcp-client-send-text
test: test-udp-client-send-text
test: test-tcp-client-send-file
test: test-udp-client-send-file
test: test-tcp-client-send-command
test: test-udp-client-send-command
test: test-tcp-server-local-port-forward

# HTTP
test-tcp-client-http:
	tests/01-tcp-client-http-server-request.sh ""

# ECHO
test-tcp-client-echo:
	@echo "TODO: Not yet implemented."
	#tests/02-tcp-client-echo-server-request.sh ""
test-udp-client-echo:
	@echo "TODO: Not yet implemented."
	#tests/02-udp-client-echo-server-request.sh ""

# SEND TEXT
test-tcp-client-send-text:
	tests/03-tcp-client-send-text-to-server.sh ""
test-udp-client-send-text:
	tests/03-udp-client-send-text-to-server.sh ""

# SEND FILE
test-tcp-client-send-file:
	tests/04-tcp-client-send-file-to-server.sh ""
test-udp-client-send-file:
	tests/04-udp-client-send-file-to-server.sh ""

# SEND COMMAND
test-tcp-client-send-command:
	tests/05-tcp-client-send-command-to-server.sh ""
test-udp-client-send-command:
	tests/05-udp-client-send-command-to-server.sh ""

# LOCAL PORT FORWARD
test-tcp-server-local-port-forward:
	@echo "TODO: Not yet implemented."
	#06-tcp-server-local-port-forward.sh ""


# -------------------------------------------------------------------------------------------------
# Documentation
# -------------------------------------------------------------------------------------------------
.PHONY: man
man: $(BINPATH)$(BINNAME)
	docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data -w /data -e UID=$(UID) -e GID=${GID} python:3-alpine sh -c ' \
		apk add help2man \
		&& help2man -n $(BINNAME) -s 1 -o $(MANPATH)$(BINNAME).1 $(BINPATH)$(BINNAME) \
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
