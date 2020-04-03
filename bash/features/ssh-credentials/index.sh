#!/usr/bin/env bash

if [ $SSH_CREDENTIALS -ne 1 ]; then
  return 0;
fi

if [ $IS_OSX -eq 1 ]; then
  find ~/.ssh -maxdepth 1 -type f ! -name "*.*" ! -name "*known_hosts" -exec ssh-add -K {} \;
fi

if [ $IS_OSX -ne 1 ]; then
  SSH_ENV=$HOME/.ssh/environment

  function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > ${SSH_ENV}
    echo succeeded
    chmod 600 ${SSH_ENV}
    . ${SSH_ENV} > /dev/null
    /usr/bin/ssh-add;
  }

  # Source SSH settings, if applicable
  if [ -f "${SSH_ENV}" ]; then
    . ${SSH_ENV} > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
      start_agent;
    }
  else
    start_agent;
  fi
fi
