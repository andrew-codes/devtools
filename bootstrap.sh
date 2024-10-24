#!/usr/bin/env bash

# This file is exclusively for setting up devtools in a dev container/codespace.

# Bash
export DEVTOOLS_BASH=true
export DEVTOOLS_BASH_DEV_HOME=~/
export DEVTOOLS_BASH_REPO_HOME=~/
export DEVTOOLS_BASH_DEVTOOLS_HOME=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export DEVTOOLS_BASH_TOOLS_HOME=~/tools
export DEVTOOLS_BASH_TOOLS_BIN_HOME=~/tools/bin
# Feature toggles
export DEVTOOLS_BASH_FEATURES_COMMANDS=true
export DEVTOOLS_BASH_FEATURES_GIT_EXTENDED=true
export DEVTOOLS_BASH_FEATURES_GIT_COMPLETION=true
export DEVTOOLS_BASH_FEATURES_GIT_PROMPT=true
# Use only one of the following: ---
export DEVTOOLS_BASH_FEATURES_USE_1PASSWORD_AGENT=false
export DEVTOOLS_BASH_FEATURES_USE_SSH_AGENT=false
export DEVTOOLS_BASH_FEATURES_CODESPACES=true
# ---

# Git
export DEVTOOLS_GIT=false
# Feature toggles
export DEVTOOLS_GIT_FEATURES_CONFIG=false
# ---

# Node.js
DEVTOOLS_NODEJS=false
DEVTOOLS_NODEJS_FEATURES_NVM=false
# ---

IGNORE_ENV_FILE=true . $DEVTOOLS_BASH_DEVTOOLS_HOME/setup.sh
