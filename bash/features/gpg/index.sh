#!/usr/bin/env bash

if [ $GPG -ne 1 ]; then
  return 0
fi

if [ $IS_WIN -eq 1 ]; then
  if test -f $HOME/.gnupg/.gpg-agent-info -a -n "$(tasklist | grep 'gpg-agent')"; then
    source $HOME/.gnupg/.gpg-agent-info
    export GPG_AGENT_INFO
  else
    echo "Starting gpg-agent daemon"
    eval $(gpg-agent --daemon)
  fi
fi
