#!/usr/bin/env bash

currentDir=$(dirname $BASH_SOURCE)
source "$currentDir/_variables.sh"

# Do not edit these
# --------
IS_OSX=0
IS_WIN=0
[ "$OSTYPE" = "darwin" ] && IS_OSX=1 || IS_OSX=0
[ "$OSTYPE" = "win" -o "$OSTYPE" = "msys" ] && IS_WIN=1 || IS_WIN=0
# -------

# # Git
source ${DEVTOOLS_HOME}/bash/features/ssh-credentials/index.sh
source ${DEVTOOLS_HOME}/bash/features/git-alias/index.sh
source ${DEVTOOLS_HOME}/bash/features/additional-git-functionality/index.sh
source ${DEVTOOLS_HOME}/bash/features/git-completion/index.sh
source ${DEVTOOLS_HOME}/bash/features/git-prompt/index.sh
source ${DEVTOOLS_HOME}/bash/features/hub/index.sh
source ${DEVTOOLS_HOME}/bash/features/project-finder/index.sh

# [GitX](http://gitx.frim.nl/user_manual.html); OSX only
[ ${IS_OSX} ] && [ -f /usr/local/bin/gitx ] && alias gui=gitx

export NVM_DIR="$HOME/.nvm"
source $(brew --prefix nvm)/nvm.sh

export PATH="/bin:$PATH"

if test -f ~/.gnupg/.gpg-agent-info -a -n "$(pgrep gpg-agent)"; then
  source ~/.gnupg/.gpg-agent-info
  export GPG_AGENT_INFO
  GPG_TTY=$(tty)
  export GPG_TTY
else
  eval $(gpg-agent --daemon ~/.gnupg/.gpg-agent-info)
fi
