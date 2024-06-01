if [ "$DEVTOOLS_BASH_FEATURES_USE_1PASSWORD_AGENT" == "true" ]; then
  git config --global gpg.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
fi

if [ ! "$DEVTOOLS_GIT_FEATURES_CONFIG_EMAIL" == "" ]; then
  git config --global user.email "$(DEVTOOLS_GIT_FEATURES_CONFIG_EMAIL)"
fi

if [ ! "$DEVTOOLS_GIT_FEATURES_CONFIG_NAME" == "" ]; then
  git config --global user.name "$(DEVTOOLS_GIT_FEATURES_CONFIG_NAME)"
fi
if [ ! "$DEVTOOLS_GIT_FEATURES_CONFIG_SIGNINGKEY" == "" ]; then
  git config --global user.signingkey "$DEVTOOLS_GIT_FEATURES_CONFIG_SIGNINGKEY"
fi

git config --global push.default simple
git config --global branch.autosetuprebase always
git config --global core.autocrlf false
git config --global core.editor "code --wait"
git config --global gpg.format ssh
git config --global commit.gpgsign true
git config --global init.defaultBranch main
