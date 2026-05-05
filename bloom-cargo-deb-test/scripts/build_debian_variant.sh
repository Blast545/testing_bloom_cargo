#!/usr/bin/env bash
set -e
trap 'echo "FAILED: $BASH_COMMAND" >&2' ERR

rm -rf /work/build-debian
rm -f /work/*.deb /work/*.changes /work/*.buildinfo
cp -r /work/crate /work/build-debian
cd /work/build-debian
bloom-generate debian --os-name ubuntu --os-version resolute --ros-distro rolling
chmod +x debian/rules
fakeroot debian/rules binary 2>&1 | tee /tmp/build-debian.log
ls /work/*.deb
mkdir -p /tmp/ext-debian
dpkg-deb --extract /work/*.deb /tmp/ext-debian
find /tmp/ext-debian -type f
objdump -h /tmp/ext-debian/usr/bin/* | grep dep-v0
cp /work/*.deb /output/
