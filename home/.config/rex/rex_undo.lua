do
  local ok, err = pcall(function()
    dofile("/Users/umeruma/.local/share/rex-ext/rex-undo/rex-undo/undo.lua").setup{
      dir = "/Users/umeruma/.local/share/rex-ext/rex-undo/rex-undo",
      rex = "/Users/umeruma/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex",
      key = "cmd+shift+t",
      history = 50,
    }
  end)
  if not ok then rex.log("rex-undo: not loaded: " .. tostring(err)) end
end
