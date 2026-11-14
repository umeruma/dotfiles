do
  local ok, err = pcall(function()
    dofile("/Users/umeruma/.local/share/rex-ext/rex-open/rex/rex_open.lua").setup{
      picker = { key = "alt+cmd+o", open = "float" },
    }
  end)
  if not ok then rex.log("rex-open: not loaded: " .. tostring(err)) end
end
