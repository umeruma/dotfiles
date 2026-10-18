# ~/.zshenv
# Lightweight environment variables (read on every zsh start).
# Avoid running external commands here.
# Also read by the non-interactive, non-login shells AI agents use to run
# commands, so PATH and agent-safe settings belong here, not in .zprofile.
#
# read order
# - .zshenv   (this file)
# - .zprofile
# - .zshrc
# LINK: https://zsh.sourceforge.io/Doc/Release/Files.html#Files

export LANG=en_US.UTF-8
export EDITOR=nvim
export VISUAL="$EDITOR"
export READNULLCMD="less"

# bat: use the terminal's 16 colours (cendre); colour man pages (omarchy envs)
export BAT_THEME=ansi
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export DOTFILES="$HOME/Codes/dotfiles"
export DOTFILES_HOME="$HOME/Codes/dotfiles/home"

# -------------------------
# PATH
# -------------------------
# .zprofile re-applies this after /etc/zprofile's path_helper moves
# system dirs ahead of it in login shells.
typeset -U path
dotfiles_path=(
  /opt/homebrew/opt/rustup/bin(N-/)
  /opt/homebrew/bin(N-/)
  /opt/homebrew/sbin(N-/)
  "$HOME/.local/bin"
  "$DOTFILES/bin"(N-/)
)
path=($dotfiles_path $path)

# Homebrew settings (agents run brew too)
# Avoid installing certain formulae via Homebrew
# Link: https://docs.brew.sh/Manpage#:~:text=fishcompletion%2C%20zshcompletion%2C%20stageonly.-,HOMEBREW_FORBIDDEN_FORMULAE,-A%20space-separated%20list
export HOMEBREW_FORBIDDEN_FORMULAE="python python3 pip npm pnpm yarn claude"

# -------------------------
# AI agents
# -------------------------
# AI agent subprocesses (Cursor, Claude Code, Codex, opencode, Gemini, …)
# Used by .zshrc to skip interactive-only sheldon plugins (enhancd).
# Export AI_AGENT=1 to force the agent side.
# - CURSOR_AGENT=1: Cursor IDE agent and cursor-agent CLI
# - AGENT: codex sets "codex", opencode sets "1" (with OPENCODE=1)
is_agent_shell() {
  [[ -n "${CURSOR_AGENT:-}" ]] && return 0
  [[ -n "${CLAUDECODE:-}${CLAUDE_CODE_CHILD_SESSION:-}" ]] && return 0
  [[ -n "${AGENT:-}${OPENCODE:-}" ]] && return 0
  [[ -n "${CODEX_CI:-}${CODEX_SANDBOX:-}" ]] && return 0
  [[ -n "${GEMINI_CLI:-}${AI_AGENT:-}" ]] && return 0
  return 1
}

# Nothing may wait for input in an agent shell: git's core.editor opens
# VS Code with -W, and a pager blocks on output.
if is_agent_shell; then
  export EDITOR=true VISUAL=true GIT_EDITOR=true PAGER=cat
fi
