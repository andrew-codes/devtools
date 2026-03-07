# Devtools

My set of idempotent scripts to install and configure devtools on a new osx or Windows machine.

## Conventions

- Available software to be configured are under `software/*`
- Software has setup and implementation scripts. Setup scripts are run immediately and are used to install the software. Implementation scripts copied to user's `.bashrc` file and work at runtime.
- Software setup/implementation can be broken down into features (`software/*/features/*`). A feature follows the same conventions as software.
- A software may have setup or implementation files for all OS and/or within os sub-directories; e.g., `software/*/osx` or `software/*/windows`
  - The order of application is OS level scripts run first, then non-OS scripts if both exist.
- All setup scripts should be idempotent.

## Feature Toggles

- Software can skipped by setting software environment variables to false.
- Env vars exist at both the software and feature levels; following these naming conventions:
  - `DEVTOOLS_SOFTWARE-NAME=true|false`
  - `DEVTOOLS_SOFTWARE_NAME_FEATURES_FEATURE_NAME=true|false`.
