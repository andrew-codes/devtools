#!/usr/bin/env bash

DEV_HOME=$HOME
REPO_HOME=$DEV_HOME
DEVTOOLS_HOME=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TOOLS_HOME=$DEV_HOME/tools/

OP_SSH_CREDENTIALS=0
SSH_CREDENTIALS=0
GPG=0
ADDITIONAL_GIT_FUNCTIONALITY=1
GIT_PROMPT=1
GIT_ALIAS=1
PROJECT_FINDER=0
DOCKER=1
COMMANDS=1

## Setup devtools for bash.
source $DEVTOOLS_HOME/add-devtools-to-bash_profile.sh
