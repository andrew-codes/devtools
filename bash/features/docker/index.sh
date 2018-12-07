#!/usr/bin/env bash

if [ $DOCKER -ne 1 ]; then
  return 0;
fi

function docker-env() {
  if ! [ -z "$1" ]; then
    eval $(docker-machine env $1)
  fi
}

# function docker-vol-bak() {
#   if [ -z "$1" ] || [ -z "$2" ]; then
#     echo 'Missing parameters; try docker-vol-bak $CONTAINER_NAME $PATH_TO_BACKUP_DIRECTORY $BACKUP_NAME'
#   fi

#   BACKUP_NAME="${3:-backup.volume}"
#   docker run --rm --volumes-from $1 busybox tar -cO $2 | gzip -c > $BACKUP_NAME.tgz
# }

# function docker-vol-restore() {
#   if [ -z "$1" ] || [ -z "$2" ]; then
#     echo 'Missing parameters; try docker-vol-restore $VOLUME_NAME $PATH_TO_BACKUP_DIRECTORY $BACKUP_NAME'
#   fi

#   BACKUP_NAME="${3:-backup.volume}"
#   docker run --rm --volumes-from $1 --volumes-from "$1" debian:jessie tar -xzvf /backup/backup.tar.gz "${@:2}"
# }
