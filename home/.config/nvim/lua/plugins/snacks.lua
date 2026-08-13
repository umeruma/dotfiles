-- Chalice folder/file fallbacks used by Snacks explorer (dir_open is not via mini.icons).
-- Codepoints match home/.config/nvim/chalice-icons.toml [glyphs]
local function chalice(code)
  return vim.fn.nr2char(tonumber(code, 16)) .. " "
end

return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        icons = {
          files = {
            dir = chalice("E000"),
            dir_open = chalice("E001"),
            file = chalice("E002"),
          },
        },
        sources = {
          explorer = {
            hidden = true, -- show dotfiles (.config, .zshrc, …)
            -- ignored = true, -- also show gitignored files (uncomment if needed)
          },
        },
      },
    },
  },
}
