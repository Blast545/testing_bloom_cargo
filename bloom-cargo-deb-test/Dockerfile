# Dockerfile for testing the bloom "cargo" Debian template PR.
#
# Image contents (crate-agnostic):
#   - bloom (with the cargo-debian patch) installed
#   - dh-cargo, cargo, cargo-auditable, rustc, debhelper, fakeroot, etc.
#   - pallet-patcher stub
#   - build_debian_variant.sh / build_rosdebian_variant.sh helpers
#
# At `docker run` time, start_docker.sh bind-mounts a crate directory at
# /work/crate (read-only) and the host output dir at /output. The build
# scripts copy /work/crate to a writable per-variant workdir, run
# bloom-generate + dpkg-buildpackage, and drop the .deb into /output.

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

# --- Build workdir ----------------------------------------------------------
# /work/crate is bind-mounted from the host at `docker run` time (see
# start_docker.sh). The build scripts copy it to /work/build-<variant>
# before running bloom-generate + dpkg-buildpackage.
WORKDIR /work

# --- Helper scripts ---------------------------------------------------------
# Drop the build_*_variant.sh helpers in /work so you can run them directly
# (./build_debian_variant.sh / ./build_rosdebian_variant.sh) after entering
# the container.
COPY scripts/build_debian_variant.sh scripts/build_rosdebian_variant.sh /work/
RUN chmod +x /work/build_debian_variant.sh /work/build_rosdebian_variant.sh

CMD ["/bin/bash"]
