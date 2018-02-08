#!/usr/bin/env bash

if [ $SSH_CREDENTIALS -ne 1 ]; then
  return 0;
fi

find ~/.ssh -maxdepth 1 -type f ! -name "*.*" ! -name "*known_hosts" -exec keychain --eval --agents ssh --inherit any {} \;
