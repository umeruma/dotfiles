-- linked by Nix (nix/home-manager/tools/rex.nix); absent where Rex isn't installed, such as Windows
local dir = vim.fn.expand("~/.local/share/rex-pane-nav")

return {
  dir = dir,
  name = "rex-pane-nav",
  main = "rex-pane-nav",
  cond = vim.uv.fs_stat(dir) ~= nil,
  lazy = false,
  opts = {},
}
