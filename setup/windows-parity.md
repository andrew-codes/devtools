# Windows parity inventory

Every piece of software and configuration the macOS path installs, mapped to
what the Windows path does about it. Nothing is left unstated: each row is
**Implemented**, **Skipped** (with the reason it does not apply), or
**Deferred** (applicable, but not done here, with what is in the way).

The macOS side is `setup/macOS.sh` + `configuration.nix` + `home.nix` +
`mas-apps.nix` + `home/`. The Windows side is `setup/windows.sh` alone: Nix has
no native Windows support, so one script carries what nix-darwin and
home-manager carry over there.

When you add something to the macOS path, add a row here.

## Target

Native Windows on x86_64 with **Git for Windows' bash** as the shell -- not
WSL. That is what HO-243 asks for ("bash should be the default shell for
wezterm", and the repo is cloned with Git for Windows before setup runs).

`home/.gitconfig-windows` and `home/.ssh/config-windows` predate this work and
were written for WSL. They keep their names and their place in the existing
`~/.gitconfig` -> `~/.gitconfig-os` include scheme; only their contents moved to
native Windows.

## Platform machinery

| macOS | Windows | Decision |
| --- | --- | --- |
| Determinate Nix (`setup/macOS.sh` step 1) | - | **Skipped.** Nix has no native Windows support; it runs only under WSL, which is not this target. |
| nix-darwin (`configuration.nix`) | `setup/windows.sh` steps 4 and 12 | **Implemented** directly: winget for packages, `reg.exe` for system defaults. |
| home-manager (`home.nix`) | `setup/windows.sh` steps 6-11 | **Implemented** directly: symlinks, activation-equivalent steps, secrets file. |
| `flake.nix` / `flake.lock` pinning | pinned version constants in `setup/windows.sh` | **Implemented**, weaker. winget resolves "latest" per package; only the two non-winget downloads are version-pinned. |
| `~/.dotfiles` symlink | same | **Implemented** (step 3). |
| `rebuild.sh` -> `devtools-rebuild` | `setup/windows.sh` -> `devtools-rebuild` | **Implemented.** Re-running the setup script *is* the rebuild; it is idempotent by design. |
| `setup.sh` dispatch | same | **Implemented.** `./setup.sh` detects `msys`/`cygwin` and execs `setup/windows.sh`. |
| Mac App Store apps (`mas-apps.nix`, `mas`) | - | **Skipped.** No Mac App Store on Windows. The one entry (Dynamic Wallpaper Library) is a wallpaper app, not dev tooling. |
| Homebrew + `nix-homebrew` | winget | **Implemented.** winget is the default; the two exceptions below say why. |
| - (macOS ships `ssh`) | Windows OpenSSH Client capability | **Implemented** (step 13). `.gitconfig-windows` pins `core.sshCommand` to the literal `C:/Windows/System32/OpenSSH/ssh.exe` (git config takes no environment expansion) because only the native client reaches 1Password's named-pipe agent, and that client is an optional feature. The step installs it with `Add-WindowsCapability` (the inbox feature, not the winget package, which lands elsewhere) and warns if it still is not there. |

## Applications (`configuration.nix` casks and brews)

| macOS | Windows | Decision |
| --- | --- | --- |
| `wezterm` | `wez.wezterm` | **Implemented.** Defaults to Git Bash on Windows - see "Shell" below. |
| `1password` | `AgileBits.1Password` | **Implemented.** |
| `1password-cli` | `AgileBits.1Password.CLI` | **Implemented.** |
| `docker-desktop` | `Docker.DockerDesktop` | **Implemented.** |
| `lens` | `Mirantis.Lens` | **Implemented.** |
| `logi-options+` | `Logitech.OptionsPlus` | **Implemented.** |
| `claude-code` | `Anthropic.ClaudeCode` | **Implemented.** |
| `raycast` | `Microsoft.PowerToys` | **Implemented, substituted.** Raycast ships no winget package. PowerToys Run is the equivalent keystroke launcher. |
| `tmux` | - | **Skipped.** Git for Windows ships no tmux and it needs a POSIX pty. WezTerm's own tabs and panes, plus herdr, cover the use. |
| `mas` | - | **Skipped.** macOS-only by definition. |
| `herdr` | - | **Deferred.** Upstream publishes macOS and Linux binaries only; Windows is a beta whose sole install path is an unpinned `irm https://herdr.dev/install.ps1 \| iex`. That is below the bar this repo holds remote installers to (see the `twgVersion` comment in `home.nix`), so the script prints the command instead of running it. Its `~/.config/herdr` config is linked either way. |
| `weaveworks/tap/gitops` | - | **Deferred.** No winget package, and Weaveworks wound down in 2024. `flux` covers the maintained part of that workflow. |
| `datawire/blackbird/telepresence` | - | **Deferred.** No winget package; the Windows install needs an elevated daemon service, so run Ambassador's own installer on demand. |

## CLI toolchain (`home.packages`)

| macOS | Windows | Decision |
| --- | --- | --- |
| `ripgrep` | `BurntSushi.ripgrep.MSVC` | **Implemented.** |
| `fd` | `sharkdp.fd` | **Implemented.** |
| `eza` | `eza-community.eza` | **Implemented.** |
| `fzf` | `junegunn.fzf` | **Implemented.** |
| `jq` | `jqlang.jq` | **Implemented.** |
| `yq` | `MikeFarah.yq` | **Implemented.** |
| `lazygit` | `JesseDuffield.lazygit` | **Implemented.** |
| `neovim` | `Neovim.Neovim` | **Implemented.** |
| `tree-sitter` | `tree-sitter.tree-sitter-cli` | **Implemented.** CLI nvim-treesitter needs to build parsers (`home/.config/nvim`, used for MDX highlighting among others). |
| `uv` | `astral-sh.uv` | **Implemented.** |
| `shfmt` | `mvdan.shfmt` | **Implemented.** |
| `gh` | `GitHub.cli` | **Implemented.** |
| `kubectl` | `Kubernetes.kubectl` | **Implemented.** |
| `fluxcd` | `FluxCD.Flux` | **Implemented.** |
| `terraform` | `Hashicorp.Terraform` | **Implemented.** |
| `volta` | `Volta.Volta` | **Implemented.** `VOLTA_HOME` is forced to `~/.volta` so one path works on both platforms. |
| `kubeseal` | GitHub release binary | **Implemented, fallback.** No winget package at all. The release is a single static binary, pinned by version in the script. |
| `nerd-fonts.hack` | GitHub release archive | **Implemented, fallback.** winget only carries `SourceFoundry.HackFonts`, which is plain Hack without the patched glyphs starship and eza need. |
| `ansible` | - | **Skipped.** Ansible does not support Windows as a control node. |
| `go` (activation-only on macOS) | `GoLang.Go` | **Implemented**, and installed for real: the Go CLIs below need a toolchain on PATH. |

## Agent harness

| macOS | Windows | Decision |
| --- | --- | --- |
| `globalNpmPackages` via Volta's npm (`pi`, `gh-axi`, `chrome-devtools-axi`, `quota-axi`, `npm-axi`, `lavish-axi`, `tasks-axi`) | same list, same `--ignore-scripts` | **Implemented** (step 6). The list is duplicated from `home.nix` because Nix cannot evaluate here; bump both together. |
| `goPackages` (`no-mistakes`, `treehouse`) | `go install`, same pinned tags | **Implemented** (step 7). If either needs cgo, `go install` fails and the script says which C toolchain to add. |
| pi extensions (`home/.pi/agent/settings.json`) | same file, linked | **Implemented.** pi installs them itself from the linked settings. |
| `~/.claude/settings.json` merge | same jq merge | **Implemented** (step 10), for the same reason: the AXI hook installers write into that file and their writes follow symlinks. |
| `~/.claude.json` MCP merge | same jq merge | **Implemented** (step 10). |
| AXI `setup hooks` | same | **Implemented** (step 11). |
| `twg` CLI | - | **Skipped, with consequences.** Atlassian's installer hard-fails on anything that is not Darwin or Linux ("Only macOS and Linux are supported"), and there is no Windows build. `home/AGENTS.md` tells agents to use `twg` and never an Atlassian MCP, so on Windows agents have **no** Atlassian tooling - they should say so and stop, which is what that rule already prescribes. |
| Claude Code hooks running bash | `CLAUDE_CODE_GIT_BASH_PATH` | **Implemented.** Every hook here is a bash script; Claude Code on Windows needs to be told where bash is. Set in the user environment and in `~/.bashrc`. |

## Shell

macOS runs zsh; Windows runs bash, because that is what Git for Windows ships
and what HO-243 requires WezTerm to launch. `home/.bashrc` is the peer of
`programs.zsh` in `home.nix`.

| macOS | Windows | Decision |
| --- | --- | --- |
| zsh as login shell (`users.users.<user>.shell`) | bash via WezTerm's `default_prog` | **Implemented** in `home/.config/wezterm/wezterm.lua`, which resolves Git's `bash.exe` and starts it as a login shell. |
| `programs.starship` | `Starship.Starship` + `starship init bash` in `~/.bashrc` | **Implemented.** The prompt settings moved out of `home.nix` into a tracked `home/.config/starship.toml` that both platforms symlink, so one file gives both the same prompt. |
| zsh autosuggestions | readline history-search on Up/Down | **Implemented, weaker.** Full ghost-text needs `ble.sh`, a large third-party runtime; history-search covers the common case with what readline already has. |
| zsh syntax highlighting | - | **Skipped.** No bash equivalent without `ble.sh`. |
| oh-my-zsh `colored-man-pages` | `LESS_TERMCAP_*` | **Implemented.** |
| oh-my-zsh `sudo`, `pj`, `docker`, `yarn`, `encode64`, `eza`, `fluxcd`, `gh`, `git-escape-magic` | - | **Skipped.** These are zsh plugins; the binaries they wrap are all installed, only the aliases and completions they add are missing. |
| `shellAliases` (`..`, `add`, `m`, `cc`, `co`) | same aliases in `~/.bashrc` | **Implemented.** |
| `~/.env` sourcing + unset-secret warning | same in `~/.bashrc` | **Implemented.** |
| `home.sessionPath` (`~/.local/bin`, `~/.volta/bin`, `~/go/bin`) | same, re-added idempotently in `~/.bashrc` | **Implemented.** The *Windows* user PATH is deliberately left alone; winget and Volta manage their own entries. |
| `EDITOR`, `REPO_HOME`, `VOLTA_HOME` | same | **Implemented.** |
| `SSH_AUTH_SOCK` -> 1Password socket | - | **Skipped.** 1Password on Windows serves the OpenSSH agent named pipe, which Git's bundled ssh cannot speak. `.gitconfig-windows` routes git through the native `ssh.exe`, which finds the pipe with no variable set. |
| `bin-completion` via `bashcompinit` | sourced natively from `~/.config/bash/bin-completion` | **Implemented.** They were already bash `complete -F` scripts. |
| `home/bin/*` custom commands | same files, linked into `~/.local/bin` | **Implemented.** Their shebangs moved from zsh to bash so they run on both platforms; `aup` and `kaup` gained `netstat`/`taskkill` branches because Windows has no `lsof`. |

## Dotfiles and paths

All linked with native symlinks (step 2 ensures Developer Mode), so editing a
config in this repo takes effect with no rebuild - the same contract
`mkOutOfStoreSymlink` gives on macOS.

| Path | Windows | Decision |
| --- | --- | --- |
| `~/.config/wezterm`, `~/.agents/skills`, `~/.claude/{skills,agents,CLAUDE.md}`, `~/.codex/AGENTS.md`, `~/.pi/agent/*`, `~/.gitconfig`, `~/.gitignore`, `~/.ssh/config`, `~/.config/mcp/mcp.json`, `~/.config/1Password/ssh/agent.toml` | identical paths | **Implemented.** |
| `~/.config/nvim` | `%LOCALAPPDATA%\nvim` | **Implemented, moved.** Neovim resolves `stdpath('config')` there on Windows. |
| `~/.config/zsh/bin-completion` | `~/.config/bash/bin-completion` | **Implemented, moved.** bash, not zsh. |
| `~/.config/herdr` | `~/.config/herdr` only | **Implemented, single link.** herdr's Windows config path is undocumented upstream, but the `%APPDATA%\herdr` candidate is deliberately not linked: `%APPDATA%\<app>` is where a Windows app writes runtime state, and those writes would follow the symlink into this tracked public checkout. If herdr turns out to read `%APPDATA%`, copy the config there rather than linking it. |
| `~/.gitconfig-os` | `home/.gitconfig-windows` | **Implemented.** Same include scheme as macOS. |
| `~/.ssh/config-os` | `home/.ssh/config-windows` | **Implemented.** Same include scheme as macOS. |
| `~/.gitconfig.local` (untracked signing key) | same, plus `gpg.ssh.program` | **Implemented.** The 1Password signer path embeds the username, so the script resolves and writes it there rather than tracking it. |
| `~/.claude/settings.json` | merged, not linked | **Implemented.** Same reason as macOS. |

## System defaults (`system.defaults`)

| macOS | Windows | Decision |
| --- | --- | --- |
| `AppleInterfaceStyle = Dark` | `AppsUseLightTheme` / `SystemUsesLightTheme` = 0 | **Implemented.** |
| `AppleShowAllExtensions` | `HideFileExt` = 0 | **Implemented.** |
| `finder.CreateDesktop = false` | `HideIcons` = 1 | **Implemented.** |
| `KeyRepeat` / `InitialKeyRepeat` | `KeyboardSpeed` = 31, `KeyboardDelay` = 0 | **Implemented.** |
| `trackpad.Clicking = false` | `PrecisionTouchPad\TapsEnabled` = 0 | **Implemented.** No-op on a machine with no precision touchpad. |
| `dock.autohide` | - | **Deferred.** Taskbar auto-hide lives inside the `StuckRects3` binary blob; editing it by hand means rewriting an opaque byte and restarting Explorer. Not worth the fragility - toggle it in Settings. |
| `_HIHideMenuBar` | - | **Skipped.** Windows has no menu bar. |
| `finder.FXPreferredViewStyle = "Nlsv"` | - | **Deferred.** Explorer stores view style per folder in its Bags; there is no clean global equivalent. |
| Spotlight indexing off (`mdutil -i off`) | - | **Skipped.** The macOS line exists because Raycast replaces Spotlight. Windows Search also backs the Start menu, so disabling it costs more than it saves. |

## Known gaps and things to check on the real machine

Everything in this PR was written on macOS and could not be executed. In
priority order:

1. **Git upgrade under a live Git Bash.** Step 1 may fail to replace files this
   very session has open. The script detects that and prints the manual command;
   confirm which branch it takes.
2. **`go install` and cgo.** If `no-mistakes` or `treehouse` pull a cgo
   dependency, Go needs a C toolchain that Git for Windows does not ship.
3. **pi on Windows.** `@earendil-works/pi-coding-agent` installs from npm, but
   it is untested here.
4. **herdr's config path**, if herdr is installed by hand. Only `~/.config/herdr`
   is linked; if the Windows build reads `%APPDATA%\herdr` instead, copy the
   config there - never link it, or herdr's own state writes land in this repo.
5. **1Password `agent.toml`** names the `andrew-mbp` key item. Add this
   machine's item to `home/.config/1Password/ssh/agent.toml`.
6. **`core.editor = zed --wait`** in the shared `~/.gitconfig` assumes Zed, and
   `home/bin/oproj` calls `code`. Neither editor is installed by the macOS path
   either, so neither is installed here - but on Windows there is no fallback
   `zed` on PATH at all, so `git commit` without `-m` will fail until one is
   installed by hand.
