function installMac() {
  if ! command -v nvm &> /dev/null; then
    brew install nvm
  fi
}

function installWindows() {
  winget install --id CoreyButler.NVMforWindows
}

runIf isMac installMac
runIf isWindows installWindows
