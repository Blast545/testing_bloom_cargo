#!/usr/bin/env bash
# Start an interactive shell in the bloom-cargo-inspect container with the
# shared output dir bind-mounted. Builder writes .debs there; you read them
# from /output/ inside this container.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/../output"
mkdir -p "$OUTPUT_DIR"

docker run --rm -it \
    -v "$OUTPUT_DIR:/output" \
    bloom-cargo-inspect
