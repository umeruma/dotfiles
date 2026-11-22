local function file_ref(l1, l2)
  local path = vim.fn.expand("%:.")
  return l1 == l2 and ("%s#L%d"):format(path, l1) or ("%s#L%d-%d"):format(path, l1, l2)
end

local function copy(text)
  vim.fn.setreg("+", text)
  vim.notify("Copied " .. text:match("[^\n]*"))
end

local function agent_context(l1, l2)
  local out = { file_ref(l1, l2), "```" .. vim.bo.filetype }
  vim.list_extend(out, vim.api.nvim_buf_get_lines(0, l1 - 1, l2, false))
  table.insert(out, "```")
  for _, d in ipairs(vim.diagnostic.get(0)) do
    if d.lnum + 1 >= l1 and d.lnum + 1 <= l2 then
      table.insert(out, ("L%d: %s"):format(d.lnum + 1, (d.message:gsub("\n", " "))))
    end
  end
  return table.concat(out, "\n") .. "\n"
end

vim.keymap.set("n", "<leader>yf", function()
  copy(file_ref(vim.fn.line("."), vim.fn.line(".")))
end, { desc = "Copy file#line" })

vim.keymap.set({ "n", "x" }, "<leader>yc", function()
  local a, b = vim.fn.line("v"), vim.fn.line(".")
  if vim.fn.mode() == "n" then
    a = b
  end
  copy(agent_context(math.min(a, b), math.max(a, b)))
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
end, { desc = "Copy code with file#line and diagnostics" })
