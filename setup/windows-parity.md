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

## Profiles

A machine has a **profile**, `personal` or `work`. `personal` is everything
installed before profiles existed and is the default whenever nothing selects
one. `work` is the same base minus an overlay that removes, plus one difference
that swaps rather than removes: firstmate comes from the
`andrew-codes` fork (see the rows below). `profiles.nix` holds the overlay for macOS, and
`setup/windows.sh` repeats it by hand (`WORK_OMIT_WINGET_PACKAGES`,
`WITH_1PASSWORD`, `WITH_KUBESEAL`, `WITH_FORK_TOOLS`) because Nix cannot evaluate here. Change both
together.

The profile is recorded outside the repo in `~/.config/devtools/profile` by
`setup/profile.sh`, which `setup.sh`, `setup/macOS.sh`, `setup/windows.sh` and
`rebuild.sh` all call. `--profile personal|work` writes the record; otherwise it
is read; otherwise `personal`. Any other value is rejected.

| macOS (`work` removes) | Windows (`work` removes) | Decision |
| --- | --- | --- |
| casks `1password`, `1password-cli` | `AgileBits.1Password`, `AgileBits.1Password.CLI` | **Implemented.** Both are filtered out of `WINGET_PACKAGES` for `work`. |
| brews `weaveworks/tap/gitops`, `datawire/blackbird/telepresence` | - | **Skipped** on Windows: neither is installed there under any profile (see Applications). |
| Mac App Store `Dynamic Wallpaper Library` (`mas-apps.nix`) | - | **Skipped** on Windows: no Mac App Store. `setup/macOS.sh` skips it for `work` through `profiles.masAppLines`. |
| `home.packages` `fluxcd` | `FluxCD.Flux` | **Implemented.** Filtered out of `WINGET_PACKAGES` for `work`. |
| `home.packages` `kubeseal` | the pinned `kubeseal` release download (step 5) | **Implemented.** Not downloaded for `work`. |
| oh-my-zsh `fluxcd` plugin | - | **Skipped** on Windows: it is a zsh plugin (see Shell). On macOS it is dropped for `work`, since it wraps a CLI `work` does not get. |
| `home.sessionVariables.SSH_AUTH_SOCK` -> 1Password socket | - | **Skipped** on Windows under every profile (see Shell). On macOS it is `personal` only. |
| `~/.config/1Password/ssh/agent.toml` link | same link | **Implemented.** `personal` only on both platforms. |
| `home.activation.installNoMistakes` (`noMistakesVersion`): `setup/no-mistakes.sh` installs the `andrew-codes/no-mistakes` release binary into `~/go/bin` | `setup/windows.sh` step 7 runs the same `setup/no-mistakes.sh` with `NO_MISTAKES_VERSION` (bump both) | **Implemented**, all profiles. One bash script shared by both platforms: downloads `no-mistakes-v<version>-<os>-<arch>.tar.gz` (`.zip` on Windows, extracted with PowerShell's `Expand-Archive` because Git for Windows has no `unzip`), verifies it against the release's `checksums.txt`, replaces the binary in one rename. Replaces both the old pinned upstream `go install` and the old fork source build; nothing installs `kunchenguid/no-mistakes` any more. On macOS the fork's arm64 binary is ad-hoc signed and its amd64 one unsigned; `curl` sets no quarantine flag and the script re-signs ad hoc if `codesign --verify` fails. A running daemon locks `no-mistakes.exe` on Windows (the script warns; run `no-mistakes daemon stop` and re-run). Windows path not executed by the author. |
| `home.activation.installForkTools` (`work` only): `setup/fork-tools.sh` clones `andrew-codes/firstmate` (`main`) and fast-forwards it | `setup/windows.sh` step 7 runs the same `setup/fork-tools.sh`, `WITH_FORK_TOOLS=1` for `work` | **Implemented.** One bash script shared by both platforms, so the guards and the update logic cannot drift. macOS runs it in home-manager activation (no network at evaluation, and the `personal` evaluation has no such step); Windows runs it in step 7. Clone: `~/developer/firstmate`, over HTTPS. Updates are `git fetch` plus `git merge --ff-only` only, and a checkout with uncommitted changes, on another branch, diverged or ahead, mid merge/rebase, or whose `origin` is not the fork is left untouched with a warning while setup continues. Not executed on Windows by the author. |
| `~/developer/firstmate` (assumed by `home/bin/firstmate`, installed by nothing) | same | **Implemented for `work`** by the row above. **Unchanged for `personal`**: devtools still installs nothing there on either platform. |
| `~/.gitconfig.os` -> `.gitconfig.macos` / `.gitconfig.windows` (op-ssh-sign, `core.sshCommand`) | same | **Implemented.** `work` links the empty `home/.gitconfig.work` instead, so no signer program and no ssh pin is set. On Windows the link is replaced, so one left by an earlier `personal` run stops pointing at 1Password. |
| `~/.ssh/config-os` -> `.ssh/config-macos` / `.ssh/config-windows` (1Password `IdentityAgent`) | same | **Implemented.** `work` links the empty `home/.ssh/config-work`. |
| - | step 13, Windows OpenSSH client | **Implemented.** `personal` only: it exists solely so `core.sshCommand` can reach 1Password's named-pipe agent. `work` has no such pin and git uses its bundled ssh. |
| - | step 14, 1Password commit signing (`gpg.ssh.program` in `~/.gitconfig.local`) | **Implemented.** `personal` only. `work` sets no signer; if a machine switched profiles and still carries 1Password's signer in `~/.gitconfig.local`, step 14 warns rather than editing that untracked file. |

Commit signing stays on for both profiles: `commit.gpgsign = true` and
`gpg.format = ssh` are in the shared `home/.gitconfig`, and `work` sets neither a
signing program nor a key. The key always comes from the untracked
`~/.gitconfig.local`, which `~/.gitconfig` includes unconditionally, so the
missing-key reminder (`configuration.nix` on macOS, step 14 on Windows) applies
to both profiles unchanged.

Not changed by a profile: what is already installed on a machine. Homebrew
cleanup stays `none` and nothing here uninstalls, so moving a machine from
`personal` to `work` stops managing the removed items; it does not remove them.

## Target

Native Windows on x86_64 with **Git for Windows' bash** as the shell -- not
WSL. That is what HO-243 asks for ("bash should be the default shell for
wezterm", and the repo is cloned with Git for Windows before setup runs).

`home/.gitconfig.windows` and `home/.ssh/config-windows` predate this work and
were written for WSL. They keep their names and their place in the existing
`~/.gitconfig` -> `~/.gitconfig.os` include scheme; only their contents moved to
native Windows.

## Platform machinery

| macOS | Windows | Decision |
| --- | --- | --- |
| Determinate Nix (`setup/macOS.sh` step 1) | - | **Skipped.** Nix has no native Windows support; it runs only under WSL, which is not this target. |
| nix-darwin (`configuration.nix`) | `setup/windows.sh` steps 4 and 12 | **Implemented** directly: winget for packages, `reg.exe` for system defaults. |
| home-manager (`home.nix`) | `setup/windows.sh` steps 6-11 | **Implemented** directly: symlinks, activation-equivalent steps, secrets file. |
| `flake.nix` / `flake.lock` pinning | pinned version constants in `setup/windows.sh` | **Implemented**, weaker. winget resolves "latest" per package; only the two non-winget downloads are version-pinned. |
| `~/.dotfiles` symlink | same | **Implemented** (step 3). |
| `rebuild.sh` -> `devtools-rebuild` | `setup/windows.sh` -> `devtools-rebuild` | **Implemented.** Re-running the setup script *is* the rebuild; it is idempotent by design. Both take `--profile personal\|work` and otherwise read the recorded profile (see Profiles). |
| `setup.sh` dispatch | same | **Implemented.** `./setup.sh` detects `msys`/`cygwin` and execs `setup/windows.sh`; `--profile` is passed through. |
| `setup/profile.sh` (profile flag, record and validation) | same script | **Implemented.** One bash script, shared by both platforms. |
| `flake.nix` `mac-<profile>` outputs (`mac` stays personal) | - | **Skipped.** Nix-only; `setup/windows.sh` filters its lists directly. |
| Mac App Store apps (`mas-apps.nix`, `mas`) | - | **Skipped.** No Mac App Store on Windows. The one entry (Dynamic Wallpaper Library) is a wallpaper app, not dev tooling. |
| Homebrew + `nix-homebrew` | winget | **Implemented.** winget is the default; the two exceptions below say why. |
| `home.activation.buildDiaSkills` (flattens `write-blog-post` into `~/.config/dia/skills`) | - | **Deferred.** Dia is installed on Windows now (see the `thebrowsercompany-dia` row), but where its Windows build reads skills from is unverified, so no file is generated. |
| `preActivation` swap of the `claude-code` cask for `claude-code@latest` | - | **Skipped.** Homebrew-only; winget has a single `Anthropic.ClaudeCode` package, so there is no second channel to conflict with. |
| - (macOS ships `ssh`) | Windows OpenSSH Client capability | **Implemented** (step 13), `personal` profile only. `.gitconfig.windows` pins `core.sshCommand` to the literal `C:/Windows/System32/OpenSSH/ssh.exe` (git config takes no environment expansion) because only the native client reaches 1Password's named-pipe agent, and that client is an optional feature. The step installs it with `Add-WindowsCapability` (the inbox feature, not the winget package, which lands elsewhere) and warns if it still is not there. |

## Applications (`configuration.nix` casks and brews)

| macOS | Windows | Decision |
| --- | --- | --- |
| `wezterm` | `wez.wezterm` | **Implemented.** Defaults to Git Bash on Windows - see "Shell" below. |
| `1password` | `AgileBits.1Password` | **Implemented.** `personal` only. |
| `1password-cli` | `AgileBits.1Password.CLI` | **Implemented.** `personal` only. |
| `docker-desktop` | `Docker.DockerDesktop` | **Implemented.** |
| `lens` | `Mirantis.Lens` | **Implemented.** |
| `logi-options+` | `Logitech.OptionsPlus` | **Implemented.** |
| `claude-code@latest` | `Anthropic.ClaudeCode` | **Implemented.** `Anthropic.ClaudeCode` has no separate stable/latest split like the two Homebrew casks - it's a single winget package bumped on every release. |
| `raycast` | `MSSTORE_PACKAGES` `9PFXXSHC64H3` (step 4) | **Implemented.** Raycast now ships for Windows, through the Microsoft Store only: raycast.com/windows redirects to Store id `9PFXXSHC64H3`, and the community winget repository has no Raycast package (no `manifests/r/Raycast`). Installed with `winget install --id 9PFXXSHC64H3 --source msstore`, unpinned. Replaces the earlier PowerToys substitute. Not executed on Windows by the author. |
| `thebrowsercompany-dia` (cask, unpinned) | Dia's own installer, `https://releases.diabrowser.com/windows/release/DiaInstaller.exe` (step 5) | **Implemented, fallback.** winget has no Dia package (`TheBrowserCompany` holds only `Arc`), so the script downloads the installer Dia publishes for Windows on diabrowser.com, from its stable "latest" URL, and runs it interactively because its silent flags are undocumented. Detection is an uninstall-registry entry named `Dia`, which is a guess; if the name differs the installer is just offered again on re-run. Not executed on Windows by the author. |
| `tmux` | - | **Skipped.** Git for Windows ships no tmux and it needs a POSIX pty. WezTerm's own tabs and panes, plus herdr, cover the use. |
| `mas` | - | **Skipped.** macOS-only by definition. |
| `herdr` | - | **Deferred.** Upstream publishes macOS and Linux binaries only; Windows is a beta whose sole install path is an unpinned `irm https://herdr.dev/install.ps1 \| iex`. That is below the bar this repo holds remote installers to (see the `twgVersion` comment in `home.nix`), so the script prints the command instead of running it. Its `~/.config/herdr` config is linked either way. |
| `weaveworks/tap/gitops` | - | **Deferred.** No winget package, and Weaveworks wound down in 2024. `flux` covers the maintained part of that workflow. macOS `personal` only. |
| `datawire/blackbird/telepresence` | - | **Deferred.** macOS `personal` only. No winget package; the Windows install needs an elevated daemon service, so run Ambassador's own installer on demand. |

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
| `fluxcd` | `FluxCD.Flux` | **Implemented.** `personal` only. |
| `terraform` | `Hashicorp.Terraform` | **Implemented.** |
| `volta` | `Volta.Volta` | **Implemented.** `VOLTA_HOME` is forced to `~/.volta` so one path works on both platforms. |
| `kubeseal` | GitHub release binary | **Implemented, fallback.** `personal` only. No winget package at all. The release is a single static binary, pinned by version in the script. |
| `nerd-fonts.hack` | GitHub release archive | **Implemented, fallback.** winget only carries `SourceFoundry.HackFonts`, which is plain Hack without the patched glyphs starship and eza need. |
| `ansible` | - | **Skipped.** Ansible does not support Windows as a control node. |
| `go` (activation-only on macOS) | `GoLang.Go` | **Implemented**, and installed for real: the Go CLIs below need a toolchain on PATH. |

## Agent harness

| macOS | Windows | Decision |
| --- | --- | --- |
| `globalNpmPackages` via Volta's npm (`pi`, `gh-axi`, `chrome-devtools-axi`, `quota-axi`, `npm-axi`, `lavish-axi`, `tasks-axi`, `twg-axi`) | same list, same `--ignore-scripts` | **Implemented** (step 6). The list is duplicated from `home.nix` because Nix cannot evaluate here; bump both together. `@andrew-codes/twg-axi` is included; it needs the `twg` CLI, see the row below. `backpass` and its `acpx` dependency are deliberately excluded here: backpass's own README states it supports macOS and Linux only, with no Windows build, so both are skipped on `setup/windows.sh`. |
| `goPackages` (`treehouse`) | `go install`, same pinned tag | **Implemented** (step 7). If it needs cgo, `go install` fails and the script says which C toolchain to add. no-mistakes is no longer a Go package; see the `installNoMistakes` row. |
| pi extensions (`home/.pi/agent/settings.json`) | same file, linked | **Implemented.** pi installs them itself from the linked settings. |
| `~/.claude/settings.json` merge | same jq merge | **Implemented** (step 10), for the same reason: the AXI hook installers write into that file and their writes follow symlinks. |
| `~/.claude.json` MCP merge | same jq merge | **Implemented** (step 10). |
| AXI `setup hooks` | same | **Implemented** (step 11). |
| `twg` CLI (`twgVersion`) | `install.ps1` from Atlassian, run with `-Version` pinned to the same number (`TWG_VERSION` in `setup/windows.sh`; bump both) | **Implemented** (step 5). Atlassian's installation page lists Windows (x64, arm64) as supported and `SHA256SUMS-v1.4.4` publishes `twg-windows-x64-v1.4.4.exe` and `twg-windows-arm64-v1.4.4.exe`; `install.ps1` verifies the download against that file. Flags `-SkipLogin -SkipSkills -Yes` mirror the macOS activation script (no interactive OAuth, no skill files written through symlinks into this checkout, terms consent recorded), followed by `twg consent --agree`. Installs to `%LOCALAPPDATA%\Programs\twg\bin`. `twg login` is still a one-time manual step. Not executed on Windows by the author. |
| `@andrew-codes/twg-axi` | same entry in the Windows `GLOBAL_NPM_PACKAGES` | **Implemented** (step 6), alongside `twg` above. |
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
| oh-my-zsh `sudo`, `pj`, `docker`, `yarn`, `encode64`, `eza`, `fluxcd`, `gh`, `git-escape-magic` | - | **Skipped.** (`fluxcd` is dropped on macOS for the `work` profile.) These are zsh plugins; the binaries they wrap are all installed, only the aliases and completions they add are missing. |
| `shellAliases` (`..`, `add`, `m`, `cc`, `co`, `zl`) | same aliases in `~/.bashrc` | **Implemented.** `zl` is the Dracula page's always-colored eza alias. |
| `EZA_COLORS` (Dracula, "universal" value) | page's Windows value, `setx` in `setup/windows.sh` plus `EZA_WINDOWS_ATTRIBUTES` and `EZA_ICONS_AUTO`, and exported in `~/.bashrc` | **Implemented.** Windows deliberately uses the page's shorter Windows set, not the macOS one. |
| `~/.env` sourcing + unset-secret warning | same in `~/.bashrc` | **Implemented.** |
| `home.sessionPath` (`~/.local/bin`, `~/.volta/bin`, `~/go/bin`) | same, re-added idempotently in `~/.bashrc` | **Implemented.** The *Windows* user PATH is deliberately left alone; winget and Volta manage their own entries. |
| `EDITOR`, `REPO_HOME`, `VOLTA_HOME` | same | **Implemented.** |
| `SSH_AUTH_SOCK` -> 1Password socket (macOS `personal` only) | - | **Skipped.** 1Password on Windows serves the OpenSSH agent named pipe, which Git's bundled ssh cannot speak. `.gitconfig.windows` routes git through the native `ssh.exe`, which finds the pipe with no variable set. |
| `bin-completion` via `bashcompinit` | sourced natively from `~/.config/bash/bin-completion` | **Implemented.** They were already bash `complete -F` scripts. |
| `home/bin/*` custom commands | same files, linked into `~/.local/bin` | **Implemented.** Their shebangs moved from zsh to bash so they run on both platforms; `aup` and `kaup` gained `netstat`/`taskkill` branches because Windows has no `lsof`. |

## Dotfiles and paths

All linked with native symlinks (step 2 ensures Developer Mode), so editing a
config in this repo takes effect with no rebuild - the same contract
`mkOutOfStoreSymlink` gives on macOS.

| Path | Windows | Decision |
| --- | --- | --- |
| `~/.config/wezterm`, `~/.agents/skills`, `~/.claude/{skills,agents,CLAUDE.md}`, `~/.codex/AGENTS.md`, `~/.pi/agent/*`, `~/.gitconfig`, `~/.gitignore`, `~/.ssh/config`, `~/.config/mcp/mcp.json` | identical paths | **Implemented.** |
| `~/.config/1Password/ssh/agent.toml` | identical path | **Implemented.** `personal` only. |
| `~/.config/nvim` | `%LOCALAPPDATA%\nvim` | **Implemented, moved.** Neovim resolves `stdpath('config')` there on Windows. |
| `~/.config/zsh/bin-completion` | `~/.config/bash/bin-completion` | **Implemented, moved.** bash, not zsh. |
| `~/.config/herdr` | `~/.config/herdr` only | **Implemented, single link.** herdr's Windows config path is undocumented upstream, but the `%APPDATA%\herdr` candidate is deliberately not linked: `%APPDATA%\<app>` is where a Windows app writes runtime state, and those writes would follow the symlink into this tracked public checkout. If herdr turns out to read `%APPDATA%`, copy the config there rather than linking it. |
| `~/.gitconfig.os` | `home/.gitconfig.windows` (`personal`) or `home/.gitconfig.work` (`work`) | **Implemented.** Same include scheme as macOS. The file was `~/.gitconfig-os` (and `home/.gitconfig-*`) before the rename; step 8 removes a stale `~/.gitconfig-os` only when it is a link into this repo's `home/`, and otherwise warns and leaves it. |
| `~/.ssh/config-os` | `home/.ssh/config-windows` (`personal`) or `home/.ssh/config-work` (`work`) | **Implemented.** Same include scheme as macOS. |
| `~/.gitconfig.local` (untracked signing key and `user.email`) | same; on `personal` also `gpg.ssh.program` | **Implemented.** The tracked `.gitconfig` sets no `user.email`; step 14 prints a reminder with the `git config --file` command when the file lacks one. The 1Password signer path embeds the username, so the script resolves and writes it there rather than tracking it. `work` writes nothing there; the key is added by hand. |
| `~/.config/devtools/profile` (the recorded profile) | same | **Implemented.** Written by `setup/profile.sh`; outside the repo, never tracked. |
| `~/.claude/settings.json` | merged, not linked | **Implemented.** Same reason as macOS. |
| `~/.claude/themes/dracula.json` (Dracula theme, `dracula/claude-code-cli` pinned commit) | same path, copied | **Implemented, copied.** macOS uses `pkgs.fetchurl` with a fixed hash; Windows has no Nix, so step 8 downloads the same commit and verifies the same sha256 (bump both together). `theme` is set to `custom:dracula` in the shared `home/.config/.claude/settings.json`, which the step 10 merge applies on both platforms. |
| lazygit Dracula theme (`dracula/lazygit` pinned commit, `home/.config/lazygit/dracula.yml`) | `%APPDATA%\lazygit\config.yml`, merged | **Implemented, merged.** macOS merges into the path `lazygit -cd` reports (`~/Library/Application Support/lazygit` by default) in `home.activation.syncLazygitTheme`; Windows reads `%APPDATA%\lazygit`. Both use mikefarah `yq` to deep-merge with the repo winning, so other keys in the file survive. Not linked: it is app-owned state. Step 10 skips with a warning if `yq` is not yet on PATH. |
| `~/.pi/agent/themes/dracula.json` (Dracula theme, `dracula/pi-coding-agent` pinned commit) | same path, copied | **Implemented, copied.** macOS uses `pkgs.fetchurl` with a fixed hash; Windows step 8 downloads the same commit and verifies the same sha256 (bump both together). `theme` is set to `dracula` in the shared, linked `home/.pi/agent/settings.json`, so it arrives on both platforms. |

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
2. **`go install` and cgo.** If `treehouse` pulls a cgo
   dependency, Go needs a C toolchain that Git for Windows does not ship.
3. **pi on Windows.** `@earendil-works/pi-coding-agent` installs from npm, but
   it is untested here.
4. **herdr's config path**, if herdr is installed by hand. Only `~/.config/herdr`
   is linked; if the Windows build reads `%APPDATA%\herdr` instead, copy the
   config there - never link it, or herdr's own state writes land in this repo.
5. **1Password `agent.toml`** (`personal` profile) names the `andrew-mbp` key
   item. Add this machine's item to `home/.config/1Password/ssh/agent.toml`.
6. **`core.editor = zed --wait`** in the shared `~/.gitconfig` assumes Zed, and
   `home/bin/oproj` calls `code`. Neither editor is installed by the macOS path
   either, so neither is installed here - but on Windows there is no fallback
   `zed` on PATH at all, so `git commit` without `-m` will fail until one is
   installed by hand.
7. **The `work` profile on Windows** (`--profile work`) was only dry-read, like
   the rest. Check that the winget list loses exactly the three ids above, that
   step 7 runs `setup/no-mistakes.sh` (the release `.zip` extracted with
   PowerShell, `~/go/bin/no-mistakes.exe` replaced; the macOS path was run, the
   Windows path handling - `cygpath`, `Expand-Archive`, replacing a running
   `.exe` - was not) and `setup/fork-tools.sh` (clones the firstmate fork), that steps 13 and 14 skip, that `~/.gitconfig.os` and `~/.ssh/config-os` end up
   pointing at the `-work` files, and that a commit signs once
   `~/.gitconfig.local` has a key -- with no `gpg.ssh.program`, git falls back
   to the `ssh-keygen` bundled with Git for Windows.
