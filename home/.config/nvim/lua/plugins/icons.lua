-- Apply Chalice icon theme to mini.icons.
-- Source of truth: stdpath("config")/chalice-icons.toml
-- Upstream: https://github.com/artlaman/chalice-icon-theme (MIT)
-- Font: mise run install-fonts → ~/Library/Fonts/ChaliceIcons-Regular.ttf
--
-- Rules:
--   1. Only Chalice glyphs for file / extension / filetype / directory
--   2. Names listed in the TOML use that category
--   3. Everything else falls back to default_file / default_folder

local hl = "MiniIconsGrey"
local toml_path = vim.fs.joinpath(vim.fn.stdpath("config"), "chalice-icons.toml")

-- VS Code languageId → Neovim filetype (only where names differ)
local language_to_ft = {
  docker = "dockerfile",
}

--- Minimal TOML reader for this file's schema (sections + quoted string values).
local function parse_toml(text)
  local root = { glyphs = {}, extensions = {}, files = {}, filetypes = {} }
  local section = root
  for line in vim.gsplit(text, "\n", { plain = true }) do
    line = line:match("^%s*(.-)%s*$") or ""
    if line ~= "" and not line:match("^#") then
      local sec = line:match("^%[([%w_]+)%]$")
      if sec then
        root[sec] = root[sec] or {}
        section = root[sec]
      else
        local key, val = line:match('^([%w_.-]+)%s*=%s*"(.-)"%s*$')
        if key and val then
          section[key] = val
        end
      end
    end
  end
  return root
end

local function read_theme()
  local lines = vim.fn.readfile(toml_path)
  if not lines or #lines == 0 then
    error("Chalice icons missing: " .. toml_path)
  end
  return parse_toml(table.concat(lines, "\n"))
end

local function glyph_entry(code)
  return { glyph = vim.fn.nr2char(tonumber(code, 16)), hl = hl }
end

local theme = read_theme()
local glyphs = {}
for name, code in pairs(theme.glyphs or {}) do
  glyphs[name] = glyph_entry(code)
end

local default_file = glyphs[theme.default_file or "document"]
local default_folder = glyphs[theme.default_folder or "folder"]
if not default_file or not default_folder then
  error("chalice-icons.toml: missing default glyphs")
end

local function map_categories(tbl)
  local out = {}
  for name, cat in pairs(tbl or {}) do
    local e = glyphs[cat]
    if not e then
      error("chalice-icons.toml: unknown category " .. vim.inspect(cat) .. " for " .. name)
    end
    out[name] = e
  end
  return out
end

local by_ext = map_categories(theme.extensions)
local by_file = map_categories(theme.files)
-- Title Case aliases for Chalice lowercase file keys (Makefile, Dockerfile)
for name, e in pairs(vim.deepcopy(by_file)) do
  by_file[name:sub(1, 1):upper() .. name:sub(2)] = e
end

local by_ft = {}
for lang, cat in pairs(theme.filetypes or {}) do
  local e = glyphs[cat]
  if not e then
    error("chalice-icons.toml: unknown category " .. vim.inspect(cat) .. " for filetype " .. lang)
  end
  by_ft[language_to_ft[lang] or lang] = e
end

local function pack(e, is_default)
  return e.glyph, e.hl, is_default == true
end

local function get_extension(name)
  local key = name:lower()
  local e = by_ext[key]
  if e then
    return pack(e, false)
  end
  local dot = string.find(key, "%.")
  while dot do
    local ext = key:sub(dot + 1)
    e = by_ext[ext]
    if e then
      return pack(e, false)
    end
    dot = string.find(key, "%.", dot + 1)
  end
  return pack(default_file, true)
end

local function get_file(name)
  local basename = vim.fs.basename(name)
  local e = by_file[basename] or by_file[basename:lower()]
  if e then
    return pack(e, false)
  end

  local dot = string.find(basename, "%..", 2)
  if dot ~= nil then
    local ext = basename:sub(dot + 1):lower()
    local icon, icon_hl, is_default = get_extension(ext)
    if not is_default then
      return icon, icon_hl, false
    end
  end

  return pack(default_file, true)
end

return {
  {
    "nvim-mini/mini.icons",
    opts = {
      style = "glyph",
      default = {
        file = default_file,
        filetype = default_file,
        directory = default_folder,
        extension = default_file,
      },
      extension = by_ext,
      file = by_file,
      filetype = by_ft,
    },
    config = function(_, opts)
      require("mini.icons").setup(opts)
      local MiniIcons = require("mini.icons")
      local orig_get = MiniIcons.get

      ---@diagnostic disable-next-line: duplicate-set-field
      MiniIcons.get = function(category, name)
        if type(category) ~= "string" or type(name) ~= "string" then
          return orig_get(category, name)
        end

        if category == "directory" then
          return pack(default_folder, false)
        end
        if category == "extension" then
          return get_extension(name)
        end
        if category == "filetype" then
          local e = by_ft[name:lower()]
          if e then
            return pack(e, false)
          end
          return pack(default_file, true)
        end
        if category == "file" then
          return get_file(name)
        end

        return orig_get(category, name)
      end
    end,
  },
}
