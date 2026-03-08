function installMac() {
  if ! command -v yq > /dev/null 2>&1; then
    brew install yq
  fi

}

function installWindows() {
  wingetInstall --id mikefarah.yq --accept-package-agreements --accept-source-agreements
}

runIf isMac installMac
runIf isWindows installWindows
