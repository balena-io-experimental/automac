MACOS_TARGET_VERSION ?= 10.15.6
PKG_IDENTIFIER ?= io.balena.automac
AUTOMAC_VERSION ?= $(shell cat VERSION)

.PHONY: fetch-installer lint clean

fetch-installer:
	/usr/sbin/softwareupdate \
		--fetch-full-installer \
		--full-installer-version $(MACOS_TARGET_VERSION)

lint:
	shellcheck scripts/*

clean:
	rm -rf build

build:
	mkdir -p $@

build/automac-component.pkg: scripts/preinstall scripts/postinstall | build
	pkgbuild \
		--nopayload \
		--scripts scripts \
		--identifier $(PKG_IDENTIFIER) \
		--version $(AUTOMAC_VERSION) \
		--ownership recommended \
		$@

# "startosinstall" install packages myst be distribution-style flat packages
# See https://github.com/munki/createOSXinstallPkg#further-note-on-additional-packages-and-yosemite-and-el-capitan
build/automac-distribution.pkg: build/automac-component.pkg
	productbuild --package $< $@
