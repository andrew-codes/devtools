git config --global push.default simple
git config --global branch.autosetuprebase always
git config --global core.autocrlf false
git config --global init.defaultBranch main

if [ -n "$GIT_EMAIL" ]; then
  git config --global user.email "$GIT_EMAIL"
fi

if [ -n "$GIT_NAME" ]; then
  git config --global user.name "$GIT_NAME"
fi

git config --global commit.gpgsign true
git config --global gpg.format ssh

if [ -n "$GIT_EDITOR_COMMAND" ]; then
  git config --global core.editor "$GIT_EDITOR_COMMAND"
fi

if [ -n "$GIT_SIGNING_KEY" ]; then
  git config --global user.signingkey "$GIT_SIGNING_KEY"
fi

function mac() {
  git config --global core.editor "code --wait"

  if [ "$GIT_SSH_AGENT" == "1p" ]; then
    git config --global gpg.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    git config --global gpg.ssh.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
  fi
}

function windows() {
  git config --global core.editor "\"${LOCALAPPDATA}\\Programs\\Microsoft VS Code\\bin\\code\" --wait"

  if [ "$GIT_SSH_AGENT" == "1p" ]; then
    git config --global gpg.ssh.program 'C:\Program Files\1Password\app\8\op-ssh-sign.exe'
    git config --global core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe"
  fi
}

runIf isMac mac
runIf isWindows windows
