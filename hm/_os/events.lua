---`CGEvent`/`NSEvent` interface
-- @module hm._os.events
-- @static

require'hm._os' -- load parent
require'ffi'.cdef[[int usleep(int);]]
local C=require'ffi'.C

local c=require'objc'
local tolua=c.tolua
c.load'CoreGraphics'
c.load'AppKit'
local CFRelease,CFEqual=c.CFRelease,c.CFEqual
local kCGSessionEventTap,kCGAnnotatedSessionEventTap=c.kCGSessionEventTap,c.kCGAnnotatedSessionEventTap
local kCGEventTapDisabledByTimeout,kCGEventTapDisabledByUserInput=c.kCGEventTapDisabledByTimeout,c.kCGEventTapDisabledByUserInput
local kCGEventSourceUserData=c.kCGEventSourceUserData
local CGEventTapEnable=c.CGEventTapEnable
local CGEventGetIntegerValueField,CGEventSetIntegerValueField=c.CGEventGetIntegerValueField,c.CGEventSetIntegerValueField
local runLoopAddSource,runLoopRemoveSource=require'hm._os'.runLoopAddSource,require'hm._os'.runLoopRemoveSource

local HM_SOURCE_USERDATA=16432299 -- not a magic number
local HM_SOURCE_DONTSKIP_USERDATA=16432300 -- neither this one
local coll=require'hm.types.coll'
local type,ipairs,pairs=type,ipairs,pairs
local tinsert,tremove,sformat=table.insert,table.remove,string.format
local band,bor=bit.band,bit.bor
local tonumber=tonumber -- convert from int64

local cgtaps,rlSources,callbacks={},{},{}

local runningTaps,tapCount={},0
---@type hm._os.events
-- @extends hm#module
local events=hm._core.module('_os.events',{eventtap={
  __tostring=function(self)return sformat('eventtap: [#%d] (%s)',self._ref,runningTaps[self] and 'active' or 'inactive') end,
  __gc=function(self) assert(not runningTaps[self]) end,
},event={
  __tostring=function(self) return sformat('event: [%s]',self[1]) end,
  __gc=function(self)CFRelease(self[1]) end,
  __eq=function(a,b) return CFEqual(a[1],b[1]) end,
}})
local log=events.log

local eventTypes={
  leftMouseDown=            c.kCGEventLeftMouseDown,
  leftMouseUp=              c.kCGEventLeftMouseUp,
  leftMouseDragged=         c.kCGEventLeftMouseDragged,
  rightMouseDown=           c.kCGEventRightMouseDown,
  rightMouseUp=             c.kCGEventRightMouseUp,
  rightMouseDragged=        c.kCGEventRightMouseDragged,
  middleMouseDown=          c.kCGEventOtherMouseDown,
  middleMouseUp=            c.kCGEventOtherMouseUp,
  middleMouseDragged=       c.kCGEventOtherMouseDragged,
  mouseMoved=               c.kCGEventMouseMoved,
  flagsChanged=             c.kCGEventFlagsChanged,
  scrollWheel=              c.kCGEventScrollWheel,
  keyDown=                  c.kCGEventKeyDown,
  keyUp=                    c.kCGEventKeyUp,
  tabletPointer=            c.kCGEventTabletPointer,
  tabletProximity=          c.kCGEventTabletProximity,
  nullEvent=                c.kCGEventNull,
  NSMouseEntered=           c.NSMouseEntered,
  NSMouseExited=            c.NSMouseExited,
  NSAppKitDefined=          c.NSAppKitDefined,
  NSSystemDefined=          c.NSSystemDefined,
  NSApplicationDefined=     c.NSApplicationDefined,
  NSPeriodic=               c.NSPeriodic,
  NSCursorUpdate=           c.NSCursorUpdate,
  NSEventTypeGesture=       c.NSEventTypeGesture,
  NSEventTypeMagnify=       c.NSEventTypeMagnify,
  NSEventTypeSwipe=         c.NSEventTypeSwipe,
  NSEventTypeRotate=        c.NSEventTypeRotate,
  NSEventTypeBeginGesture=  c.NSEventTypeBeginGesture,
  NSEventTypeEndGesture=    c.NSEventTypeEndGesture,
  NSEventTypeSmartMagnify=  c.NSEventTypeSmartMagnify,
  NSEventTypeQuickLook=     c.NSEventTypeQuickLook,
  NSEventTypePressure=      c.NSEventTypePressure,
  tapDisabledByTimeout=         c.kCGEventTapDisabledByTimeout,
  tapDisabledByUserInput=       c.kCGEventTapDisabledByUserInput,
}
---A string describing an event type.
-- Valid values are: `"leftMouseDown"`,`"leftMouseUp"`,`"leftMouseDragged"`,`"rightMouseDown"`,`"rightMouseUp"`,`"rightMouseDragged"`,
-- `"middleMouseDown"`,`"middleMouseUp"`,`"middleMouseDragged"`,`"mouseMoved"`,`"flagsChanged"`,`"scrollWheel"`,`"keyDown"`,`"keyUp"`,
-- `"tabletPointer"`,`"tabletProximity"`,`"nullEvent"`,`"NSMouseEntered"`,`"NSMouseExited"`,`"NSAppKitDefined"`,`"NSSystemDefined"`,
-- `"NSApplicationDefined"`,`"NSPeriodic"`,`"NSCursorUpdate"`,`"NSEventTypeGesture"`,`"NSEventTypeMagnify"`,`"NSEventTypeSwipe"`,
-- `"NSEventTypeRotate"`,`"NSEventTypeBeginGesture"`,`"NSEventTypeEndGesture"`,`"NSEventTypeSmartMagnify"`,`"NSEventTypeQuickLook"`,
-- `"NSEventTypePressure"`,`"tapDisabledByTimeout"`,`"tapDisabledByUserInput"`
-- @type eventType
-- @extends #string

---@type eventTypes
-- @map <#eventType,#number>
events.types=coll.merge(eventTypes,coll.toIndex(eventTypes))
checkers['eventType']=function(v) return eventTypes[v] and true or false end

---@type eventtap
-- @extends hm#module.object
local tap=events._classes.eventtap
local newTap=tap._new

---@type event
-- @extends hm#module.object
local event=events._classes.event
local newEvent=event._new

local toeventmt={__index=event}
local setmetatable=setmetatable
local function createTap(eventType) hmcheck'eventType'
  log.i('Creating main tap:',eventType)
  local handler=function(_tapProxy,evType,ev,_data)
    if evType==kCGEventTapDisabledByTimeout or evType==kCGEventTapDisabledByUserInput then
      log.w('The main tap for',eventType,'was disabled! Restarting.')
      CGEventTapEnable(cgtaps[eventType],true)
      return ev
    end
    -- skip events posted by us, to avoid infinite loops
    if tonumber(CGEventGetIntegerValueField(ev,kCGEventSourceUserData))==HM_SOURCE_USERDATA then return ev end
    --    log.v('Received event',eventTypes[evType])
    hmassert(evType==eventTypes[eventType])
    local wev=setmetatable({ev},toeventmt) -- no CFRelease on these dudes, but keep the methods
    for _,cb in ipairs(callbacks[eventType]) do
      if cb(wev) then return nil end
    end
    return ev
  end
  local cgtap=assert(c.CGEventTapCreate(kCGSessionEventTap,c.kCGHeadInsertEventTap,c.kCGEventTapOptionDefault,2^eventTypes[eventType],handler,nil))
  cgtaps[eventType]=cgtap
  callbacks[eventType]={}
  local rlSource=c.CFMachPortCreateRunLoopSource(nil,cgtap,0)
  runLoopAddSource(rlSource,c.kCFRunLoopCommonModes)
  rlSources[eventType]=rlSource
end
local function startTap(eventType) log.d('Starting main tap:',eventType) CGEventTapEnable(cgtaps[eventType],true) end

local function stopTap(eventType) log.d('Stopping main tap:',eventType) CGEventTapEnable(cgtaps[eventType],false) end

checkers['eventTypeList']=function(v) return type(v)=='table' and coll.every(v,function(ev)return eventTypes[ev] end) end

---Creates an eventtap.
-- @function [parent=#hm._os.events] eventtap
-- @param #table events a list of @{<#eventType>}s of interest
-- @param #function fn callback function that will receive the @{<#event>} as its sole argument
-- @return #eventtap
function events.eventtap(events,fn) hmcheck('eventTypeList','callable')
  tapCount=tapCount+1
  events=coll.map(events,function(ev)return type(ev)=='string' and ev or eventTypes[ev] end):toSet()
  return newTap{_eventTypes=events,_cb=fn,_ref=tapCount}
end

---Starts the eventtap.
-- @function [parent=#eventtap] start
-- @param #eventtap self
function tap:start()
  if runningTaps[self] then return end
  for eventType in pairs(self._eventTypes) do
    if not callbacks[eventType] then createTap(eventType) end
    if not callbacks[eventType][1] then startTap(eventType) end
    tinsert(callbacks[eventType],self._cb)
  end
  runningTaps[self]=true
  log.i(self,'started')
end

---Stops the eventtap.
-- @function [parent=#eventtap] stop
-- @param #eventtap self
function tap:stop()
  if not runningTaps[self] then return end
  for eventType in pairs(self._eventTypes) do
    for i=1,#callbacks[eventType] do
      if callbacks[eventType][i]==self._cb then tremove(callbacks[eventType],i) break end
    end
    if not callbacks[eventType][1] then stopTap(eventType) end
  end
  runningTaps[self]=nil
  log.i(self,'stopped')
end

---Returns `true` if the eventtap is currently active.
-- @param #eventtap self
function tap:isActive() return runningTaps[self] and true or false end

--[[
function events.getKeyCode(ev) return tonumber(CGEventGetIntegerValueField(ev,kCGKeyboardEventKeycode)) end
function events.getFlags(ev)
  local mask=CGEventGetFlags(ev) or 0
  local r={} for k,v in pairs(flagMasks) do r[k]=band(mask,v)>0 end return r
end
--]]

local CGEventCreateCopy=c.CGEventCreateCopy
---Returns a copy of the event.
-- @function [parent=#event] copy
-- @param #self
-- @return #event a new copy of this event
function event:copy() return newEvent{CGEventCreateCopy(self[1])} end
local CGEventGetType=c.CGEventGetType
---Returns the event type
-- @function [parent=#event] getType
-- @param #event self
-- @return #number
function event:getType() return CGEventGetType(self[1]) end
local kCGKeyboardEventKeycode=c.kCGKeyboardEventKeycode
---Returns the key code for this keyboard event.
-- @function [parent=#event] getKeyCode
-- @param #event self
-- @return #number
function event:getKeyCode() return tonumber(CGEventGetIntegerValueField(self[1],kCGKeyboardEventKeycode)) end

local CGEventSetIntegerValueField=c.CGEventSetIntegerValueField
---Sets the key code for this keyboard event.
-- @function [parent=#event] setKeyCode
-- @param #event self
-- @param #number code
-- @return #event this event
function event:setKeyCode(code) CGEventSetIntegerValueField(self[1],kCGKeyboardEventKeycode,code) return self end

local CGEventGetFlags,CGEventSetFlags=c.CGEventGetFlags,c.CGEventSetFlags
local flagMasks={cmd=c.kCGEventFlagMaskCommand,ctrl=c.kCGEventFlagMaskControl,alt=c.kCGEventFlagMaskAlternate,
  shift=c.kCGEventFlagMaskShift,fn=c.kCGEventFlagMaskSecondaryFn}
---Returns the modifier keys for this keyboard event.
-- @function [parent=#event] getMods
-- @param #event self
-- @return #table {modKeyCode=true,...}
function event:getMods()
  local mask=CGEventGetFlags(self[1]) or 0
  local r={} for k,v in pairs(flagMasks) do r[k]=band(mask,v)>0 end return r
end
---Sets the modifier keys for this keyboard event.
-- @function [parent=#event] setMods
-- @param #event self
-- @param #table mods {modKeyCode=true,...}
-- @return #event this event
function event:setMods(mods)
  local mask=0 for k,v in pairs(mods) do mask=bor(mask,flagMasks[k] or 0) end
  CGEventSetFlags(self[1],mask) return self
end
local NSEvent=c.NSEvent
---Returns the Unicode representation of this keyboard event.
-- @function [parent=#event] getCharacter
-- @param #event self
-- @param #boolean ignoreModifiers if `true`, modifier keys in this event other than 'shift' will be ignored
-- @return #string
-- @return #nil if a character representation cannot be found
function event:getCharacter(ignoreModifiers)
  local evType=self:getType()
  if evType~=eventTypes.keyDown and evType~=eventTypes.keyUp then return nil end
  local nsev=NSEvent:eventWithCGEvent(self[1])
  local nsstr=ignoreModifiers and nsev.charactersIgnoringModifiers or nsev.characters
  return nsstr:UTF8String()
end

local CGEventPost=c.CGEventPost
---Posts the event to the OS or to an application.
-- @function [parent=#event] post
-- @param #event self
-- @param #boolean beforeTaps if `true`, running eventtaps will recapture the posted event
-- @return #event this event
function event:post(beforeTaps)
  if beforeTaps then CGEventSetIntegerValueField(self[1],kCGEventSourceUserData,HM_SOURCE_DONTSKIP_USERDATA) end
  CGEventPost(kCGSessionEventTap,self[1]) --[[C.usleep(500) --]]return self
end

local CGEventPostToPSN=c.CGEventPostToPSN
---Posts the event to an application.
-- @function [parent=#event] postToApplication
-- @param #event self
-- @param hm.applications#application application
-- @return #event this event
function event:postToApplication(application) hmcheck('hm._os.events#event','hm.applications#application')
  CGEventPostToPSN(application.psn,self[1]) C.usleep(500) return self
end

local eventSource=c.CGEventSourceCreate(c.kCGEventSourceStatePrivate)
c.CGEventSourceSetUserData(eventSource,HM_SOURCE_USERDATA)
---Creates a new key event
-- @function [parent=#hm._os.events] keyEvent
-- @param #number code
-- @param #boolean isDown `true` for key press, `false` for key release
-- @return #event the new event
function events.keyEvent(code,isDown) return newEvent{c.CGEventCreateKeyboardEvent(eventSource,code,isDown and true or false)} end




---@private
function events.__gc()
  CFRelease(eventSource)
  for tap in pairs(runningTaps) do tap:stop() end
  for eventType,cgtap in pairs(cgtaps) do
    log.i('Destroying main tap:',eventType)
    c.CFMachPortInvalidate(cgtap)
    runLoopRemoveSource(rlSources[eventType],c.kCFRunLoopCommonModes)
    CFRelease(cgtap)
    rlSources[eventType]=nil
    cgtaps[eventType]=nil
  end
end

return events
