function denv() {
  if ! [ -z "$1" ]; then
    export DOCKER_HOST="$1"
  fi
}

function dka() {
  docker kill $(docker ps -q)
}
