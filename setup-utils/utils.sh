function runInDir() {
  pushd "$(dirname "${1}")" >>/dev/null

  if [ -f $(basename $1) ]; then
    . $(basename $1)
  fi

  popd >>/dev/null
}

function brewInstall() {
  echo -e "Installing $1"

  brew list $1 >/dev/null 2>&1 || brew install $1
}

function wingetInstall() {
  echo -e "Installing $1"

  winget list $1 >/dev/null 2>&1 || winget install --accept-package-agreements --accept-source-agreements --exact --silent -q $1
}
