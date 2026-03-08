# Devtools

My set of idempotent scripts to install and configure devtools on a new macOS or Windows machine.

## Running Setup

```bash
./setup.sh <manifest.json>
```

The script auto-elevates (sudo on macOS/Linux, UAC on Windows). On Windows, the environment is refreshed after each step so newly installed software is immediately available to subsequent steps.

## Manifest

The manifest is a JSON file that controls the run. See `manifest.example.json`.

```json
{
  "env": {
    "KEY": "value"
  },
  "steps": [
    "step-name"
  ],
  "extensions": [
    "publisher.extension-id"
  ]
}
```

- **`env`** — key/value pairs exported as environment variables available to all steps.
- **`steps`** — ordered list of steps to run. Each entry is a subdirectory name under `workbench/`. Remove a step to skip it.
- **`extensions`** — VS Code extension IDs installed by the `vscode` step.

## Workbench

Each step lives in `workbench/<step-name>/` and must contain an `index.sh`. Steps are executed as subshells with their own directory as the working directory.

```
workbench/
└── my-step/
    ├── index.sh          # required — runs when step is executed
    ├── bin/              # optional — copied to $TOOLS_BIN_HOME
    │   ├── my-command
    │   ├── osx/          # macOS-specific bin, takes priority over general
    │   ├── windows/      # Windows-specific bin
    │   └── linux/        # Linux-specific bin
    └── completion/       # optional — added to ~/.bashrc per command name
        └── my-command
```

`index.sh` is sourced (not executed), so `return` exits the step early without aborting setup.

## Utility Functions

All functions from `setup-utils/utils.sh` are automatically available inside every `index.sh`.

### OS / Architecture predicates

```bash
isMac       # darwin
isWindows   # msys (Git Bash)
isLinux     # linux

isArm       # arm64
isIntel     # x86_64
```

### Conditional execution

```bash
runIf <predicate> [and|or|not <predicate> ...] <function>

runIf isMac installMac
runIf isMac and isArm installMacArm
runIf not isWindows and isIntel install
```

### Copying bin files

```bash
installBinFiles
```

Copies `./bin/*` and `./bin/<os>/*` to `$TOOLS_BIN_HOME`. OS-specific files take priority over general ones on name collision. Registers any matching `./completion/<cmd>` file into `~/.bashrc`.

### Writing to ~/.bashrc

```bash
addToBashrc <id> <function-name|string>
```

Writes a block into `~/.bashrc` wrapped in `# BEGIN devtools:<id>` / `# END devtools:<id>` markers. Re-running removes the old block before adding the new one (idempotent). Accepts either a function name (body is extracted) or a plain string.

```bash
function myBlock() {
  export FOO="bar"
}
addToBashrc "my-id" myBlock

addToBashrc "gh-completion" 'eval "$(gh completion --shell bash)"'
```

## Conventions

- All steps must be idempotent — safe to run multiple times.
- Use `return` (not `exit`) for early exits inside `index.sh`.
- OS-specific logic should use `runIf` rather than inline `if` checks where possible.
- Bin files default to cross-platform; add an `osx/`, `windows/`, or `linux/` subdirectory only when behaviour differs by OS.
