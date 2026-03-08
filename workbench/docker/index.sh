function installMac() {
  if ! command -v docker &> /dev/null; then
    brew install --cask docker-desktop
  fi
}

function installWindows() {
  if ! command -v docker &> /dev/null; then
    winget install --id Docker.DockerDesktop
  fi
}

runIf isMac installMac
runIf isWindows installWindows

installBinFiles
