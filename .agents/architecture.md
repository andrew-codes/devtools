Architecture and directory structure for the devtools repo.

# Supported Platforms

| Platform | Site Playbook |
| --- | --- |
| macOS arm64 (Apple Silicon) | `ansible/site-macos-arm64.yml` |
| Windows 11 amd64 | `ansible/site-windows-amd64.yml` |

# How setup.sh Works

1. Detects OS and CPU architecture
2. Bootstraps Python 3 and Ansible via `pip`
3. On Windows: installs Chocolatey and configures WinRM for local connections
4. Installs required Ansible Galaxy collections (`community.general`, `chocolatey.chocolatey`, `ansible.windows`)
5. Runs the site playbook for the detected platform

# Directory Structure

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
  playbooks/                 # Per-tool playbooks (one file per tool)
```
