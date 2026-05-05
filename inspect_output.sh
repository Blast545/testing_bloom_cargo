#!/usr/bin/env bash
# Inspect .deb files in output/ — dump the embedded cargo-auditable SBOM.
# Requires binutils (objcopy) and dpkg (dpkg-deb) on the host.
set -e

cd "$(dirname "$0")/output"

for deb in *.deb; do
    echo "=== $deb ==="
    workdir=$(mktemp -d)
    dpkg-deb --extract "$deb" "$workdir"
    bin=$(find "$workdir" -type f -executable -path '*/bin/*' | head -1)
    objcopy --dump-section .dep-v0=/tmp/deps.zlib "$bin"
    python3 -c "import zlib,json; \
d=json.loads(zlib.decompress(open('/tmp/deps.zlib','rb').read())); \
print(f'  packages: {len(d[\"packages\"])}'); \
[print(f\"    {p['name']} {p['version']} ({p.get('kind','runtime')})\") for p in d['packages']]"
    rm -rf "$workdir"
done
