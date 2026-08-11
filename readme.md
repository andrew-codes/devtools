# Devtools

My **personal** developer workbench, defined declaratively with [Nix](https://nixos.org/). One command takes a clean machine to a fully configured environment: system settings, applications, CLI tooling, shell, dotfiles, and an AI agent harness.

Everything is reproducible and version controlled. Configuration files are symlinked back into this repo, so editing a config here takes effect immediately without a rebuild.

## Supported Platforms

| Platform | Status |
| --- | --- |
| macOS on Apple Silicon (`aarch64-darwin`) | Supported |
| Windows on x86_64, in Git for Windows' bash | Supported |
| macOS on Intel | Not supported |
| WSL | Not supported (the Windows path is native, not WSL) |

## Install

```bash
git clone https://github.com/andrew-codes/devtools.git ~/developer/repos/devtools
cd ~/developer/repos/devtools
./setup.sh
```

`setup.sh` detects the OS and architecture and dispatches to the matching platform script: `setup/macOS.sh` on Apple Silicon, `setup/windows.sh` on Windows. On any other platform it prints what was detected and exits rather than attempting an install.

On macOS nothing needs to be preinstalled; the setup script bootstraps Nix itself. On Windows, run it from Git for Windows' bash -- you already have that, since it is what cloned this repo.

### macOS

The macOS script:

1. Installs [Determinate Nix](https://determinate.systems/) if `nix` is not already present.
2. Symlinks the repo to `~/.dotfiles`, which every config path resolves through.
3. Offers to rewrite the `user = "..."` line in `flake.nix` to match your macOS username.
4. Trusts the Homebrew taps that already have something installed from them, so out-of-band installs survive later rebuilds. On a first-ever run there is no `brew` yet, so this is a no-op.
5. Acquires the Mac App Store apps listed in `mas-apps.nix` with `mas get`, then waits for each to land on disk.
6. Runs the first `darwin-rebuild switch` against the flake.

Sign in to the Mac App Store before step 5; `mas` cannot authenticate on its own, and it prompts for an admin password when it has real work to do. App Store apps are acquired here, as the real user in the real login session, rather than through nix-darwin's `homebrew.masApps` -- that option runs outside the per-user launchd session `mas` needs, so it would fail on every rebuild. `homebrew.masApps` is deliberately left empty.

### Windows

Nix does not run natively on Windows, so `setup/windows.sh` carries by itself what nix-darwin and home-manager carry on macOS. It:

1. Ensures the latest Git for Windows, upgrading only when one is available.
2. Ensures native symlinks are allowed, enabling Developer Mode (one UAC prompt) if they are not. Every dotfile is a symlink into this repo, exactly as on macOS.
3. Symlinks the repo to `~/.dotfiles`.
4. Installs applications and CLI tools with `winget`.
5. Installs the two things winget cannot deliver -- the Hack Nerd Font and `kubeseal` -- from their pinned upstream releases.
6. Installs Node via Volta and the global agent CLIs, then the Go CLIs.
7. Links every dotfile, stubs `~/.env`, merges Claude Code's settings and MCP servers, installs the AXI session hooks, applies the Windows system defaults, and wires up 1Password commit signing.

Expect UAC prompts during the winget step. Re-running is safe and is the supported way to apply later changes.

**[`setup/windows-parity.md`](setup/windows-parity.md) is the map**: every macOS package, config and system default, with what Windows does about it -- implemented, deliberately skipped with a reason, or deferred. Read it before adding anything to either platform.

Two consequences worth knowing up front: the shell is **bash**, not zsh, and WezTerm launches it by default; and the `twg` CLI has no Windows build at all, so agents have no Atlassian tooling there.

### Applying Changes Later

After the first install, rebuild from anywhere with:

```bash
devtools-rebuild    # symlinked onto PATH on both platforms
```

On macOS that runs `rebuild.sh` (`darwin-rebuild switch`); on Windows it re-runs `setup/windows.sh`, which is idempotent.

### Required Manual Steps

Two files hold values that are specific to a single machine or are secret, so they are never tracked in this public repo.

| File | Purpose |
| --- | --- |
| `~/.env` | Secrets. Auto-created with every required key stubbed empty. The shell warns on every startup until each has a value. |
| `~/.gitconfig.local` | This machine's git SSH signing key. Setup prints a reminder if missing. On Windows it also holds the resolved 1Password signer path. |
| `~/.ssh/config.local` | Optional. Personal SSH hosts, included from the tracked `~/.ssh/config`. |

> **Note:** Homebrew uses `onActivation.cleanup = "none"`, so packages installed outside this repo are left alone on rebuild. Existing files at a managed path must be moved aside before the first activation; home-manager will not clobber them. `setup/windows.sh` moves them aside itself, to `<name>.bak`.

---

## What You Get

### Shell

- **zsh on macOS** with autosuggestions (`Ctrl-F` to accept) and syntax highlighting; **bash on Windows** (`home/.bashrc`), where Up/Down search history in place of autosuggestions and there is no syntax highlighting.
- A [starship](https://starship.rs/) prompt on both, showing directory, git branch/status, and command duration. Its config is a tracked `home/.config/starship.toml` shared by both platforms.
- **Secret loading.** `~/.env` is sourced and exported at startup so child processes (agents, MCP servers) inherit it.
- **Completions.** Tab-completion for the custom commands below. They are bash `complete -F` scripts, loaded natively by bash and through `bashcompinit` by zsh.
- Aliases: `..`, `add`, `m`, `cc`, `co`.

### Custom Commands

Scripts in `home/bin/` are symlinked individually into `~/.local/bin`. They are bash, so they run on both platforms.

| Group | Commands |
| --- | --- |
| Agents | `firstmate` (launch pi inside the firstmate repo) |
| Git | `gco` `db` `fa` `glg` `gnxt` `gwta` `lb` `nb` `pmb` `pull` `push` `rba` `rbc` `rbi` `rbs` `rh` `rs` `sb` `st` `stash` |
| Docker | `denv` `dka` |
| Projects | `oproj` `projs` (open and list repos under `$REPO_HOME`) |
| Ports | `aup` (show what is listening on a port) `kaup` (kill it) |

### CLI Toolchain

Installed from nixpkgs on macOS: `ripgrep`, `fd`, `eza`, `fzf`, `jq`, `yq`, `lazygit`, `neovim`, `uv`, `shfmt`, `gh`, `kubectl`, `kubeseal`, `fluxcd`, `terraform`, `ansible`, `volta`, plus the Hack Nerd Font.

The same set comes from `winget` on Windows, except `ansible` (no Windows control node), `kubeseal` and the Hack Nerd Font (no winget package -- taken from their pinned upstream releases). `setup/windows-parity.md` lists every id.

Node.js is managed by [Volta](https://volta.sh/), which pins each global CLI to the Node version it was installed with, so changing your default Node version never breaks an installed tool.

### Applications

Installed via Homebrew and the Mac App Store on macOS, via `winget` on Windows:

| App | Purpose | Windows |
| --- | --- | --- |
| [WezTerm](https://wezterm.org/) | Terminal emulator | Yes, defaulting to bash |
| [1Password](https://1password.com/) + CLI | Passwords, SSH agent, commit signing | Yes |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Containers | Yes |
| [Lens](https://k8slens.dev/) | Kubernetes IDE | Yes |
| [Claude Code](https://www.anthropic.com/claude-code) | Anthropic coding agent | Yes |
| [Logi Options+](https://www.logitech.com/software/logi-options-plus.html) | Logitech device configuration | Yes |
| [Raycast](https://raycast.com/) | Launcher (replaces Spotlight) | [PowerToys](https://learn.microsoft.com/windows/powertoys/) Run instead |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer | No -- WezTerm's own panes |
| [herdr](https://herdr.dev/) | Agent session multiplexer | Not yet; Windows is an upstream beta |
| [gitops](https://github.com/weaveworks/weave-gitops) / [telepresence](https://www.telepresence.io/) | Kubernetes workflow CLIs | No |
| Dynamic Wallpaper Library | Wallpapers (Mac App Store) | No -- macOS only |

Every one of these decisions, with its reason, is in [`setup/windows-parity.md`](setup/windows-parity.md).

### AI Agent Harness

The environment is built around [pi](https://pi.dev/) as the primary agent harness.

**Agent CLIs** (installed globally, `--ignore-scripts` for supply-chain safety):

- `pi` - the coding agent itself
- [AXI](https://axi.md/) tools, token-efficient CLIs designed for agent use: `gh-axi`, `chrome-devtools-axi`, `quota-axi`, `npm-axi`, `lavish-axi` (HTML artifacts as a review surface), `tasks-axi` (task and backlog manager)
- [`no-mistakes`](https://kunchenguid.github.io/no-mistakes/) - AI-gated push pipeline (review, test, lint before code lands)
- [`treehouse`](https://github.com/kunchenguid/treehouse) - pooled, reusable git worktrees

**pi extensions**, declared in `home/.pi/agent/settings.json` and installed by pi itself:

| Extension | Capability |
| --- | --- |
| `pi-mcp-adapter` | MCP servers behind a single token-efficient proxy tool |
| `pi-subagents` | Autonomous sub-agents in isolated sessions |
| `pi-subdir-context` | Auto-loads `AGENTS.md` / `CLAUDE.md` walking up the tree |
| `pi-yaml-hooks` | YAML-defined lifecycle hooks |
| `codex-fast-mode`, `openai-server-compaction` | Model and context tuning |

**pi extensions written here**, symlinked into `~/.pi/agent/extensions/` where pi auto-discovers them:

| Extension | Capability |
| --- | --- |
| `terminal-status-title.js` | Live session name and agent status in the terminal title |
| `axi-ambient-context.js` | Appends `lavish-axi` and `tasks-axi` ambient context to pi's system prompt |

**Session hooks** (`home/.pi/agent/hook/hooks.yaml`) run on every new pi session: warm up the AXI CLIs, and run `no-mistakes init` when inside a git repo so each repo is gated automatically without manual per-repo setup.

**AXI ambient context.** `lavish-axi` and `tasks-axi` can put their current state -- live Lavish review sessions, the task backlog -- in front of the agent from the first turn, instead of costing a tool call to discover. Each ships a `setup hooks` command that wires this into Claude Code, Codex, OpenCode and GitHub Copilot CLI; activation runs both on every rebuild, which is a no-op once installed and repairs the hook path after a reinstall moves the binaries. Neither supports pi, so `home/.pi/agent/extensions/axi-ambient-context.js` does the same job there through pi's `before_agent_start` event.

Because those commands write into `~/.claude/settings.json`, that one file is applied by merge during activation rather than symlinked out of the repo like the rest -- otherwise every hook install rewrote the tracked file with a machine-specific path. Editing `home/.config/.claude/settings.json` therefore needs a rebuild to take effect.

**MCP servers** (`home/.config/mcp/mcp.json`): Context7 for library documentation. Secrets are referenced as `${VAR}` and resolved from the environment at connection time, never stored in the file.

**Atlassian tooling.** Jira and Confluence are reached through the [`twg` CLI](https://developer.atlassian.com/cloud/twg-cli/), not an MCP server, and `home/AGENTS.md` instructs every agent to use it and never the Rovo MCP. A CLI keeps the tool definitions out of the model's context until they are actually needed, and one authenticated binary serves every harness. `twg` is pinned to an exact version in `home.nix` and installed during activation; run `twg login` once by hand afterwards, since its OAuth flow is interactive and cannot run inside a rebuild.

Atlassian ships no Windows build -- its installer refuses to run anywhere but macOS and Linux -- so on Windows there is no `twg`. The rule in `home/AGENTS.md` already covers that case: agents say so and stop rather than falling back to an MCP.

**Shared agent context.** A single `home/AGENTS.md` is symlinked to both `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`, so every harness follows the same instructions. Global agent skills live in `home/.agents/skills/`.

### Git and SSH

Git config is layered so shared settings stay tracked while machine-specific and OS-specific values do not:

```text
~/.gitconfig          tracked, shared settings
  -> ~/.gitconfig-os      OS-specific (1Password signing paths)
  -> ~/.gitconfig.local   machine-specific signing key, untracked
```

`~/.gitconfig-os` points at `home/.gitconfig-macos` or `home/.gitconfig-windows` depending on the platform. SSH follows the same pattern: a tracked `~/.ssh/config` includes `~/.ssh/config-os` and an untracked `~/.ssh/config.local` for personal hosts.

1Password acts as the SSH agent and signs commits, with the offered key declared in `home/.config/1Password/ssh/agent.toml`. On macOS git reaches it through the `SSH_AUTH_SOCK` socket; on Windows it listens on the OpenSSH agent named pipe, which only the native `ssh.exe` can speak, so `.gitconfig-windows` sets `core.sshCommand` to it by absolute path.

### System Defaults

**macOS:** dark mode, fast key repeat, auto-hiding dock and menu bar, all file extensions visible, Finder in list view, no desktop icons, tap-to-click disabled, and Spotlight indexing turned off since Raycast replaces it.

**Windows:** dark mode, fast key repeat, all file extensions visible, no desktop icons, tap-to-click disabled. Taskbar auto-hide, Explorer's default view and Windows Search are deliberately left alone -- `setup/windows-parity.md` says why for each.

### Edit-in-Place Configs

These are symlinked out of the repo on both platforms, so edits apply immediately with no rebuild: WezTerm, Neovim, starship, herdr, bash (`.bashrc`), pi (settings, models, theme, extensions, hooks), and the global gitignore.

Claude Code's `settings.json` is the exception: the AXI `setup hooks` commands write into it, and their writes follow symlinks, so it is merged in during activation and needs a rebuild instead.

Windows needs native symlinks for any of this, which is why `setup/windows.sh` turns on Developer Mode before it links anything.

---

## Repo Layout

```text
flake.nix              Inputs (nixpkgs, nix-darwin, home-manager, nix-homebrew) and the "mac" host
configuration.nix      System level: macOS defaults, Homebrew formulae and casks
home.nix               User level: packages, zsh, dotfile symlinks, activation scripts
mas-apps.nix           Mac App Store apps, applied by setup/macOS.sh (not by nix-darwin)
setup.sh               Detects OS/arch, dispatches to the matching setup/ script
setup/macOS.sh         First-time bootstrap for macOS on Apple Silicon
setup/windows.sh       Setup and rebuild for Windows; stands in for nix-darwin and home-manager
setup/windows-parity.md  Every macOS entry mapped to its Windows decision
rebuild.sh             Apply changes on macOS (also on PATH as devtools-rebuild)
home/                  Every tracked dotfile, symlinked into place
  bin/                 Custom commands -> ~/.local/bin
  bin-completion/      Their bash completions
  .bashrc              The Windows shell, peer of programs.zsh in home.nix
  .pi/agent/           pi harness config
  .config/mcp/         MCP server definitions
  .agents/skills/      Global agent skills
```

## Customizing

Anything that changes what is installed or configured needs a decision on both platforms, and a row in `setup/windows-parity.md`.

| To add | Edit |
| --- | --- |
| A CLI from nixpkgs | `home.packages` in `home.nix`, and `WINGET_PACKAGES` in `setup/windows.sh` |
| A GUI app or Homebrew formula | `homebrew.casks` / `brews` in `configuration.nix`, and `WINGET_PACKAGES` |
| A Mac App Store app | `mas-apps.nix`, then re-run `setup/macOS.sh` (not `homebrew.masApps`) |
| A global npm CLI | `globalNpmPackages` in `home.nix` and `GLOBAL_NPM_PACKAGES` in `setup/windows.sh` |
| A Go CLI | `goPackages` in `home.nix` and `GO_PACKAGES` in `setup/windows.sh` (pinned to a release tag) |
| A required secret | `secretEnvVars` in `home.nix`, `SECRET_ENV_VARS` in `setup/windows.sh`, and `_secret_vars` in `home/.bashrc`; it is stubbed into `~/.env` on the next rebuild |
| A custom command | Drop a bash executable in `home/bin/`; it is picked up automatically on both platforms |
| A pi extension | `packages` in `home/.pi/agent/settings.json` |
| An agent skill | Add `home/.agents/skills/<name>/SKILL.md`; shared by pi and Claude Code |
| A subagent | Add `home/.pi/agent/agents/<name>.md`; shared by pi and Claude Code |
| The prompt | `home/.config/starship.toml` (shared, edit-in-place) |
