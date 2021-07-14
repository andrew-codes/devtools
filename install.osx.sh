#!/usr/bin/env bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew update

xcode-select --install

brew install 1password
brew install alfred
brew install altair-graphql-client
brew install ansible
brew install azure-cli
brew install backblaze
brew install bettertouchtool
brew install cdrtools
brew install dash
brew install discord
brew install docker
brew install dos2unix
brew install gcc
brew install gh
brew install gpg-suite
brew install hazel
brew install iterm2
brew install jq
brew install keybase
brew install keychain
brew install kindle
brew install kubectl
brew install kubeseal
brew install lens
brew install logitech-presentation
brew install microsoft-edge
brew install microsoft-office
brew install microsoft-teams
brew install moonlight
brew install nvm
brew install parsec
brew install pdf-expert
brew install pinentry-mac
brew install pliim
brew install python@3.9
brew install rowanj-gitx
brew install slack
brew install snagit
brew install spotify
brew install visual-studio-code
brew install yarn
brew install yq

## Setup devtools for bash.
source ./bash_features.sh
source ./add-devtools-to-bash_profile.sh

source ./vscode.extensions.sh

# Setup GPG keys from keybase
source ./gpg-keybase.sh
