# Devtools

This repo is my **personal** collection of dotfiles, configuration settings, templates, and productivity tools. The intention is to be able to automate the installation and setup of a new developer workbench as much as possible. This represents the culmination of numerous iterations across various companies to automate developer onboarding.

## Customizing Your Workbench

A workbench is setup via a series of idempotent steps. The steps and their execution order is defined in a manifest.json file. There is a sample one provided `./manifest.example.json`. To add new steps, see the section "Adding New Steps."

## Install Your Workbench

The only required software is bash (or git Bash for Windows). Everything else is installed and configured via the workbench.

```bash
# Copy configuration file, make updates to it to enable software and features.
cp manifest.example.json manifest.json

# Will use .env file for configuration.
./setup.sh manifest.json
```

## Adding New Steps

The manifest references a step by its name. It is by convention that steps are `index.sh` file within directories by step name, located in the `./workbench` directory. Create a new directory with an index.sh file that handles the logic and add it to the steps array in the manifest. Note, the same step is run for all platforms. It is up to the step to install and configure its domain, including across OS/arch combinations. However, there are some very handy utilities that every step has access.

### Step Utilities

> All functions from `setup-utils/utils.sh` are automatically available inside every `index.sh`. You never need to source it manually.

#### Checking the OS and architecture

Use these predicates anywhere you need to gate behavior on the current platform. They return 0 (true) or 1 (false) like any shell test.

```bash
isMac      # true on macOS (darwin)
isWindows  # true on Windows running Git Bash / MSYS
isLinux    # true on Linux

isArm      # true when running on arm64 (Apple Silicon, ARM Linux)
isIntel    # true when running on x86_64
```

#### Running code conditionally with `runIf`

`runIf` calls a function only when the predicate expression evaluates to true. The last argument is always the function to call; everything before it is the condition.

```bash
runIf <predicate> [and|or|not <predicate> ...] <function>
```

Define a function for each variant, then declare when to run it:

```bash
function installMac() {
  brew install jq
}

function installWindows() {
  winget install jq
}

runIf isMac     installMac
runIf isWindows installWindows
```

Predicates can be chained with `and`, `or`, and `not`:

```bash
runIf isMac and isArm    installMacArm
runIf isMac and isIntel  installMacIntel
runIf not isWindows      installUnix
```

#### Copying bin files with `installBinFiles`

Call `installBinFiles` to copy scripts from the step's `bin/` directory into `$TOOLS_BIN_HOME`, where they will be on the user's `PATH`.

```bash
installBinFiles
```

It looks for files in two places, in this order:

1. `./bin/` — installed on all platforms
2. `./bin/osx/`, `./bin/windows/`, or `./bin/linux/` — installed on the matching OS only, overwriting any same-named file from step 1

Every installed file is made executable automatically. If a file with the same name exists under `./completion/`, its contents are also written into `~/.bashrc` as a tab-completion script.

#### Writing to `~/.bashrc` with `addToBashrc`

Use `addToBashrc` when a step needs to add something to the user's shell environment — exports, aliases, functions, or completion hooks.

```bash
addToBashrc <id> <content>
```

`<content>` can be a **function name** or a **string**. Passing a function name extracts its body, which lets you write the content as a real bash function and get syntax highlighting in your editor.

```bash
# Function — body is extracted, editor highlights it correctly
function myShellConfig() {
  export TOOLS_BIN_HOME="$HOME/tools/bin"
  alias ll="ls -lah"
}
addToBashrc "my-step" myShellConfig

# String — good for short one-liners
addToBashrc "gh-completion" 'eval "$(gh completion --shell bash)"'
```

The block is wrapped in `# BEGIN devtools:<id>` / `# END devtools:<id>` markers. On re-runs the old block is removed before the new one is written, so setup is safe to run multiple times. Use a unique `<id>` per block — the step name is a good default.
