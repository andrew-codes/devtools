function devup() {
  devpod up github.com/$GITHUB_USER/$1 --dotfiles https://github.com/$GITHUB_USER/$DEVTOOLS_REPO_NAME --provider kubernetes --debug
}

function devbuild() {
  devpod build github.com/$GITHUB_USER/$1 --provider docker --repository ghcr.io/$GITHUB_USER/$1 --debug
}
