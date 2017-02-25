#!/usr/bin/env bash
DEV_HOME=$HOME/Developer
REPO_HOME=${DEV_HOME}/repositories
DEVTOOLS_HOME=${REPO_HOME}/devtools
TOOLS_HOME=${DEV_HOME}/tools/
source ${DEVTOOLS_HOME}/bash/_env-settings.sh


# Do not edit these
# --------
IS_OSX=0
IS_WIN=0
[ "$OSTYPE" = "darwin" ] && IS_OSX=1 || IS_OSX=0
[ "$OSTYPE" = "win" -o "$OSTYPE" = "msys" ] && IS_WIN=1 || IS_WIN=0
# -------

# # Aliases
[ -f ${DEVTOOLS_HOME}/bash/alias.sh ] &&	source ${DEVTOOLS_HOME}/bash/alias.sh

# # Git
[ -f ${DEVTOOLS_HOME}/bash/git-completion.bash ] && source ${DEVTOOLS_HOME}/bash/git-completion.bash
[ -f ${DEVTOOLS_HOME}/bash/hub-completion.sh ] && source ${DEVTOOLS_HOME}/bash/hub-completion.sh
[ -f ${DEVTOOLS_HOME}/bash/git-prompt.sh ] && source ${DEVTOOLS_HOME}/bash/git-prompt.sh
[ -f ${DEVTOOLS_HOME}/bash/git-prompt.sh ] && [ ${IS_WIN} ] && PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
[ -f ${DEVTOOLS_HOME}/bash/git.sh ] && source ${DEVTOOLS_HOME}/bash/git.sh
[ -f ${DEVTOOLS_HOME}/bash/ssh-env.sh ] && source ${DEVTOOLS_HOME}/bash/ssh-env.sh

function prj() {
  cd ${REPO_HOME}/$1
}

function lprj() {
  if ! [ -z "$1" ]; then
    ls ${REPO_HOME} | grep "$1"
  else
    ls ${REPO_HOME}
  fi
}
