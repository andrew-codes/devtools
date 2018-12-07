#!/usr/bin/env bash

if [ $ADDITIONAL_GIT_FUNCTIONALITY -ne 1 ]; then
  return 0;
fi

function rh() {
  if ! [ -z "$1" ]; then
    if ! [ -z "$2" ]; then
      git reset --hard $1/$2
    else
      git reset --hard $1
    fi
  else
    git reset --hard
  fi
  git clean -fd
}

function rs() {
  if ! [ -z "$1" ]; then
    if ! [ -z "$2" ]; then
      git reset --soft $1/$2
    else
      git reset --soft $1
    fi
  else
    git checkout .
  fi
}

function lb() {
  if ! [ -z "$1" ]; then
    git branch -a | grep "$1"
  else
    git branch -a
  fi
}

function nb() {
  if ! [ -z "$2" ] ; then
    git stash
    git checkout $2
  	git pull --rebase
  	git stash apply
  fi
  git checkout -b $1
  git push origin $1
  sb
}

function db() {
	git push origin --delete $1
  git branch -D $1
}

function pull() {
  if ! [ -z "$1" ]; then
  	if ! [ -z "$2" ]; then
  	  git pull --rebase $1 $2
  	else
	    git pull --rebase origin $1
    fi
  else
	   git pull --rebase
  fi
}

function stash() {
	git stash "$@"
}

function sb() {
  if ! [ -z "$1" ]; then
    if ! [ -z "$2" ]; then
      git branch --set-upstream-to=$1/$2
    else
      git branch --set-upstream-to=origin/$1
    fi
  else
    currentBranch="`git rev-parse --abbrev-ref HEAD`"
    git branch --set-upstream-to=origin/${currentBranch}
  fi
}

function pmb() {
  git branch --merged master --no-color  | grep -v '^[ *]*master$' | xargs git branch -d
}
