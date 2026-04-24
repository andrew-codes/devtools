An Ansible-driven devtools setup that bootstraps a developer workbench on macOS arm64 and Windows 11 amd64 from a single bash entry-point (`setup.sh`).

# Setup

Run `./setup.sh` from the repo root. Logs are written to `workbench.log`.

# Conventions

All playbooks must be **idempotent** — safe to re-run multiple times.

## Platform guards

- macOS: `when: ansible_facts['system'] == 'Darwin'`
- Windows: `when: ansible_facts['os_family'] == 'Windows'`

## Package managers

- macOS: `community.general.homebrew` or `community.general.homebrew_cask`
- Windows: `chocolatey.chocolatey.win_chocolatey` — do not use winget

## Windows-specific modules

- Shell: `ansible.windows.win_shell` (not `ansible.builtin.shell` or `command`)
- File copy: `ansible.windows.win_copy` (not `ansible.builtin.copy`)

## Windows PATH refresh

Each `win_shell` task runs in its own PowerShell session. Tools installed via Chocolatey are shimmed into the Chocolatey bin dir and are available immediately. Tools installed by nvm (Node, npm) write to the registry PATH and are **not** visible in the current session without a refresh. Any `win_shell` task that calls `nvm`, `npm`, `node`, or similar nvm-managed binaries must begin with:

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

## bashrc blocks

Use `ansible.builtin.blockinfile` with `marker: "# {mark} devtools:<id>"`. This produces idempotent `# BEGIN devtools:<id>` / `# END devtools:<id>` markers in `~/.bashrc`.

## Variables

All configuration comes from environment variables via `ansible/group_vars/all.yml` using `lookup('env', 'VAR_NAME')`. Add new variables there with sensible defaults.

## Repo files in playbooks

The setup script passes `devtools_repo_root` as an Ansible extra var (`-e`). Use it to reference files inside the repo.

## Bin scripts

Bin scripts for git-shortcuts, projects, and bash-utilities live under `workbench/<tool>/bin/`. Playbooks use `ansible.builtin.find` + `ansible.builtin.copy` (with `remote_src: true`) to install them to `tools_bin_home`.

# Resources

- [Architecture](.agents/architecture.md) — platforms, directory structure, how setup.sh works
- [Environment Variables](.agents/environment-variables.md) — all variables and defaults
- [Adding a New Tool](.agents/adding-tools.md) — playbook template and site playbook registration
