local M = {}

-- DeskPad 起動中はメニューバーを隠す（会議・画面共有向け）
local triggerAppBundleID = "com.stengo.DeskPad"

local function setMenuBarAutohide(state)
    hs.osascript.applescript(string.format([[
        tell application "System Events" to tell dock preferences
            set autohide menu bar to %s
        end tell
    ]], tostring(state)))
end

function M.init()
    local watcher = hs.application.watcher.new(function(name, event, app)
        if app:bundleID() == triggerAppBundleID then
            if event == hs.application.watcher.launched then
                setMenuBarAutohide(true)
            elseif event == hs.application.watcher.terminated then
                setMenuBarAutohide(false)
            end
        end
    end)
    watcher:start()

    if hs.application.get(triggerAppBundleID) then
        setMenuBarAutohide(true)
    end
end

return M
