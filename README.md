# automac
> ⚠️ unattended macOS installations; target volume(s) will be erased

## ToC

* [prepare hardware](#prepare-hardware)
* [create custom installer image](#create-custom-installer-image)
* [legacy (manual) install](#legacy-manual-install)
* [troubleshooting](#troubleshooting)
* [future work](#future-work)


## prepare hardware
> prepare hardware to boot from (modified `BaseSystem.dmg|img`) USB

* boot into stock Recovery System (Command ⌘ + R)
* open Terminal
* run `csrutil disable`
* for [T2](https://support.apple.com/en-ca/HT208330) enabled hardware, set `No Security` and `Allow booting from external media`
* shutdown/power-off


## create custom installer image
> perform these steps on a suitable macOS machine

* download [macOS Catalina](https://support.apple.com/en-gb/HT201475)
* mount `BaseImage.dmg`

```
rm -rf /tmp/BaseSystem.shadow \
  && hdiutil attach -owners on \
  /Applications/Install\ macOS\ Catalina.app/Contents/SharedSupport/BaseSystem.dmg \
  -shadow /tmp/BaseSystem.shadow
```

* build custom assets

```
make lint automac-component.pkg automac-distribution.pkg
```

* inject assets

```
sudo mkdir -p /Volumes/macOS\ Base\ System/etc/balena \
  && sudo cp install.sh /Volumes/macOS\ Base\ System/etc/balena/ \
  && sudo chmod +x /Volumes/macOS\ Base\ System/etc/balena/install.sh \
  && sudo cp automac-distribution.pkg /Volumes/macOS\ Base\ System/opt/ \
  && sudo cp com.apple.install.balena.plist /Volumes/macOS\ Base\ System/System/Library/LaunchDaemons/com.apple.install.balena.plist \
  && sync
```

* detach image

```
hdiutil eject /Volumes/macOS\ Base\ System
```

* export customised image

```
rm -rf /tmp/BaseSystem.dmg \
  && hdiutil convert -format UDZO \
  /Applications/Install\ macOS\ Catalina.app/Contents/SharedSupport/BaseSystem.dmg \
  -o /tmp/BaseSystem.dmg \
  -shadow /tmp/BaseSystem.shadow
```

* convert image

```
qemu-img convert /tmp/BaseSystem.dmg -O raw /tmp/BaseSystem.img
```

* flash image to USB using [Etcher](https://www.balena.io/etcher/)
* connect to the network
* boot from USB
* update software if prompted on start-up
* wait for installer to complete
> the installer will run in the background as a [LaunchDaemon](com.apple.install.balena.plist) and restart the system automatically

```
    tail -f /var/log/balena.log
```


## legacy (manual) install

* boot into Recovery System
* open Terminal
* ⚠️ erase physcical disk and format with APFS

```
diskutil eraseDisk JHFS+ Untitled disk0

diskutil apfs createContainer /dev/disk0s2

container_disk=$(diskutil list /dev/disk0s2 | grep disk0s2 | awk '{print $4}')

diskutil apfs addVolume "${container_disk}" APFS Macintosh\ HD
```

* download custom package

```
curl --progress-bar --output /tmp/automac-distribution.pkg \
  https://raw.githubusercontent.com/balena-io-playground/automac/master/automac-distribution.pkg
```

* install

```
/Install\ macOS\ Catalina.app/Contents/Resources/startosinstall \
  --nointeraction \
  --agreetolicense \
  --installpackage /tmp/automac-distribution.pkg \
  --volume /Volumes/Macintosh\ HD
```


## troubleshooting
> show output of [postinstall](scripts/postinstall) script after the installation is complete

    grep -E 'package_script_service|postinstall' /var/log/install.log | more


## future work

* [add custom app(s) to Recovery System](https://jacobsalmela.com/2014/05/19/osx-customize-recovery-partition-with-your-own-apps/)
