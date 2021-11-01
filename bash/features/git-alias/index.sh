#!/usr/bin/env bash

if [ $GIT_ALIAS -ne 1 ]; then
  return 0
fi

# Git related aliases
alias push='git push'
alias mt='git mergetool'
alias df='git difftool'
alias fa='git fetch --all'
alias st='git status'
alias glg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
alias rbi='git rebase -i'
alias rbc='git rebase --continue'
alias rbs='git rebase --skip'
alias rba='git rebase --abort'
alias co='git checkout'
