#!/usr/bin/env bash
set -e
trap 'echo "FAILED: $BASH_COMMAND" >&2' ERR

cd /work/ros_tokio_demo_rosdeb
fakeroot debian/rules binary 2>&1 | tee /tmp/build-rosdeb.log
ls /work/*.deb
mkdir -p /tmp/ext-rosdeb
dpkg-deb --extract /work/ros-rolling-ros-tokio-demo_*.deb /tmp/ext-rosdeb
find /tmp/ext-rosdeb -type f
objdump -h /tmp/ext-rosdeb/opt/ros/rolling/bin/* | grep dep-v0
cp /work/ros-rolling-ros-tokio-demo_*.deb /output/
