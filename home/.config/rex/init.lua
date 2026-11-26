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

-- rex-undo / rex-open are linked by Nix (nix/home-manager/tools/rex.nix).
pcall(require, "rex_undo")
pcall(require, "rex_open")

-- lg and n report these through osc7577_exec (nix/home-manager/tools/rex.nix)
rex.set("resume.trust.lazygit", { command = { "lazygit" } })
rex.set("resume.trust.nvim", { command = { "nvim", rex.match.under("~") } })

-- rex-pane-nav is linked by Nix (nix/home-manager/tools/rex.nix); tabs matches Workspace.tabStyle there
local ok, err = pcall(function()
  dofile(os.getenv("HOME") .. "/.local/share/rex-pane-nav/rex/pane_nav.lua").setup{
    tabs = "vertical",
    rex  = os.getenv("HOME") .. "/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex",
  }
end)
if not ok then rex.log("rex-pane-nav: not loaded: " .. tostring(err)) end
