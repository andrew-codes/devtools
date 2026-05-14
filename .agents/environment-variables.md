# Environment Variables

## Setup Variables

Resolved in `ansible/group_vars/all.yml` via `lookup('env', 'VAR_NAME')`. Must be set before running `setup.sh`.

| Variable | Default | Description |
| --- | --- | --- |
| `DEV_HOME` | `~/developer` | Root developer directory |
| `REPO_HOME` | `$DEV_HOME/repos` | Git repository directory |
| `DEVTOOLS_HOME` | `$DEV_HOME/devtools` | Devtools installation directory |
| `TOOLS_HOME` | `$DEV_HOME/tools` | Shared tools directory |
| `TOOLS_BIN_HOME` | `$TOOLS_HOME/bin` | Tools binary directory (added to PATH) |
| `GITHUB_USERNAME` | _(required)_ | GitHub username |
| `GIT_EMAIL` | _(optional)_ | Git commit email |
| `GIT_NAME` | _(optional)_ | Git commit display name |
| `GIT_SIGNING_KEY` | _(optional)_ | SSH public key path for commit signing |
| `GIT_SSH_AGENT` | `1p` | SSH agent type (`1p` for 1Password) |
| `ONEPASSWORD_SSH_KEY` | _(optional)_ | 1Password SSH key selector for `agent.toml` (`[[ssh-keys]].item`), defaults to `GIT_SIGNING_KEY` |
| `NODE_VERSION` | `24.14.1` | Node.js version to install via nvm |

### Windows Only

| Variable | Description |
| --- | --- |
| `ANSIBLE_PASSWORD` | Windows user account password — required for WinRM authentication |

## Runtime Variables

Must be present in the shell environment when using the installed tools. Not consumed by Ansible at setup time.

### Claude Code MCP

| Variable | Description |
| --- | --- |
| `CONTEXT7_API_KEY` | Context7 API key — used by the Context7 MCP server |
| `GITHUB_TOKEN` | GitHub personal access token — used by the GitHub MCP server |
