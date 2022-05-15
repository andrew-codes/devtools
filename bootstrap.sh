#!/usr/bin/env bash

DEV_HOME=$HOME
REPO_HOME=$DEV_HOME
DEVTOOLS_HOME=/workspaces/.codespaces/.persistedshare/dotfiles
TOOLS_HOME=$DEV_HOME/tools/

SSH_CREDENTIALS=1
GPG=1
ADDITIONAL_GIT_FUNCTIONALITY=1
GIT_PROMPT=1
GIT_ALIAS=1
PROJECT_FINDER=0
DOCKER=1
COMMANDS=1

## Setup devtools for bash.
source $DEVTOOLS_HOME/add-devtools-to-bash_profile.sh
