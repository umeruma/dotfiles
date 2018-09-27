# The following lines were added by compinstall
zstyle :compinstall filename '/Users/umeruma/.zshrc'

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

# Hook for desk activation
[ -n "$DESK_ENV" ] && source "$DESK_ENV" || true

export PATH=$HOME/.nodebrew/current/bin:$PATH

export PATH=/usr/local/bin:/bin:/usr/bin:$PATH
export PATH=/usr/local/sbin:$PATH
export NODEBREW_ROOT=/usr/local/var/nodebrew
export PATH=/usr/local/var/nodebrew/current/bin:$PATH
export PATH=~/.gem/ruby/2.0.0/bin:$PATH

export HOMEBREW_CASK_OPTS="--appdir=/Applications"

export ENHANCD_FILTER=peco:fzf

source <(npm completion)

#zplug start
source ~/.zplug/init.zsh
#export ZPLUG_HOME=/usr/local/opt/zplug
#source $ZPLUG_HOME/init.zsh
  
zplug "b4b4r07/enhancd", use:init.sh

zplug "jamesob/desk", as:command

# Hook for desk activation @see https://github.com/jamesob/desk
[ -n "$DESK_ENV" ] && source "$DESK_ENV" || true
alias d.="desk ."

zplug "stedolan/jq", as:command, from:gh-r, rename-to:jq
zplug "b4b4r07/emoji-cli", on:"stedolan/jq"
zplug "mrowa44/emojify", as:command

zplug "akoenig/gulp.plugin.zsh"
zplug "zsh-users/zsh-syntax-highlighting", defer:3
zplug "zsh-users/zsh-completions"
zplug 'yonchu/grunt-zsh-completion'

zplug 'mafredri/zsh-async'
zplug 'sindresorhus/pure', use:pure.zsh, as:theme

# Can manage local plugins
#zplug "~/.zsh", from:local
# A relative path is resolved with respect to the $ZPLUG_HOME
# zplug "repos/robbyrussell/oh-my-zsh/custom/plugins/my-plugin", from:local

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load
#zplug end
function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}

alias ls="ls -G"
alias ll="ls -lG"
alias la="ls -laG"
