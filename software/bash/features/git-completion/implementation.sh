if [ ! -f $TOOLS_HOME/.git-completion.bash ]; then
  curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o $TOOLS_HOME/.git-completion.bash
fi
. $TOOLS_HOME/.git-completion.bash
