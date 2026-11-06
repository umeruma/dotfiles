--- Dirs: same name color as files + trailing `/` (tree and flat/search views).
local function fix_dir_name(parts)
  for _, part in ipairs(parts) do
    if part.field == "file" and type(part[1]) == "string" and part[1] ~= "" then
      if part[2] == "SnacksPickerDirectory" then
        part[2] = "SnacksPickerFile"
      end
      -- basename only (SnacksPickerDir is the parent path segment)
      if part[2] ~= "SnacksPickerDir" and not part[1]:find("/$") then
        part[1] = part[1] .. "/"
      end
    end
  end
  return parts
end

local function explorer_format(item, picker)
  local ret = require("snacks.picker.format").file(item, picker)
  if not item.dir then
    return ret
  end
  for _, part in ipairs(ret) do
    if type(part.resolve) == "function" then
      local orig = part.resolve
      part.resolve = function(max_width)
        return fix_dir_name(orig(max_width))
      end
    end
  end
  return fix_dir_name(ret)
end

local picker_opts = {
  formatters = { file = { icon_width = 3 } },
  icons = {
    files = { dir = "[] ", dir_open = "][ ", file = "-- " },
  },
  sources = {
    explorer = {
      hidden = true, -- show dotfiles (.config, .zshrc, …)
      -- ignored = true, -- also show gitignored files (uncomment if needed)
      format = explorer_format,
    },
  },
}

return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = picker_opts,
      lazygit = { config = { gui = { nerdFontsVersion = "" } } },
    },
  },
}
