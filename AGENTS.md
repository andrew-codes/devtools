# Project notes for agents

Deliberate decisions in this repo - do NOT silently revert them:

- `homebrew.onActivation.cleanup = "none"` in `configuration.nix` is intentional. These machines carry Homebrew packages that are deliberately not managed here - notably non-development oriented apps, like `snagit` and `moonlight`. `uninstall` or `zap` would delete all of them on the next rebuild. This setting previously was `zap` to force declaring every package in Nix; that traded away too much for reproducibility we do not get anyway, since much of the machine predates this config. Declare new packages in `configuration.nix` regardless.
- Never commit `.no-mistakes/` validation evidence to this public repo. `.no-mistakes/` is gitignored; if a validation pipeline stages evidence into a branch, drop it before merging.
- Claude Code and pi share one harness configuration; there is no Claude-specific copy to edit. Skills live in `home/.agents/skills/`, subagents in `home/.pi/agent/agents/`, session-start actions in `home/.pi/agent/hook/session-start.sh` (referenced by both `hooks.yaml` and `home/.config/.claude/settings.json`), and MCP servers in `home/.config/mcp/mcp.json` (synced into Claude's stateful `~/.claude.json` by `home.activation.syncClaudeMcp` in `home.nix`). Edit the shared source, not `~/.claude/*`.
- A path under `~` that a third-party installer writes to must not be an out-of-store symlink into this repo: those writes follow symlinks straight into the tracked, public checkout. `home.nix` handles the three known cases differently on purpose - suppress the write (`--skip-skills` for the twg installer), merge instead of link (`syncClaudeMcp`, `syncClaudeSettings`), or accept the write because the target is unmanaged. Check which applies before adding a `home.file` entry or an installer call.

## Two platforms

macOS is Nix (`configuration.nix` + `home.nix`); Windows is `setup/windows.sh` alone, because Nix has no native Windows support. Windows means native Windows in Git for Windows' bash - not WSL - and the shell there is bash, not zsh.

`setup/windows-parity.md` maps every macOS package, config and system default to its Windows decision. It is the contract, not a summary: anything added to either platform needs a row there. Some lists (npm globals, Go CLIs, secrets) are necessarily duplicated between `home.nix` and `setup/windows.sh` - bump both.

Scripts in `home/bin/` are bash so they run on both platforms. Validate them with `shellcheck`, not `zsh -n`; only `rebuild.sh` is still zsh.

## Validating changes without mutating the machine

This repo configures a real machine and agent sessions usually run on that machine. `setup.sh`, `setup/macOS.sh`, `setup/windows.sh`, `rebuild.sh`, `darwin-rebuild switch`, `brew`, `mas`, `winget`, `pi install`, and `npm install -g` all change live state, so none of them are validation steps. Use instead:

- `nix flake check` and `nix eval .#darwinConfigurations.mac.system.outPath` - evaluate the entire configuration without activating it.
- `shellcheck` for the bash scripts, including `setup/windows.sh`, `home/.bashrc` and everything in `home/bin/`. `zsh -n` only for `rebuild.sh`; shellcheck rejects zsh outright (SC1071).

Sessions normally run on the macOS machine, so the Windows path cannot be executed at all from here. `shellcheck` and `bash -n` are the whole of what can be checked; say plainly what stayed unverified rather than implying it was tested. Verify winget package ids against the `microsoft/winget-pkgs` manifests (`gh api repos/microsoft/winget-pkgs/contents/manifests/<first-letter>/<Publisher>/<Package>`) instead of trusting a remembered id.

This repo has no CI: there is no `.github/` directory, so pull requests legitimately report zero checks. Do not add a workflow to make a pipeline look green.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
