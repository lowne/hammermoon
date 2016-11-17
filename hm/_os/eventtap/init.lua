---
-- @module hm._os.eventtap
-- @static

local c=require'objc'
c.load'CoreGraphics'
--c.load'CoreFoundation'
local kCGEventTapDisabledByTimeout,kCGEventTapDisabledByUserInput=c.kCGEventTapDisabledByTimeout,c.kCGEventTapDisabledByUserInput
local CGEventTapEnable=c.CGEventTapEnable

local runLoopAddSource,runLoopRemoveSource=hm._os.runLoopAddSource,hm._os.runLoopRemoveSource

local coll=require'hm.types.coll'
local type,ipairs,pairs=type,ipairs,pairs
local tinsert,tremove,sformat=table.insert,table.remove,string.format
local band=bit.band


local tappers,rlSources,callbacks={},{},{}

local runningTaps,tapCount=hm._core.retainKeys(),0

---@type hm._os.eventtap
-- @extends hm#module
local evtap=hm._core.module('_os.eventtap',{
  __tostring=function(self)return sformat('eventtap: [#%d] (%s)',self._ref,runningTaps[self] and 'enabled' or 'disabled') end,
  __gc=function(self) return self:stop() end,
},{'event'})
local log=evtap.log

---@field [parent=#hm._os.eventtap] hm._os.eventtap.event#hm._os.eventtap.event event

---@type eventtap
-- @extends hm#module.object
local tap,new=evtap._class,evtap._class._new

local eventTypes=require'hm._os.eventtap.event'.types

local function createTap(eventType) hmcheck'string'
  log.i('Creating main tap:',eventType)
  local handler=function(_tapProxy,evType,ev,_data)
    if evType==kCGEventTapDisabledByTimeout or evType==kCGEventTapDisabledByUserInput then
      log.i('an eventtap was disabled, restarting')
      CGEventTapEnable(tappers[eventType],true)
      return ev
    end
    log.v('Received event',eventTypes[evType])
    hmassert(evType==eventTypes[eventType])
    for _,cb in ipairs(callbacks[eventType]) do
      if cb(ev) then return nil end
    end
    return ev
  end
  local tapper=assert(c.CGEventTapCreate(c.kCGSessionEventTap,c.kCGHeadInsertEventTap,c.kCGEventTapOptionDefault,2^eventTypes[eventType],handler,nil))
  tappers[eventType]=tapper
  callbacks[eventType]={}
  local rlSource=c.CFMachPortCreateRunLoopSource(nil,tapper,0)
  runLoopAddSource(rlSource,c.kCFRunLoopCommonModes)
  rlSources[eventType]=rlSource
end
local function startTap(eventType) log.d('Starting main tap:',eventType) CGEventTapEnable(tappers[eventType],true) end

local function stopTap(eventType) log.d('Stopping main tap:',eventType) CGEventTapEnable(tappers[eventType],false) end

checkers['eventTypeList']=function(v) return type(v)=='table' and coll.every(v,function(ev)return eventTypes[ev] end) end

function evtap.new(events,fn) hmcheck('eventTypeList','callable')
  tapCount=tapCount+1
  events=coll.map(events,function(ev)return type(ev)=='string' and ev or eventTypes[ev] end):toSet()
  return new{_eventTypes=events,_cb=fn,_ref=tapCount}
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

---
-- @internalchange We don't want to create a new object for every event, since many of these could prove to be uninteresting to the
-- consumers; therefore properties are queried via simple static functions.

local CGEventGetIntegerValueField,kCGKeyboardEventKeycode=c.CGEventGetIntegerValueField,c.kCGKeyboardEventKeycode
local tonumber=tonumber -- convert from int64
function evtap.getKeyCode(ev) return tonumber(CGEventGetIntegerValueField(ev,kCGKeyboardEventKeycode)) end

local CGEventGetFlags=c.CGEventGetFlags
--local maskCommand,maskControl,maskAlternate,maskShift,maskSecondaryFn=
--  c.kCGEventFlagMaskCommand,c.kCGEventFlagMaskControl,c.kCGEventFlagMaskAlternate,c.kCGEventFlagMaskShift,c.kCGEventFlagMaskSecondaryFn
local flagMasks={cmd=c.kCGEventFlagMaskCommand,ctrl=c.kCGEventFlagMaskControl,alt=c.kCGEventFlagMaskAlternate,
  shift=c.kCGEventFlagMaskShift,fn=c.kCGEventFlagMaskSecondaryFn}

function evtap.getFlags(ev)
  local mask=CGEventGetFlags(ev) or 0
  local r={}
  for k,v in pairs(flagMasks) do r[k]=band(mask,v)>0 end
  return r
    --  return band(mask,maskCommand),band(mask,maskControl),band(mask,maskAlternate),band(mask,maskShift),band(mask,maskSecondaryFn)
end










---@private
function evtap.__gc()
  for tap in pairs(runningTaps) do tap:stop() end
  for eventType,tapper in pairs(tappers) do
    c.CFMachPortInvalidate(tapper)
    runLoopRemoveSource(rlSources[eventType],c.kCFRunLoopCommonModes)
    rlSources[eventType]=nil
    tappers[eventType]=nil
  end
end

return evtap
