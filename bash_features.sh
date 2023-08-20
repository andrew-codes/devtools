# <DEVTOOLS>
# Path variables
# ==============
DEV_HOME=$HOME/developer
REPO_HOME=$DEV_HOME/repos
DEVTOOLS_HOME=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TOOLS_HOME=$DEV_HOME/tools/

# Enable/Disable Features
# =======================
# set to 0 to disable.

OP_SSH_CREDENTIALS=1
SSH_CREDENTIALS=0
GPG=1
ADDITIONAL_GIT_FUNCTIONALITY=1
GIT_PROMPT=1
GIT_ALIAS=1
PROJECT_FINDER=1
DOCKER=1
COMMANDS=1
# </DEVTOOLS>
