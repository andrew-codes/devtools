function bashRcContents() {
  eval "$(gh completion --shell bash)"
}

function installMac() {
  addToBashrc 'gh' bashRcContents

  if command -v gh > /dev/null 2>&1; then
    echo "gh already installed, skipping."
    return
  fi

  brew install gh
}

runIf isMac installMac
