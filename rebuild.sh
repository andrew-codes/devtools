#!/usr/bin/env zsh

set -euo pipefail

# :A resolves symlinks, so this still finds the real repo root when run
# via the ~/.local/bin/devtools-rebuild symlink.
SCRIPT_DIR="${0:A:h}"
ln -sfn "$SCRIPT_DIR" ~/.dotfiles

# Homebrew 6+ ignores formulae/casks from any third-party tap until it's
# explicitly trusted. Only trust taps that actually have something
# installed from them (not every tap that happens to be tapped), so
# out-of-band installs (anything not cleaned up per
# onActivation.cleanup = "none") keep working after a rebuild.
if command -v brew >/dev/null 2>&1; then
  { brew list --full-name; brew list --cask --full-name; } 2>/dev/null \
    | grep '/' \
    | sed -E 's#(.*)/[^/]+$#\1#' \
    | sort -u \
    | while read -r tap; do
        brew trust "$tap" >/dev/null 2>&1 || true
      done
fi

exec sudo darwin-rebuild switch --flake ~/.dotfiles#mac
