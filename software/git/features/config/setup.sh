gpgProgram=""
if [ "$DEVTOOLS_BASH_FEATURES_USE_1PASSWORD_AGENT" == "true" ]; then
  gpgProgram="program = /Applications/1Password.app/Contents/MacOS/op-ssh-sign"
fi

if [ ! -f ~/.gitconfig ]; then
echo -e "
[user]
  name = $(DEVTOOLS_GIT_FEATURES_CONFIG_NAME)
  email = $(DEVTOOLS_GIT_FEATURES_CONFIG_EMAIL)
" >~/.gitconfig
fi

config="$(cat ~/.gitconfig | tr '\n' '\r' | sed -e "s;# <DEVTOOLS>.*</DEVTOOLS>;;g" | tr '\r' '\n')"
echo "
$config
# <DEVTOOLS>
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
  $(echo "$gpgProgram")
  format = ssh

[commit]
  gpgsign = true

[init]
  defaultBranch = main

[user]
  signingkey = ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDHGX0BrMpr5mm/maYDNJJhBrn1lvjgy+9//ufn+QV5rC8MQpkakTKi3qzEQ22Xw4bOPb59C80TkH8T6ur4Ygb0oPMhFCQoBpd1rabQCIISSwi+I4bth58h8Jl/tXdiNclfTyPHNBPxRTjOGG9Op+Zu8EQtd4QUinf3iFFKJ4Wyk9cuHbKGYkhKnQG/u1LD+IJ6y2pt4Cdh2hnO2HIsSKOp6djx8zuCOMyguN1giFsa4gmd3/TcNO/O/p6G1Xs3v1H9KWWtXVL0gRRd1NTbnbqyuBmlBu2wKWVbznlf7Jjkb0asophnHBSsIcwJU079YGWfCVeZ0eoq/goDcI2Nj+FkNTJsJxuOwCUCBCikPZwUstU1cRAhTP72pu08ZQXM/B+uF2lDCLVu+Kui2bZQbOjNGunRnsFfer7XGpfqIeaYd8zJNFQPQIoE5N+iRMRQ/M1NHY1+E0TtdxWIi3pN11r7d9SLV4XYYdU5OgZFBKeQXULY5tKYG/ZMQj0MPmpksZ8=
# </DEVTOOLS>
" >>~/.gitconfig
