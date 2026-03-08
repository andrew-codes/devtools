function installMac() {
  if ! command -v shfmt > /dev/null 2>&1; then
    brew install shfmt
  fi

}

function installWindows() {
  if ! command -v shfmt > /dev/null 2>&1; then
    winget install --id mvdan.shfmt --accept-package-agreements --accept-source-agreements
  fi
}

runIf isMac installMac
runIf isWindows installWindows
