MACOS_TARGET_VERSION ?= 10.15.6
PKG_IDENTIFIER ?= io.balena.automac
AUTOMAC_VERSION ?= $(shell cat VERSION)

.PHONY: fetch-installer lint

fetch-installer:
	/usr/sbin/softwareupdate \
		--fetch-full-installer \
		--full-installer-version $(MACOS_TARGET_VERSION)

lint:
	shellcheck scripts/*

version:
	echo $(AUTOMAC_VERSION)

build:
	mkdir -p $@

build/automac.pkg: | build
	pkgbuild \
		--nopayload \
		--scripts scripts \
		--identifier $(PKG_IDENTIFIER) \
		--version $(AUTOMAC_VERSION) \
		--ownership recommended \
		$@
