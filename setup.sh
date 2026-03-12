#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKBENCH_DIR="$SCRIPT_DIR/workbench"
UTILS_FILE="$SCRIPT_DIR/setup-utils/utils.sh"

manifest_file="${1:-}"

if [ -z "$manifest_file" ]; then
  echo "Usage: setup.sh <manifest.json>"
  exit 1
fi

if [ ! -f "$manifest_file" ]; then
  echo "Error: manifest file not found: $manifest_file"
  exit 1
fi

manifest_file="$(cd "$(dirname "$manifest_file")" && pwd)/$(basename "$manifest_file")"

# Cache sudo credentials upfront on Mac so steps can call runElevated without prompting mid-run
if [[ $OSTYPE == darwin* ]]; then
  sudo -v
fi

exec > >(tee "$SCRIPT_DIR/workbench.log") 2>&1

# Export env vars from manifest so all steps can access them
while IFS= read -r line; do
  key=$(echo "$line" | grep -o '"[^"]*"' | sed -n '1p' | tr -d '"')
  value=$(echo "$line" | grep -o '"[^"]*"' | sed -n '2p' | tr -d '"')
  if [ -n "$key" ]; then
    expanded=$(eval echo "$value")
    export "${key}=${expanded}"
  fi
done < <(sed -n '/"env"/,/\}/p' "$manifest_file" | grep ':')

export MANIFEST_FILE="$manifest_file"

# shellcheck source=setup-utils/utils.sh
source "$UTILS_FILE"

# Clear all devtools-managed bashrc blocks so steps re-add them in the correct order
if [ -f ~/.bashrc ]; then
  tmpfile=$(mktemp)
  sed '/# BEGIN devtools:/,/# END devtools:/d' ~/.bashrc > "$tmpfile"
  mv "$tmpfile" ~/.bashrc
fi

# Parse steps array from manifest
steps=$(sed -n '/"steps"/,/\]/p' "$manifest_file" | grep -o '"[^"]*"' | tr -d '"' | grep -v '^steps$' | grep -v '^$')

while IFS= read -r step; do
  step_dir="$WORKBENCH_DIR/$step"
  step_script="$step_dir/index.sh"

  if [ ! -d "$step_dir" ]; then
    echo "Error: step directory not found: $step_dir"
    exit 1
  fi

  if [ ! -f "$step_script" ]; then
    echo "Error: index.sh not found in step directory: $step_dir"
    exit 1
  fi

  echo ""
  echo "==> $step"

  (
    cd "$step_dir"
    # shellcheck source=setup-utils/utils.sh
    source "$UTILS_FILE"
    source ./index.sh
  ) || {
    echo ""
    echo "Error: step '$step' failed. Aborting."
    exit 1
  }

  refreshEnv

done <<< "$steps"

refreshEnv

echo ""
echo "Setup complete."
