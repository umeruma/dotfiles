local function in_nvim(ctx)
  local p = rex.block.call("com.superlogical.terminal", "process", { session_id = ctx.session_id, block_id = ctx.block_id })
  if not p then return false end
  if p.foreground and p.foreground.name == "nvim" then return true end
  for _, a in ipairs(p.ancestors or {}) do
    if a.name == "nvim" then return true end
  end
  return false
end

local function tabs_vertical()
  local r = rex.exec.start{ "defaults", "read", "com.superlogical.rex", "Workspace.tabStyle" }:wait()
  return r.ok and r.stdout:match("vertical") ~= nil
end

local function find_rect(node, block_id)
  if not node then return nil end
  if node.block_id == block_id then return node.rect end
  if node.split then
    return find_rect(node.split.before, block_id) or find_rect(node.split.after, block_id)
  end
end

local function at_edge(ctx, dir)
  local v = rex.session.view{ session_id = ctx.session_id }
  for _, w in ipairs(v and v.windows or {}) do
    for _, l in ipairs(w.layers or {}) do
      local r = l.kind == "tiled" and find_rect(l.layout, ctx.block_id)
      if r then
        local x, y, wd, ht = r[1], r[2], r[3], r[4]
        -- 1e-6: rects are normalized floats, so a pane on the edge can be off by rounding
        if dir == "left" then return x <= 1e-6 end
        if dir == "right" then return x + wd >= 1 - 1e-6 end
        if dir == "up" then return y <= 1e-6 end
        return y + ht >= 1 - 1e-6
      end
    end
  end
  return false
end

local tab_step = {
  vertical   = { up = -1, down = 1 },
  horizontal = { left = -1, right = 1 },
}

local function step_tab(ctx, step)
  local v = rex.session.view{ session_id = ctx.session_id }
  local ws = v and v.windows or {}
  local i
  for n, w in ipairs(ws) do
    if w.window_id == v.active_window_id then i = n end
  end
  local inside = i and ws[i + step]
  if inside then
    rex.client.queue(step > 0 and "client.tab.next" or "client.tab.previous", {})
  else
    rex.client.queue(step > 0 and "session.next" or "session.previous", {})
  end
end

for key, dir in pairs{ h = "left", j = "down", k = "up", l = "right" } do
  rex.action{
    name    = "navigate_" .. dir,
    title   = "Navigate " .. dir .. " through Neovim, Rex panes and tabs",
    repeats = true,
    run     = function(ctx)
      if in_nvim(ctx) then
        rex.client.queue("pane.send_key", { key = "ctrl+" .. key })
        return
      end
      local step = tab_step[tabs_vertical() and "vertical" or "horizontal"][dir]
      if step and at_edge(ctx, dir) then
        step_tab(ctx, step)
      else
        rex.client.queue("pane.focus", { direction = dir, wrap = true })
      end
    end,
  }
  rex.bind("shift+cmd+" .. key, "navigate_" .. dir)
end
