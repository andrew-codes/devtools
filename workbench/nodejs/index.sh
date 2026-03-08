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

function _installWindows() {
  wingetInstall --id CoreyButler.NVMforWindows --accept-package-agreements --accept-source-agreements
}

function installWindows() {
    runElevated _installWindows
}

runIf isMac installMac
runIf isWindows installWindows

refreshEnv

# Note, latest 24.x has issues with nvm not installing npm, npx, and corepack.
nvm install 22.22.1
nvm use 22.22.1
