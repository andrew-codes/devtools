#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

os_type="$OSTYPE"
arch_type="$(uname -m)"
[[ $OSTYPE == darwin* ]] && os_type="macos"

echo "==> Detected: $os_type / $arch_type"

if [[ $os_type == "macos" && $arch_type == "arm64" ]]; then
  exec "$SCRIPT_DIR/setup/macOS.sh"
fi

echo "Error: Unsupported platform: $os_type / $arch_type" >&2
echo "Currently supported: macOS on Apple Silicon (arm64)." >&2
exit 1
