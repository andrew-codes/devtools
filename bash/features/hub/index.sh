#!/usr/bin/env bash

if [ $HUB -ne 1 ]; then
  return 0;
fi

currentDir=$(dirname $BASH_SOURCE)
source "$currentDir/hub-completion.sh"

# GitHub [Hub](https://github.com/github/hub); OSX and Windows
if [ ${IS_OSX} ] && [ -f /usr/local/bin/hub ]; then
  alias git=hub
elif [ ${IS_WIN} ] && [ -f ${TOOLS_HOME}/hub/bin/hub.exe ]; then
  export PATH=$PATH:${TOOLS_HOME}/hub/bin
  eval "$(hub alias -s)"
fi
