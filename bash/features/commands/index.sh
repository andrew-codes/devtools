#!/usr/bin/env bash

if [ $COMMANDS -ne 1 ]; then
  return 0
fi

function pap() {
  lsof -nP -i4TCP:$1 | grep LISTEN
}

if [ $IS_LINUX -eq 1 ]; then
  alias pbcopy='xsel --clipboard --input'
  alias pbpaste='xsel --clipboard --output'
fi
