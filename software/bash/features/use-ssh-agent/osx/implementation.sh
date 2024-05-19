find ~/.ssh -maxdepth 1 -type f ! -name "*.*" ! -name "*known_hosts" ! -name "*config" -exec keychain --eval --agents ssh --inherit any {} \;
