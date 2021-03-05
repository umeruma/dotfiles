#!/bin/bash
unamestr=`uname`

if type brew >/dev/null 2>&1; then
    echo "brew is installed";
else
    if [[ "$unamestr" == 'Linux' ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
    elif [[ "$unamestr" == 'Darwin' ]]; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
fi

if [ -f ~/.zinit/bin/zinit.zsh ]; then
    echo "zinit is installed"
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
fi

if [[ "$SHELL" == "/bin/zsh" ]]; then
    echo "Using /bin/zsh"
else
    echo "Change default shell to /bin/zsh"
    chsh -s /bin/zsh
fi
