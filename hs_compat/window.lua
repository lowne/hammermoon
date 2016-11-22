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

function hswin.allWindows() return wraplist(win.allWindows) end

--function hswin

