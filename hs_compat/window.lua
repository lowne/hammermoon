local deprecate=hm._core.deprecate
local disallow=hm._core.disallow
local property=hm._core.property
local hswin=hm._core.hs_compat_module('window')
local win=hm.windows
local setmetatable,type,ipairs=setmetatable,type,ipairs

nope=error'not yet implemented'

local function wrapobj(hmwin)
  return setmetatable({hmwin},{__index=hswin})
end
local function wraplist(hmwinlist)
  for i,hmwin in ipairs(hmwinlist) do hmwinlist[i]=wrapobj(hmwin) end
  return hmwinlist
end

property(hswin,'animationDuration',nope,nope) --TODO

property(hswin,'setFrameCorrectness',nope,nope) --TODO

function hswin.allWindows() return wraplist(win.windows) end
function hswin.desktop() end --TODO
function hswin.orderedWindows() return wraplist(win.orderedWindows) end
function hswin.snapshotForID(id) nope() end --TODO
function hswin.visibleWindows() return wraplist(win.visibleWindows) end

function hswin.find(hint) nope() end --TODO
function hswin.focusedWindow() return wrapobj(win.focusedWindow) end
function hswin.frontmostWindow() return wrapobj(win.frontmostWindow) end
function hswin.get(hint) nope() end --TODO

function hswin:application() return self[1].application end
function hswin:becomeMain() self[1].application.mainWindow=self[1] end
function hswin:centerOnScreen() nope() end --TODO
function hswin:close() nope() end --TODO
function hswin:focus() self[1].focused=true return self end
function hswin:frame() return self[1].frame end
function hswin:id() return self[1].id end
function hswin:isFullScreen() return self[1].fullscreen end
function hswin:isMinimized() return self[1].minimized end
function hswin:isStandard() return self[1].standard end
function hswin:isVisible() return self[1].visible end
function hswin:maximize() nope() end --TODO
function hswin:minimize() self[1].minimized=true return self end
function hswin:move() nope() end --TODO
function hswin:otherWindowsAllScreens() nope() end --TODO
function hswin:otherWindowsSameScreen() nope() end --TODO
--function hswin:raise() nope() end --TODO
disallow(hswin,'raise')
function hswin:role() return self[1].role end
function hswin:screen() nope() end --TODO
function hswin:sendToBack() nope() end --TODO
function hswin:setFrame(frame) self[1].frame=frame return self end
function hswin:setFrameInScreenBounds(frame) nope() end --TODO
function hswin:setFrameWithWorkarounds(frame) nope() end --TODO
function hswin:setFullScreen(v) self[1].fullscreen=v return self end --TODO
function hswin:setSize(size) self[1]._ax.size=size return self end
function hswin:setTopLeft(tl) self[1]._ax.topleft=tl return self end
function hswin:size() return self[1]._ax.size end
function hswin:snapshot() nope() end --TODO
function hswin:subrole() return self[1].subrole end
function hswin:title() return self[1].title end
function hswin:toggleFullScreen() self[1].fullscreen=not self[1].fullscreen return self end
--function hswin:toggleZoom() nope() end --TODO
disallow(hswin,'toggleZoom')
function hswin:topLeft() return self[1]._ax.topleft end
function hswin:unminimize() self[1].minimized=false return self end
--function hswin:zoomButtonRect() nope() end --TODO
disallow(hswin,'zoomButtonRect')

for _,dir in ipairs{'East','North','South','West'} do
  hswin['focusWindow'..dir]=function(self) nope() end --TODO
  hswin['moveOneScreen'..dir]=function(self) nope() end --TODO
  hswin['windowsTo'..dir]=function(self) nope() end --TODO
end

