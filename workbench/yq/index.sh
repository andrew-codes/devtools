function installMac() {
  if ! command -v yq > /dev/null 2>&1; then
    brew install yq
  fi

}

function installWindows() {
  if ! command -v yq > /dev/null 2>&1; then
    winget install --id mikefarah.yq --accept-package-agreements --accept-source-agreements
  fi
}

runIf isMac installMac
runIf isWindows installWindows
