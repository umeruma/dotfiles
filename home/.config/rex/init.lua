-- https://www.superlogical.com/rex/docs/customize/config
-- Apply changes with `rex config reload`.

-- New tab in the focused terminal's directory with `git wt ` pre-typed:
-- type a branch name and Enter to create (or switch to) its worktree there.
rex.action{
  name  = "wt_tab",
  title = "New Worktree Tab",
  run   = function(ctx)
    local p = rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id })
    local cwd = p and p.foreground and p.foreground.cwd
    local w, err = rex.session.new_window{
      layout = rex.layout.block{
        flavor  = "com.superlogical.terminal.shell",
        options = { cwd = cwd, initial_input = "git wt " },
      },
    }
    if err ~= nil then error(err, 0) end
    rex.session.focus_block{ block_id = w.block_ids[1] }
    -- make the app show the new tab, not just the server's active window
    pcall(rex.client.queue, "session.select", { session_id = ctx.session_id, window_id = w.window_id })
  end,
}

rex.bind("shift+cmd+w", "wt_tab")

-- rex-durable / rex-undo live in ~/.local/share/rex-ext, outside this repo;
-- remove these lines once Rex restores tabs and closed panes itself.
pcall(require, "rex_durable")
pcall(require, "rex_undo")
