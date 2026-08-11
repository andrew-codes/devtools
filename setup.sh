#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

os_type="$OSTYPE"
arch_type="$(uname -m)"
[[ $OSTYPE == darwin* ]] && os_type="macos"
# Git for Windows' bash reports msys; a Cygwin shell reports cygwin. Both are
# running on Windows, and setup/windows.sh checks for the same pair itself.
[[ $OSTYPE == msys* || $OSTYPE == cygwin* ]] && os_type="windows"

echo "==> Detected: $os_type / $arch_type"

if [[ $os_type == "macos" && $arch_type == "arm64" ]]; then
  exec "$SCRIPT_DIR/setup/macOS.sh"
fi

if [[ $os_type == "windows" && $arch_type == "x86_64" ]]; then
  exec "$SCRIPT_DIR/setup/windows.sh"
fi

echo "Error: Unsupported platform: $os_type / $arch_type" >&2
echo "Currently supported: macOS on Apple Silicon (arm64), Windows on x86_64." >&2
exit 1
