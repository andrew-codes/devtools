function installMac() {
  if ! command -v uvx &>/dev/null; then
    brew install uv
  fi
}

function installWindows() {
  wingetInstall --id astral-sh.uv --accept-package-agreements --accept-source-agreements --source winget
}

runIf isMac installMac
runIf isWindows installWindows
