if [ ! -f $TOOLS_HOME/gh-completion.sh ]; then
  gh completion --shell bash >$TOOLS_HOME/gh-completion.sh
fi
. $TOOLS_HOME/gh-completion.sh
