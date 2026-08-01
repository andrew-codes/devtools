# Project notes for agents

Deliberate decisions in this repo - do NOT silently revert them:

- `homebrew.onActivation.cleanup = "none"` in `configuration.nix` is intentional. These machines carry Homebrew packages that are deliberately not managed here - notably non-development oriented apps, like `snagit` and `moonlight`. `uninstall` or `zap` would delete all of them on the next rebuild. This setting previously was `zap` to force declaring every package in Nix; that traded away too much for reproducibility we do not get anyway, since much of the machine predates this config. Declare new packages in `configuration.nix` regardless.
- Never commit `.no-mistakes/` validation evidence to this public repo. `.no-mistakes/` is gitignored; if a validation pipeline stages evidence into a branch, drop it before merging.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
