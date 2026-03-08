function installMac() {
  if command -v yq > /dev/null 2>&1; then
    echo "yq already installed, skipping."
    return
  fi

  brew install yq
}

runIf isMac installMac
