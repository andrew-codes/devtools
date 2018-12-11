#!/usr/bin/env bash

currentDir=$(dirname $BASH_SOURCE)
source "$currentDir/_variables.sh"

# Do not edit these
# --------
IS_OSX=0
IS_WIN=0
[[ "$OSTYPE" == *"darwin"* ]] && IS_OSX=1 || IS_OSX=0
[[ "$OSTYPE" == *"win"* ]] && IS_WIN=1 || IS_WIN=0
[[ "$OSTYPE" == *"msys"* ]] && IS_WIN=1 || IS_WIN=0
# -------

source ${DEVTOOLS_HOME}/bash/features/ssh-credentials/index.sh
source ${DEVTOOLS_HOME}/bash/features/git-alias/index.sh
source ${DEVTOOLS_HOME}/bash/features/additional-git-functionality/index.sh
source ${DEVTOOLS_HOME}/bash/features/git-completion/index.sh
source ${DEVTOOLS_HOME}/bash/features/git-prompt/index.sh
source ${DEVTOOLS_HOME}/bash/features/hub/index.sh
source ${DEVTOOLS_HOME}/bash/features/project-finder/index.sh
source ${DEVTOOLS_HOME}/bash/features/gpg/index.sh
source ${DEVTOOLS_HOME}/bash/features/docker/index.sh

# [GitX](http://gitx.frim.nl/user_manual.html); OSX only
[ $IS_OSX -eq 1 ] && [ -f /usr/local/bin/gitx ] && alias gui=gitx

export NVM_DIR="$HOME/.nvm"
if [ $IS_OSX -eq 1 ]; then
  source $(brew --prefix nvm)/nvm.sh
fi

export PATH="/bin:$PATH"
