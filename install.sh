#!/bin/sh

set -eux

# physical disk will be erased
ERASE_DISK=disk0

# https://www.virtuallyghetto.com/2013/02/enable-auto-startup-after-power-failure.html
pmset autorestart 1

diskutil list

diskutil eraseDisk JHFS+ Untitled ${ERASE_DISK}

diskutil apfs createContainer /dev/${ERASE_DISK}s2

container_disk=$(diskutil list /dev/${ERASE_DISK}s2 | grep ${ERASE_DISK}s2 | awk '{print $4}')

diskutil apfs addVolume "${container_disk}" APFS Macintosh\ HD

diskutil list

/Install\ macOS\ Catalina.app/Contents/Resources/startosinstall \
  --nointeraction \
  --agreetolicense \
  --volume /Volumes/Macintosh\ HD \
  --installpackage /opt/automac-distribution.pkg