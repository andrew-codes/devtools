# Devtools

This repo is my **personal** collection of dotfiles, configuration settings, templates, and productivity tools. The intention is to be able to automate the installation and setup of a new developer workbench as much as possible. This represents the culmination of numerous iterations across various companies to automate developer onboarding.

## Install Your Workbench

The only required software is bash (or Git Bash for Windows). Everything else — including Python and Ansible — is bootstrapped automatically by the setup script.

### Required Environment Variables

Set these before running `setup.sh`. Variables without a default **must** be set.

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

### Running Setup

```bash
# Set required environment variables
export GITHUB_USERNAME="your-username"
export GIT_EMAIL="you@example.com"
export GIT_NAME="Your Name"
export GIT_SIGNING_KEY="~/.ssh/id_ed25519.pub"

# Run the setup script
./setup.sh
```

Setup logs are written to `workbench.log` in the repository root.

---

## How It Works

The setup is driven by [Ansible](https://www.ansible.com/) playbooks. `setup.sh` is the single entry point:

1. Detects the OS and CPU architecture
2. Bootstraps Python 3 and Ansible (via `pip`)
3. On Windows: installs Chocolatey and configures WinRM for local Ansible connections
4. Runs the appropriate site playbook for the detected platform

### Supported Platforms

| Platform | Site Playbook |
| --- | --- |
| macOS arm64 (Apple Silicon) | `ansible/site-macos-arm64.yml` |
| Windows 11 amd64 | `ansible/site-windows-amd64.yml` |

### Playbook Structure

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
    devtools-bash-env.yml    # Dev directory structure + PATH export
    bash-profile.yml         # ~/.bash_profile → sources ~/.bashrc
    brew.yml                 # Homebrew (macOS only)
    git-config.yml           # Git globals, signing, editor
    uvx.yml                  # uv / uvx (Python tool runner)
    shfmt.yml                # Shell script formatter
    jq.yml                   # JSON processor
    git-completion.yml       # Bash tab-completion for git
    git-prompt.yml           # Git branch info in shell prompt
    gh.yml                   # GitHub CLI
    yq.yml                   # YAML processor
    git-shortcuts.yml        # Custom git shortcut scripts
    projects.yml             # Project navigation scripts
    bash-utilities.yml       # Custom bash utility scripts
    1p-ssh-agent.yml         # 1Password SSH agent
    nodejs.yml               # Node.js via nvm
    claude-code.yml          # Claude Code CLI
    vscode.yml               # VS Code + extensions
    docker.yml               # Docker Desktop + bin utilities
```

Each playbook is self-contained, idempotent, and uses `when:` guards for platform-specific tasks. macOS tasks use [Homebrew](https://brew.sh/); Windows tasks use [Chocolatey](https://chocolatey.org/).

---

## Adding New Tools

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

---

## Windows Prerequisites

On Windows, Ansible connects to `localhost` via WinRM. `setup.sh` will configure WinRM automatically, but the Windows user account must have administrator rights. Set `ANSIBLE_PASSWORD` to your Windows account password before running:

```bash
export ANSIBLE_PASSWORD="your-windows-password"
./ansible/setup.sh
```
