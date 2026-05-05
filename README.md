# bloom cargo Debian template — test rig

Two Docker images that together exercise the bloom debian generator's
`cargo` build_type template end-to-end: one builds `.deb` packages from a
fixture ROS Rust package, the other inspects them.

I wanted to use this as a sample repo to test if the template for rust worked without setting up a complete

## Layout

```
testing_bloom_cargo/
├── output/                       # shared, bind-mounted into both containers as /output/
├── inspect_output.sh             # host-side SBOM dump for every .deb in output/
├── bloom-cargo-deb-test/         # builder
│   ├── Dockerfile
│   ├── build_docker.sh
│   ├── start_docker.sh           # mounts ../output:/output
│   └── scripts/
│       ├── build_debian_variant.sh    # ends with `cp /work/*.deb /output/`
│       └── build_rosdebian_variant.sh # ends with `cp /work/*.deb /output/`
└── bloom-cargo-deb-inspect/      # inspector
    ├── Dockerfile                # cargo-audit + dpkg-dev + binutils (Ubuntu 26.04 system rustc)
    ├── build_docker.sh
    └── start_docker.sh           # mounts the same ../output:/output
```

The shared `output/` directory is the only path both containers see, so
artifacts produced by the builder appear on the host filesystem and are
immediately visible to the inspector.

## Install

```bash
git clone git@github.com:blast545/testing_bloom_cargo.git
cd testing_bloom_cargo

# bloom is not vendored — clone upstream, then fetch the PR with the cargo template
git clone https://github.com/ros-infrastructure/bloom.git bloom-cargo-deb-test/bloom
cd bloom-cargo-deb-test/bloom
git fetch origin pull/<PR#>/head:cargo-debian
git checkout cargo-debian
cd ../..
```

Or with the GitHub CLI:

```bash
git clone https://github.com/ros-infrastructure/bloom.git bloom-cargo-deb-test/bloom
cd bloom-cargo-deb-test/bloom && gh pr checkout <PR#> && cd ../..
```

Replace `<PR#>` with the bloom PR number that adds the cargo Debian template.

## Workflow

```bash
# One-time image builds (in any order):
cd ~/testing_bloom_cargo/bloom-cargo-deb-test    && ./build_docker.sh
cd ~/testing_bloom_cargo/bloom-cargo-deb-inspect && ./build_docker.sh

# Generate the debs:
cd ~/testing_bloom_cargo/bloom-cargo-deb-test && ./start_docker.sh
# inside builder container:
./build_debian_variant.sh
./build_rosdebian_variant.sh
exit

# Confirm the debs are visible on the host:
ls ~/testing_bloom_cargo/output/

# Quick host-side SBOM dump (no container needed; needs binutils + dpkg):
./inspect_output.sh

# Inspect them:
cd ~/testing_bloom_cargo/bloom-cargo-deb-inspect && ./start_docker.sh
# inside inspector container (default WORKDIR is /output):
ls
mkdir -p /tmp/ext && dpkg-deb --extract ros-rolling-ros-tokio-demo_*.deb /tmp/ext
cargo audit bin /tmp/ext/opt/ros/rolling/bin/ros_tokio_demo
```

## Note on the inspector image

The inspector's `./build_docker.sh` compiles `cargo-audit` from source
against Ubuntu 26.04's system `rustc` (1.93). First build takes ~5-10
minutes; subsequent rebuilds use Docker layer cache.

If that's too heavy, `objcopy + python3` (already in the inspector image)
can dump the embedded `.dep-v0` SBOM without `cargo-audit`:

```bash
objcopy --dump-section .dep-v0=/tmp/deps.zlib /tmp/ext/opt/ros/rolling/bin/ros_tokio_demo
python3 -c "import zlib,json; print(json.dumps(json.loads(zlib.decompress(open('/tmp/deps.zlib','rb').read())), indent=2))"
```

Same data, no vulnerability scan.
