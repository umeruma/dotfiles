-- rex-pane-nav is cloned by lazy.nvim (nvim/lua/plugins/rex-navigator.lua)
do
  local ok, err = pcall(function()
    dofile(os.getenv("HOME") .. "/.local/share/nvim/lazy/rex-pane-nav/rex/pane_nav.lua").setup{
      -- Workspace.tabStyle is not a public API; read it per key so a tab style change applies at once
      tabs = function()
        local r = rex.exec.start{ "defaults", "read", "com.superlogical.rex", "Workspace.tabStyle" }:wait()
        return r.ok and r.stdout:match("vertical") and "vertical" or "horizontal"
      end,
    }
  end)
  if not ok then rex.log("rex-pane-nav: not loaded: " .. tostring(err)) end
end
