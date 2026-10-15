-- Silence LazyVim / Neovim release-notes popups (omarchy-nvim).
return {
  "LazyVim/LazyVim",
  opts = {
    news = {
      lazyvim = false,
      neovim = false,
    },
  },
}
