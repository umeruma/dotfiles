# The following lines were added by compinstall
zstyle :compinstall filename '~/.zshrc'

autoload -U compinit
compinit -u
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install

alias arduino="/Applications/Arduino.app/Contents/MacOS/Arduino"

export LANG=en_US.UTF-8

export PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:$PATH
export PATH=/usr/local/var/nodebrew/current/bin:$PATH
export PATH=~/.gem/ruby/2.0.0/bin:$PATH
export PATH=$HOME/.nodebrew/current/bin:$PATH

export PATH="/usr/local/opt/gettext/bin:$PATH"

export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export NODEBREW_ROOT=/usr/local/var/nodebrew
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

if (( $+commands[npm] )); then
    source <(npm completion)
fi

if [[ -f ~/.zplug/init.zsh ]]; then
    export ZPLUG_HOME=~/.zplug
    source ~/.zplug/init.zsh

    zplug "b4b4r07/enhancd", use:init.sh

    if zplug check "b4b4r07/enhancd"; then
        export ENHANCD_FILTER="fzf --height 50% --reverse --ansi"
        export ENHANCD_DOT_SHOW_FULLPATH=1
    fi

    zplug "zsh-users/zsh-syntax-highlighting", defer:3
    zplug "zsh-users/zsh-completions"
    zplug "agkozak/polyglot", use:polyglot.sh, as:theme

    if ! zplug check --verbose; then
        printf "Install? [y/N]: "
        if read -q; then
            echo; zplug install
        fi
    fi
    zplug load
else
    print "try % curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh"
fi

function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}

alias ls="ls -G"
alias ll="ls -lG"
alias la="ls -laG"
