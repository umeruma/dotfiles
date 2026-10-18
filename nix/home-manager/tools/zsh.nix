# zsh itself: env, PATH, options, history, keys, completion.
# Each tool's aliases / functions / init live in that tool's file.
# Linux (Omarchy) still uses home/.zshrc via mise.unix.toml [dotfiles].
{ config, ... }:
{
  programs.zsh = {
    enable = true;
    # ~/.config/zsh is the repo's home/.config/zsh on Linux; keep zsh files in ~
    dotDir = config.home.homeDirectory;
    defaultKeymap = "emacs";
    autocd = true;
    syntaxHighlighting.enable = true;

    history = {
      path = "$HOME/.histfile";
      size = 10000;
      save = 10000;
      share = true;
      extended = true;
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      findNoDups = true;
      saveNoDups = true;
    };

    # Read by every zsh, including the non-interactive shells AI agents use,
    # so PATH and agent-safe settings belong here.
    envExtra = ''
      export LANG=en_US.UTF-8
      export READNULLCMD="less"
      export XDG_CONFIG_HOME="$HOME/.config"

      export DOTFILES="$HOME/Codes/dotfiles"
      export DOTFILES_HOME="$HOME/Codes/dotfiles/home"

      # Nix profiles go ahead of the system dirs, and Homebrew only fills in
      # what Nix does not provide. Listed here, not left to /etc/zshenv: it
      # skips PATH when __NIX_DARWIN_SET_ENVIRONMENT_DONE is inherited, as in
      # agent shells spawned by GUI apps (Orca, Cursor) with their own PATH.
      typeset -U path
      path=(
        "$HOME/.local/bin" "$DOTFILES/bin"(N-/)
        "/etc/profiles/per-user/$USER/bin" /run/current-system/sw/bin /nix/var/nix/profiles/default/bin
        ''${path:#/opt/homebrew/*}
        /opt/homebrew/bin(N-/) /opt/homebrew/sbin(N-/)
      )

      export HOMEBREW_FORBIDDEN_FORMULAE="python python3 pip npm pnpm yarn claude"

      # AI agent subprocesses (Cursor, Claude Code, Codex, opencode, Gemini, …).
      # Export AI_AGENT=1 to force the agent side.
      is_agent_shell() {
        [[ -n "''${CURSOR_AGENT:-}" ]] && return 0
        [[ -n "''${CLAUDECODE:-}''${CLAUDE_CODE_CHILD_SESSION:-}" ]] && return 0
        [[ -n "''${AGENT:-}''${OPENCODE:-}" ]] && return 0
        [[ -n "''${CODEX_CI:-}''${CODEX_SANDBOX:-}" ]] && return 0
        [[ -n "''${GEMINI_CLI:-}''${AI_AGENT:-}" ]] && return 0
        return 1
      }

      # Nothing may wait for input in an agent shell: an editor or a pager blocks.
      if is_agent_shell; then
        export EDITOR=true VISUAL=true GIT_EDITOR=true PAGER=cat
      fi
    '';

    initContent = ''
      # Arrow keys: walk history filtered by what is already typed (omarchy inputrc)
      bindkey '^[[A' history-beginning-search-backward
      bindkey '^[[B' history-beginning-search-forward
      bindkey '^[OA' history-beginning-search-backward
      bindkey '^[OB' history-beginning-search-forward

      # Completion: case-insensitive, Tab / Shift+Tab cycle candidates (omarchy inputrc)
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      setopt MENU_COMPLETE
      bindkey '^[[Z' reverse-menu-complete

      autoload -Uz zmv
      alias zmv='noglob zmv -W'

      # History (based on prezto's history module); the rest is in `history` above
      setopt BANG_HIST HIST_VERIFY HIST_BEEP

      # Directory (based on prezto's directory module)
      setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT PUSHD_TO_HOME CDABLE_VARS
      setopt MULTIOS EXTENDED_GLOB
      unsetopt CLOBBER

      alias dot='cd $DOTFILES'
    '';
  };
}
