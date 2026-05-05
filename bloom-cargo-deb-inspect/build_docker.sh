#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Building bloom-cargo-inspect image ==="
docker build -t bloom-cargo-inspect "$SCRIPT_DIR"
echo "=== Done. Run ./start_docker.sh to enter the container. ==="
