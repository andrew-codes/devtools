# Devtools

This repo is my **personal** collection of dotfiles, configuration settings, templates, and productivity tools. The intention is to be able to automate the installation and setup of a new developer workbench as much as possible.

This repo defines two primary use cases; installation of software and enabling features in Bash, other software.

## Installing Software

This is **not configurable**. Running `install.osx.sh` will install the software I regularly use.

## Bash Features

Despite this being my personal collection, there may be things useful to others. With this in mind, features may be turned on/off by updating the `bash_features.sh` file. See the [bash README](bash) for details on each feature and what it does.

### Example Toggling Features
```shell
# Enable/Disable Features
# =======================
# set to 0 to disable.

SSH_CREDENTIALS=1
GPG=0 # Turn off by setting to 0
ADDITIONAL_GIT_FUNCTIONALITY=1
GIT_PROMPT=1
GIT_ALIAS=1
PROJECT_FINDER=1
DOCKER=1
COMMANDS=1
# </DEVTOOLS>
```

## VS Code

### Extensions

See the list of extensions I use found in the[vscode.extensions.sh](vscode.extenions.sh) file. Optionally, running the shell file will install all mentioned extensions.

### Templates/Snippets

I have published several extensions that provide different sets of snippets for VS Code.

* [Mocha](https://marketplace.visualstudio.com/items?itemName=andrew-codes.mocha-snippets)
* [React](https://marketplace.visualstudio.com/items?itemName=andrew-codes.react-snippets)
* [Redux with React](https://marketplace.visualstudio.com/items?itemName=andrew-codes.redux-react-snippets)

## BDD Spec Writing (Windows Only)

An autohokey script to replace spaces, ` `, with underscores. This makes writing specs that read as sentences easier. Simply write the sentence and let autohotkey change the spaces to underscores. I typically have this enabled/disabled via a hotkey.

See [Writing BDD specs with ease in C#](autohotkey) for more details.
