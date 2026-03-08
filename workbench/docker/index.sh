function installMac() {
  if ! command -v docker &> /dev/null; then
    brew install --cask docker-desktop
  fi
}

function _installWindows() {
  winget install --id Docker.DockerDesktop --accept-package-agreements --accept-source-agreements
}

function installWindows() {
  if ! command -v docker &> /dev/null; then
    runElevated _installWindows

     winget install --id Docker.DockerCLI --accept-package-agreements --accept-source-agreements
  fi
}

runIf isMac installMac
runIf isWindows installWindows

installBinFiles
