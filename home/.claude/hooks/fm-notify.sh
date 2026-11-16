#!/bin/bash
# Claude Code Notification hook: the only sender of macOS notifications.
#
# Registered per project (the firstmate checkout's .claude/settings.local.json),
# never globally. It fires for every session in that project, so it filters on
# the session's cwd: only firstmate's own session notifies, its crewmates stay
# silent. herdr's toast and sound are turned off in home/.config/herdr/config.toml
# so nothing else notifies either.
#
# macOS only. Elsewhere there is no terminal-notifier, and this exits quietly.

# Hooks inherit a minimal PATH. jq lives in the nix profile; terminal-notifier
# is Homebrew's (nixpkgs only repackages the Intel-only upstream binary).
PATH="/opt/homebrew/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/${USER:-$(id -un)}/bin:/run/current-system/sw/bin:$PATH"

[ "$(uname -s)" = "Darwin" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0
command -v terminal-notifier >/dev/null 2>&1 || exit 0

FM_DIR="$HOME/developer/repos/firstmate"
WEZTERM_BUNDLE_ID="com.github.wez.wezterm"

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
msg=$(printf '%s' "$input" | jq -r '.message // "Firstmate is waiting"')

[ "$cwd" = "$FM_DIR" ] || exit 0

terminal-notifier -title "firstmate" -message "$msg" -group firstmate \
  -activate "$WEZTERM_BUNDLE_ID"
