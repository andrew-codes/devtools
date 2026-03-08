#!/usr/bin/env bash

touch ~/.bash_profile
touch ~/.bashrc

if ! grep -q '\.bashrc' ~/.bash_profile; then
  printf '\nsource ~/.bashrc\n' >> ~/.bash_profile
  echo "Added source ~/.bashrc to ~/.bash_profile."
else
  echo "~/.bash_profile already sources ~/.bashrc, skipping."
fi
