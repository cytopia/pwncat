ifneq (,)
.error This Makefile requires GNU Make.
endif

# -------------------------------------------------------------------------------------------------
# Default configuration
# -------------------------------------------------------------------------------------------------
.PHONY: help lint test pycodestyle pydocstyle black version dist sdist bdist build checkbuild deploy autoformat clean


VERSION = 2.7
BINPATH = bin/
BINNAME = netcat


# -------------------------------------------------------------------------------------------------
# Default Target
# -------------------------------------------------------------------------------------------------
help:
	@echo "lint             Lint source code"
	@echo "test             Test source code"
	@echo "autoformat       Autoformat code according to Python black"
	@echo "install          Install (requires sudo or root)"
	@echo "uninstall        Uninstall (requires sudo or root)"
	@echo "build            Build Python package"
	@echo "dist             Create source and binary distribution"
	@echo "sdist            Create source distribution"
	@echo "bdist            Create binary distribution"
	@echo "clean            Build"


# -------------------------------------------------------------------------------------------------
# Lint Targets
# -------------------------------------------------------------------------------------------------

lint: pycodestyle pydocstyle black version

pycodestyle:
	docker run --rm -v $(PWD):/data cytopia/pycodestyle --show-source --show-pep8 $(BINPATH)$(BINNAME)

pydocstyle:
	docker run --rm -v $(PWD):/data cytopia/pydocstyle $(BINPATH)$(BINNAME)

black:
	docker run --rm -v ${PWD}:/data cytopia/black -l 100 --check --diff $(BINPATH)$(BINNAME)

version:
	@if [ "$$(grep version= setup.py | awk -F'"' '{print $$2}')" != "$$(grep 'VERSION ' bin/netcat | awk -F'"' '{print $$2}')" ]; then \
		echo "Version mismatch in setup.py and bin/netcat"; \
		exit 1; \
	fi



# -------------------------------------------------------------------------------------------------
# Test Targets
# -------------------------------------------------------------------------------------------------

test:
	@echo "noop"


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
