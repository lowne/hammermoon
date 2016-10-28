local c=require'objc'
c.load'CoreFoundation'

local tolua,toobj,nptr=c.tolua,c.toobj,c.nptr
--c.load'AppKit'
--c.load'ApplicationServices.framework/Versions/Current/Frameworks/HIServices'
local AXCreateApp=c.AXUIElementCreateApplication
local ffi=require'ffi'
local cast=ffi.cast
--local log=hm.logger.new'application'
local pairs,ipairs,next,setmetatable=pairs,ipairs,next,setmetatable
local sformat=string.format
local tinsert,tremove=table.insert,table.remove
--local hmobject=hm._core.hmobject
local workspace=hm._core.sharedWorkspace

local application=hm._core.module('application',{
  __tostring=function(self) return sformat('hm.application: [pid:%d] %s',self._pid,self._name or '<?>') end,
  __gc=function(self) end, --TODO
})
local app,new=application._class,application._class._new
local log=application.log
--local app=setmetatable({},{__tostring=function()return'<application>'end}) -- object
--local application={log=log,_object=app} -- module

--- object
local applications=setmetatable({},{__mode='v'})
local function clearCache(_,info,pid)
  pid=pid or tolua(info:objectForKey'NSApplicationProcessIdentifier')
  if not pid then log.e('Process terminated, but no pid in notification!')
  else
    if applications[pid] then log.d('Cleared cache for pid',pid) applications[pid]=nil
    else log.v('Process terminated, but pid was not cached:',pid) end
  end
end
local function newApp(nsapp,pid,info)
  if not nsapp then
    if not pid then return nil
    elseif applications[pid] then return applications[pid] end
    nsapp=c.NSRunningApplication:runningApplicationWithProcessIdentifier(pid)
    if not nsapp then applications[pid]=nil return nil end
  elseif not pid then pid=nsapp.processIdentifier end
  assert(pid or nsapp)-- and applications[nsapp.processIdentifier])
  --  pid=pid or nsapp.processIdentifier
  local o=applications[pid]
  --  o=nil
  if o then return o end
  if pid~=-1 then
    o={_ax=AXCreateApp(pid),_pid=pid}
    applications[pid]=o
    log.v('Cached pid',pid)
  else o={} end
  o._name=tolua(nsapp.localizedName or (info and info:objectForKey'NSApplicationName'))
  o._bundleid=tolua(nsapp.bundleIdentifier or (info and info:objectForKey'NSApplicationBundleIdentifier'))
  o._nsapp=nsapp
  --  o=hmobject(o,app)
  o=new(o)
  --  assert(o:role()=='AXApplication')
  o._role='AXApplication'
  return o
end
application._newApplication=newApp

local function getAppFromNotif(info)
  local pid=tolua(info:objectForKey'NSApplicationProcessIdentifier')
  if pid and applications[pid] then return applications[pid] end
  local nsapp=info:objectForKey'NSWorkspaceApplicationKey'
  return newApp(nsapp,pid,info)
end


--function app:__gc()end --TODO
--function app:__tostring() return sformat('hm.application: [pid:%d] %s',self._pid,self._name or '<?>') end
function app:pid() return self._pid end
function app:bundleID() return self._bundleid end
function app:name() return self._name end
function app:path() return application.pathForBundleID(self._bundleid) end
package.loaded['extensions.application']=application
local newWindow=hm.window._newWindow
function app:mainWindow() return newWindow(self:_getObjProp(c.NSAccessibilityMainWindowAttribute),self._pid) end
function app:focusedWindow() return newWindow(self:_getObjProp(c.NSAccessibilityFocusedWindowAttribute),self._pid) end

function app:isHidden() return self:_getBooleanProp(c.NSAccessibilityHiddenAttribute) end
function app:isFrontmost() return self:_getBooleanProp(c.NSAccessibilityFrontmostAttribute) end
function app:kind()
  if not self._kind then
    local policy=self._nsapp.activationPolicy
    if policy==c.NSApplicationActivationPolicyRegular then self._kind=1
    elseif policy==c.NSApplicationActivationPolicyAccessory then self._kind=0
    elseif policy==c.NSApplicationActivationPolicyProhibited then self._kind=-1
    else error('unknown activationPolicy:'..policy) end
  end
  return self._kind
end
local axref=ffi.typeof'AXUIElementRef'
function app:allWindows()
  local r={}
  for i,axwin in ipairs(self:_getArrayProp(c.NSAccessibilityWindowsAttribute)) do
    tinsert(r,newWindow(cast(axref,axwin),self._pid))
  end
  return r
end
function app:visibleWindows()
  if self:isHidden() then return {} end
  local windows=self:allWindows()
  for i=#windows,1,-1 do if windows[i]:isMinimized() then tremove(windows,i) end end
  return windows
end
function app:isRunning()
  if self._nsapp.terminated then
    --  if c.NSRunningApplication:runningApplicationWithProcessIdentifier(self._pid)==nil then
    return clearCache(nil,nil,self._pid) or false
  else return true end
end

function app:activate(allWindows)
  --TODO maybe? seems to be fine as is
  return self._nsapp:activateWithOptions(c.NSApplicationActivateIgnoringOtherApps+(allWindows and c.NSApplicationActivateAllWindows or 0))
end

function app:hide() return self:_setProp(c.NSAccessibilityHiddenAttribute,1) end
function app:unhide() return self:_setProp(c.NSAccessibilityHiddenAttribute,0) end
function app:kill()self._nsapp:terminate()end
function app:kill9()self._nsapp:forceTerminate()end

-- deprecated stuff
--[[ function app:isunresponsive()
  c.addfunction('CGSMainConnectionID',{retval='i'})
  c.addfunction('CGSEventIsAppUnresponsive',{retval='B','i','^i'})
    typedef int CGSConnectionID;
    CG_EXTERN CGSConnectionID CGSMainConnectionID(void);
    bool CGSEventIsAppUnresponsive(CGSConnectionID cid, const ProcessSerialNumber *psn);
    // srsly come on now

    pid_t pid = pid_for_app(L, 1);
    ProcessSerialNumber psn;
    GetProcessForPID(pid, &psn);

    CGSConnectionID conn = CGSMainConnectionID();
    bool is = CGSEventIsAppUnresponsive(conn, &psn);
end
-- similarly for bringtofront
--]]
--- module functions
function application.applicationForPID(pid) return newApp(nil,pid) end
function application.frontmostApplication() return newApp(workspace.frontmostApplication) end

function application.runningApplications()
  local apps=tolua(workspace:runningApplications())
  for i,app in ipairs(apps) do apps[i]=newApp(app) end
  return apps
end

function application.applicationsForBundleID(bid)
  local apps=tolua(c.NSRunningApplication:runningApplicationsWithBundleIdentifier(bid))
  for i,nsapp in ipairs(apps) do apps[i]=newApp(nsapp) end
  return apps
end
function application.launchOrFocus(name) return workspace:launchApplication(name) end
function application.launchOrFocusByBundleID(bid)
  return workspace:launchAppWithBundleIdentifier_options_additionalEventParamDescriptor_launchIdentifier(bid,c.NSWorkspaceLaunchDefault,nil,nil)
end
function application.pathForBundleID(bid) return workspace:absolutePathForAppBundleWithIdentifier(bid) end
function application.nameForBundleID(bid)
  local path=application.pathForBundleID(bid)
  local bundle=path and c.NSBundle:bundleWithPath(path)
  local info=bundle and bundle.infoDictionary
  return info and tolua(info:objectForKey'CFBundleName') or nil
end

--- watcher
application.watcher={launching=0,launched=1,terminated=2,hidden=3,unhidden=4,activated=5,deactivated=6} --module
local watcher={} --object
application.watcher._object=watcher

local NStoHSnotifications={
  NSWorkspaceWillLaunchApplicationNotification=0,
  NSWorkspaceDidLaunchApplicationNotification=1,
  NSWorkspaceDidTerminateApplicationNotification=2,
  NSWorkspaceDidHideApplicationNotification=3,
  NSWorkspaceDidUnhideApplicationNotification=4,
  NSWorkspaceDidActivateApplicationNotification=5,
  NSWorkspaceDidDeactivateApplicationNotification=6,
}
--local watchers=setmetatable({},{__mode='k'})
local runningWatchers={}


local function workspaceObserverCallback(event,info)
  if not next(runningWatchers) then return end
  local eventHSNumber=NStoHSnotifications[event]
  assert(eventHSNumber~=nil)
  --dEBUG
  --  local obj=notif.object
  log.d('received notification',event)
  local userInfo=c.tolua(info)
  for k,v in pairs(userInfo) do log.v(k,':',v) end
  --enddebug
  local hmApp=getAppFromNotif(info)
  for w in pairs(runningWatchers) do
    w._cb(hmApp._name,eventHSNumber,hmApp)
  end
end


function application.watcher.new(cb)
  return setmetatable({_isRunning=false,_cb=cb},{__index=watcher,__tostring=watcher.tostring})
end
function watcher:tostring() return sformat('hs.application.watcher: %s',self._cb) end
function watcher:isRunning() return self._isRunning end
function watcher:start()
  self._isRunning=true
  if not next(runningWatchers) then
    for event in pairs(NStoHSnotifications) do
      hm._core.registerWorkspaceObserver(event,workspaceObserverCallback)
    end
    hm._core.registerWorkspaceObserver('NSWorkspaceDidTerminateApplicationNotification',clearCache)
  end
  runningWatchers[self]=true -- retain ref to avoid gc
  return self
end
function watcher:stop()
  self._isRunning=false
  runningWatchers[self]=nil -- can be gc'ed now
end


function application._hmdestroy()
  for w in pairs(runningWatchers) do w:stop() end
end

getmetatable(app).__index=hm.uielement._class
return application

