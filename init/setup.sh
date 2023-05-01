#!/bin/bash
unamestr=$(uname)

if type brew >/dev/null 2>&1; then
    echo "brew is installed";
else
    if [[ "$unamestr" == 'Linux' ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
    elif [[ "$unamestr" == 'Darwin' ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
fi

if [ -f /usr/local/bin/tea ]; then
    echo "tea is installed";
else
    if [[ "$unamestr" == 'Darwin' ]]; then
        sh <(curl https://tea.xyz)
    fi
fi

if [ -f ~/.zi/bin/lib/zsh/install.zsh ]; then
    echo "zinit is installed"
else
    sh -c "$(curl -fsSL get.zshell.dev)" -- -i skip -b main
fi

if [[ "$SHELL" == "/bin/zsh" ]]; then
    echo "Using /bin/zsh"
else
    echo "Change default shell to /bin/zsh"
    chsh -s /bin/zsh
fi
