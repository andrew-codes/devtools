SSH_ENV=$HOME/.ssh/environment

function startAgent {
  echo "Initialising new SSH agent."
  /usr/bin/ssh-agent | sed 's/^echo/#echo/' >${SSH_ENV}
  chmod 600 ${SSH_ENV}
  . ${SSH_ENV} >/dev/null
  /usr/bin/ssh-add
}

# Source SSH settings, if applicable
if [ -f "${SSH_ENV}" ]; then
  . ${SSH_ENV} >/dev/null
  # ps ${SSH_AGENT_PID} doesn't work under cywgin
  ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ >/dev/null || {
    startAgent
  }
else
  startAgent
fi
