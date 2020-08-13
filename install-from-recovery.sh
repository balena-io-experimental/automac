#!/bin/sh

set -e
ARGV_VOLUME="$2"
set -u

if [ -z "$ARGV_VOLUME" ]
then
  echo "Pass the destination volume path as an argument" 1>&2
  exit 1
fi

INSTALLER="/Install macOS Catalina.app"

if [ ! -d "$INSTALLER"  ]
then
  echo "This script must run from within the macOS Recovery system" 1>&2
  exit 1
fi

"$INSTALLER/Contents/Resources/startosinstall" \
   --nointeraction \
   --volume "$ARGV_VOLUME" \
   --agreetolicense
