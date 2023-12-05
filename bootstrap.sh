#!/usr/bin/env bash

# This file is exclusively for setting up devtools in a dev container/codespace.

export DEV_HOME=$HOME
export REPO_HOME=$DEV_HOME
export DEVTOOLS_HOME=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export TOOLS_HOME=$DEV_HOME/tools/
