#!/usr/bin/env bash
# Start an interactive shell in the bloom-cargo-test container.
#
# Bind-mounts:
#   - $1 (default ./ros_tokio_demo)  -> /work/crate (read-only)
#   - ../output                      -> /output     (writable)
#
# Inside the container, run ./build_debian_variant.sh and/or
# ./build_rosdebian_variant.sh. Each script copies /work/crate into a
# variant-specific workdir, runs bloom-generate + dpkg-buildpackage, and
# drops the produced .deb into /output/.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/../output"
CRATE_DIR="${1:-$SCRIPT_DIR/ros_tokio_demo}"

mkdir -p "$OUTPUT_DIR"
[ -d "$CRATE_DIR" ] || { echo "crate dir not found: $CRATE_DIR" >&2; exit 1; }

docker run --rm -it \
    -v "$OUTPUT_DIR:/output" \
    -v "$(realpath "$CRATE_DIR"):/work/crate:ro" \
    bloom-cargo-test
