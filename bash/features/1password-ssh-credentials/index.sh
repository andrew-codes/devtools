#!/usr/bin/env bash

if [ $OP_SSH_CREDENTIALS -ne 1 ]; then
  return 0
fi

if [ $IS_WIN -eq 1 ]; then
  export SSH_AUTH_SOCK=\\\\.\\pipe\\openssh-ssh-agent
else
  export SSH_AUTH_SOCK=$HOME/.1password/agent.sock
fi
