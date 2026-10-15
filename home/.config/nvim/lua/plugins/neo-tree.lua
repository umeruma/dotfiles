-- neo-tree: folders end with `/` (all OS); folder icons → Chalice (macOS / Linux).
-- File icons already come from mini.icons via its nvim-web-devicons mock (icons.lua).
-- Chalice codepoints: chalice-icons.toml [glyphs]. Windows skips them for the same
-- reason as icons.lua (no PUA codepoint-map in Windows Terminal).

local function glyph(code)
  return vim.fn.nr2char(tonumber(code, 16))
end

local component_configs = {
  name = { trailing_slash = true },
}

if vim.fn.has("win32") == 0 then
  component_configs.icon = {
    folder_closed = glyph("E000"),
    folder_open = glyph("E001"),
    folder_empty = glyph("E000"),
    folder_empty_open = glyph("E001"),
    default = glyph("E002"),
  }
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    default_component_configs = component_configs,
  },
}
