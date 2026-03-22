#!/usr/bin/env bash

function installMac() {
  if ! command -v jq >/dev/null 2>&1; then
    brew install jq
  fi
}

function installWindows() {
  wingetInstall --id jqlang.jq --accept-package-agreements --accept-source-agreements --source winget
}

runIf isMac installMac
runIf isWindows installWindows
