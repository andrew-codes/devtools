brewInstall devpod --cask
brewInstall kubectl
brewInstall docker --cask

devpod providers add docker
devpod providers add kubernetes
