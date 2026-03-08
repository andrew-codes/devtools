#!/usr/bin/env bash

function installMac() {
  if command -v brew > /dev/null 2>&1; then
    echo "brew already installed, skipping."
    return
  fi

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

runIf isMac installMac
