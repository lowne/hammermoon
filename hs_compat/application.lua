local deprecate=hm._core.deprecate
local hsapp=hm._core.hs_compat_module('application')
local app=hm.applications
local setmetatable,type,ipairs=setmetatable,type,ipairs

nope=error'not yet implemented'

local function wrapobj(hmapp)
  return setmetatable({hmapp},{__index=hsapp})
end
local function wraplist(hmapplist)
  for i,hmapp in ipairs(hmapplist) do hmapplist[i]=wrapobj(hmapp) end
  return hmapplist
end
function hsapp.applicationForPID(pid) nope() end --TODO
function hsapp.applicationsForBundleID(bid)
  return wraplist(app.runningApplications:concat(app.runningBackgroundApplications):ifilterByField('bundleID',bid))
end
function hsapp.frontmostApplication() return wrapobj(app.active) end

function hsapp.launchOrFocus(name) nope() end--TODO

function hsapp.launchOrFocusByBundleID(name) nope() end--TODO

function hsapp.nameForBundleID(name) nope() end --TODO

function hsapp.pathForBundleID(name) nope() end --TODO

function hsapp.runningApplications() return wraplist(app.runningApplications:concat(app.runningBackgroundApplications)) end

function hsapp.find() nope() end --TODO

function hsapp.get() nope() end --TODO

function hsapp.open() nope() end --TODO

function hsapp:activate(allWindows) return allWindows and self[1]:activate() or self[1]:bringToFront() and true end

function hsapp:allWindows() end --TODO

function hsapp:bundleID() return self[1].bundleID end

function hsapp:findMenuItem() nope() end --TODO

function hsapp:findWindow() nope() end --TODO

function hsapp:focusedWindow() end --TODO

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

function hsapp:mainWindow() end --TODO

function hsapp:name() return self[1].name end

function hsapp:path() return self[1].path end

function hsapp:pid() return self[1].pid end

function hsapp:selectMenuItem() nope() end --TODO

function hsapp:title() return self[1].name end

function hsapp:unhide() self[1]:unhide() return true end

function hsapp:visibleWindows() end --TODO

return hsapp
