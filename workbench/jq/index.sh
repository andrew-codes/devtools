#!/usr/bin/env bash

function installMac() {
  if ! command -v jq > /dev/null 2>&1; then
    brew install jq
  fi
}

function installWindows() {
  if ! command -v jq > /dev/null 2>&1; then
    winget install --id jqlang.jq
  fi
}

runIf isMac installMac
runIf isWindows installWindows
