if [ ! "$IGNORE_ENV_FILE" == "true" ]; then
  set -o allexport
  if [ -n "$1" ]; then
    echo "Usage: $1 environment configuration"
    source $1
  else
    source sample.env
  fi
  set +o allexport
fi

export os=${OSTYPE//[0-9.]/}

case $os in
darwin*)
  os="osx"
  ;;
msys*)
  os="windows"
  ;;
*)
  os=$(cat /etc/*-release | grep "^ID_LIKE" | sed s/^ID_LIKE=//)
  ;;
esac

source setup-utils/utils.sh

mkdir -p .tmp/docs
mkdir -p .tmp/docs/assets
mkdir -p $DEVTOOLS_BASH_DEV_HOME/docs

runInDir ./software/settings/setup.sh
runInDir ./software/bash/setup.sh
runInDir ./software/vscode/setup.sh

printH1 "Generating dev tooling docs"
echo -e "Docs located at $DEVTOOLS_BASH_DEV_HOME/docs"
mv .tmp/docs/* $DEVTOOLS_BASH_DEV_HOME/docs
rm -rf .tmp

echo -e ""
