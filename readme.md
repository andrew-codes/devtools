# Devtools

My **personal** developer workbench, defined declaratively with [Nix](https://nixos.org/). One command takes a clean machine to a fully configured environment: system settings, applications, CLI tooling, shell, dotfiles, and an AI agent harness.

Everything is reproducible and version controlled. Configuration files are symlinked back into this repo, so editing a config here takes effect immediately without a rebuild.

## Supported Platforms

| Platform | Status |
| --- | --- |
| macOS on Apple Silicon (`aarch64-darwin`) | Supported |
| macOS on Intel | Not supported |
| Windows / WSL | Not yet migrated |

## Install

Requires macOS on Apple Silicon. Nothing else needs to be preinstalled; the setup script bootstraps Nix itself.

```bash
git clone https://github.com/andrew-codes/devtools.git ~/developer/repos/devtools
cd ~/developer/repos/devtools
./setup.sh
```

`setup.sh` detects the OS and architecture and dispatches to the matching platform script -- currently just `setup/macOS.sh` for macOS on Apple Silicon. On any other platform it prints what was detected and exits rather than attempting an install.

The macOS script:

1. Installs [Determinate Nix](https://determinate.systems/) if `nix` is not already present.
2. Symlinks the repo to `~/.dotfiles`, which every config path resolves through.
3. Offers to rewrite the `user = "..."` line in `flake.nix` to match your macOS username.
4. Trusts the Homebrew taps that already have something installed from them, so out-of-band installs survive later rebuilds. On a first-ever run there is no `brew` yet, so this is a no-op.
5. Acquires the Mac App Store apps listed in `mas-apps.nix` with `mas get`, then waits for each to land on disk.
6. Runs the first `darwin-rebuild switch` against the flake.

Sign in to the Mac App Store before step 5; `mas` cannot authenticate on its own, and it prompts for an admin password when it has real work to do. App Store apps are acquired here, as the real user in the real login session, rather than through nix-darwin's `homebrew.masApps` -- that option runs outside the per-user launchd session `mas` needs, so it would fail on every rebuild. `homebrew.masApps` is deliberately left empty.

### Applying Changes Later

After the first install, rebuild with either:

```bash
devtools-rebuild    # from anywhere, symlinked onto PATH
```

### Required Manual Steps

Two files hold values that are specific to a single machine or are secret, so they are never tracked in this public repo.

| File | Purpose |
| --- | --- |
| `~/.env` | Secrets. Auto-created with every required key stubbed empty. zsh warns on every shell until each has a value. |
| `~/.gitconfig.local` | This machine's git SSH signing key. Activation prints a reminder if missing. |
| `~/.ssh/config.local` | Optional. Personal SSH hosts, included from the tracked `~/.ssh/config`. |

> **Note:** Homebrew uses `onActivation.cleanup = "none"`, so packages installed outside this repo are left alone on rebuild. Existing files at a managed path must be moved aside before the first activation; home-manager will not clobber them.

---

## What You Get

### Shell

- **zsh** with autosuggestions (`Ctrl-F` to accept), syntax highlighting, and a [starship](https://starship.rs/) prompt showing directory, git branch/status, and command duration.
- **Secret loading.** `~/.env` is sourced and exported at startup so child processes (agents, MCP servers) inherit it.
- **Completions.** Tab-completion for the custom commands below, loaded through `bashcompinit`.
- Aliases: `..`, `add`, `m`, `cc`, `co`.

### Custom Commands

Scripts in `home/bin/` are symlinked individually into `~/.local/bin`.

| Group | Commands |
| --- | --- |
| Agents | `firstmate` (launch pi inside the firstmate repo) |
| Git | `gco` `db` `fa` `glg` `gnxt` `gwta` `lb` `nb` `pmb` `pull` `push` `rba` `rbc` `rbi` `rbs` `rh` `rs` `sb` `st` `stash` |
| Docker | `denv` `dka` |
| Projects | `oproj` `projs` (open and list repos under `$REPO_HOME`) |
| Ports | `aup` (show what is listening on a port) `kaup` (kill it) |

### CLI Toolchain

Installed from nixpkgs: `ripgrep`, `fd`, `eza`, `fzf`, `jq`, `yq`, `lazygit`, `neovim`, `uv`, `shfmt`, `gh`, `kubectl`, `kubeseal`, `fluxcd`, `terraform`, `ansible`, `volta`, plus the Hack Nerd Font.

Node.js is managed by [Volta](https://volta.sh/), which pins each global CLI to the Node version it was installed with, so changing your default Node version never breaks an installed tool.

### Applications

Installed via Homebrew and the Mac App Store:

| App | Purpose |
| --- | --- |
| [WezTerm](https://wezterm.org/) | Terminal emulator |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer |
| [1Password](https://1password.com/) + CLI | Passwords, SSH agent, commit signing |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Containers |
| [Raycast](https://raycast.com/) | Launcher (replaces Spotlight) |
| [Lens](https://k8slens.dev/) | Kubernetes IDE |
| [Claude Code](https://www.anthropic.com/claude-code) | Anthropic coding agent |
| [herdr](https://herdr.dev/) | Agent session multiplexer |
| [gitops](https://github.com/weaveworks/weave-gitops) / [telepresence](https://www.telepresence.io/) | Kubernetes workflow CLIs |
| [Logi Options+](https://www.logitech.com/software/logi-options-plus.html) | Logitech device configuration |
| Dynamic Wallpaper Library | Wallpapers (Mac App Store) |

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

**Shared agent context.** A single `home/AGENTS.md` is symlinked to both `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`, so every harness follows the same instructions. Global agent skills live in `home/.agents/skills/`.

### Git and SSH

Git config is layered so shared settings stay tracked while machine-specific and OS-specific values do not:

```text
~/.gitconfig          tracked, shared settings
  -> ~/.gitconfig-os      OS-specific (1Password signing paths)
  -> ~/.gitconfig.local   machine-specific signing key, untracked
```

SSH follows the same pattern: a tracked `~/.ssh/config` includes `~/.ssh/config-os` (the 1Password `IdentityAgent`) and an untracked `~/.ssh/config.local` for personal hosts.

1Password acts as the SSH agent (`SSH_AUTH_SOCK`) and signs commits, with the offered key declared in `home/.config/1Password/ssh/agent.toml`.

### macOS System Defaults

Dark mode, fast key repeat, auto-hiding dock and menu bar, all file extensions visible, Finder in list view, no desktop icons, tap-to-click disabled, and Spotlight indexing turned off since Raycast replaces it.

### Edit-in-Place Configs

These are symlinked out of the repo, so edits apply immediately with no rebuild: WezTerm, Neovim, herdr, pi (settings, models, theme, extensions, hooks), and the global gitignore.

Claude Code's `settings.json` is the exception: the AXI `setup hooks` commands write into it, and their writes follow symlinks, so it is merged in during activation and needs a rebuild instead.

---

## Repo Layout

```text
flake.nix              Inputs (nixpkgs, nix-darwin, home-manager, nix-homebrew) and the "mac" host
configuration.nix      System level: macOS defaults, Homebrew formulae and casks
home.nix               User level: packages, zsh, dotfile symlinks, activation scripts
mas-apps.nix           Mac App Store apps, applied by setup/macOS.sh (not by nix-darwin)
setup.sh               Detects OS/arch, dispatches to the matching setup/ script
setup/macOS.sh         First-time bootstrap for macOS on Apple Silicon
rebuild.sh             Apply changes (also on PATH as devtools-rebuild)
home/                  Every tracked dotfile, symlinked into place
  bin/                 Custom commands -> ~/.local/bin
  bin-completion/      Their zsh completions
  .pi/agent/           pi harness config
  .config/mcp/         MCP server definitions
  .agents/skills/      Global agent skills
```

## Customizing

| To add | Edit |
| --- | --- |
| A CLI from nixpkgs | `home.packages` in `home.nix` |
| A GUI app or Homebrew formula | `homebrew.casks` / `brews` in `configuration.nix` |
| A Mac App Store app | `mas-apps.nix`, then re-run `setup/macOS.sh` (not `homebrew.masApps`) |
| A global npm CLI | `globalNpmPackages` in `home.nix` (semver range, upgrades in place) |
| A Go CLI | `goPackages` in `home.nix` (pinned to a release tag) |
| A required secret | `secretEnvVars` in `home.nix`; it is stubbed into `~/.env` on the next rebuild |
| A custom command | Drop an executable in `home/bin/`; it is picked up automatically |
| A pi extension | `packages` in `home/.pi/agent/settings.json` |
