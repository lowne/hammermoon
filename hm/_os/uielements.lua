---`AXUIElement` interface
-- @module hm._os.uielements
-- @static

require'hm._os'

local c=require'objc'
local tolua,toobj,nptr=c.tolua,c.toobj,c.nptr
c.load'CoreFoundation'
c.load'ApplicationServices.HIServices'
c.load'CoreGraphics'
-- patch AX stuff that uses CF
-- this one expects (2nd arg) CFString (which objc.lua can't construct), allow NSStrings instead
c.addfunction('AXUIElementCopyAttributeValue',{retval='i','^{__AXUIElement=}','@"NSString"','^^v'},false)
c.addfunction('AXUIElementSetAttributeValue',{retval='i','^{__AXUIElement=}','@"NSString"','@'})
-- CFString to NSString, also refdata from ^v to i
c.addfunction('AXObserverAddNotification',{retval='i','^{__AXObserver=}','^{__AXUIElement=}','@"NSString"','i'},false)
-- this one wants (1st arg) an AXValueRef (outval from AXUIElementCopyAttributeValue) but we don't want to fficast every time
c.addfunction('AXValueGetValue',{retval='B','^{__CFType=}','i','^v'},false)
-- CFString to NSString, cb refdata ^v to ^i
c.addfunction('AXObserverCreate',{retval='i','i','^?',fp={[2]={'^{__AXObserver=}','^{__AXUIElement=}','@"NSString"','i'}},'^^{__AXObserver}'})
-- private API yeah!
c.addfunction('_AXUIElementGetWindow',{retval='i','^{__AXUIElement=}','^i'},false)

local ffi=require'ffi'
local cast=ffi.cast

local property=hm._core.property

local coll=require'hm.types.coll'
local next,pairs,ipairs,type,setmetatable=next,pairs,ipairs,type,setmetatable
local sformat,tinsert,tremove=string.format,table.insert,table.remove

local CFEqual=c.CFEqual
---@type hm._os.uielements
-- @extends hm#module
local uielements=hm._core.module('hm._os.uielements',{uielement={
  __tostring=function(self)return sformat('uielement: [%d] %s',self._ref,self.role) end,
  __gc=function(self) end,
  __eq=function(e1,e2) return e2[1] and CFEqual(e1[1],e2[1]) end,
},watcher={
  __tostring=function(self)return sformat('uielement watcher: [#%d] [pid:%d] %s (%s)',self._ref,self._pid,self._elem.role,self.isActive and 'active' or 'inactive') end,
  __gc=function(self)end,
}})
local log=uielements.log

---@type uielement
-- @extends hm#module.object
-- @class
local elem=uielements._classes.uielement
local new=elem._new

local value_out=ffi.new'int[1]'
local prop_out=ffi.new'CFTypeRef[1]'

local _AXUIElementGetWindow=c._AXUIElementGetWindow
---Only for window elements
-- @return #number window id
function elem:getWindowID()
  local result=_AXUIElementGetWindow(self[1],value_out)
  return result==0 and value_out[0] or
    log.fw('%s: window ID <= [pid:%d]',require'hm._os.bridge.axerrors'[result],self._pid)
end

---The process identifier of the application owning this uielement.
-- @field [parent=#uielement] #number pid
-- @readonlyproperty
property(elem,'pid',function(self)return self._pid end)



local AXUIElementCopyAttributeValue=c.AXUIElementCopyAttributeValue
local function getProp(self,prop)
  local res=AXUIElementCopyAttributeValue(self[1],prop,prop_out)
  --TODO do something smarter with errors
  return res==0 and prop_out[0] or log.fe('%s: %s <= %d',require'hm._os.bridge.axerrors'[res],tolua(prop),self._ref)
end

--typedef enum {kAXValueCGPointType = 1,kAXValueCGSizeType = 2,kAXValueCGRectType = 3,kAXValueCFRangeType = 4,
--   kAXValueAXErrorType = 5,kAXValueIllegalType = 0} AXValueType;
local AXValueGetValue=c.AXValueGetValue
local valueTypes,valueCasts={CGPoint=1,CGSize=2,CGRect=3,CFRange=4},{}
for k in pairs(valueTypes) do valueCasts[k]=ffi.typeof(k..' *') end
local function getValueProp(self,prop,cls)
  local res=AXValueGetValue(getProp(self,prop),valueTypes[cls],value_out)
  if not res then return log.fe('AXValueGetValue: %s <= %d',tolua(prop),self._ref) end
  --TODO do something smarter with errors
  return cast(valueCasts[cls],value_out) -- cast to appropriate struct (which is bridged by objc.lua)
end

local function getNSObjectProp(self,prop,cls,sel)
  local v=getProp(self,prop)
  return v and tolua(cls[sel](cls, v))-- quite a lousy way to cast the result, but afaict it doesn't allocate
end

local AXUIElementSetAttributeValue=c.AXUIElementSetAttributeValue
local function setProp(self,prop,v)
  local result=AXUIElementSetAttributeValue(self[1],prop,v)
  return result==0 and true or log.fe('%s: %s => %d',require'hm._os.bridge.axerrors'[result],tolua(prop),self._ref)
end

---Checks if this element has a given AX property
-- @function [parent=#uielement] hasProp
-- @param #uielement self
-- @param #string prop
-- @return #boolean
function elem:hasProp(prop) return AXUIElementCopyAttributeValue(self[1],prop,prop_out)==0 end
---Returns an AX property without any conversion
-- @function [parent=#uielement] getRawProp
-- @param #uielement self
-- @param #string prop property name
-- @return #cdata
elem.getRawProp=getProp

local NSString,NSNumber,NSArray=c.NSString,c.NSNumber,c.NSArray
local getNumberFromCFNumberRef=c.caller('NSNumber','doubleValue')

---Returns an AX property of type integer
-- @function [parent=#uielement] getIntegerProp
-- @param #uielement self
-- @param #string prop property name
-- @return #number
function elem:getIntegerProp(prop) return getNumberFromCFNumberRef(getProp(self,prop)) end
--function elem:getIntegerProp(prop) return tolua(getProp(self,prop)) end
--function elem:getIntegerProp(prop) return getNSObjectProp(self,prop,NSNumber,'numberWithInteger') or 0 end

---Returns an AX property of type boolean
-- @function [parent=#uielement] getBooleanProp
-- @param #uielement self
-- @param #string prop property name
-- @return #boolean
function elem:getBooleanProp(prop) return self:getIntegerProp(prop)==1 end
---Returns an AX property of type string
-- @function [parent=#uielement] getStringProp
-- @param #uielement self
-- @param #string prop property name
-- @return #string
function elem:getStringProp(prop) return getNSObjectProp(self,prop,NSString,'stringWithString') or '' end
---Returns an AX property of type array
-- @function [parent=#uielement] getArrayProp
-- @param #uielement self
-- @param #string prop property name
-- @return #table
function elem:getArrayProp(prop) return getNSObjectProp(self,prop,NSArray,'arrayWithArray') or {} end

---Sets an AX property without any conversion
-- @function [parent=#uielement] setRawProp
-- @param #uielement self
-- @param #string prop property name
-- @param #cdata value
-- @return #boolean `true` on success
elem.setRawProp=setProp

---Sets an AX property of type integer
-- @function [parent=#uielement] setIntegerProp
-- @param #uielement self
-- @param #string prop property name
-- @param #number value
-- @return #boolean `true` on success
function elem:setIntegerProp(prop,value) return setProp(self,prop,toobj(value)) end
--elem.setIntegerProp=setProp
---Sets an AX property of type boolean
-- @function [parent=#uielement] setBooleanProp
-- @param #uielement self
-- @param #string prop property name
-- @param #boolean value
-- @return #boolean `true` on success
function elem:setBooleanProp(prop,value) return setProp(self,prop,toobj(value and 1 or 0)) end
--elem.setBooleanProp=function(self,v)setProp(self,v and 1 or 0) end
---Sets an AX property of type string
-- @function [parent=#uielement] setStringProp
-- @param #uielement self
-- @param #string prop property name
-- @param #string value
-- @return #boolean `true` on success
elem.setStringProp=elem.setIntegerProp
---Sets an AX property of type array
-- @function [parent=#uielement] setArrayProp
-- @param #uielement self
-- @param #string prop property name
-- @param #list value
-- @return #boolean `true` on success
elem.setArrayProp=elem.setIntegerProp

local point,size=require'hm.types.geometry'.point,require'hm.types.geometry'.size
---Returns an AX property of type point
-- @function [parent=#uielement] getPointProp
-- @param #uielement self
-- @param #string prop property name
-- @return hm.types.geometry#point
function elem:getPointProp(prop) local p=getValueProp(self,prop,'CGPoint') return point(p.x,p.y) end
---Returns an AX property of type size
-- @function [parent=#uielement] getSizeProp
-- @param #uielement self
-- @param #string prop property name
-- @return hm.types.geometry#size
function elem:getSizeProp(prop) local s=getValueProp(self,prop,'CGSize') return size(s.width,s.height) end

local NSMakePoint,NSMakeSize=c.NSMakePoint,c.NSMakeSize
---Sets an AX property of type point
-- @function [parent=#uielement] setPointProp
-- @param #uielement self
-- @param #string prop property name
-- @param hm.types.geometry#point value
-- @return #boolean `true` on success
function elem:setPointProp(prop,value) return setProp(self,prop,NSMakePoint(value.x,value.y)) end
---Sets an AX property of type size
-- @function [parent=#uielement] setSizeProp
-- @param #uielement self
-- @param #string prop property name
-- @param hm.types.geometry#size value
-- @return #boolean `true` on success
function elem:setSizeProp(prop,value) return setProp(self,prop,NSMakeSize(value.w,value.h)) end

---The element's title
-- @field [parent=#uielement] #string title
-- @readonlyproperty
property(elem,'title',function(self)
  return self:hasProp(c.NSAccessibilityTitleAttribute) and self:getStringProp(c.NSAccessibilityTitleAttribute) or ''
end,false)
---The element's `AXRole`
-- @field [parent=#uielement] #string role
-- @readonlyproperty
property(elem,'role',function(self) return self._role or self:getStringProp(c.NSAccessibilityRoleAttribute) end)
---The element's `AXSubrole`
-- @field [parent=#uielement] #string subrole
-- @readonlyproperty
property(elem,'subrole',function(self) return self:getStringProp(c.NSAccessibilitySubroleAttribute) end,false)
---The element's selected text
-- @field [parent=#uielement] #string selectedText
-- @readonlyproperty
property(elem,'selectedText',function(self) return self:getStringProp(c.NSAccessibilityRoleSelectedTextAttribute) end,false)
---The element's top left corner
-- @field [parent=#uielement] hm.types.geometry#point topLeft
-- @property
property(elem,'topLeft',
  function(self) return self:getPointProp(c.NSAccessibilityPositionAttribute) end,
  function(self,v) self:setPointProp(c.NSaccessibilityPositionAttribute,v) end,'hm.types.geometry#point')
---The element's size
-- @field [parent=#uielement] hm.types.geometry#size size
-- @property
property(elem,'size',
  function(self) return self:getSizeProp(c.NSAccessibilitySizeAttribute) end,
  function(self,v) self:setSizeProp(c.NSAccessibilitySizeAttribute,v) end,'hm.types.geometry#size')


local cachedElements=hm._core.cacheValues()
local CFHash=c.CFHash
local AXUIElementGetPid=c.AXUIElementGetPid
local function newElem(ax,pid,o)
  local hash=nptr(CFHash(ax))
  if cachedElements[hash] then return cachedElements[hash] end
  if not pid then
    local result=AXUIElementGetPid(ax,value_out)
    pid=result==0 and value_out[0] or error'cannot get pid from axuielement'
  end
  o=o or {} o[1]=ax o._pid=pid o._ref=hash
  o=new(o)
  log.v('cached hash',hash) cachedElements[hash]=o
  return o
end
--[[
function elem:isApplication() return self:role()=='AXApplication' end
local function isWindow(role,self)
  return role=='AXWindow' or elem._hasProp(self,c.NSAccessibilityMinimizedAttribute)
end
function elem:isWindow() return isWindow(self:role(),self) end

local newWin,newApp=hm.window._newWindow,hm.application._newApplication

local cachedElements=hm._core.cacheValues()
--local cfptr_t=ffi.typeof('void*')
local function newElem(axelem,pid)
  --  local hash=nptr(CFHash(cast(cfptr_t,axelem)))
  local hash=nptr(CFHash(axelem))
  if cachedElements[hash] then return cachedElements[hash] end
  if not pid then
    local result=AXGetPid(axelem,value_out)
    pid=result==0 and value_out[0] or error'cannot get pid from axuielement'
  end
  local o={_ax=axelem,_pid=pid}
  local role=tolua(NSString:stringWithString(getProp(o,c.NSAccessibilityRoleAttribute)))
  if isWindow(role,o) then
    o=newWin(axelem,pid)
  elseif role=='AXApplication' then
    o=newApp(nil,pid)
  else
    --    assert(role~='AXApplication')
    o=new({_ax=axelem,_pid=pid})
  end
  log.v('cached hash',hash)
  cachedElements[hash]=o
  return o
    --  return setmetatable({_ax=axelem,_pid=pid},{__index=ui,__tostring=ui.tostring})
end--]]

---@function [parent=#hm._os.uielements] newElement
-- @param #cdata ax `AXUIElementRef`
-- @param #number pid (optional)
-- @return #uielement
uielements.newElement=newElem

local AXUIElementCreateApplication=c.AXUIElementCreateApplication
---@function [parent=#hm._os.uielements] newElementForApplication
-- @param #number pid
-- @return #uielement
function uielements.newElementForApplication(pid)
  return newElem(AXUIElementCreateApplication(pid),pid,{_role='AXApplication'})
end

----- AX watchers -----

local logw=hm.logger.new('uielement.watcher')
local events=require'hm._os.bridge.axevents'
local elementDestroyed = "AXUIElementDestroyed"

---An event name.
-- Valid event names are: `"applicationActivated"`, `"applicationDeactivated"`, `"applicationHidden"`, `"applicationShown"`,
-- `"mainWindowChanged"`, `"focusedWindowChanged"`, `"focusedElementChanged"`, `"windowCreated"`, `"windowMoved"`,
-- `"windowResized"`, `"windowMinimized"`, `"windowUnminimized"`, `"elementDestroyed"`, `"titleChanged"`.
-- @type eventName
-- @extends #string

---@type eventNameList
-- @list <#eventName>

checkers['hm._os.uielements#eventName']=function(v) return type(v)=='string' and events[v] and true end

---A uielement watcher
-- @type watcher
-- @extends hm#module.object
-- @class
local watcher=uielements._classes.watcher
local newWatcher=watcher._new

local watcherCount=0
---Creates a new watcher for this element.
-- @function [parent=#uielement] newWatcher
-- @param #uielement self
-- @param #watcherCallback fn callback function
-- @param data (optional)
-- @return #watcher the new watcher
function elem:newWatcher(fn,data) checkargs('hm._os.uielements#uielement','callable')
  logw.v('Creating watcher for',self)
  watcherCount=watcherCount+1
  return newWatcher{_elem=self,_pid=self._pid,_isActive=false,_cb=fn,_data=data,_ref=watcherCount}
end

---Creates and starts a new watcher for this element.
-- This method is a shortcut for `uielem:newWatcher():start()`
-- @function [parent=#uielement] startWatcher
-- @param #uielement self
-- @param #eventNameList events
-- @param #function fn callback function
-- @param data (optional)
-- @return #watcher the new watcher
function elem:startWatcher(events,fn,data) return self:newWatcher(fn,data):start() end

---@function [parent=#watcher] watcherCallback
-- @param #uielement element that caused the event; note that this is not necessarily the same as the element being watched
-- @param #eventName event
-- @param #watcher watcher that triggered the callback
-- @param data
-- @prototype

local watchersForPid={}
local runningWatchers={}
local function observerCallback(_AXObserver,AXElement,notificationName,ref)
  local watcher=runningWatchers[ref]
  if not watcher or not watcher._isActive then return logw.e'event on stopped watcher' end
  local event=tolua(notificationName)
  assert(watcher._events[event],'event on uninterested watcher')
  logw.v(watcher,'received event',event,'- running callback')
  local elem=newElem(AXElement,watcher._pid)
  if event==elementDestroyed then
    if watcher._watchingDestroyed then
      watcher._cb(elem,event,watcher,watcher._data)
    end
    watcher:stop()
  else return watcher._cb(elem,event,watcher,watcher._data) end
end

local function stopChildrenWatchers(_,info)
  local pid=tolua(info:objectForKey'NSApplicationProcessIdentifier')
  if not pid then return logw.e('Process terminated, but no pid in notification!')
  else
    if watchersForPid[pid] then
      logw.d('Stopping watchers for pid:',pid)
      for w in pairs(watchersForPid[pid]) do w:stop() end
      watchersForPid[pid]=nil
    else logw.v('Process terminated with no watchers:',pid) end
  end
end


local globalWatcher --flag for 1st registration
local obs_t=ffi.typeof'AXObserverRef[1]'
local observers={}--setmetatable({},{__mode='kv'})
---
local AXObserverGetRunLoopSource=c.AXObserverGetRunLoopSource
local AXObserverCreate,AXObserverAddNotification=c.AXObserverCreate,c.AXObserverAddNotification
local runLoopAddSource=require'hm._os'.runLoopAddSource
---Starts this watcher
-- @function [parent=#watcher] start
-- @param #watcher self
-- @param #eventNameList events events to watch
-- @return #watcher this watcher
function watcher:start(events) sanitizeargs('hm._os.uielements#watcher','listOrValue(hm._os.uielements#eventName)')
  if not globalWatcher then
    require'hm._os'.wsNotificationCenter:register('NSWorkspaceDidTerminateApplicationNotification',stopChildrenWatchers,true)
    globalWatcher=true
  elseif self._isActive then logw.w(self,'is already running') return self end
  ---@private
  self._isActive=true
  local pid=self._pid
  local observer
  if watchersForPid[pid] then observer=observers[pid]
  else
    logw.d('Creating observer for pid',pid)
    watchersForPid[pid]={}
    local obs_p=obs_t()
    local result=AXObserverCreate(pid,observerCallback,obs_p)
    if result~=0 then error('cannot create AXObserver: '..require'hm._os.bridge.axerrors'[result]) end
    observer=obs_p[0]
    runLoopAddSource(AXObserverGetRunLoopSource(observer))
    observers[pid]=observer
  end
  watchersForPid[pid][self]=true
  ---@private
  self._watchingDestroyed=events[elementDestroyed]
  events[elementDestroyed]=true
  for event in pairs(events) do
    local result=AXObserverAddNotification(observer,self._elem[1],toobj(event),self._ref)
    if result~=0 then error('error on AXObserverAddNotification: '..require'hm._os.bridge.axerrors'[result]) end
    logw.v(self,'listening for',event)
  end
  ---@private
  self._events=events
  logw.d(self,'started')
  return self
end

local runLoopRemoveSource=require'hm._os'.runLoopRemoveSource
---Stops this watcher
-- @function [parent=#watcher] stop
-- @param #watcher self
-- @return #watcher this watcher
function watcher:stop()
  if not self._isActive then return self end
  self._isActive=false
  self._watchingDestroyed=nil
  local pid=self._pid
  assert(watchersForPid[pid])
  watchersForPid[pid][self]=nil
  log.d(self,'stopped')
  if not next(watchersForPid[pid]) then
    log.d('Last watcher stopped, removing observer for pid',pid)
    watchersForPid[pid]=nil
    runLoopRemoveSource(AXObserverGetRunLoopSource(observers[pid]))
    observers[pid]=nil
  end
  return self
end

---@private
function uielements.__gc()
  for pid,watchers in pairs(watchersForPid) do
    for watcher in pairs(watchers) do watcher:stop() end
  end
end

return uielements
