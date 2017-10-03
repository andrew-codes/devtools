# Bash

## Installation

1. Edit `/bash/_variables.sh` with your path information and desired [features](#features).
1. Source the `_devtools.sh` file from your `.bashrc` file located in your User directory. Example is as follows:

```bash
devtools=/path/to/where/this/repo/was/cloned
source $devtools/bash/_devtools.sh
```

# Features
Features can be enabled or disabled in the `./_variables.sh` file.

1. [SSH Credentials](features/ssh-credentials)
1. [Additional git features](features/additional-git-functionality)
1. [Hub integration](features/hub) (learn more about [Hub](https://hub.github.com/))
1. [Git aliases](features/git-alias)
1. [Git prompt](features/git-prompt)

# Repo/Project searching

1. `proj` will change directory to your repo directory
1. `proj some-repo` will change directory to `some-repo` directory
1. `projs` will list all your repos
1. `projs some-value` will return any repo with `some-value` in the name
