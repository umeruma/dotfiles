#!/bin/bash

if ! xcode-select -p >/dev/null 2>&1; then
    xcode-select --install
else 
    echo "CommandLineTools is installed"
fi