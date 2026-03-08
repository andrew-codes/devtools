function macBashrc() {
  find ~/.ssh -maxdepth 1 -type f ! -name "*.*" ! -name "*known_hosts" ! -name "*config" -exec keychain --eval --agents ssh --inherit any {} \;
}

function windowsBashrc() {
  SSH_ENV=$HOME/.ssh/environment

  function startAgent {
    echo "Initializing new SSH agent."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > ${SSH_ENV}
    chmod 600 ${SSH_ENV}
    . ${SSH_ENV} > /dev/null
    /usr/bin/ssh-add
  }

  # Source SSH settings, if applicable
  if [ -f "${SSH_ENV}" ]; then
    . ${SSH_ENV} > /dev/null
    # ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
      startAgent
    }
  else
    startAgent
  fi
}

function installMac() {
  brew install keychain
  addToBashrc 'ssh-agent' macBashrc
}

function installWindows() {
  addToBashrc 'ssh-agent' windowsBashrc
}

runIf isMac installMac
runIf isWindows installWindows
