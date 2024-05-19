gpgProgram=""
if [ "$DEVTOOLS_BASH_FEATURES_USE_1PASSWORD_AGENT" == "true" ]; then
  gpgProgram="program = /Applications/1Password.app/Contents/MacOS/op-ssh-sign"
fi

echo -e "
[user]
  name = $(DEVTOOLS_BASH_FEAUTURES_GIT_CONFIG_NAME)
  email = $(DEVTOOLS_BASH_FEAUTURES_GIT_CONFIG_EMAIL)
  signingkey = $(DEVTOOLS_BASH_FEAUTURES_GIT_CONFIG_SIGNING_KEY)

[push]
  default = simple

[branch]
  autosetuprebase = always

[core]
  autocrlf = false
  editor = code --wait

[filter "media"]
  clean = git-media-clean %f
  smudge = git-media-smudge %f

[gpg]
  format = ssh
  $(gpgPgrogram)

[commit]
  gpgsign = true

[init]
  defaultBranch = main

[filter "lfs"]
  process = git-lfs filter-process
  required = true
  clean = git-lfs clean -- %f
  smudge = git-lfs smudge -- %f
" >~/.gitconfig
