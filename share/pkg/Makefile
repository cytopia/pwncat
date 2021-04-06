SHELL = bash

# View versions here: https://repology.org/project/pwncat/versions


.PHONY: brew
brew:
	@mkdir -p $@
	.lib/brew.sh > $@/pwncat.rb
	@echo
	@echo "Update here"
	@echo "https://github.com/Homebrew/homebrew-core/blob/master/Formula/pwncat.rb"
	@echo


.PHONY: blackarch
blackarch:
	@mkdir -p $@
	.lib/blackarch.sh > $@/PKGBUILD
	@echo "pwncat" > $@/to-release
	@echo
	@echo "Update here"
	@echo "https://github.com/BlackArch/blackarch/blob/master/packages/pwncat/PKGBUILD"
	@echo "https://github.com/BlackArch/blackarch/blob/master/lists/to-release"
	@echo


.PHONY: nixos
nixos:
	@mkdir -p $@
	docker run -it --rm \
		-v $(PWD)/$@:/data \
		--entrypoint=sh \
		python:3-alpine -c " \
		pip install nixpkgs-pytools \
		&& python-package-init pwncat \
		&& cp default.nix /data/default.nix \
		&& chown $$(id -u):$$(id -g) /data/default.nix \
		"
	@echo
	@echo "Update here"
	@echo "https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/security/pwncat/default.nix"
	@echo


.PHONY: pentoo
pentoo:
	@mkdir -p $@
	docker run -it --rm \
		-v $(PWD)/.lib:/tmp \
		-v $(PWD)/pentoo:/data \
		--entrypoint=sh \
		python:2-alpine -c " \
		apk add \
			bash \
			curl \
			gcc \
			python2-dev \
			musl-dev \
		&& pip install pyblake2 \
		&& /tmp/pentoo.sh > /data/Manifest \
		&& chown $$(id -u):$$(id -g) /data/Manifest \
		"
	@echo
	@echo "Update here"
	@echo "https://github.com/pentoo/pentoo-overlay/blob/master/net-analyzer/pwncat/Manifest"
	@echo
