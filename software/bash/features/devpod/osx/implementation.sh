function devup() {
    devpod up github.com/$GITHUB_USER/$0 --dotfiles https://github.com/$GITHUB_USER/$DEVTOOLS_REPO_NAME --provider kubernetes
}

function devbuild() {
    devpod build github.com/$GITHUB_USER/$0 --provider docker --repository ghcr.io/$GITHUB_USER/$0
}