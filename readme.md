# Devtools

This repo is my **personal** collection of dotfiles, configuration settings, templates, and productivity tools. The intention is to be able to automate the installation and setup of a new developer workbench as much as possible.

## Getting Started

```bash
# Will use sample.env file for configuration
# Defaults to all options being disabled.
./setup.sh

# Copy configuration file for edits; allowing enabling tooling and its features.
cp sample.env .env

# Will use .env file for configuration.
./setup .env

# Documentation will be output for each enabled tool/feature
# Change directory for docs
ls $DEVTOOLS_HOME/docs
```

## Configuration

Configuration of devtool installation is controlled by env variables. By default, `sample.env` file will be used which disables all tools and features. Tools may be enabled and additionally features of the tool via the environment variables found in `sample.env`.

## What's Included?

All configured software is located under `./software/*`. All features of software are located under the software's features directory. For OS specific configuration, see feature's sub-directory by OS name, e.g., `osx` or `windows`. See the `README.md` for each software and feature for more details.

For example, to see information about VS Codes's keybindings feature, you can view the [./software/vscode/features/keybindings/README.md](./software/vscode/features/keybindings/README.md) for more information.
