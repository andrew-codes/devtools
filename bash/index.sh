#!/usr/bin/env bash

# READ BEFORE EDITING THIS FILE
# =============================
# If the objective is to enable or disable a feature, refer to the `_variables.sh` file and set each feature to either `1` or `0`.
# Setting a feature to 0 will disable the feature.

export GPG_TTY=$(tty)

IS_OSX=0
IS_WIN=0
IS_LINUX=0
[[ "$OSTYPE" == *"darwin"* ]] && IS_OSX=1 || IS_OSX=0
[[ "$OSTYPE" == *"win"* ]] && IS_WIN=1 || IS_WIN=0
[[ "$OSTYPE" == *"msys"* ]] && IS_WIN=1 || IS_WIN=0
[[ "$OSTYPE" == *"linux"* ]] && IS_LINUX=1 || IS_LINUX=0

source ${DEVTOOLS_HOME}/bash/features/ssh-credentials/index.sh
source ${DEVTOOLS_HOME}/bash/features/git-alias/index.sh
source ${DEVTOOLS_HOME}/bash/features/additional-git-functionality/index.sh
source ${DEVTOOLS_HOME}/bash/features/git-completion/index.sh
source ${DEVTOOLS_HOME}/bash/features/git-prompt/index.sh
source ${DEVTOOLS_HOME}/bash/features/project-finder/index.sh
source ${DEVTOOLS_HOME}/bash/features/gpg/index.sh
source ${DEVTOOLS_HOME}/bash/features/docker/index.sh
source ${DEVTOOLS_HOME}/bash/features/commands/index.sh

export SSH_AUTH_SOCK=~/.1password/agent.sock

if type brew &>/dev/null; then
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
    for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
      [[ -r "$COMPLETION" ]] && source "$COMPLETION"
    done
  fi
fi

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
export NVM_DIR="$HOME/.nvm"
if [ $IS_OSX -eq 1 ]; then
  source $(brew --prefix nvm)/nvm.sh
fi

export PATH="/bin:$PATH"
