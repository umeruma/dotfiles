-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local debounce = vim.uv.new_timer()
local watcher = vim.uv.new_fs_event()
if
  debounce
  and watcher
  and vim.fn.argc() == 1
  and vim.fn.isdirectory(vim.fn.argv(0) --[[@as string]]) == 1
then
  local reload = vim.schedule_wrap(function()
    if vim.fn.getcmdwintype() ~= "" or vim.api.nvim_get_mode().mode:match("[cR!s]") then
      return
    end
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local name = vim.api.nvim_buf_get_name(buf)
      if
        vim.bo[buf].buftype == ""
        and not vim.bo[buf].modified
        and name ~= ""
        and not name:match("^%w+://")
      then
        vim.cmd.checktime(buf)
      end
    end
  end)
  watcher:start(vim.fn.getcwd(), { recursive = true }, function()
    debounce:start(100, 0, reload)
  end)
end

local function color_column()
  local separator = vim.api.nvim_get_hl(0, { name = "WinSeparator", link = false })
  vim.api.nvim_set_hl(0, "ColorColumn", { bg = separator.fg })
end
color_column()
vim.api.nvim_create_autocmd("ColorScheme", { callback = color_column })
