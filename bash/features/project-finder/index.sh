#!/usr/bin/env bash

if [ $PROJECT_FINDER -ne 1 ]; then
  return 0;
fi

function proj() {
  cd ${REPO_HOME}/$1
}

function projs() {
  if ! [ -z "$1" ]; then
    ls ${REPO_HOME} | grep "$1"
  else
    ls ${REPO_HOME}
  fi
}

_proj ()   {
    local currToken="${COMP_WORDS[COMP_CWORD]}" matches matchCount
    matches=$(ls ${REPO_HOME} | grep "${currToken}" | sed 's/^\(.*\)/\1/')
    cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=()
    COMPREPLY=($(compgen -W "${matches}" -- ${currToken}) )
    }
complete -F _proj proj proj
