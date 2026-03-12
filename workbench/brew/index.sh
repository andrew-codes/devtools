#!/usr/bin/env bash

function brewBashrc() {
  export PATH="/opt/homebrew/bin:$PATH"
}

function installMac() {
  if ! command -v brew > /dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  addToBashrc "brew" brewBashrc
}

runIf isMac installMac
