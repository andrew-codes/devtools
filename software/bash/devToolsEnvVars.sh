echo "Modifying .bash_profile with Dev Tools env vars."
echo -e "$(
  cat <<END
# <DEVTOOLS>
# Environment variables
# =====================
export DEV_HOME=$DEVTOOLS_BASH_DEV_HOME
export REPO_HOME=$DEVTOOLS_BASH_REPO_HOME
export DEVTOOLS_HOME=$DEVTOOLS_BASH_DEVTOOLS_HOME
export TOOLS_HOME=$DEVTOOLS_BASH_TOOLS_HOME
export TOOLS_BIN_HOME=$DEVTOOLS_BASH_TOOLS_BIN_HOME
# </DEVTOOLS>
END
)" >>~/.bash_profile
