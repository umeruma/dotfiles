local hl = "FileIcon"

local function set_hl()
  -- cendre: darker than NonText #463e3a, still above NeoTreeNormal bg #0f0c0a
  vim.api.nvim_set_hl(0, hl, { fg = "#3c3531" })
  vim.api.nvim_set_hl(0, "NeoTreeDirectoryIcon", { link = hl })
  vim.api.nvim_set_hl(0, "NeoTreeFileIcon", { link = hl })
end
set_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })

-- VS Code languageId → Neovim filetype (only where names differ)
local language_to_ft = {
  docker = "dockerfile",
}

--- Minimal TOML reader for file-icons.toml (sections + quoted string values).
local function parse_toml(path)
  local root = { glyphs = {}, extensions = {}, files = {}, filetypes = {} }
  local section = root
  for _, line in ipairs(vim.fn.readfile(path)) do
    line = vim.trim(line)
    local sec = line:match("^%[([%w_]+)%]$")
    if sec then
      root[sec] = root[sec] or {}
      section = root[sec]
    else
      local key, val = line:match('^([%w_.-]+)%s*=%s*"(.-)"$')
      if key then
        section[key] = val
      end
    end
  end
  return root
end

local theme = parse_toml(vim.fs.joinpath(vim.fn.stdpath("config"), "file-icons.toml"))

local function category_map(tbl)
  local out = {}
  for name, cat in pairs(tbl) do
    out[name] = assert(theme.glyphs[cat], "file-icons.toml: unknown category " .. cat)
  end
  return out
end

local default_file = theme.glyphs[theme.default_file]
local default_folder = theme.glyphs[theme.default_folder]
local by_ext = category_map(theme.extensions)
local by_file = category_map(theme.files)
local by_ft = {}
for lang, glyph in pairs(category_map(theme.filetypes)) do
  by_ft[language_to_ft[lang] or lang] = glyph
end

local function get_extension(name)
  local key = name:lower()
  if by_ext[key] then
    return by_ext[key], false
  end
  local dot = key:find("%.")
  while dot do
    local g = by_ext[key:sub(dot + 1)]
    if g then
      return g, false
    end
    dot = key:find("%.", dot + 1)
  end
  return default_file, true
end

local function get_file(name)
  local basename = vim.fs.basename(name):lower()
  if by_file[basename] then
    return by_file[basename], false
  end
  local dot = basename:find("%..", 2)
  if dot then
    return get_extension(basename:sub(dot + 1))
  end
  return default_file, true
end

local resolvers = {
  directory = function()
    return default_folder, false
  end,
  extension = get_extension,
  file = get_file,
  filetype = function(name)
    local g = by_ft[name:lower()] or by_ext[name:lower()]
    return g or default_file, g == nil
  end,
}

return {
  {
    "nvim-mini/mini.icons",
    opts = { style = "ascii" },
    config = function(_, opts)
      local MiniIcons = require("mini.icons")
      MiniIcons.setup(opts)
      local orig_get = MiniIcons.get
      ---@diagnostic disable-next-line: duplicate-set-field
      MiniIcons.get = function(category, name)
        local resolve = resolvers[category]
        if resolve and type(name) == "string" then
          local glyph, is_default = resolve(name)
          return glyph, hl, is_default
        end
        return orig_get(category, name)
      end
    end,
  },
}
