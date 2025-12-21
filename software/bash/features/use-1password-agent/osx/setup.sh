if [ ! -d "/Applications/1Password.app" ]; then
  brewInstall 1password --cask
else
  echo "1Password is already installed, skipping installation"
fi
echo "Please follow directions to turn on 1Password SSH Agent; https://developer.1password.com/docs/ssh/get-started#step-3-turn-on-the-1password-ssh-agent"
