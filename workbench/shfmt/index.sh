function installMac() {
  if ! command -v shfmt >/dev/null 2>&1; then
    brew install shfmt
  fi

}

function installWindows() {
  wingetInstall --id mvdan.shfmt --accept-package-agreements --accept-source-agreements --source winget
}

runIf isMac installMac
runIf isWindows installWindows
