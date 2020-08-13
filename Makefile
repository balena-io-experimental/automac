VERSION ?= 10.15.6

.PHONY: fetch-installer lint

fetch-installer:
	/usr/sbin/softwareupdate --fetch-full-installer --full-installer-version $(VERSION)

lint:
	shellcheck scripts/*
