# ~/.zshenv
# Lightweight environment variables (read on every zsh start).
# Avoid running external commands here.
# 
# read order
# - .zshenv   (this file)
# - .zprofile
# - .zshrc
# LINK: https://zsh.sourceforge.io/Doc/Release/Files.html#Files

export LANG=en_US.UTF-8
export EDITOR=micro
export VISUAL="$EDITOR"
export READNULLCMD="less"

export DOTFILES="$HOME/Codes/dotfiles"
export DOTFILES_HOME="$HOME/Codes/dotfiles/home"

# AI agent subprocesses (Cursor, Claude Code, Codex, …)
# Used by .zshrc to skip interactive-only sheldon plugins (enhancd).
is_agent_shell() {
  [[ -n "${CURSOR_AGENT:-}" ]] && return 0
  [[ -n "${CLAUDE_CODE_CHILD_SESSION:-}" ]] && return 0
  [[ "${AGENT:-}" == codex ]] && return 0
  [[ -n "${CODEX_CI:-}" ]] && return 0
  return 1
}
