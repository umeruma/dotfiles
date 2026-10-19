# Hand-written dotfiles in home/, linked into ~ (macOS). The links point at
# the repo, not the Nix store, so edits apply without a switch. Linux and
# Windows link the same files with mise [dotfiles] (mise.linux.toml /
# mise.windows.toml). A tool's own dotfile is linked from its tools/<tool>.nix.
{ config, lib, ... }:
let
  repo = config.my.repo;
  link = path: { source = config.lib.file.mkOutOfStoreSymlink "${repo}/${path}"; };
  home = name: link "home/${name}";
  # Claude Code only reads ~/.claude/skills; Cursor and Copilot read ~/.agents.
  claudeSkills = [
    "commit"
    "dev-crit"
    "dev-server"
    "git-wt"
    "natural-japanese"
    "orca-cli"
    "orchestration"
    "wt-slots"
  ];
in
{
  home.file =
    lib.genAttrs [
      ".gitconfig"
      ".gitignore" # git's core.excludesfile
      # Whole dir: skill installers (npx skills) write through it into the repo
      ".agents"
      ".claude/CLAUDE.md"
      # Claude Code writes back through it (theme, marketplaces)
      ".claude/settings.json"
      ".cursor/settings.json"
      ".cursor/hooks.json"
    ] home
    // lib.genAttrs (map (s: ".claude/skills/${s}") claudeSkills) (
      n: link "home/.agents/skills/${lib.removePrefix ".claude/skills/" n}"
    )
    // {
      ".copilot/instructions/global.instructions.md" =
        link "home/.agents/instructions/global.instructions.md";
    };

  # ~/.config links to home/.config as a whole, so tools keep writing their
  # config there; their state and credentials are ignored by
  # home/.config/.gitignore. Linked before home-manager checks its targets,
  # so anything home-manager writes under ~/.config goes through the link.
  home.activation.dotfilesConfigLink = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    if [[ -L ~/.config && "$(/usr/bin/readlink ~/.config)" == "${repo}/home/.config" ]]; then
      :
    elif [[ -d ~/.config && ! -L ~/.config && -z "$(/bin/ls -A ~/.config)" ]]; then
      run /bin/rmdir ~/.config
      run /bin/ln -s "${repo}/home/.config" ~/.config
    elif [[ ! -e ~/.config && ! -L ~/.config ]]; then
      run /bin/ln -s "${repo}/home/.config" ~/.config
    else
      errorEcho "~/.config is not a link to ${repo}/home/.config; move its contents into ${repo}/home/.config, remove it and switch again"
      exit 1
    fi
  '';

  # Dropover greys out symlinks in its file picker, so this one is copied.
  home.activation.dropoverScript = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run /bin/mkdir -p ~/"Library/Application Scripts/me.damir.dropover-mac"
    run /usr/bin/install -m 755 \
      "${repo}/home/Library/Application Scripts/me.damir.dropover-mac/upload-r2.sh" \
      ~/"Library/Application Scripts/me.damir.dropover-mac/upload-r2.sh"
  '';
}
