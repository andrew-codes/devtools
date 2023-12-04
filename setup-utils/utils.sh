function runInDir() {
  pushd "$(dirname "${1}")" >>/dev/null

  if [ -f $(basename $1) ]; then
    . $(basename $1)
  fi

  popd >>/dev/null
}

function brewInstall() {
  echo -e "Ensuring $1 is installed."

  brew list $1 >/dev/null 2>&1 || brew install $1
}

function wingetInstall() {
  echo -e "Ensuring $1 is installed."

  winget list $1 >/dev/null 2>&1 || winget install --accept-package-agreements --accept-source-agreements --exact --silent -q $1
}

function printH1() {
  echo -e "$1
$(echo $1 | sed "s/./=/"g)
"
}

function printH2() {
  echo -e "$1
$(echo $1 | sed "s/./-/"g)
"
}
