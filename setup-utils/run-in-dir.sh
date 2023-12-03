pushd "$(dirname "${1}")"
. $(basename $1)
popd
