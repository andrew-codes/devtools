#!/usr/bin/env bash
#
# First-time bootstrap and re-runnable rebuild for Windows.
#
# Peer of setup/macOS.sh, but it carries more. On macOS, nix-darwin and
# home-manager own package installs, dotfile symlinks, activation scripts and
# system defaults, so setup/macOS.sh only has to bootstrap them. Nix has no
# native Windows support, so everything configuration.nix and home.nix do over
# there is done directly here.
#
# setup/windows-parity.md maps every macOS entry to what this script does --
# or deliberately does not do -- about it. Keep it in step with this file.
#
# Runs in Git for Windows' bash. Re-running is the supported way to apply
# changes: every step is a no-op once it has been done, and this file is
# symlinked onto PATH as `devtools-rebuild`, the same name macOS uses for
# rebuild.sh.

set -euo pipefail

# The repo root, one level up from this script's own directory. Resolved
# through the symlink first, the same thing rebuild.sh's ${0:A:h} does on
# macOS: the supported way to re-run this is ~/.local/bin/devtools-rebuild,
# which is a link to this file, and a plain dirname would land in ~/.local.
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"

# Cheap guard, because getting this wrong is silent and destructive: Step 3
# would repoint ~/.dotfiles at the wrong directory and Step 8 would then
# replace every correct dotfile symlink with a dangling one.
if [ ! -f "$SCRIPT_DIR/setup/windows.sh" ]; then
  echo "Error: could not locate the repo root (resolved $SCRIPT_DIR)." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# What gets installed.
#
# These lists are this file's answer to configuration.nix (homebrew.brews and
# .casks) and home.nix (home.packages, globalNpmPackages, goPackages,
# secretEnvVars). The declaration lives here; the steps below are only the
# mechanism.
#
# The npm, Go and secret lists are duplicated from home.nix on purpose -- Nix
# cannot evaluate on Windows, so there is nothing to import. Bump both when you
# bump either; home.nix carries a comment pointing back here.
# ---------------------------------------------------------------------------

# winget ids, each verified against the microsoft/winget-pkgs manifests. The
# comment on each line names the macOS entry it stands in for.
WINGET_PACKAGES=(
  Git.Git                 # kept current by Step 1; listed so a machine that
                          # somehow lacks it still gets it
  wez.wezterm             # cask wezterm
  AgileBits.1Password     # cask 1password
  AgileBits.1Password.CLI # cask 1password-cli
  Docker.DockerDesktop    # cask docker-desktop
  Mirantis.Lens           # cask lens
  Logitech.OptionsPlus    # cask logi-options+
  Anthropic.ClaudeCode    # cask claude-code
  Microsoft.PowerToys     # stands in for cask raycast; PowerToys Run is the
                          # keystroke launcher, and Raycast ships no Windows
                          # package on winget
  BurntSushi.ripgrep.MSVC # pkgs.ripgrep
  sharkdp.fd              # pkgs.fd
  eza-community.eza       # pkgs.eza
  junegunn.fzf            # pkgs.fzf
  jqlang.jq               # pkgs.jq
  MikeFarah.yq            # pkgs.yq
  JesseDuffield.lazygit   # pkgs.lazygit
  Neovim.Neovim           # pkgs.neovim
  tree-sitter.tree-sitter-cli # pkgs.tree-sitter; nvim-treesitter needs it to build parsers
  astral-sh.uv            # pkgs.uv
  mvdan.shfmt             # pkgs.shfmt
  GitHub.cli              # pkgs.gh
  Kubernetes.kubectl      # pkgs.kubectl
  FluxCD.Flux             # pkgs.fluxcd
  Hashicorp.Terraform     # pkgs.terraform
  Volta.Volta             # pkgs.volta
  GoLang.Go               # macOS gets go only inside home-manager activation;
                          # here the Go CLIs need a real toolchain on PATH
  Starship.Starship       # programs.starship
)

# Pinned, because winget has no package for either. See Step 5.
HACK_NERD_FONT_VERSION="3.5.0" # https://github.com/ryanoasis/nerd-fonts/releases
KUBESEAL_VERSION="0.39.1"      # https://github.com/bitnami-labs/sealed-secrets/releases

# Mirrors globalNpmPackages in home.nix.
GLOBAL_NPM_PACKAGES=(
  "@earendil-works/pi-coding-agent@^0.84.2"
  "gh-axi@^0.1.30"
  "chrome-devtools-axi@^0.1.29"
  "quota-axi@^0.1.29"
  "npm-axi@^0.1.1"
  "lavish-axi@^0.1.53"
  "tasks-axi@^0.2.5"
)

# Mirrors axiAmbientContextTools in home.nix.
AXI_AMBIENT_CONTEXT_TOOLS=(lavish-axi tasks-axi)

# Mirrors goPackages in home.nix.
GO_PACKAGES=(
  "github.com/kunchenguid/no-mistakes/cmd/no-mistakes@v1.53.0"
  "github.com/kunchenguid/treehouse@v1.8.0"
)

# Mirrors secretEnvVars in home.nix.
SECRET_ENV_VARS=(
  CONTEXT7_API_KEY # mcp.json: context7 headers
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Anything worth telling the captain about at the end rather than losing in
# several hundred lines of install output.
WARNINGS=()

warn() {
  WARNINGS+=("$1")
  echo "    WARNING: $1" >&2
}

# Windows programs get their arguments mangled by the MSYS runtime: a bare
# `/f` looks like an absolute POSIX path and is rewritten to a drive path.
# MSYS_NO_PATHCONV=1 turns that off for one command, which is what every
# reg.exe / cmd.exe call below needs.
win() {
  MSYS_NO_PATHCONV=1 "$@"
}

# `test -x` does not know about the implicit .exe suffix that MSYS applies when
# it actually runs a command, so check for both spellings.
have_file() {
  [ -f "$1" ] || [ -f "$1.exe" ] || [ -f "$1.cmd" ]
}

# The Git Bash launcher, as a Windows path. Not `command -v bash`: that resolves
# to Git\usr\bin\bash.exe, the raw MSYS shell, where Git\bin\bash.exe is the
# wrapper that sets MSYSTEM and the right PATH. Which prefix it lives under
# depends on whether Git was installed machine-wide or per-user.
git_bash_path() {
  local root candidate
  for root in "${ProgramW6432:-}" "${ProgramFiles:-}" "${LOCALAPPDATA:-}\\Programs"; do
    [ -n "$root" ] || continue
    candidate="$(cygpath -u "$root" 2>/dev/null)/Git/bin/bash.exe"
    if [ -f "$candidate" ]; then
      cygpath -w "$candidate"
      return 0
    fi
  done
  cygpath -w "$(command -v bash)"
}

# ---------------------------------------------------------------------------
# Preflight
# ---------------------------------------------------------------------------

case "${OSTYPE:-}" in
msys* | cygwin*) ;;
*)
  echo "Error: setup/windows.sh has to run from Git for Windows' bash." >&2
  echo "Detected OSTYPE='${OSTYPE:-unset}'." >&2
  exit 1
  ;;
esac

if ! command -v winget >/dev/null 2>&1; then
  echo "Error: winget is not on PATH." >&2
  echo "It ships with Windows 11 as App Installer. Install or update it from" >&2
  echo "the Microsoft Store ('App Installer'), then re-run this script." >&2
  exit 1
fi

LOCALAPPDATA_DIR="$(cygpath -u "${LOCALAPPDATA:?LOCALAPPDATA is not set}")"

TMP_ROOT="$(mktemp -d)"
cleanup() { rm -rf "$TMP_ROOT"; }
trap cleanup EXIT

echo "==> Step 1: latest Git for Windows"
# The ticket's one hard requirement about Git: ensure the latest is installed
# on every run, without reinstalling when it is already current.
#
# winget's exit status is not the signal to read here. `winget upgrade` exits
# non-zero both when there is nothing to do and when something went wrong, so
# judge on git's own version instead and only inspect the log to tell those two
# cases apart.
GIT_VERSION_BEFORE="$(git --version 2>/dev/null || echo "unknown")"
GIT_UPGRADE_LOG="$TMP_ROOT/git-upgrade.log"
winget upgrade --id Git.Git --exact --silent \
  --accept-package-agreements --accept-source-agreements \
  --disable-interactivity >"$GIT_UPGRADE_LOG" 2>&1 || true
GIT_VERSION_AFTER="$(git --version 2>/dev/null || echo "unknown")"

if [ "$GIT_VERSION_BEFORE" != "$GIT_VERSION_AFTER" ]; then
  echo "    upgraded: $GIT_VERSION_BEFORE -> $GIT_VERSION_AFTER"
elif grep -qiE "no (applicable|available|newer|installed)" "$GIT_UPGRADE_LOG"; then
  # "no installed package" is in that list because a Git installed outside
  # winget is invisible to `winget upgrade`. Step 4 installs Git.Git for real in
  # that case, which registers it, so the next run of this step can upgrade it.
  echo "    already current ($GIT_VERSION_AFTER)"
else
  # Most likely cause: the installer could not replace files that this very
  # Git Bash session has open. Not fatal -- the rest of the setup is still
  # worth doing -- but say so loudly and repeat it in the summary.
  tail -n 5 "$GIT_UPGRADE_LOG" >&2 || true
  warn "Git for Windows may be out of date ($GIT_VERSION_AFTER). Close every Git Bash and WezTerm window, then run: winget upgrade --id Git.Git -e"
fi

echo "==> Step 2: native symlink capability"
# Every dotfile below is a symlink into this repo, which is what makes editing
# a config here take effect with no rebuild -- the same contract home.nix's
# mkOutOfStoreSymlink gives on macOS. Windows only lets an unprivileged user
# create symlinks when Developer Mode is on, so establish that first and fail
# early rather than half-way through linking.
#
# MSYS would otherwise silently fall back to copying files, which would break
# edit-in-place and let a later run clobber edits; nativestrict makes it fail
# instead.
can_symlink() {
  local probe="$TMP_ROOT/symlink-probe"
  rm -rf "$probe" "$probe.link"
  mkdir -p "$probe"
  MSYS=winsymlinks:nativestrict ln -s "$probe" "$probe.link" 2>/dev/null
}

if can_symlink; then
  echo "    already allowed"
else
  echo "    not allowed yet; enabling Developer Mode (expect one UAC prompt)"
  DEV_MODE_PS1="$TMP_ROOT/enable-developer-mode.ps1"
  cat >"$DEV_MODE_PS1" <<'PS1'
$key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
New-Item -Path $key -Force | Out-Null
Set-ItemProperty -Path $key -Name AllowDevelopmentWithoutDevLicense -Value 1 -Type DWord
PS1
  powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \
    "Start-Process -Verb RunAs -Wait -FilePath powershell.exe -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','$(cygpath -w "$DEV_MODE_PS1")'" \
    >/dev/null 2>&1 || true

  # The flag is read when CreateSymbolicLinkW is called, not at logon, so it
  # takes effect for the very next attempt.
  if can_symlink; then
    echo "    enabled"
  else
    echo "Error: cannot create symbolic links." >&2
    echo "Turn on Settings > System > For developers > Developer Mode (or run" >&2
    echo "this script from an elevated Git Bash) and try again." >&2
    exit 1
  fi
fi

echo "==> Step 3: symlink this repo to ~/.dotfiles"
# Same indirection macOS uses: every link below points through ~/.dotfiles, so
# the recorded path is identical on both platforms and moving the checkout only
# needs this one link repointed.
DOTFILES="$HOME/.dotfiles"
if [ -L "$DOTFILES" ]; then
  rm -f "$DOTFILES"
elif [ -e "$DOTFILES" ]; then
  echo "Error: $DOTFILES exists and is not a symlink. Move it aside first." >&2
  exit 1
fi
MSYS=winsymlinks:nativestrict ln -s "$SCRIPT_DIR" "$DOTFILES"

# Now that ~/.dotfiles exists, define the linker the dotfile step uses.
link() {
  local target="$1" link_path="$2"
  mkdir -p "$(dirname "$link_path")"

  if [ -L "$link_path" ]; then
    # Compare where it actually resolves rather than the stored string: MSYS
    # records native symlinks with a Windows path, so the raw readlink output
    # never matches the POSIX path handed in here.
    if [ "$(readlink -f "$link_path" 2>/dev/null)" = "$(readlink -f "$target" 2>/dev/null)" ]; then
      return 0
    fi
    rm -f "$link_path"
  elif [ -e "$link_path" ]; then
    # Something real is already there. Move it aside rather than destroy it --
    # the same contract as home-manager.backupFileExtension = "bak" in
    # flake.nix.
    echo "    backing up $link_path -> $link_path.bak"
    rm -rf "$link_path.bak"
    mv "$link_path" "$link_path.bak"
  fi

  MSYS=winsymlinks:nativestrict ln -s "$target" "$link_path"
}

echo "==> Step 4: applications and CLI tools (winget)"
# Install-if-missing, never force-upgrade. That matches macOS, where brew
# bundle installs what is missing and leaves installed versions alone
# (homebrew.onActivation.upgrade is off), and it is what keeps a re-run fast.
for id in "${WINGET_PACKAGES[@]}"; do
  if winget list --id "$id" --exact --accept-source-agreements >/dev/null 2>&1; then
    echo "    $id (installed)"
    continue
  fi
  echo "    $id (installing)"
  if ! winget install --id "$id" --exact --silent \
    --accept-package-agreements --accept-source-agreements \
    --disable-interactivity; then
    warn "winget could not install $id"
  fi
done

# winget puts its shims in %LOCALAPPDATA%\Microsoft\WinGet\Links and adds that
# directory to the *Windows* user PATH. This bash process inherited its PATH
# long before any of that happened, so the rest of this run would not see the
# tools it just installed. Go and Volta ship MSIs that add their own entries,
# with the same problem.
PROGRAM_FILES_DIR="$(cygpath -u "${ProgramFiles:-C:\\Program Files}")"
for dir in \
  "$LOCALAPPDATA_DIR/Microsoft/WinGet/Links" \
  "$PROGRAM_FILES_DIR/Go/bin" \
  "$PROGRAM_FILES_DIR/Volta" \
  "$LOCALAPPDATA_DIR/Volta/bin"; do
  if [ -d "$dir" ]; then
    case ":$PATH:" in
    *":$dir:"*) ;;
    *) PATH="$dir:$PATH" ;;
    esac
  fi
done
export PATH

echo "==> Step 5: tools winget cannot deliver"
# winget first is the rule; these two are the exceptions, and each says why.

# The Hack Nerd Font: winget carries SourceFoundry.HackFonts, which is plain
# Hack without the patched glyphs. starship's prompt and eza's icons both need
# the Nerd Font variant, so take it from the upstream release instead.
FONT_DIR="$LOCALAPPDATA_DIR/Microsoft/Windows/Fonts"
if compgen -G "$FONT_DIR/HackNerdFont-*.ttf" >/dev/null; then
  echo "    Hack Nerd Font (installed)"
else
  echo "    Hack Nerd Font (installing v$HACK_NERD_FONT_VERSION)"
  FONT_ZIP="$TMP_ROOT/Hack.zip"
  FONT_EXTRACT="$TMP_ROOT/hack-nerd-font"
  if curl -fsSL --retry 2 -o "$FONT_ZIP" \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v${HACK_NERD_FONT_VERSION}/Hack.zip"; then
    mkdir -p "$FONT_EXTRACT" "$FONT_DIR"
    # Git Bash's tar cannot read zip archives; PowerShell's Expand-Archive is
    # always present and can.
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \
      "Expand-Archive -LiteralPath '$(cygpath -w "$FONT_ZIP")' -DestinationPath '$(cygpath -w "$FONT_EXTRACT")' -Force" \
      >/dev/null 2>&1 || true

    FONTS_INSTALLED=0
    for ttf in "$FONT_EXTRACT"/*.ttf; do
      [ -f "$ttf" ] || continue
      base="$(basename "$ttf")"
      cp -f "$ttf" "$FONT_DIR/$base"
      # Copying the file is enough for WezTerm, which scans the per-user font
      # directory itself; the registry entry is what makes the font show up in
      # every other Windows application.
      win reg.exe add "HKCU\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Fonts" \
        /v "${base%.ttf} (TrueType)" /t REG_SZ \
        /d "$(cygpath -w "$FONT_DIR/$base")" /f >/dev/null
      FONTS_INSTALLED=$((FONTS_INSTALLED + 1))
    done

    if [ "$FONTS_INSTALLED" -eq 0 ]; then
      warn "the Hack Nerd Font archive extracted no .ttf files; WezTerm will fall back to a system font"
    else
      echo "    installed $FONTS_INSTALLED font files"
    fi
  else
    warn "could not download the Hack Nerd Font; WezTerm will fall back to a system font"
  fi
fi

# kubeseal: no winget package at all, and the upstream release is a single
# static binary, so drop it next to the other user-scoped commands.
KUBESEAL_BIN="$HOME/.local/bin/kubeseal"
if have_file "$KUBESEAL_BIN" && "$KUBESEAL_BIN" --version 2>/dev/null | grep -q "$KUBESEAL_VERSION"; then
  echo "    kubeseal (installed)"
else
  echo "    kubeseal (installing v$KUBESEAL_VERSION)"
  KUBESEAL_TGZ="$TMP_ROOT/kubeseal.tar.gz"
  if curl -fsSL --retry 2 -o "$KUBESEAL_TGZ" \
    "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-windows-amd64.tar.gz"; then
    mkdir -p "$HOME/.local/bin"
    # Never fatal: a changed archive layout must not take the whole setup down.
    tar -xzf "$KUBESEAL_TGZ" -C "$HOME/.local/bin" kubeseal.exe ||
      warn "kubeseal v$KUBESEAL_VERSION downloaded but kubeseal.exe was not where expected in the archive"
  else
    warn "could not download kubeseal v$KUBESEAL_VERSION"
  fi
fi

echo "==> Step 6: Node toolchain and global agent CLIs"
# Volta defaults to %LOCALAPPDATA%\Volta on Windows. Point it at ~/.volta
# instead so one path works on both platforms -- home.nix, the shell configs
# and the shared session-start hook all reach for $VOLTA_HOME/bin.
VOLTA_HOME="$HOME/.volta"
export VOLTA_HOME
VOLTA_HOME_WIN="$(cygpath -w "$VOLTA_HOME")"
CURRENT_VOLTA_HOME="$(powershell.exe -NoProfile -Command \
  "[Environment]::GetEnvironmentVariable('VOLTA_HOME','User')" 2>/dev/null | tr -d '\r')"
if [ "$CURRENT_VOLTA_HOME" != "$VOLTA_HOME_WIN" ]; then
  # Windows-native processes (Volta's own shims, anything launched outside
  # bash) read this from the user environment, not from ~/.bashrc.
  win setx VOLTA_HOME "$VOLTA_HOME_WIN" >/dev/null
  echo "    set user VOLTA_HOME=$VOLTA_HOME_WIN"
fi
PATH="$VOLTA_HOME/bin:$PATH"
export PATH

if have_file "$VOLTA_HOME/bin/npm"; then
  echo "    node (installed)"
elif command -v volta >/dev/null 2>&1; then
  echo "    node (installing latest LTS via volta)"
  volta install node || warn "volta could not install node"
else
  warn "volta is not on PATH; skipped Node and every global npm CLI"
fi

if have_file "$VOLTA_HOME/bin/npm"; then
  for pkg in "${GLOBAL_NPM_PACKAGES[@]}"; do
    # Each entry is a semver range; npm no-ops when the installed version
    # already satisfies it, so this is both the install and the upgrade path.
    # --ignore-scripts skips install-time lifecycle scripts, a common
    # supply-chain vector, exactly as home.nix does.
    echo "    npm -g $pkg"
    "$VOLTA_HOME/bin/npm" install -g --ignore-scripts "$pkg" >/dev/null ||
      warn "npm could not install $pkg"
  done
fi

echo "==> Step 7: Go CLIs"
if command -v go >/dev/null 2>&1; then
  mkdir -p "$HOME/go/bin"
  # go.exe is a native Windows program, and MSYS rewrites arguments that look
  # like paths but never environment variables -- so GOBIN has to be handed
  # over already in Windows form or Go writes to a "C:\c\Users\..." of its own
  # invention.
  GOBIN_WIN="$(cygpath -w "$HOME/go/bin")"
  for pkg in "${GO_PACKAGES[@]}"; do
    echo "    go install $pkg"
    # Pinned @<tag> refs go through Go's module system, which verifies against
    # sum.golang.org -- the reason home.nix prefers this over each project's
    # own unpinned curl | sh installer.
    GOBIN="$GOBIN_WIN" go install "$pkg" ||
      warn "go install $pkg failed; if it needs cgo, install a C toolchain (winget install MSYS2.MSYS2) and re-run"
  done
else
  warn "go is not on PATH; skipped no-mistakes and treehouse"
fi

echo "==> Step 8: dotfiles"
# The Windows half of home.nix's home.file block. Every path that differs from
# macOS says why on the spot.

# Directories.
link "$DOTFILES/home/.agents/skills" "$HOME/.agents/skills"
link "$DOTFILES/home/.config/wezterm" "$HOME/.config/wezterm"
link "$DOTFILES/home/.pi/agent/agents" "$HOME/.pi/agent/agents"
# Claude Code reads the same harness sources as pi: one source of truth, two
# harnesses pointing at it.
link "$DOTFILES/home/.agents/skills" "$HOME/.claude/skills"
link "$DOTFILES/home/.pi/agent/agents" "$HOME/.claude/agents"
# Neovim on Windows resolves stdpath('config') to %LOCALAPPDATA%\nvim, not
# ~/.config/nvim, so this is the one config directory that moves.
link "$DOTFILES/home/.config/nvim" "$LOCALAPPDATA_DIR/nvim"
# The completions are bash `complete -F` scripts. macOS loads them into zsh
# through bashcompinit from ~/.config/zsh/bin-completion; bash reads them
# natively from here.
link "$DOTFILES/home/bin-completion" "$HOME/.config/bash/bin-completion"
# herdr's config location on Windows is not documented upstream, and its
# Windows build is a beta. Only the XDG path macOS uses is linked. The
# %APPDATA%\herdr link is deliberately not created: %APPDATA%\<app> is where a
# Windows app writes runtime state, and a third-party write through an
# out-of-store symlink lands in this tracked public checkout -- the pattern
# AGENTS.md warns about. If herdr on Windows turns out to read %APPDATA%
# instead, copy the config there; never link it.
link "$DOTFILES/home/.config/herdr" "$HOME/.config/herdr"

# Files.
link "$DOTFILES/home/.pi/agent/themes/rose-pine-moon.json" "$HOME/.pi/agent/themes/rose-pine-moon.json"
link "$DOTFILES/home/.pi/agent/models.json" "$HOME/.pi/agent/models.json"
link "$DOTFILES/home/.pi/agent/settings.json" "$HOME/.pi/agent/settings.json"
link "$DOTFILES/home/.pi/agent/extensions/terminal-status-title.js" "$HOME/.pi/agent/extensions/terminal-status-title.js"
link "$DOTFILES/home/.pi/agent/extensions/axi-ambient-context.js" "$HOME/.pi/agent/extensions/axi-ambient-context.js"
link "$DOTFILES/home/.pi/agent/hook/hooks.yaml" "$HOME/.pi/agent/hook/hooks.yaml"
link "$DOTFILES/home/.pi/agent/hook/session-start.sh" "$HOME/.pi/agent/hook/session-start.sh"
link "$DOTFILES/home/AGENTS.md" "$HOME/.claude/CLAUDE.md"
link "$DOTFILES/home/AGENTS.md" "$HOME/.codex/AGENTS.md"
link "$DOTFILES/home/gitignore" "$HOME/.gitignore"
link "$DOTFILES/home/.gitconfig" "$HOME/.gitconfig"
link "$DOTFILES/home/.gitconfig-windows" "$HOME/.gitconfig-os"
link "$DOTFILES/home/.ssh/config" "$HOME/.ssh/config"
link "$DOTFILES/home/.ssh/config-windows" "$HOME/.ssh/config-os"
link "$DOTFILES/home/.config/1Password/ssh/agent.toml" "$HOME/.config/1Password/ssh/agent.toml"
link "$DOTFILES/home/.config/mcp/mcp.json" "$HOME/.config/mcp/mcp.json"
link "$DOTFILES/home/.config/starship.toml" "$HOME/.config/starship.toml"
# bash is the shell here, so these two stand in for programs.zsh in home.nix.
link "$DOTFILES/home/.bash_profile" "$HOME/.bash_profile"
link "$DOTFILES/home/.bashrc" "$HOME/.bashrc"
# Re-running this script is the rebuild, so devtools-rebuild points at it
# rather than at rebuild.sh (which is zsh and darwin-rebuild only).
link "$DOTFILES/setup/windows.sh" "$HOME/.local/bin/devtools-rebuild"

# The custom commands, one link each, exactly as home.nix does it.
for script in "$SCRIPT_DIR"/home/bin/*; do
  name="$(basename "$script")"
  link "$DOTFILES/home/bin/$name" "$HOME/.local/bin/$name"
done

# Claude Code on Windows needs to be told where bash is before it will run a
# bash hook -- and every hook in this repo is a bash script.
CLAUDE_BASH="$(git_bash_path)"
CURRENT_CLAUDE_BASH="$(powershell.exe -NoProfile -Command \
  "[Environment]::GetEnvironmentVariable('CLAUDE_CODE_GIT_BASH_PATH','User')" 2>/dev/null | tr -d '\r')"
if [ "$CURRENT_CLAUDE_BASH" != "$CLAUDE_BASH" ]; then
  win setx CLAUDE_CODE_GIT_BASH_PATH "$CLAUDE_BASH" >/dev/null
  echo "    set user CLAUDE_CODE_GIT_BASH_PATH=$CLAUDE_BASH"
fi

echo "==> Step 9: secrets file"
# Mirrors home.activation.ensureEnvFile: stub every key without touching a
# value that is already set, so adding a key later tops the file up.
ENV_FILE="$HOME/.env"
if [ ! -e "$ENV_FILE" ]; then
  install -m 600 /dev/null "$ENV_FILE"
  {
    echo "# Secrets sourced by bash on startup. Never commit this file."
    echo "# Quote values containing spaces or shell metacharacters."
    echo
  } >>"$ENV_FILE"
fi
for var in "${SECRET_ENV_VARS[@]}"; do
  if ! grep -q "^$var=" "$ENV_FILE"; then
    echo "$var=" >>"$ENV_FILE"
    echo "    stubbed $var in ~/.env -- set its value"
  fi
done

echo "==> Step 10: Claude Code settings and MCP servers"
# Both merges exist for the same reason they do in home.nix: these two files
# are not exclusively ours. ~/.claude.json also holds auth, history and
# per-project state, and ~/.claude/settings.json is written by the AXI
# `setup hooks` commands in Step 11, whose writes would follow a symlink
# straight into this public repo.
if ! command -v jq >/dev/null 2>&1; then
  warn "jq is not on PATH; skipped the Claude Code settings and MCP merges"
else
  CLAUDE_SETTINGS="$HOME/.claude/settings.json"
  SETTINGS_SRC="$SCRIPT_DIR/home/.config/.claude/settings.json"
  mkdir -p "$HOME/.claude"
  if [ -L "$CLAUDE_SETTINGS" ]; then
    rm -f "$CLAUDE_SETTINGS"
  fi
  CURRENT_SETTINGS="$TMP_ROOT/claude-settings-current.json"
  if [ -f "$CLAUDE_SETTINGS" ]; then
    cp "$CLAUDE_SETTINGS" "$CURRENT_SETTINGS"
  else
    echo '{}' >"$CURRENT_SETTINGS"
  fi
  # `.[0] * .[1]` deep-merges with this repo winning, so settings Claude Code
  # writes itself survive. hooks.SessionStart is an array, so it is replaced
  # outright and Step 11 puts the AXI entries back.
  if jq -s '.[0] * .[1]' "$CURRENT_SETTINGS" "$SETTINGS_SRC" >"$TMP_ROOT/claude-settings.json"; then
    mv "$TMP_ROOT/claude-settings.json" "$CLAUDE_SETTINGS"
    echo "    merged ~/.claude/settings.json"
  else
    warn "jq merge failed; left ~/.claude/settings.json unchanged"
  fi

  CLAUDE_JSON="$HOME/.claude.json"
  MCP_SRC="$HOME/.config/mcp/mcp.json"
  if [ -f "$CLAUDE_JSON" ] && [ -f "$MCP_SRC" ]; then
    if jq --slurpfile mcp "$MCP_SRC" \
      '.mcpServers = ((.mcpServers // {}) + $mcp[0].mcpServers)' \
      "$CLAUDE_JSON" >"$TMP_ROOT/claude.json"; then
      mv "$TMP_ROOT/claude.json" "$CLAUDE_JSON"
      echo "    merged MCP servers into ~/.claude.json"
    else
      warn "jq merge failed; left ~/.claude.json unchanged"
    fi
  fi
fi

echo "==> Step 11: AXI ambient-context hooks"
# Each command is idempotent and repairs a stale binary path after a
# reinstall, so running it every time is a no-op once everything is in place.
for tool in "${AXI_AMBIENT_CONTEXT_TOOLS[@]}"; do
  if have_file "$VOLTA_HOME/bin/$tool"; then
    echo "    $tool setup hooks"
    "$VOLTA_HOME/bin/$tool" setup hooks >/dev/null ||
      warn "\`$tool setup hooks\` failed; agents start without its ambient context"
  fi
done

echo "==> Step 12: Windows system defaults"
# The Windows half of system.defaults in configuration.nix. reg.exe writes the
# same value on every run, so this is idempotent by construction.
# windows-parity.md records the macOS defaults that have no equivalent here and
# the ones deliberately left alone.
reg_dword() {
  win reg.exe add "$1" /v "$2" /t REG_DWORD /d "$3" /f >/dev/null
}
reg_sz() {
  win reg.exe add "$1" /v "$2" /t REG_SZ /d "$3" /f >/dev/null
}

THEMES_KEY="HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize"
EXPLORER_KEY="HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced"

reg_dword "$THEMES_KEY" AppsUseLightTheme 0   # NSGlobalDomain.AppleInterfaceStyle = Dark
reg_dword "$THEMES_KEY" SystemUsesLightTheme 0
reg_dword "$EXPLORER_KEY" HideFileExt 0       # AppleShowAllExtensions
reg_dword "$EXPLORER_KEY" HideIcons 1         # finder.CreateDesktop = false
reg_sz "HKCU\\Control Panel\\Keyboard" KeyboardDelay 0   # InitialKeyRepeat
reg_sz "HKCU\\Control Panel\\Keyboard" KeyboardSpeed 31  # KeyRepeat
# trackpad.Clicking = false. Harmless on a machine with no precision touchpad.
reg_dword "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\PrecisionTouchPad" TapsEnabled 0
echo "    applied; Explorer settings show up after a sign-out or an Explorer restart"

echo "==> Step 13: Windows OpenSSH client"
# home/.gitconfig-windows pins core.sshCommand to this exact binary, because it
# is the only ssh that can reach 1Password's named-pipe agent. It ships as an
# optional Windows feature, so a machine without it fails every git fetch and
# push with a bare "cannot run" error. Resolve it from SystemRoot rather than
# hardcoding C:, and install the inbox capability when it is missing -- not the
# winget OpenSSH package, which installs somewhere else entirely and would not
# satisfy the pinned path.
SYSTEM_ROOT_DIR="$(cygpath -u "${SystemRoot:-${SYSTEMROOT:-C:\\Windows}}")"
OPENSSH_CLIENT="$SYSTEM_ROOT_DIR/System32/OpenSSH/ssh.exe"
if [ -f "$OPENSSH_CLIENT" ]; then
  echo "    already installed ($OPENSSH_CLIENT)"
else
  echo "    not installed; enabling the OpenSSH Client capability (expect one UAC prompt)"
  OPENSSH_PS1="$TMP_ROOT/install-openssh-client.ps1"
  cat >"$OPENSSH_PS1" <<'PS1'
$name = 'OpenSSH.Client~~~~0.0.1.0'
$cap = Get-WindowsCapability -Online -Name $name -ErrorAction SilentlyContinue
if ($cap -and $cap.State -ne 'Installed') {
  Add-WindowsCapability -Online -Name $name | Out-Null
}
PS1
  powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \
    "Start-Process -Verb RunAs -Wait -FilePath powershell.exe -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','$(cygpath -w "$OPENSSH_PS1")'" \
    >/dev/null 2>&1 || true

  if [ -f "$OPENSSH_CLIENT" ]; then
    echo "    installed"
  else
    warn "the Windows OpenSSH client is still missing from $OPENSSH_CLIENT; git over SSH will fail because .gitconfig-windows routes core.sshCommand through that exact path. From an elevated PowerShell run: Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0"
  fi
fi

echo "==> Step 14: 1Password commit signing"
# The signer's path embeds this machine's username, so it belongs in the
# untracked ~/.gitconfig.local next to the signing key -- not in the tracked
# .gitconfig-windows. `git config --file` edits that file surgically, so an
# existing user.signingkey is left alone.
OP_SSH_SIGN="$LOCALAPPDATA_DIR/1Password/app/8/op-ssh-sign.exe"
if [ -f "$OP_SSH_SIGN" ]; then
  git config --file "$HOME/.gitconfig.local" gpg.ssh.program "$(cygpath -m "$OP_SSH_SIGN")"
  echo "    pointed gpg.ssh.program at $OP_SSH_SIGN"
else
  warn "1Password's op-ssh-sign.exe is not installed yet; run this script again after signing in to 1Password so commit signing gets wired up"
fi

if ! git config --file "$HOME/.gitconfig.local" --get user.signingkey >/dev/null 2>&1; then
  cat <<'EOF'

===================================================================
NEXT STEP: add this machine's git signing key to ~/.gitconfig.local

  [user]
      signingkey = ssh-ed25519 AAAA...
===================================================================
EOF
fi

echo
echo "==> Done. Re-run this script (or devtools-rebuild) to apply later changes."
echo "    Open a new WezTerm window to pick up the new shell configuration."

if [ ${#WARNINGS[@]} -gt 0 ]; then
  echo
  echo "==> ${#WARNINGS[@]} warning(s):"
  for w in "${WARNINGS[@]}"; do
    echo "    - $w"
  done
fi

cat <<'EOF'

==> Deliberately not installed here; see setup/windows-parity.md for why:
    herdr        beta on Windows, and its installer is an unpinned
                 `irm https://herdr.dev/install.ps1 | iex`. Run that by hand
                 if you want it.
    twg          upstream supports macOS and Linux only; its installer
                 refuses to run on Windows.
    telepresence, weave gitops, tmux, ansible, mas, nix
EOF
