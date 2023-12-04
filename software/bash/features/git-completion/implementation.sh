if [ ! -f $DEVTOOLS_BASH_TOOLS_HOME/.git-completion.bash ]; then
  curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o $DEVTOOLS_BASH_TOOLS_HOME/.git-completion.bash
fi
. $DEVTOOLS_BASH_TOOLS_HOME/.git-completion.bash
