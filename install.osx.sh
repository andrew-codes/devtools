echo "Install homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
brew update

echo "Installing security items..."
brew cask install 1password
brew cask install keybase

echo "Installing Internet items..."
brew cask install google-chrome
brew cask install discord

echo "Installing productivity items..."
brew cask install alfred
brew cask install iterm2
brew cask install docker
brew cask install bettertouchtool
# brew cask install snagit

echo "Installing development items..."
brew cask install visual-studio-code
brew install nvm
echo "Installing scm items..."
brew install git
brew install github/gh/gh
brew cask install rowanj-gitx

echo "Installing gaming items..."
brew cask install parsec

echo "Setting up vscode extenions..."
source ./vscode.extensions.sh