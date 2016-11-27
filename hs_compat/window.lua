local deprecate=hm._core.deprecate
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

property(win,'animationDuration',nope,nope) --TODO

property(win,'setFrameCorrectness',nope,nope) --TODO

function hswin.allWindows() return wraplist(win.windows) end
function hswin.desktop() end --TODO
function hswin.orderedWindows() return wraplist(win.orderedWindows) end
function hswin.snapshotForID(id) nope() end --TODO
function hswin.visibleWindows() return wraplist(win.visibleWindows) end

function hswin.find(hint) nope() end --TODO
function hswin.focusedWindow() return wrapobj(win.focusedWindow) end
function hswin.frontmostWindow() nope() end --TODO
function hswin.get(hint) nope() end --TODO

function hswin:application() return self[1].application end
function hswin:becomeMain() nope() end --TODO
function hswin:centerOnScreen() nope() end --TODO
function hswin:close() nope() end --TODO
function hswin:focus() nope() end --TODO
function hswin:frame() return self[1].frame end
function hswin:id() return self[1].id end
function hswin:isFullScreen() nope() end --TODO
function hswin:isMinimized() return self[1].minimized end
function hswin:isStandard() return self[1].standard end
function hswin:isVisible() return self[1].visible end
function hswin:maximize() nope() end --TODO
function hswin:minimize() self[1].minimized=true end --TODO
function hswin:move() nope() end --TODO
function hswin:otherWindowsAllScreens() nope() end --TODO
function hswin:otherWindowsSameScreen() nope() end --TODO
function hswin:raise() nope() end --TODO
function hswin:role() return self[1].role end
function hswin:screen() nope() end --TODO
function hswin:sendToBack() nope() end --TODO
function hswin:setFrame(frame) self[1].frame=frame return self end
function hswin:setFrameInScreenBounds(frame) nope() end --TODO
function hswin:setFrameWithWorkarounds(frame) nope() end --TODO
function hswin:setFullScreen() nope() end --TODO
function hswin:setSize(size) self[1]._ax.size=size return self end
function hswin:setTopLeft(tl) self[1]._ax.topleft=tl return self end
function hswin:size() return self[1]._ax.size end
function hswin:snapshot() nope() end --TODO
function hswin:subrole() return self[1].subrole end
function hswin:title() return self[1].title end
function hswin:toggleFullScreen() nope() end --TODO
function hswin:toggleZoom() nope() end --TODO
function hswin:topLeft() return self[1]._ax.topleft end
function hswin:unminimize() self[1].minimized=false return self end
function hswin:zoomButtonRect() nope() end --TODO

for _,dir in ipairs{'East','North','South','West'} do
  hswin['focusWindow'..dir]=function(self) nope() end --TODO
  hswin['moveOneScreen'..dir]=function(self) nope() end --TODO
  hswin['windowsTo'..dir]=function(self) nope() end --TODO
end

