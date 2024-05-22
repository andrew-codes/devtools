brewInstall devpod --cask
brewInstall kubectl
brewInstall docker --cask

devpod provider add docker
devpod provider add kubernetes
