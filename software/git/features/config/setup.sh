if [ ! "$DEVTOOLS_GIT_FEATURES_CONFIG_EMAIL" == "" ]; then
  git config --global user.email "$DEVTOOLS_GIT_FEATURES_CONFIG_EMAIL"
fi

if [ ! "$DEVTOOLS_GIT_FEATURES_CONFIG_NAME" == "" ]; then
  git config --global user.name "$DEVTOOLS_GIT_FEATURES_CONFIG_NAME"
fi

if [ -z "$CODESPACES" ] || [ "$CODESPACES" == "true" ]; then
  git config --global commit.gpgsign true
  git config --global gpg.format ssh

  if [ ! "$DEVTOOLS_GIT_FEATURES_CONFIG_EDITOR_COMMAND" == "" ]; then
    git config --global core.editor "$DEVTOOLS_GIT_FEATURES_CONFIG_EDITOR_COMMAND"
  fi

  if [ ! "$DEVTOOLS_GIT_FEATURES_CONFIG_SIGNINGKEY" == "" ]; then
    git config --global user.signingkey "$DEVTOOLS_GIT_FEATURES_CONFIG_SIGNINGKEY"
  fi

  if [ "$DEVTOOLS_BASH_FEATURES_USE_1PASSWORD_AGENT" == "true" ]; then
    git config --global gpg.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
  fi
fi

git config --global push.default simple
git config --global branch.autosetuprebase always
git config --global core.autocrlf false
git config --global init.defaultBranch main
