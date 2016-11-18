---Low level `CGEvent`/`NSEvent` interface
-- @module hm._os.events
-- @static

local c=require'objc'
c.load'CoreGraphics'
c.load'CoreFoundation'
local kCGEventTapDisabledByTimeout,kCGEventTapDisabledByUserInput=c.kCGEventTapDisabledByTimeout,c.kCGEventTapDisabledByUserInput
local CGEventTapEnable=c.CGEventTapEnable

local runLoopAddSource,runLoopRemoveSource=require'hm._os'.runLoopAddSource,require'hm._os'.runLoopRemoveSource

local coll=require'hm.types.coll'
local type,ipairs,pairs=type,ipairs,pairs
local tinsert,tremove,sformat=table.insert,table.remove,string.format
local band=bit.band
c.addfunction('CFRelease',{'^v'},false)
local CFRelease=c.CFRelease

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
local tap,newTap=events._classes.eventtap,events._classes.eventtap._new

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
    --    log.v('Received event',eventTypes[evType])
    hmassert(evType==eventTypes[eventType])
    local wev=setmetatable({ev},toeventmt) -- no CFRelease on these dudes, but keep the methods
    for _,cb in ipairs(callbacks[eventType]) do
      if cb(wev) then return nil end
    end
    return ev
  end
  local cgtap=assert(c.CGEventTapCreate(c.kCGSessionEventTap,c.kCGHeadInsertEventTap,c.kCGEventTapOptionDefault,2^eventTypes[eventType],handler,nil))
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
-- @param #function fn callback function that will receive the bare `CGEvent` as its sole argument
-- @return #eventtap
function events.eventtap(events,fn) hmcheck('eventTypeList','callable')
  tapCount=tapCount+1
  events=coll.map(events,function(ev)return type(ev)=='string' and ev or eventTypes[ev] end):toSet()
  return newTap{_eventTypes=events,_cb=fn,_ref=tapCount}
end

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

function tap:isEnabled() return runningTaps[self] and true or false end

--[[
function events.getKeyCode(ev) return tonumber(CGEventGetIntegerValueField(ev,kCGKeyboardEventKeycode)) end
function events.getFlags(ev)
  local mask=CGEventGetFlags(ev) or 0
  local r={} for k,v in pairs(flagMasks) do r[k]=band(mask,v)>0 end return r
end
--]]


local CGEventGetIntegerValueField,kCGKeyboardEventKeycode=c.CGEventGetIntegerValueField,c.kCGKeyboardEventKeycode
local tonumber=tonumber -- convert from int64
function event:getKeyCode() return tonumber(CGEventGetIntegerValueField(self[1],kCGKeyboardEventKeycode)) end
local CGEventGetFlags=c.CGEventGetFlags
local flagMasks={cmd=c.kCGEventFlagMaskCommand,ctrl=c.kCGEventFlagMaskControl,alt=c.kCGEventFlagMaskAlternate,
  shift=c.kCGEventFlagMaskShift,fn=c.kCGEventFlagMaskSecondaryFn}
function event:getFlags()
  local mask=CGEventGetFlags(self[1]) or 0
  local r={} for k,v in pairs(flagMasks) do r[k]=band(mask,v)>0 end return r
end

local eventSource=c.CGEventSourceCreate(c.kCGEventSourceStatePrivate)

function events.key(code,isDown) return newEvent{c.CGEventCreateKeyboardEvent(eventSource,code,isDown)} end
--function events.key(code,isDown) return c.CGEventCreateKeyboardEvent(eventSource,code,isDown) end



--require'ffi'.metatype('struct __CGEvent',{__index=event,__gc=event.__gc})






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
