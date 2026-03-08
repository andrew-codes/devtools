function installMac() {
  if ! command -v docker &> /dev/null; then
    brew install --cask docker-desktop
  fi
}

function installWindows() {
  if ! command -v docker &> /dev/null; then
    winget install --id Docker.DockerDesktop --accept-package-agreements --accept-source-agreements
    winget install --id Docker.DockerCLI --accept-package-agreements --accept-source-agreements
  fi
}

runIf isMac installMac
runIf isWindows installWindows

installBinFiles
