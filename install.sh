#!/usr/bin/env bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew cask install bettertouchtool
brew cask install dash
brew cask install discord
brew cask install docker
brew cask install firefox
brew cask install google-chrome
brew cask install grammarly
brew cask install iterm2
brew cask install keybase
brew cask install kindle
brew cask install logitech-presentation
brew cask install microsoft-office
brew cask install microsoft-teams
brew cask install parsec
brew cask install pdf-expert
brew cask install pliim
brew cask install slack
brew cask install snagit
brew cask install spotify
brew cask install visual-studio-code
brew install gh
brew install keychain

## Setup devtools for bash.
source ./add-devtools-to-bash_profile.sh