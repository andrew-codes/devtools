#!/usr/bin/env bash

# This file is exclusively for setting up devtools in a dev container/codespace.

# Bash
export DEVTOOLS_BASH=true
export DEVTOOLS_BASH_DEV_HOME=$HOME
export DEVTOOLS_BASH_REPO_HOME=$HOME
export DEVTOOLS_BASH_DEVTOOLS_HOME=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export DEVTOOLS_BASH_TOOLS_HOME=$HOME/tools
export DEVTOOLS_BASH_TOOLS_BIN_HOME=$HOME/tools/bin
# Feature toggles
export DEVTOOLS_BASH_FEATURES_COMMANDS=true
export DEVTOOLS_BASH_FEATURES_GIT_EXTENDED=true
export DEVTOOLS_BASH_FEATURES_GIT_COMPLETION=true
export DEVTOOLS_BASH_FEATURES_GIT_PROMPT=true
# Use only one of the following: ---
export DEVTOOLS_BASH_FEATURES_USE_1PASSWORD_AGENT=false
export DEVTOOLS_BASH_FEATURES_USE_SSH_AGENT=false
# ---

IGNORE_ENV_FILE=true . $DEVTOOLS_BASH_DEVTOOLS_HOME/setup.sh
