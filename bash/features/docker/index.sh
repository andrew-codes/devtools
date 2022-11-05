#!/usr/bin/env bash

if [ $DOCKER -ne 1 ]; then
  return 0
fi

export DOCKER_HOST=ssh://root@codespaces

function denv() {
  if ! [ -z "$1" ]; then
    export DOCKER_HOST="$1"
  fi
}

function dkill() {
  docker kill $(docker ps -q)
}
