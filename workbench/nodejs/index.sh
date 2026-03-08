function macNvmBashrc() {
  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}

function installMac() {
  if ! command -v nvm &> /dev/null; then
    brew install nvm
  fi

  addToBashrc macNvmBashrc

  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
}

function installWindows() {
  if ! command -v nvm &> /dev/null; then
    winget install --id CoreyButler.NVMforWindows
  fi
}

runIf isMac installMac
runIf isWindows installWindows

refreshEnv

nvm install lts
nvm use lts
