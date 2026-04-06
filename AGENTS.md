# Devtools

My personal collection of dotfiles, configuration settings, templates, and productivity tools. The setup is driven by Ansible playbooks with a single bash entry-point that bootstraps everything from scratch.

## Running Setup

```bash
# Set required environment variables
export GITHUB_USERNAME="your-username"
export GIT_EMAIL="you@example.com"
export GIT_NAME="Your Name"
export GIT_SIGNING_KEY="~/.ssh/id_ed25519.pub"

# Run the setup script
./ansible/setup.sh
```

Setup logs are written to `workbench.log` in the repository root.

## Architecture

The setup is driven by Ansible playbooks. `ansible/setup.sh` is the single entry point:

1. Detects OS and CPU architecture
2. Bootstraps Python 3 and Ansible (via `pip`)
3. On Windows: installs Chocolatey and configures WinRM for local connections
4. Runs the appropriate site playbook for the detected platform

### Supported Platforms

| Platform | Site Playbook |
| --- | --- |
| macOS arm64 (Apple Silicon) | `ansible/site-macos-arm64.yml` |
| Windows 11 amd64 | `ansible/site-windows-amd64.yml` |

### Directory Structure

```text
ansible/
  setup.sh                   # Bootstrap entry point
  requirements.yml           # Ansible Galaxy collections
  inventory-macos.yml        # macOS localhost inventory (connection: local)
  inventory-windows.yml      # Windows localhost inventory (connection: winrm)
  group_vars/
    all.yml                  # Variables resolved from environment variables
  site-macos-arm64.yml       # macOS arm64 entry playbook
  site-windows-amd64.yml     # Windows amd64 entry playbook
  playbooks/
    devtools-bash-env.yml
    bash-profile.yml
    brew.yml
    git-config.yml
    uvx.yml
    shfmt.yml
    jq.yml
    git-completion.yml
    git-prompt.yml
    gh.yml
    yq.yml
    git-shortcuts.yml
    projects.yml
    bash-utilities.yml
    1p-ssh-agent.yml
    nodejs.yml
    claude-code.yml
    vscode.yml
    docker.yml
```

## Adding a New Tool

Create a new playbook in `ansible/playbooks/` following this pattern:

```yaml
---
- name: Install my-tool
  hosts: localhost
  gather_facts: true
  tasks:
    - name: Install my-tool (macOS via Homebrew)
      community.general.homebrew:
        name: my-tool
        state: present
      when: ansible_system == 'Darwin'

    - name: Install my-tool (Windows via Chocolatey)
      chocolatey.chocolatey.win_chocolatey:
        name: my-tool
        state: present
      when: ansible_os_family == 'Windows'
```

Then add it to the appropriate site playbook(s):

```yaml
# ansible/site-macos-arm64.yml
- import_playbook: playbooks/my-tool.yml
```

## Conventions

- **All playbooks must be idempotent** — safe to run multiple times.
- **Platform guards**: use `when: ansible_system == 'Darwin'` for macOS tasks and `when: ansible_os_family == 'Windows'` for Windows tasks.
- **Package managers**: use `community.general.homebrew` / `homebrew_cask` for macOS; use `chocolatey.chocolatey.win_chocolatey` for Windows. Do not use winget — Ansible does not support it.
- **Shell tasks on Windows**: use `ansible.windows.win_shell` instead of `ansible.builtin.shell` or `command`.
- **File copy on Windows**: use `ansible.windows.win_copy` instead of `ansible.builtin.copy`.
- **bashrc blocks**: use `ansible.builtin.blockinfile` with `marker: "# {mark} devtools:<id>"` to write to `~/.bashrc`. This is compatible with the existing `# BEGIN devtools:<id>` / `# END devtools:<id>` marker convention.
- **Variables**: all configuration is sourced from environment variables via `group_vars/all.yml` using `lookup('env', 'VAR_NAME')`. Add new variables there with sensible defaults.
- **Repo path**: the setup script passes `devtools_repo_root` as an Ansible extra var (`-e`). Use this variable in playbooks that need to reference files inside the repo (e.g. bin scripts, config files).
- **Bin files**: bin files for git-shortcuts, projects, and bash-utilities live under `workbench/<tool>/bin/`. Playbooks use `ansible.builtin.find` + `ansible.builtin.copy` (with `remote_src: true`) to install them to `tools_bin_home`.

## Environment Variables

All variables are resolved in `ansible/group_vars/all.yml`. Variables without a default must be set before running `setup.sh`.

| Variable | Default | Description |
| --- | --- | --- |
| `DEV_HOME` | `~/developer` | Root developer directory |
| `REPO_HOME` | `$DEV_HOME/repos` | Git repository directory |
| `DEVTOOLS_HOME` | `$DEV_HOME/devtools` | Devtools installation directory |
| `TOOLS_HOME` | `$DEV_HOME/tools` | Shared tools directory |
| `TOOLS_BIN_HOME` | `$TOOLS_HOME/bin` | Tools binary directory (added to PATH) |
| `GITHUB_USERNAME` | _(required)_ | Your GitHub username |
| `GIT_EMAIL` | _(optional)_ | Git commit email |
| `GIT_NAME` | _(optional)_ | Git commit display name |
| `GIT_SIGNING_KEY` | _(optional)_ | SSH public key path for commit signing |
| `GIT_SSH_AGENT` | `1p` | SSH agent type (`1p` for 1Password) |
| `CONTEXT7_API_KEY` | _(optional)_ | Context7 API key |
| `NODE_VERSION` | `22.22.1` | Node.js version to install via nvm |
| `GITHUB_TOKEN` | _(optional)_ | GitHub personal access token |

**Windows only:**

| Variable | Description |
| --- | --- |
| `ANSIBLE_PASSWORD` | Windows user account password (required for WinRM authentication) |
