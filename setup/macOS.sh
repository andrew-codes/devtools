#!/usr/bin/env bash

set -euo pipefail

# The repo root, one level up from this script's own directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Step 1: Determinate Nix"
if command -v nix >/dev/null 2>&1; then
  echo "    nix already installed, skipping"
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> Step 2: symlink this repo to ~/.dotfiles"
# home.nix resolves its mkOutOfStoreSymlink paths through ~/.dotfiles, so this
# has to exist before the first switch or the build will fail to find them.
ln -sfn "$SCRIPT_DIR" ~/.dotfiles

echo "==> Step 3: personalize the configured username"
# Do this before any sudo call: sudo resets $USER to root, so whoami has to
# run as the real interactive user first.
REAL_USER="$(whoami)"
FLAKE_USER="$(sed -nE 's/^[[:space:]]*user = "([^"]+)";.*/\1/p' "$SCRIPT_DIR/flake.nix" | head -n1)"
if [ -z "$FLAKE_USER" ]; then
  echo "    Could not find the single \"user = \" line in flake.nix."
  echo "    Edit flake.nix yourself before continuing."
  exit 1
elif [ "$FLAKE_USER" != "$REAL_USER" ]; then
  echo "    flake.nix is configured for user \"$FLAKE_USER\", but you are \"$REAL_USER\"."
  read -r -p "    Rewrite flake.nix's \"user = \" line to \"$REAL_USER\"? [y/N] " REPLY
  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    sed -i '' -E "s/^([[:space:]]*user = \")[^\"]+(\";.*)/\1${REAL_USER}\2/" "$SCRIPT_DIR/flake.nix"
    echo "    Updated. Review the change with: git diff flake.nix"
  else
    echo "    Skipped. Edit the single \"user = \" line in flake.nix yourself before continuing."
    exit 1
  fi
else
  echo "    flake.nix already matches \"$REAL_USER\", nothing to do."
fi

echo "==> Step 4: trust Homebrew taps with something installed from them"
# Homebrew 6+ ignores formulae/casks from any third-party tap until it's
# explicitly trusted. Only trust taps that actually have something
# installed from them (not every tap that happens to be tapped). On a
# first-ever run brew doesn't exist yet, so this is a no-op; on a re-run
# it keeps darwin-rebuild from skipping taps behind out-of-band installs.
if command -v brew >/dev/null 2>&1; then
  { brew list --full-name; brew list --cask --full-name; } 2>/dev/null \
    | grep '/' \
    | sed -E 's#(.*)/[^/]+$#\1#' \
    | sort -u \
    | while read -r tap; do
        brew trust "$tap" >/dev/null 2>&1 || true
      done
fi

echo "==> Step 5: install Mac App Store apps"
# Mac App Store apps are installed here rather than through nix-darwin's
# `homebrew.masApps`, because that option cannot work from inside activation:
# nix-darwin runs brew bundle under plain `sudo --user=<you>` with no
# `launchctl asuser`, which lands outside your per-user launchd session. mas
# reaches the App Store through StoreAgent, which lives in that session, so
# `mas list` returns nothing there, brew bundle decides the app is missing,
# and the `mas install` it then runs fails for want of a TTY to sudo against
# -- on every rebuild, however the app is really installed. See mas-apps.nix.
#
# Two further reasons this has to be `mas get` and not `mas install`: mas
# documents install as "Install previously gotten apps", so it only handles
# apps already in the signed-in Apple ID's library. Being signed in is not
# enough. `get` is what adds a free app to that library, and acquiring is
# per-Apple-ID and permanent rather than per-machine -- so on later machines
# the app is already owned, `get` just warns "Already got" and exits 0, and
# this step stays idempotent.
#
# Build mas from this flake's own locked nixpkgs rather than `nix run
# nixpkgs#mas`, so the version is pinned alongside everything else and costs
# no extra download.
MAS_BIN="$(nix build --no-link --print-out-paths --impure --expr \
  "let f = builtins.getFlake \"$SCRIPT_DIR\"; \
   in f.inputs.nixpkgs.legacyPackages.aarch64-darwin.mas")/bin/mas"

# Emit "<id> <name>" per line; empty when mas-apps.nix is an empty set.
# shellcheck disable=SC2016  # ${n} below is Nix interpolation; the shell must not expand it.
nix eval --raw --file "$SCRIPT_DIR/mas-apps.nix" \
  --apply 'apps: builtins.concatStringsSep "\n"
    (map (n: (toString apps.${n}) + " " + n) (builtins.attrNames apps))' \
  | while read -r id name || [ -n "$id" ]; do
      # `|| [ -n "$id" ]` above: the nix eval output has no trailing newline,
      # so a plain `read` would discard the final (often only) entry.
      [ -n "$id" ] || continue
      echo "    $name ($id)"
      # Run as the invoking user, NOT under sudo: this is the whole reason
      # the step exists, and mas escalates to root by itself when it has real
      # work to do. Not fatal on failure -- setup should still finish.
      "$MAS_BIN" get "$id" \
        || echo "    WARNING: could not acquire $name. Check that the App Store is signed in (mas needs an admin password here)."

      # `mas get` hands the download off to the App Store and can return
      # before the app is on disk, so wait for it to actually land rather
      # than reporting success on a download still in flight. Match on ID:
      # the store's display name often differs from the name used here
      # (1582358382 lists as "Dynamic wallpaper", not the fuller title).
      for _ in $(seq 1 60); do
        "$MAS_BIN" list 2>/dev/null | grep -q "^$id " && break
        sleep 5
      done
      "$MAS_BIN" list 2>/dev/null | grep -q "^$id " \
        || echo "    WARNING: $name still not installed after 5 minutes; darwin-rebuild may report it as failed."
    done

echo "==> Step 6: first darwin-rebuild switch (pinned to nix-darwin-26.05)"
# darwin-rebuild doesn't exist yet on a fresh machine, so run it straight
# from the flake this once. After this, rebuild.sh works normally.
# This fetches the darwin-rebuild tool from the nix-darwin-26.05 release branch,
# not the exact flake.lock revision. The system config it applies is still pinned
# by this repo's flake.lock.
# sudo resets PATH to a secure default that excludes /nix/.../bin, so a
# freshly installed `nix` would not be found under sudo even though it's
# on PATH here. Resolve the absolute path first and invoke that instead.
NIX_BIN="$(command -v nix)"
# "mac" is the flake host label - if you renamed it, change it in flake.nix
# and rebuild.sh too.
sudo "$NIX_BIN" run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake ~/.dotfiles#mac
# If this still fails with "nix: command not found", open a new terminal
# (Determinate adds nix to new shells' PATH) and re-run ./setup/macOS.sh.

echo "==> Done. Use devtools-rebuild for future changes."
