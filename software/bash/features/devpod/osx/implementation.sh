function devup() {
  devpod up github.com/$GITHUB_USER/$1 --dotfiles https://github.com/$GITHUB_USER/$DEVTOOLS_REPO_NAME --provider kubernetes --debug
}

function devbuild() {
  if [ ! "$DEVTOOLS_BASH_FEATURES_1PASSWORD_CLI" == "true" ]; then
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u $GITHUB_USER --password-stdin
  else
    echo "$(op read "op://Home Automation Secrets/github-cr-token/password")" | docker login ghcr.io -u $GITHUB_USER --password-stdin
  fi

  devpod build github.com/$GITHUB_USER/$1 --provider docker --repository ghcr.io/$GITHUB_USER/$($1 | sed s/\./__/) --debug
}
