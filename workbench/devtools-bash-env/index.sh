function bashRcContents() {
  export DEV_HOME=$DEV_HOME
  export REPO_HOME=$REPO_HOME
  export DEVTOOLS_HOME=$DEVTOOLS_HOME
  export TOOLS_HOME=$TOOLS_HOME
  export TOOLS_BIN_HOME=$TOOLS_BIN_HOME
  export DEVTOOLS_REPO_NAME=devtools
  export GITHUB_USERNAME=$GITHUB_USERNAME
  export PATH=$TOOLS_BIN_HOME:$PATH
}

addToBashrc 'env' bashRcContents

mkdir -p $DEV_HOME
mkdir -p $REPO_HOME
mkdir -p $DEVTOOLS_HOME
mkdir -p $TOOLS_HOME
mkdir -p $TOOLS_BIN_HOME
