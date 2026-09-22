-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- markdown の記号（`` や ** など）を隠さない
vim.opt.conceallevel = 0

-- 折り返し表示（LazyVim デフォルトは wrap=false）
-- vim.opt.wrap = true

-- .mdx は標準では検出されず ft=conf に落ちるので markdown 扱いにする
vim.filetype.add({ extension = { mdx = "markdown" } })
