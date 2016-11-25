local deprecate=hm._core.deprecate
local hsapp=hm._core.hs_compat_module('application')
local app=hm.applications
local setmetatable,type,ipairs=setmetatable,type,ipairs

nope=error'not yet implemented'

local function wrapobj(hmapp) return setmetatable({hmapp},{__index=hsapp}) end
--local function wraplist(hmapplist) return hmapplist:imap(wrapobj) end

function hsapp.applicationForPID(pid) return app.applicationForPID(pid) end

function hsapp.applicationsForBundleID(bid) return app.bundlesForBundleID(bid):imapToField'application':imap(wrapobj) end
--  return wraplist(app.runningApplications:concat(app.runningBackgroundApplications):ifilterByField('bundleID',bid))

function hsapp.frontmostApplication() return wrapobj(app.active) end

function hsapp.launchOrFocus(name) nope() end--TODO

function hsapp.launchOrFocusByBundleID(name) nope() end--TODO

function hsapp.nameForBundleID(bid) local b=app.defaultBundleForBundleID(bid) return b and b.name end

function hsapp.pathForBundleID(bid) local b=app.defaultBundleForBundleID(bid) return b and b.path end

function hsapp.runningApplications() return app.runningApplications:concat(app.runningBackgroundApplications):imap(wrapobj) end

function hsapp.find() nope() end --TODO

function hsapp.get() nope() end --TODO

function hsapp.open() nope() end --TODO

function hsapp:activate(allWindows) return allWindows and self[1]:activate() or self[1]:bringToFront() and true end

function hsapp:allWindows() return self[1].allWindows end

function hsapp:bundleID() return self[1].bundle.id end

function hsapp:findMenuItem() nope() end --TODO

function hsapp:findWindow() nope() end --TODO

function hsapp:focusedWindow() return self[1].focusedWindow end

function hsapp:getMenuItems() nope() end --TODO

function hsapp:getWindow() nope() end --TODO

function hsapp:hide() self[1]:hide() return true end

function hsapp:isFrontmost() return self[1].active end

function hsapp:isHidden() return self[1].hidden end

function hsapp:isRunning() return self[1].running end

function hsapp:kill() self[1]:quit() end

function hsapp:kill9() self[1]:forceQuit(0) end

local HS_KINDS={background=-1,accessory=0,standard=1}
function hsapp:kind() return HS_KINDS[self[1].kind] end

function hsapp:mainWindow() return self[1].mainWindow end

function hsapp:name() return self[1].name end

function hsapp:path() return self[1].bundle.path end

function hsapp:pid() return self[1].pid end

function hsapp:selectMenuItem() nope() end --TODO

function hsapp:title() return self[1].name end

function hsapp:unhide() self[1]:unhide() return true end

function hsapp:visibleWindows() return self[1].visibleWindows end

hsapp.watcher={}

local HMtoHSevents={launching=0,launched=1,terminated=2,hidden=3,unhidden=4,activated=5,deactivated=6,}
function hsapp.watcher.new(fn)
  local hmwatcher=app.newWatcher(function(hmapp,eventname)return fn(hmapp.name,HMtoHSevents[eventname],wrapobj(hmapp))end)
  return setmetatable({hmwatcher},{__index=hsapp.watcher})
end

function hsapp.watcher:start() self[1]:start() return self end

function hsapp.watcher:stop() self[1]:stop() return self end

return hsapp
