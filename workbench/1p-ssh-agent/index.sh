function macBashrc() {
  export SSH_AUTH_SOCK=$HOME/.1password/agent.sock
}

function windowsBashrc() {
  export SSH_AUTH_SOCK=\\\\.\\pipe\\openssh-ssh-agent
}

function _installWindows() {
  winget install --id AgileBits.1Password --accept-package-agreements --accept-source-agreements
}

function installWindows() {
  runElevated _installWindows
}

function installMac() {
  brew install --cask 1password
  addToBashrc '1p-ssh-agent' macBashrc
}

runIf isMac installMac
runIf isWindows installWindows
