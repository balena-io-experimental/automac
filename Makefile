MACOS_TARGET_VERSION ?= 10.15.6
PKG_IDENTIFIER ?= io.balena.automac
AUTOMAC_VERSION ?= $(shell cat VERSION)

.PHONY: fetch-installer lint 

fetch-installer:
	/usr/sbin/softwareupdate \
		--fetch-full-installer \
		--full-installer-version $(MACOS_TARGET_VERSION)

lint:
	shellcheck scripts/* *.sh

automac-component.pkg: scripts/preinstall scripts/postinstall
	pkgbuild \
		--nopayload \
		--scripts scripts \
		--identifier $(PKG_IDENTIFIER) \
		--version $(AUTOMAC_VERSION) \
		--ownership recommended \
		$@

# "startosinstall" install packages myst be distribution-style flat packages
# See https://github.com/munki/createOSXinstallPkg#further-note-on-additional-packages-and-yosemite-and-el-capitan
automac-distribution.pkg: automac-component.pkg
	productbuild --package $< $@
