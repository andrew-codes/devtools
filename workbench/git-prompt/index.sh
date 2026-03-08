
function install() {
  if [ ! -f  $TOOLS_HOME/git-prompt.sh ]; then
    curl -L https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh > $TOOLS_HOME/git-prompt.sh
    chmod +x $TOOLS_HOME/git-prompt.sh
  fi
}

function bashrc() {
  source $TOOLS_HOME/git-prompt.sh
}

install
addToBashrc 'git-prompt' bashrc
