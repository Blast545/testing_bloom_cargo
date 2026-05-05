#!/usr/bin/env bash
# Build the bloom-cargo-test Docker image.
# Run from anywhere — the script resolves its own directory.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Building bloom-cargo-test image ==="
docker build -t bloom-cargo-test "$SCRIPT_DIR"
echo "=== Done. Run ./start_docker.sh to enter the container. ==="
