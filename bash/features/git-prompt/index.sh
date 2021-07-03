#!/usr/bin/env bash

if [ $GIT_PROMPT -ne 1 ]; then
  return 0;
fi

currentDir=$(dirname $BASH_SOURCE)
source "$currentDir/git-prompt.sh"

[ ${IS_WIN} ] && PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
