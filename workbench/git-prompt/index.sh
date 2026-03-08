curl -L https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh > $TOOLS_HOME/git-prompt.sh

function bashrc() {
  source $TOOLS_HOME/git-prompt.sh
}

addToBashrc 'git-prompt' bashrc
