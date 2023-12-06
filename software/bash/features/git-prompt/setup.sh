curl -L https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh >$DEVTOOLS_BASH_TOOLS_HOME/git-prompt.sh

echo -e "# <DEVTOOLS>
# Git Prompt
# ==========
source $TOOLS_HOME/git-prompt.sh
# </DEVTOOLS>
" >>~/.bash_profile
