# Inspector image for the bloom cargo Debian template test rig.
#
# Companion to ../bloom-cargo-deb-test (the builder). The builder produces
# .deb files into ../output/ on the host; this image bind-mounts that same
# directory at /output/ and ships the tools needed to inspect them:
#
#   - dpkg-deb           extract / list / show package metadata
#   - binutils           objdump / objcopy for the embedded .dep-v0 section
#   - python3            zlib + json one-liner for raw SBOM dumps
#   - cargo-audit        vulnerability scan against the embedded SBOM
#
# Ubuntu 26.04 (resolute) ships rustc 1.93, which is new enough to compile
# the latest cargo-audit directly — no rustup bootstrap needed.

FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        binutils \
        dpkg-dev \
        python3 \
        cargo \
        rustc \
        build-essential \
        pkg-config \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Compile cargo-audit from source (~5-10 min); symlink it into /usr/local/bin
# so it's on PATH without exposing /root/.cargo/bin globally.
RUN cargo install cargo-audit \
    && ln -s /root/.cargo/bin/cargo-audit /usr/local/bin/cargo-audit

WORKDIR /output

CMD ["/bin/bash"]
