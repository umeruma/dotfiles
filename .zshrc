# for check stanby time
# zmodload zsh/zprof && zprof

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

export LANG=en_US.UTF-8
export EDITOR=nano
export VISUAL="$EDITOR"


# Start of lines zi setting
# see: https://wiki.zshell.dev/docs/guides/commands
source <(curl -sL init.zshell.dev); zzinit

zi light-mode for @sindresorhus/pure
# zi load b4b4r07/enhancd
# export ENHANCD_FILTER="fzf --height 50% --reverse --ansi"
# export ENHANCD_DOT_SHOW_FULLPATH=1
# End of lines zi setting


# export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# eval $(/opt/homebrew/bin/brew shellenv) >>
export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";

function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}

alias ls="ls -G"
alias ll="ls -lG"
alias la="ls -laG"

# for check stanby time
# if (which zprof > /dev/null 2>&1) ;then
#   zprof
# fi
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# for Playdate SDK
export PLAYDATE_SDK_PATH="$HOME/Developer/PlaydateSDK"
export PATH="$PLAYDATE_SDK_PATH/bin:$PATH"

add-zsh-hook -Uz chpwd(){ source <(tea -Eds) }  #tea
