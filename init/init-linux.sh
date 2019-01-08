#!/bin/bash

sudo apt-get update

if ! type make >/dev/null 2>&1; then
    sudo apt-get install build-essential
fi
if ! type zsh >/dev/null 2>&1; then
    sudo apt-get install zsh
fi