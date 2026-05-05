# Dockerfile for testing the bloom "cargo" Debian template PR.
#
# Stages:
#   1. Install bloom with the cargo-debian patch applied.
#   2. Run `bloom-generate debian` on ros_tokio_demo (Path 2).
#   3. Run `dpkg-buildpackage` to produce a real .deb (Path 3).
#
# Usage:
#   docker build -t bloom-cargo-test .
#   docker run --rm -it bloom-cargo-test
#
# The container drops you into a shell with the fixture at /work/ros_tokio_demo
# and a prebuilt generated debian/ tree, ready for you to run the build.

FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# --- ROS 2 apt repository ---------------------------------------------------
# python3-rosdep, python3-rosdistro, colcon, vcstool live here.
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg2 \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc \
        | gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
        http://packages.ros.org/ros2/ubuntu resolute main" \
        > /etc/apt/sources.list.d/ros2.list \
    && rm -rf /var/lib/apt/lists/*

# --- System deps ------------------------------------------------------------
# git, python + pip for bloom; dh-cargo/cargo/rustc for the actual build;
# debhelper and build-essential for dpkg-buildpackage; sudo for rosdep init.
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        sudo \
        python3 \
        python3-pip \
        python3-venv \
        python3-rosdep \
        python3-rosdistro \
        python3-catkin-pkg \
        python3-empy \
        build-essential \
        debhelper \
        devscripts \
        fakeroot \
        dh-cargo \
        cargo \
        cargo-auditable \
        rustc \
        pkg-config \
        libssl-dev \
        colcon \
        vcstool \
    && rm -rf /var/lib/apt/lists/*

# --- Initialize rosdep ------------------------------------------------------
# bloom-generate needs rosdep to resolve keys like `libssl-dev` to the actual
# Debian package name. We initialize and update the cache so the generator
# can run offline-ish later.
RUN rosdep init && rosdep update

# --- Install bloom with the cargo patch -------------------------------------
WORKDIR /src
COPY ./bloom /src/bloom

# Install into the system python. `--break-system-packages` is required on
# Ubuntu 24.04+ because the base python is marked externally-managed.
RUN pip3 install --break-system-packages /src/bloom

# pallet-patcher isn't in Ubuntu archives; install the stub so the rules
# file doesn't error out at build time. Replace this with the real thing
# once it's packaged.
RUN printf '#!/bin/sh\necho "# pallet-patcher stub: no-op" > "$(pwd)/.pallet-patcher.stub"\nexit 0\n' \
    > /usr/local/bin/pallet-patcher && chmod +x /usr/local/bin/pallet-patcher

# --- Fixture ----------------------------------------------------------------
WORKDIR /work
COPY ros_tokio_demo /work/ros_tokio_demo

# --- Pre-fetch crate dependencies -------------------------------------------
# cargo needs network access to download the crates.io index and crate sources.
# Do it here (during image build) so the in-container build can run offline.
# This also generates a real Cargo.lock that dh-cargo can use.
RUN cargo fetch --manifest-path /work/ros_tokio_demo/Cargo.toml

# --- Path 2a: generate the debian/ tree via `bloom-generate debian` ---------
# Plain Debian/Ubuntu packaging path (mirrors PR #763's plain-rpm scope):
# package name `ros-tokio-demo`, install prefix `/usr`. Useful for distro
# packagers who don't have an /opt/ros overlay.
RUN cd /work/ros_tokio_demo && \
    bloom-generate debian \
        --os-name ubuntu \
        --os-version resolute \
        --ros-distro rolling \
        && chmod +x debian/rules \
        && echo "=== [debian] Generated debian/ tree ===" \
        && ls -la debian/ \
        && echo "=== [debian] debian/control ===" \
        && cat debian/control \
        && echo "=== [debian] debian/rules ===" \
        && cat debian/rules

# --- Path 2b: generate the debian/ tree via `bloom-generate rosdebian` ------
# ROS-overlay packaging path: package name `ros-rolling-ros-tokio-demo`,
# install prefix `/opt/ros/rolling`. This is what real ROS Rust packages
# will ship as. Re-uses the same templates/cargo/ via DebianGenerator
# inheritance — if this build also succeeds, we've shown the cargo template
# works for both `debian` and `rosdebian` flavors with no extra wiring.
RUN cp -a /work/ros_tokio_demo /work/ros_tokio_demo_rosdeb && \
    cd /work/ros_tokio_demo_rosdeb && \
    rm -rf debian && \
    bloom-generate rosdebian \
        --os-name ubuntu \
        --os-version resolute \
        --ros-distro rolling \
        && chmod +x debian/rules \
        && echo "=== [rosdebian] Generated debian/ tree ===" \
        && ls -la debian/ \
        && echo "=== [rosdebian] debian/control ===" \
        && cat debian/control \
        && echo "=== [rosdebian] debian/rules ===" \
        && cat debian/rules

# --- Helper scripts ---------------------------------------------------------
# Drop the build_*_variant.sh helpers in /work so you can run them directly
# (./build_debian_variant.sh / ./build_rosdebian_variant.sh) after entering
# the container.
COPY scripts/build_debian_variant.sh scripts/build_rosdebian_variant.sh /work/
RUN chmod +x /work/build_debian_variant.sh /work/build_rosdebian_variant.sh

CMD ["/bin/bash"]
