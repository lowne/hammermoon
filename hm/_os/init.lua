---Low level access to macOS
-- @module hm._os
-- @static
-- @dev

local c=require'objc'
c.load'AppKit'
c.load'CoreFoundation'
-- these wants (3rd arg) a CFString, but kCFRunLoopDefaultMode is defined as const CFString - hence the 'r' in the patch
c.addfunction('CFRunLoopAddSource',{retval='v','^{__CFRunLoop=}','^{__CFRunLoopSource=}','r^{__CFString=}'})
c.addfunction('CFRunLoopRemoveSource',{retval='v','^{__CFRunLoop=}','^{__CFRunLoopSource=}','r^{__CFString=}'})
--release for all! \o/
c.addfunction('CFRelease',{'^v'},false)
c.addfunction('CFHash',{retval='Q','^v'})

local tolua=c.tolua
local rawset,rawget,pairs,tinsert=rawset,rawget,pairs,table.insert


---@type hm._os
-- @extends hm#module
local os=hm._core.module('_os',nil,{'events'})

--- @field [parent=#hm._os] hm._os.events#hm._os.events events

local log=os.log

---@type notificationCenter
--@class
local function makeNCwrapper(nc)
  local callbacks={} --store in a closure for the block
  local ipairs=ipairs
  return {
    _nc=nc,_events={},_callbacks=callbacks,_observers={},
    _block=c.block(function(notif)
      local event,info=tolua(notif.name),notif.userInfo
      for _,cb in ipairs(callbacks[event]) do cb(event,info) end
    end,'v@'),
    ---@function [parent=#notificationCenter] register
    --@param #notificationCenter self
    --@param #string event
    --@param #function cb
    --@param #boolean priority
    --@dev
    --@internalchange Centralized callback registry for notification centers, to be used by extensions.
    register=function(self,event,cb,priority)
      assert(type(event)=='string')
      if not self._events[event] then
        log.d('Adding observer for notification',event)
        tinsert(self._observers,(assert(self._nc:addObserverForName_object_queue_usingBlock(event,nil,nil,self._block),'cannot add observer')))
        self._events[event]=true
        self._callbacks[event]={}
      end
      log.v('Registering callback for notification',event)
      if priority then tinsert(self._callbacks[event],1,cb)
      else tinsert(self._callbacks[event],cb) end
    end
  }
end

local props={
  ---`AXUIElementCreateSystemWide()` instance
  --@field [parent=#hm._os] #cdata systemWideAccessibility
  --@internalchange Instance to be used by extensions.
  systemWideAccessibility=c.AXUIElementCreateSystemWide,
  ---The shared `NSWorkspace` instance
  --@field [parent=#hm._os] #cdata sharedWorkspace
  sharedWorkspace=function()return c.NSWorkspace:sharedWorkspace()end,
  ---The shared workspace's Notification Center.
  --@field [parent=#hm._os] #notificationCenter wsNotificationCenter
  wsNotificationCenter=function()return makeNCwrapper(os.sharedWorkspace.notificationCenter)end,
  ---The default Notification Center.
  --@field [parent=#hm._os] #notificationCenter defaultNotificationCenter
  defaultNotificationCenter=function()return makeNCwrapper(c.NSNotificationCenter:defaultCenter())end,
  ---The `CFRunLoop` object for HM's (only) thread.
  --@field [parent=#hm._os] #cdata runLoop
  runLoop=c.CFRunLoopGetCurrent,
}
for k,f in pairs(props) do
  hm._core.property(os,k,function()
    log.i('Retrieving',k)
    local r=assert(f(),'cannot retrieve '..k)
    rawset(os,k,r) return r
  end,false)
end

local rlDefaultMode=c.kCFRunLoopDefaultMode
local rlAddSource=c.CFRunLoopAddSource
function os.runLoopAddSource(src,mode)
  rlAddSource(os.runLoop,src,mode or rlDefaultMode)
end
local rlRemoveSource=c.CFRunLoopRemoveSource
function os.runLoopRemoveSource(src,mode)
  rlRemoveSource(os.runLoop,src,mode or rlDefaultMode)
end

---@private
function os.__gc()
  for _,ncname in pairs{'defaultNotificationCenter','wsNotificationCenter'} do
    local nc=rawget(os,ncname)
    if nc then
      log.i('Removing observers from',ncname)
      for _,obs in pairs(nc._observers) do nc._nc:removeObserver(obs,nil) end
      nc._observers=nil
      --      os[ncname]=nil
    end
  end
end

return os
