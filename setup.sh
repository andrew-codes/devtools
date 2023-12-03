if [ -n"$1" ]; then
  echo "Usage: $1 environment configuration"
  set -o allexport
  source $1
  set +o allexport
fi

export os=${OSTYPE//[0-9.]/}

. setup-utils/run-in-dir.sh ./setup-utils/test/software/setup.sh

case $os in
darwin*)
  if [ "$DEVTOOLS_VSCODE" == "true" ]; then
    . setup-utils/run-in-dir.sh ./software/vscode/osx/setup.sh
  fi

  ;;
msys*)
  source ./software/vscode/windows/setup.sh

  ;;
*)
  echo "Unsupported OS: $OSTYPE"
  ;;
esac
