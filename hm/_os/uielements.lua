---`AXUIElement` interface
-- @module hm._os.uielements
-- @static

require'hm._os'

local c=require'objc'
local tolua,toobj,nptr=c.tolua,c.toobj,c.nptr
c.load'CoreFoundation'
c.load'Foundation'
c.load'ApplicationServices.HIServices'
c.load'CoreGraphics'
-- patch AX stuff that uses CF
-- this one expects (2nd arg) CFString (which objc.lua can't construct), allow NSStrings instead
--c.addfunction('AXUIElementCopyAttributeValue',{retval='i','^{__AXUIElement=}','@"NSString"','^^v'},false)
--c.addfunction('AXUIElementSetAttributeValue',{retval='i','^{__AXUIElement=}','@"NSString"','@'})
-- CFString to NSString, also refdata from ^v to i
c.addfunction('AXObserverAddNotification',{retval='i','^{__AXObserver=}','^{__AXUIElement=}','@"NSString"','i'},false)
-- this one wants (1st arg) an AXValueRef (outval from AXUIElementCopyAttributeValue) but we don't want to fficast every time
c.addfunction('AXValueGetValue',{retval='B','^{__CFType=}','i','^v'},false)
-- CFString to NSString, cb refdata ^v to ^i
c.addfunction('AXObserverCreate',{retval='i','i','^?',fp={[2]={'^{__AXObserver=}','^{__AXUIElement=}','@"NSString"','i'}},'^^{__AXObserver}'})
-- private API yeah!
c.addfunction('_AXUIElementGetWindow',{retval='i','^{__AXUIElement=}','^i'},false)

local ffi=require'ffi'
local C,cast,gc=ffi.C,ffi.cast,ffi.gc

local property=hm._core.property

local next,pairs,ipairs,type,setmetatable,rawset=next,pairs,ipairs,type,setmetatable,rawset
local sformat,tinsert,tremove=string.format,table.insert,table.remove
local cf=require'hm._os.cf'
c.cdef'CFEqual' c.cdef'CFHash' c.cdef'CFRelease'

---@type hm._os.uielements
-- @extends hm#module
local uielements=hm._core.module('hm._os.uielements',{uielement={
  __tostring=function(self)return sformat('uielement: [%d] %s',self._ref,self.role) end,
  __gc=function(self) end,
  __eq=function(e1,e2) return e2[1] and C.CFEqual(e1[1],e2[1]) end,
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

local attrs=setmetatable({
  ['fullscreen']='NSAccessibilityFullScreenAttribute',
  ['fullscreen']='AXFullScreen',
--TODO test fullscreen
},{
  __index=function(t,k)
    hmassertf(type(k)=='string','attribute must be a string')
    local ck='NSAccessibility'..k:sub(1,1):upper()..k:sub(2)..'Attribute'
    local attr=hmassertf(c[ck],'invalid AX attribute %s (%s not found)',k,ck)
    attr=cf.makeString(tolua(attr))
    rawset(t,k,attr)
    return attr
  end,
  __newindex=function()error 'not allowed' end,
})

elem.attrs=attrs

--local object_out=ffi.new'int[1]'
local id_out=ffi.new'int32_t[1]'
local value_out=ffi.new'CFTypeRef[1]'

--local _AXUIElementGetWindow=c._AXUIElementGetWindow
---Only for window elements
-- @return #number window id
function elem:getWindowID()
  local result=C._AXUIElementGetWindow(self[1],id_out)
  return result==0 and id_out[0] or
    log.fw('%s: window ID <= [pid:%d]',require'hm._os.bridge.axerrors'[result],self._pid)
end

---The process identifier of the application owning this uielement.
-- @field [parent=#uielement] #number pid
-- @readonlyproperty
property(elem,'pid',function(self)return self._pid end)


--local AXUIElementCopyAttributeValue=c.AXUIElementCopyAttributeValue
c.cdef'AXUIElementCopyAttributeValue'
local function getAttr(self,attr,default)
  log.vf('get %s for %d',attr,self._ref)
  local res=C.AXUIElementCopyAttributeValue(self[1],attrs[attr],value_out)
  if res==0 then return gc(value_out[0],function(self) log.w('CFRelease') C.CFRelease(self) end)
  elseif default~=nil then return default
    --TODO do something smarter with errors
  else return log.fe('%s: %s <= %d',require'hm._os.bridge.axerrors'[res],attr,self._ref) end
end

--local AXUIElementSetAttributeValue=c.AXUIElementSetAttributeValue
c.cdef'AXUIElementSetAttributeValue'
local function setAttr(self,attr,v)
  local result=C.AXUIElementSetAttributeValue(self[1],attrs[attr],v)
  return result==0 and true or log.fe('%s: %s => %d',require'hm._os.bridge.axerrors'[result],attr,self._ref)
end

c.cdef'AXValueGetValue'
local valueTypes,valueCasts={CGPoint=1,CGSize=2,CGRect=3,CFRange=4},{}
for k in pairs(valueTypes) do valueCasts[k]=ffi.typeof(k..' *') end
local function getStructAttr(self,attr,cls)
  local res=C.AXValueGetValue(getAttr(self,attr),valueTypes[cls],value_out)
  if not res then return log.fe('AXValueGetValue: %s <= %d',attr,self._ref) end
  --TODO do something smarter with errors
  return cast(valueCasts[cls],value_out) -- cast to appropriate struct (which is bridged by objc.lua)
end
c.cdef'AXValueCreate'
local function setStructAttr(self,attr,cls,value)
  local struct_ret=C.AXValueCreate(valueTypes[cls],value)
  local res=setAttr(self,attr,struct_ret)
  C.CFRelease(struct_ret)
  return res
end

---Checks if this element has a given AX attribute
-- @function [parent=#uielement] hasAttr
-- @param #uielement self
-- @param #string attr
-- @return #boolean
function elem:hasAttr(attr) return getAttr(self,attr,false) and true end

---Returns an AX attribute without any conversion
-- @function [parent=#uielement] getRaw
-- @param #uielement self
-- @param #string attr attribute name
-- @return #cdata
elem.getRaw=getAttr

--local getNumberFromCFNumberRef=c.caller('NSNumber','doubleValue')

---Returns an AX attribute of type integer
-- @function [parent=#uielement] getInt
-- @param #uielement self
-- @param #string attr attribute name
-- @param default default value
-- @return #number
function elem:getInt(attr,default) return cf.getInt(getAttr(self,attr,default)) end
--function elem:getInteger(attr,default) return getNumberFromCFNumberRef(getAttr(self,attr,default)) end
--function elem:getIntegerProp(prop) return tolua(getProp(self,prop)) end
--function elem:getIntegerProp(prop) return getNSObjectProp(self,prop,NSNumber,'numberWithInteger') or 0 end

---Returns an AX attribute of type boolean
-- @function [parent=#uielement] getBool
-- @param #uielement self
-- @param #string attr attribute name
-- @return #boolean
function elem:getBool(attr) return self:getInt(attr)==1 end

--local getStringFromCFStringRef=c.caller('NSString','UTF8String')
---Returns an AX attribute of type string
-- @function [parent=#uielement] getString
-- @param #uielement self
-- @param #string attr attribute name
-- @param default default value
-- @return #string
function elem:getString(attr,default) return cf.getString(getAttr(self,attr,default)) end
--function elem:getString(attr,default) return getStringFromCFStringRef(getAttr(self,attr,default)) end
--function elem:getString(attr,default) return getNSObject(self,attr,NSString,'stringWithString') or '' end
---Returns an AX attribute of type array
-- @function [parent=#uielement] getArrayattr
-- @param #uielement self
-- @param #string attr attribute name
-- @return #table
function elem:getArray(attr,default) return cf.getArray(getAttr(self,attr,default)) end
--function elem:getArray(attr) return getNSObject(self,attr,NSArray,'arrayWithArray') or {} end

---Sets an AX attribute without any conversion
-- @function [parent=#uielement] setRaw
-- @param #uielement self
-- @param #string attr attribute name
-- @param #cdata value
-- @return #boolean `true` on success
elem.setRaw=setAttr

---Sets an AX attribute of type integer
-- @function [parent=#uielement] setInt
-- @param #uielement self
-- @param #string attr attribute name
-- @param #number value
-- @return #boolean `true` on success
function elem:setInt(attr,value) return setAttr(self,attr,cf.makeInt(value)) end
--function elem:setInteger(attr,value) return setAttr(self,attr,toobj(value)) end
--elem.setIntegerProp=setProp
---Sets an AX attribute of type boolean
-- @function [parent=#uielement] setBool
-- @param #uielement self
-- @param #string attr attribute name
-- @param #boolean value
-- @return #boolean `true` on success
function elem:setBool(attr,value) return self:setInt(attr,value and 1 or 0) end
--elem.setBooleanProp=function(self,v)setProp(self,v and 1 or 0) end
---Sets an AX attribute of type string
-- @function [parent=#uielement] setString
-- @param #uielement self
-- @param #string attr attribute name
-- @param #string value
-- @return #boolean `true` on success
function elem:setString(attr,value) return setAttr(self,attr,cf.makeString(value)) end
--elem.setString=elem.setInteger
---Sets an AX attribute of type array
-- @function [parent=#uielement] setArray
-- @param #uielement self
-- @param #string attr attribute name
-- @param #list value
-- @return #boolean `true` on success

--elem.setArray=elem.setInteger

local point,size=require'hm.types.geometry'.point,require'hm.types.geometry'.size
---Returns an AX attribute of type point
-- @function [parent=#uielement] getPoint
-- @param #uielement self
-- @param #string attr attribute name
-- @return hm.types.geometry#point
function elem:getPoint(prop) local p=getStructAttr(self,prop,'CGPoint') return point(p.x,p.y) end
---Returns an AX attribute of type size
-- @function [parent=#uielement] getSize
-- @param #uielement self
-- @param #string attr attribute name
-- @return hm.types.geometry#size
function elem:getSize(prop) local s=getStructAttr(self,prop,'CGSize') return size(s.width,s.height) end

--local NSMakePoint,NSMakeSize=C.NSMakePoint,c.NSMakeSize
c.cdef'NSMakePoint' c.cdef'NSMakeSize'
---Sets an AX attribute of type point
-- @function [parent=#uielement] setPoint
-- @param #uielement self
-- @param #string attr attribute name
-- @param hm.types.geometry#point value
-- @return #boolean `true` on success
function elem:setPoint(prop,value) return setAttr(self,prop,C.NSMakePoint(value.x,value.y)) end
---Sets an AX attribute of type size
-- @function [parent=#uielement] setSize
-- @param #uielement self
-- @param #string attr attribute name
-- @param hm.types.geometry#size value
-- @return #boolean `true` on success
function elem:setSize(prop,value) return setAttr(self,prop,C.NSMakeSize(value.w,value.h)) end

---The element's title
-- @field [parent=#uielement] #string title
-- @readonlyproperty
property(elem,'title',function(self) return self:getString('title','') end,false)
---The element's `AXRole`
-- @field [parent=#uielement] #string role
-- @readonlyproperty
property(elem,'role',function(self) return self._role or self:getString('role') end)
---The element's `AXSubrole`
-- @field [parent=#uielement] #string subrole
-- @readonlyproperty
property(elem,'subrole',function(self) return self:getString('subrole') end,false)
---The element's selected text
-- @field [parent=#uielement] #string selectedText
-- @readonlyproperty
property(elem,'selectedText',function(self) return self:getString('selectedText') end,false)
---The element's top left corner
-- @field [parent=#uielement] hm.types.geometry#point topLeft
-- @property
property(elem,'topleft',
  function(self) return self:getPoint'position' end,
  function(self,v) self:setPoint('position',v) end,'hm.types.geometry#point')
---The element's size
-- @field [parent=#uielement] hm.types.geometry#size size
-- @property
property(elem,'size',
  function(self) return self:getSize'size' end,
  function(self,v) self:setSize('size',v) end,'hm.types.geometry#size')


local cachedElements=hm._core.cacheValues()
--local CFHash=c.CFHash
c.cdef'AXUIElementGetPid'
--local AXUIElementGetPid=c.AXUIElementGetPid
local function newElem(ax,pid,o)
  local hash=nptr(C.CFHash(ax))
  if cachedElements[hash] then return cachedElements[hash] end
  if not pid then
    local result=C.AXUIElementGetPid(ax,id_out)
    pid=result==0 and id_out[0] or error'cannot get pid from axuielement'
  end
  o=o or {} o[1]=ax o._pid=pid o._ref=hash
  o=new(o)
  log.v('cached hash',hash) cachedElements[hash]=o
  return o
end

---@function [parent=#hm._os.uielements] newElement
-- @param #cdata ax `AXUIElementRef`
-- @param #number pid (optional)
-- @return #uielement
uielements.newElement=newElem

c.cdef'AXUIElementCreateApplication'
---@function [parent=#hm._os.uielements] newElementForApplication
-- @param #number pid
-- @return #uielement
function uielements.newElementForApplication(pid)
  return newElem(C.AXUIElementCreateApplication(pid),pid,{_role='AXApplication'})
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
