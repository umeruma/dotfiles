---
title: dotfiles
---

## install
Open Termilal.app, and run:

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/umeruma/dotfiles/main/install)"
```

To update macOS defaults setting, run:
```
cd ~/.dotfiles && just defaults
```

## tech stack

- [Just](https://github.com/casey/just) as command runner
- [Sheldon](https://github.com/rossmacarthur/sheldon#readme) as zsh plugin manager
- [Homebrew](https://docs.brew.sh/Manpage) as package manager