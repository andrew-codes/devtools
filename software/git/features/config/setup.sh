if [ "$DEVTOOLS_BASH_FEATURES_USE_1PASSWORD_AGENT" == "true" ]; then
  git config --global gpg.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
fi

if [ ! "$DEVTOOLS_GIT_FEATURES_CONFIG_EMAIL" == "" ]; then
  git config --global user.email "$(DEVTOOLS_GIT_FEATURES_CONFIG_EMAIL)"
fi

if [ ! "$DEVTOOLS_GIT_FEATURES_CONFIG_NAME" == "" ]; then
  git config --global user.name "$(DEVTOOLS_GIT_FEATURES_CONFIG_NAME)"
fi

git config --global user.signingkey "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDHGX0BrMpr5mm/maYDNJJhBrn1lvjgy+9//ufn+QV5rC8MQpkakTKi3qzEQ22Xw4bOPb59C80TkH8T6ur4Ygb0oPMhFCQoBpd1rabQCIISSwi+I4bth58h8Jl/tXdiNclfTyPHNBPxRTjOGG9Op+Zu8EQtd4QUinf3iFFKJ4Wyk9cuHbKGYkhKnQG/u1LD+IJ6y2pt4Cdh2hnO2HIsSKOp6djx8zuCOMyguN1giFsa4gmd3/TcNO/O/p6G1Xs3v1H9KWWtXVL0gRRd1NTbnbqyuBmlBu2wKWVbznlf7Jjkb0asophnHBSsIcwJU079YGWfCVeZ0eoq/goDcI2Nj+FkNTJsJxuOwCUCBCikPZwUstU1cRAhTP72pu08ZQXM/B+uF2lDCLVu+Kui2bZQbOjNGunRnsFfer7XGpfqIeaYd8zJNFQPQIoE5N+iRMRQ/M1NHY1+E0TtdxWIi3pN11r7d9SLV4XYYdU5OgZFBKeQXULY5tKYG/ZMQj0MPmpksZ8="
git config --global push.default = simple
git config --global branch.autosetuprebase = always
git config --global core.autocrlf = false
git config --global core.editor = "code --wait"
git config --global gpg.format = ssh
git config --global commit.gpgsign = true
git config --global init.defaultBranch = main
git config --global gpg.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
