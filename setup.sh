set -o allexport
if [ -n "$1" ]; then
  echo "Usage: $1 environment configuration"
  source $1
else
  source sample.env
fi
set +o allexport

export os=${OSTYPE//[0-9.]/}

case $os in
darwin*)
  os="osx"
  ;;
msys*)
  os="windows"

  ;;
*)
  echo "Unsupported OS: $OSTYPE"

  exit 1
  ;;
esac

source setup-utils/utils.sh

mkdir -p .tmp/docs
mkdir -p $DEVTOOLS_BASH_DEV_HOME/devtools-docs

runInDir ./software/settings/setup.sh
runInDir ./software/bash/setup.sh
runInDir ./software/vscode/setup.sh

echo -e "Generating dev tooling docs to $DEVTOOLS_BASH_DEV_HOME/devtools-docs"
mv .tmp/docs/* $DEVTOOLS_BASH_DEV_HOME/devtools-docs

echo -e ""
