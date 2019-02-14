#!/bin/bash

if ! xcode-select -p >/dev/null 2>&1; then

    echo "Start to install CommandLineTools"
    xcode-select --install

    # Wait until the Command Line Tools are installed
    until xcode-select -p &> /dev/null; do
        sleep 5
    done

    echo "CommandLineTools are installed"
else 
    echo "CommandLineTools are already installed"
fi
