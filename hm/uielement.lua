------ OBJC -------
local c=require'objc'
local tolua,toobj,nptr=function(o) return o~=nil and c.tolua(o) or nil end,c.toobj,c.nptr
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

c.addfunction('CFHash',{retval='Q','^v'})
--[[
<function name='AXObserverCreate'>
<arg type='i'/>
<arg function_pointer='true' type='^?'>
<arg type='^{__AXObserver=}'/>
<arg type='^{__AXUIElement=}'/>
<arg type='^{__CFString=}'/>
<arg type='^v'/>
<retval type='v'/>
</arg>
<arg type='^^{__AXObserver}'/>
<retval type='l' type64='i'/>
</function>
--]]
local CFHash=c.CFHash
local NSString,NSNumber,NSArray=c.NSString,c.NSNumber,c.NSArray
local NSMakePoint,NSMakeSize=c.NSMakePoint,c.NSMakeSize
local AXGetAttribute,AXGetValue,AXSetAttribute=c.AXUIElementCopyAttributeValue,c.AXValueGetValue,c.AXUIElementSetAttributeValue
local AXGetPid=c.AXUIElementGetPid
local AXCreateObserver,AXAddNotification=c.AXObserverCreate,c.AXObserverAddNotification
local AXGetObserverRL=c.AXObserverGetRunLoopSource
--local RLAddSource,RLRemoveSource=c.CFRunLoopAddSource,c.CFRunLoopRemoveSource
--local RLDefaultMode=c.kCFRunLoopDefaultMode
--local currentRL=c.CFRunLoopGetCurrent()
local runLoopAddSource=hm._os.runLoopAddSource
local runLoopRemoveSource=hm._os.runLoopRemoveSource

local ffi=require'ffi'
local cast=ffi.cast

----- locals -----
--local hmobject=hm._core.hmobject
--local log=hm.logger.new'uielement',5
local point,size=hm.geometry.point,hm.geometry.size

local next,pairs,ipairs,setmetatable=next,pairs,ipairs,setmetatable
--local newproxy=newproxy
local sformat=string.format
local tinsert,tremove=table.insert,table.remove


----- module -----
local uielement=hm._core.module('uielement',{
  __tostring=function(self)return sformat('uielement: <%s>',self._ax) end,
  __gc=function(self) end, --TODO
  __eq=function(e1,e2) return e2._ax and c.CFEqual(e1._ax,e2._ax) end,
})
local elem,new=uielement._class,uielement._class._new
local log=uielement.log
--
--local elem=setmetatable({},{__tostring=function()return'<uielement>'end}) -- object
--local uielement={log=log,_object=elem} -- module
package.loaded['hm.uielement']=uielement

local value_out=ffi.new'int[1]'
local function getPid(axelem)
  local result=AXGetPid(axelem,value_out)
  return result==0 and value_out[0] or error'cannot get pid from axuielement'
end
function elem:pid() if not self._pid then self._pid=getPid(self._ax) end return self._pid end

local prop_out=ffi.new'CFTypeRef[1]'
local function getProp(self,prop)
  --  local result=AXGetAttribute(self._ax,NSString:stringWithUTF8String(prop),prop_out) -- patch renders this unnecessary
  local result=AXGetAttribute(self._ax,prop,prop_out)
  --TODO do something smarter with errors
  --  return result==0 and prop_out[0] or error(sformat('Accessibility error: getting attribute "%s" for <%s> returned "%s"',tolua(prop),self,require'bridge'.axerror[result]))
  return result==0 and prop_out[0] or log.wf('%s: %s <= %s',require'bridge.axerror'[result],tolua(prop),self)
end

local valueTypes={CGPoint=1,CGSize=2,CGRect=3,CFRange=4}
local valueCast={}
for k in pairs(valueTypes) do valueCast[k]=ffi.typeof(k..' *') end
--local valueCast={CGPoint='CGPoint *',CGSize='CGSize *',CGRect='CGRect *',CFRange='CFRange *'}
function elem:_getValueProp(prop,cls)
  --  local cast=ffi.cast('AXValueRef',f) -- patch renders this unnecessary
  local res=AXGetValue(getProp(self,prop),valueTypes[cls],value_out)
  --TODO proper errors
  if not res then error'value error' end
  return cast(valueCast[cls],value_out) -- cast to appropriate struct (which is bridged by objc.lua)
end
--typedef enum {kAXValueCGPointType = 1,kAXValueCGSizeType = 2,kAXValueCGRectType = 3,kAXValueCFRangeType = 4,
--   kAXValueAXErrorType = 5,kAXValueIllegalType = 0} AXValueType;
function elem:_getPointProp(prop) local p=self:_getValueProp(prop,'CGPoint') return point(p.x,p.y) end
function elem:_getSizeProp(prop) local s=self:_getValueProp(prop,'CGSize') return size(s.width,s.height) end
elem._getObjProp=getProp
function elem:_getProp(prop,cls,sel)
  local v=getProp(self,prop)
  return v and tolua(cls[sel](cls, v))-- quite a lousy way to cast the result, but afaict it doesn't allocate
end
function elem:_hasProp(prop) return AXGetAttribute(self._ax,prop,prop_out)==0 end
function elem:_getIntegerProp(prop) return self:_getProp(prop,NSNumber,'numberWithInteger') or 0 end
function elem:_getBooleanProp(prop) return self:_getIntegerProp(prop)==1 end
function elem:_getStringProp(prop) return self:_getProp(prop,NSString,'stringWithString') or '' end
function elem:_getArrayProp(prop) return self:_getProp(prop,NSArray,'arrayWithArray') or {} end
function elem:_setProp(prop,v)
  local result=AXSetAttribute(self._ax,prop,v)
  return result==0 and true or log.wf('%s: %s => %s',require'bridge.axerror'[result],tolua(prop),self)
end
function elem:_setPointProp(prop,p) return self:_setProp(prop,NSMakePoint(p.x,p.y)) end
function elem:_setSizeProp(prop,s) return self:_setProp(prop,NSMakeSize(s.w,s.h)) end
function elem:title() return self:_hasProp(c.NSAccessibilityTitleAttribute) and self:_getStringProp(c.NSAccessibilityTitleAttribute) or '' end
function elem:role() return self._role or self:_getStringProp(c.NSAccessibilityRoleAttribute) end
function elem:subrole() return self:_getStringProp(c.NSAccessibilitySubroleAttribute) end
function elem:selectedText() return self:_getStringProp(c.NSAccessibilityRoleSelectedTextAttribute) end
function elem:isApplication() return self:role()=='AXApplication' end
local function isWindow(role,self)
  return role=='AXWindow' or elem._hasProp(self,c.NSAccessibilityMinimizedAttribute)
end
function elem:isWindow() return isWindow(self:role(),self) end

function elem:topLeft() return self:_getPointProp(c.NSAccessibilityPositionAttribute) end
function elem:size() return self:_getSizeProp(c.NSAccessibilitySizeAttribute) end

local newWin,newApp=hm.window._newWindow,hm.application._newApplication

local elements=hm._core.cacheValues()
--local cfptr_t=ffi.typeof('void*')
local function newElem(axelem,pid)
  --  local hash=nptr(CFHash(cast(cfptr_t,axelem)))
  local hash=nptr(CFHash(axelem))
  if elements[hash] then return elements[hash] end
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
  elements[hash]=o
  return o
    --  return setmetatable({_ax=axelem,_pid=pid},{__index=ui,__tostring=ui.tostring})
end
uielement._newElement=newElem
--[[
local ptr_t=ffi.typeof'void*'
local elements=setmetatable({},{__mode='kv'})

local function newElement(axelem,pid)
  --  local ref=nptr(cast(ptr_t,axelem)[0])
  local ref=nptr(cast(ptr_t,axelem))
  print('requesting newelment',axelem,ref,cast(ptr_t,axelem)[0])
  --  local ref=nptr(axelem)
  local ret=elements[ref]
  ret=nil
  if not ret then
    log.d('Creating new uielement',ref)
    if not pid then --TODO
      local result=AXGetPid(axelem,value_out)
      pid=result==0 and value_out[0] or error'cannot get pid from axuielement'
    end
    ret=setmetatable({_ax=axelem,_pid=pid,_ref=ref},{__index=ui,__tostring=ui.tostring})
    elements[ref]=ret
  else print'was cached!'
  end
  return ret
end
--]]
--function elem:__tostring()return sformat('hm.uielement: <%s>',self._ax) end
--function elem:__gc()end --TODO
--function elem:__eq(e2) return e2._ax and c.CFEqual(self._ax,e2._ax) end

----- AX watchers -----
local logw=hm.logger.new('uielement.watcher')
local elementDestroyed = "AXUIElementDestroyed"
local events={
  applicationActivated   = "AXApplicationActivated",
  applicationDeactivated = "AXApplicationDeactivated",
  applicationHidden      = "AXApplicationHidden",
  applicationShown       = "AXApplicationShown",

  mainWindowChanged     = "AXMainWindowChanged",
  focusedWindowChanged  = "AXFocusedWindowChanged",
  focusedElementChanged = "AXFocusedUIElementChanged",

  windowCreated     = "AXWindowCreated",
  windowMoved       = "AXWindowMoved",
  windowResized     = "AXWindowResized",
  windowMinimized   = "AXWindowMiniaturized",
  windowUnminimized = "AXWindowDeminiaturized",

  elementDestroyed = elementDestroyed,
  titleChanged     = "AXTitleChanged",
  log=logw,
}
uielement.watcher=events --submodule
local watcher=setmetatable({},{__tostring=function()return'<uielement.watcher>'end}) --object
uielement.watcher._object=watcher

local runningWatchers={}
local function stopChildrenWatchers(_,info)
  local pid=tolua(info:objectForKey'NSApplicationProcessIdentifier')
  if not pid then logw.e('Process terminated, but no pid in notification!')
  else
    if runningWatchers[pid] then
      logw.d('Stopping watchers for pid:',pid)
      for w in pairs(runningWatchers[pid]) do w:stop() end
      --      runningWatchers[pid]=nil
    else logw.v('Process terminated with no watchers:',pid) end
  end
end

local watchers=setmetatable({},{__mode='kv'})
local watcherCount=0
function elem:newWatcher(cb,data)
  logw.v('Creating watcher for',self)
  watcherCount=watcherCount+1
  local ret=hmobject({_elem=self,_pid=self._pid,_isRunning=false,_cb=cb,_data=data,_ref=watcherCount},watcher)
  watchers[watcherCount]=ret
  logw.d('Created watcher',self)
  return ret
end
function watcher:__tostring() return sformat('hm.uielement.watcher: #%d [pid:%d] %s',self._ref,self._pid,self._elem:role()) end
function watcher:__gc() end --TODO

local globalWatcher --flag for 1st registration
local function observerCallback(obs,axelem,notificationName,ref)
  local watcher=watchers[ref]
  assert(watcher,'event with wrong ref')
  if not watcher._isRunning then logw.e'event on stopped watcher' return end
  local event=tolua(notificationName)
  assert(watcher._events[event],'event on uninterested watcher')
  logw.v(watcher,'received event',event,'- running callback')
  local elem=newElem(axelem,watcher._pid)
  if event==elementDestroyed then
    if watcher._watchingDestroyed then
      watcher._cb(newElem(axelem),event,watcher,watcher._data)
    end
    watcher:stop()
  else return watcher._cb(newElem(axelem),event,watcher,watcher._data) end
end
--local runLoopMode=fficast('struct __CFString *',c.kCFRunLoopDefaultMode)
local obs_t=ffi.typeof'AXObserverRef[1]'
local observers={}--setmetatable({},{__mode='kv'})
function watcher:start(events)
  if not globalWatcher then
    hm._os.wsNotificationCenter:register('NSWorkspaceDidTerminateApplicationNotification',stopChildrenWatchers,true)
    globalWatcher=true
  elseif self._isRunning then logw.w(self,'is already running') return self end
  self._isRunning=true
  local pid=self._pid
  local observer
  if not runningWatchers[pid] then
    logw.d('Creating observer for pid',pid)
    runningWatchers[pid]={}
    local obs_p=obs_t()
    local res=AXCreateObserver(pid,observerCallback,obs_p)
    if res~=0 then error'axobservercreate' end
    observer=obs_p[0]
    runLoopAddSource(AXGetObserverRL(observer))
    observers[pid]=observer
  else
    observer=observers[pid]
  end
  --  self._observer=observer
  runningWatchers[pid][self]=true
  local evs={}
  for _,ev in ipairs(events) do
    if ev==elementDestroyed then self._watchingDestroyed=true end
    evs[ev]=true
  end
  evs[elementDestroyed]=true
  for ev in pairs(evs) do
    local result=AXAddNotification(observer,self._elem._ax,toobj(ev),self._ref)
    if not result then error'AX add notification' end
    logw.v(self,'listening for',ev)
  end
  self._events=evs

  --[[
  local obs_p=obs_t()
  local res=AXCreateObserver(pid,observerCallback,obs_p)
  if res~=0 then error'axobservercreate' end
  local obs=obs_p[0]
  self._observer=obs self._obsrl=AXGetObserverRL(obs)
  for _,ev in ipairs(events) do
    local result=AXAddNotification(obs,self._elem._ax,toobj(ev),self._ref)
    if not result then error'AX add notification' end
    log.v(self,'listening for',ev)
  end
  --  c.CFRunLoopAddSource(c.CFRunLoopGetCurrent(), c.AXObserverGetRunLoopSource(obs[0]), runLoopMode);
  RLAddSource(currentRL, self._obsrl, RLDefaultMode);
  --]]
  log.d(self,'started')
  return self
end

function watcher:stop()
  if not self._isRunning then return self end
  self._isRunning=false
  self._watchingDestroyed=nil
  --  RLRemoveSource(currentRL,self._obsrl,RLDefaultMode)
  --  self._obsrl=nil self._observer=nil
  local pid=self._pid
  assert(runningWatchers[pid])
  runningWatchers[pid][self]=nil
  log.d(self,'stopped')
  if not next(runningWatchers[pid]) then
    log.d('Last watcher stopped, removing observer for pid',pid)
    runningWatchers[pid]=nil
    runLoopRemoveSource(AXGetObserverRL(observers[pid]))
    observers[pid]=nil
  end
  return self
end

function uielement._hmdestroy()
  for pid,watchers in pairs(runningWatchers) do
    for watcher in pairs(watchers) do watcher:stop() end
  end
end
return uielement
