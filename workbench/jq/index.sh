#!/usr/bin/env bash

function installMac() {
  if command -v jq > /dev/null 2>&1; then
    echo "jq already installed, skipping."
    return
  fi

  brew install jq
}

runIf isMac installMac
