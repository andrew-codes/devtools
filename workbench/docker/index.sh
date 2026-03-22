function installMac() {
  if ! command -v docker &>/dev/null; then
    brew install --cask docker-desktop
  fi
}

function _installWindows() {
  wingetInstall --id Docker.DockerDesktop --accept-package-agreements --accept-source-agreements --source winget
}

function installWindows() {
  if ! command -v docker &>/dev/null; then
    runElevated _installWindows

    wingetInstall --id Docker.DockerCLI --accept-package-agreements --accept-source-agreements --source winget
  fi
}

runIf isMac installMac
runIf isWindows installWindows

installBinFiles
