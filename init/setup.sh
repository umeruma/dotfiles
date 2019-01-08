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

if [ -f ~/.zplug/init.zsh ]; then
	echo "zplug is installed"
else
	curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
	sudo chmod -R 755 ~/.zplug
fi

if [[ "$SHELL" == "/bin/zsh" ]]; then
	echo "Using /bin/zsh"
else
	echo "Change default shell to /bin/zsh"
	chsh -s /bin/zsh
fi
