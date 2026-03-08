function gitCompletionBashrc() {
  if [ ! -f $TOOLS_HOME/git-completion.sh ]; then
    curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o $TOOLS_HOME/git-completion.sh
    chmod +x $TOOLS_HOME/git-completion.sh
  fi
  . $TOOLS_HOME/git-completion.sh
}

addToBashrc 'git-completion' gitCompletionBashrc
