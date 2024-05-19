# Devtools

This repo is my **personal** collection of dotfiles, configuration settings, templates, and productivity tools. The intention is to be able to automate the installation and setup of a new developer workbench as much as possible.

## Getting Started

> The devtools assume git and bash are installed locally. No other software is required to get started.
>
> All commands are run in a bash terminal.

```bash
# Will use sample.env file for configuration
# Defaults to all options being disabled.
./setup.sh

# Copy configuration file, make updates to it to enable software and features.
cp sample.env .env

# Will use .env file for configuration.
./setup .env

# Documentation will be output for each enabled tool/feature
# View docs files via:
ls $DEVTOOLS_HOME/docs
```

## Configuration

All software and their features are configurable via environment variables. By default, `sample.env` file will be used which disables all tools and features. Tools may be enabled and additionally features of the tool via the environment variables found in `sample.env`.

## What's Included?

See the comprehensive [features documentation](./features.md) for more details. This is a compendium of all software and features into a single document.
