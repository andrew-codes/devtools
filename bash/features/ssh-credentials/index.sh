#!/usr/bin/env bash

if [ $SSH_CREDENTIALS -ne 1 ]; then
  return 0;
fi

if [ $IS_OSX -eq 1 ]; then
  find ~/.ssh -maxdepth 1 -type f ! -name "*.*" ! -name "*known_hosts" -exec keychain --eval --agents ssh --inherit any {} \;
fi
