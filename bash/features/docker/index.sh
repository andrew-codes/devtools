#!/usr/bin/env bash

if [ $DOCKER -ne 1 ]; then
  return 0;
fi

function denv() {
  if ! [ -z "$1" ]; then
    eval $(docker-machine env $1)
  fi
}

function dkill() {
  docker kill $(docker ps -q)
}
