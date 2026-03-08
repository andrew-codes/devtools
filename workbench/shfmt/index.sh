function installMac() {
  if command -v shfmt > /dev/null 2>&1; then
    echo "shfmt already installed, skipping."
    return
  fi

  brew install shfmt
}

runIf isMac installMac
