# Fonts

Terminal / Neovim fonts are **not** vendored in this repo.

## Install (macOS)

```bash
mise run install-fonts
```

Downloads into `~/Library/Fonts/`:

| Font | Upstream | License |
| --- | --- | --- |
| Moralerspace Neon | [yuru7/moralerspace](https://github.com/yuru7/moralerspace) | SIL OFL |
| ChaliceIcons | [artlaman/chalice-icon-theme](https://github.com/artlaman/chalice-icon-theme) | MIT |

Pin Moralerspace version:

```bash
MORALERSPACE_TAG=v2.0.0 mise run install-fonts
```

Alternative (full Moralerspace family via Homebrew):

```bash
brew install --cask font-moralerspace
```

Our task installs Neon faces only (what Ghostty uses).
