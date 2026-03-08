function installMac() {
  if command -v go > /dev/null 2>&1; then
    echo "go already installed, skipping."
    return
  fi

  brew install go
}

runIf isMac installMac
