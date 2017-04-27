# The following lines were added by compinstall
zstyle :compinstall filename '/Users/takumisaito/.zshrc'
fpath=(/usr/local/share/zsh-completions $fpath)

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
alias vim="nvim"


# Hook for desk activation
[ -n "$DESK_ENV" ] && source "$DESK_ENV" || true

export PATH=/usr/local/bin:/bin:/usr/bin:$PATH
export PATH="/usr/local/sbin:$PATH"
export NODEBREW_ROOT=/usr/local/var/nodebrew
export PATH=/usr/local/var/nodebrew/current/bin:$PATH

export HOMEBREW_CASK_OPTS="--appdir=/Applications"

export PATH="$(brew --prefix homebrew/php/php55)/bin:$PATH"

export ENHANCD_FILTER=fzy:fzf

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
    
zplug "b4b4r07/ultimate", as:theme
zplug "akoenig/gulp.plugin.zsh"
zplug 'yonchu/grunt-zsh-completion'

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

# pip zsh completion start
function _pip_completion {
  local words cword
  read -Ac words
  read -cn cword
  reply=( $( COMP_WORDS="$words[*]" \
             COMP_CWORD=$(( cword-1 )) \
             PIP_AUTO_COMPLETE=1 $words[1] ) )
}
compctl -K _pip_completion pip
# pip zsh completion end
export PATH="/usr/local/bin:$PATH"

export PATH="$HOME/.yarn/bin:$PATH"
export PATH="$PATH:`yarn global bin`"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# tabtab source for yarn package
# uninstall by removing these lines or running `tabtab uninstall yarn`
[[ -f /Users/takumisaito/.config/yarn/global/node_modules/tabtab/.completions/yarn.zsh ]] && . /Users/takumisaito/.config/yarn/global/node_modules/tabtab/.completions/yarn.zsh
eval "$(rbenv init -)"
