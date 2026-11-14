local function in_nvim(ctx)
  local p = rex.block.call("com.superlogical.terminal", "process", { session_id = ctx.session_id, block_id = ctx.block_id })
  if not p then return false end
  if p.foreground and p.foreground.name == "nvim" then return true end
  for _, a in ipairs(p.ancestors or {}) do
    if a.name == "nvim" then return true end
  end
  return false
end

for key, dir in pairs{ h = "left", j = "down", k = "up", l = "right" } do
  rex.action{
    name    = "navigate_" .. dir,
    title   = "Navigate " .. dir .. " through Neovim and Rex",
    repeats = true,
    run     = function(ctx)
      if in_nvim(ctx) then
        rex.client.queue("pane.send_key", { key = "ctrl+" .. key })
      else
        rex.client.queue("pane.focus", { direction = dir, wrap = true })
      end
    end,
  }
  rex.bind("shift+cmd+" .. key, "navigate_" .. dir)
end
