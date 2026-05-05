#!/usr/bin/env bash
set -e
trap 'echo "FAILED: $BASH_COMMAND" >&2' ERR

rm -rf /work/build-rosdebian
rm -f /work/*.deb /work/*.changes /work/*.buildinfo
cp -r /work/crate /work/build-rosdebian
cd /work/build-rosdebian
bloom-generate rosdebian --os-name ubuntu --os-version resolute --ros-distro rolling
chmod +x debian/rules
fakeroot debian/rules binary 2>&1 | tee /tmp/build-rosdeb.log
ls /work/*.deb
mkdir -p /tmp/ext-rosdeb
dpkg-deb --extract /work/*.deb /tmp/ext-rosdeb
find /tmp/ext-rosdeb -type f
objdump -h /tmp/ext-rosdeb/opt/ros/rolling/bin/* | grep dep-v0
cp /work/*.deb /output/
