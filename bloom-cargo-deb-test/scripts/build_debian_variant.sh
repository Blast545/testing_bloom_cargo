#!/usr/bin/env bash
set -e
trap 'echo "FAILED: $BASH_COMMAND" >&2' ERR

cd /work/ros_tokio_demo
fakeroot debian/rules binary 2>&1 | tee /tmp/build-debian.log
ls /work/*.deb
mkdir -p /tmp/ext-debian
dpkg-deb --extract /work/ros-tokio-demo_*.deb /tmp/ext-debian
find /tmp/ext-debian -type f
objdump -h /tmp/ext-debian/usr/bin/* | grep dep-v0
cp /work/ros-tokio-demo_*.deb /output/
