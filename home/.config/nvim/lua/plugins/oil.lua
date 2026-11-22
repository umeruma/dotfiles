return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = {
      -- oil-git-status uses two sign columns (index, worktree)
      win_options = { signcolumn = "yes:2" },
      -- leave <C-h>/<C-l> to rex-pane-nav
      keymaps = { ["<C-h>"] = false, ["<C-l>"] = false },
    },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory (oil)" },
    },
  },
  {
    "refractalize/oil-git-status.nvim",
    dependencies = { "stevearc/oil.nvim" },
    config = true,
  },
}
