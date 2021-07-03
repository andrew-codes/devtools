#!/usr/bin/env bash

if [ $COMMANDS -ne 1 ]; then
  return 0;
fi

function pap() {
  lsof -nP -i4TCP:$1 | grep LISTEN
}