keybase pgp export | gpg --import
keybase pgp export --secret | gpg --allow-secret-key-import --import
git config --global gpg.program $(which gpg)