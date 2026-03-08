function installMac() {
  if command -v docker &> /dev/null; then
    return
  fi

  brew install --cask docker-desktop
}

runIf isMac installMac
installBinFiles
