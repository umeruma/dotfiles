-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

if vim.env.REX_SESSION and vim.env.REX_SESSION ~= "" then
  for key, dir in pairs({ h = "Left", j = "Down", k = "Up", l = "Right" }) do
    vim.keymap.set("n", "<C-" .. key .. ">", "<Plug>(RexNavigate" .. dir .. ")")
  end
end
