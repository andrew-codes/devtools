function bashRcContents() {
  eval "$(gh completion --shell bash)"
}

function installMac() {
  addToBashrc 'gh' bashRcContents

  if ! command -v gh >/dev/null 2>&1; then
    brew install gh
  fi
}

function installWindows() {
  wingetInstall --id GitHub.cli --accept-package-agreements --accept-source-agreements
}

runIf isMac installMac
runIf isWindows installWindows
