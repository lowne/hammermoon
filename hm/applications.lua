---Run, stop, query and manage applications.
-- @module hm.applications
-- @static

local c=require'objc'
c.load'CoreFoundation'
c.load'CoreServices.LaunchServices'
-- CFStringRef to NSString, return value CFArrayRef to NSArray
c.addfunction('LSCopyApplicationURLsForBundleIdentifier',{retval='@"NSArray"','@"NSString"','^^v'},false)
c.addfunction('LSCopyApplicationURLsForURL',{retval='@"NSArray"','@"NSURL"','I'},false)

local tolua,toobj,nptr=c.tolua,c.toobj,c.nptr
local ffi=require'ffi'
local cast=ffi.cast

local pairs,ipairs,next,setmetatable=pairs,ipairs,next,setmetatable
local sformat=string.format
local tinsert,tremove=table.insert,table.remove
local coll=require'hm.types.coll'
local list=coll.list
local property=hm._core.property
local hmtype=hm.type

---@type hm.applications
-- @extends hm#module
local applications=hm._core.module('applications',{application={
  __tostring=function(self) return sformat('application: [pid:%d] %s',self._pid,self._name or '<?>') end,
  __gc=function(self) end,
  __eq=function(a1,a2) return hmtype(a2)=='hm.applications#application' and a1._ax==a2._ax end,
},appBundle={
  __tostring=function(self) return sformat('appBundle: %s (%s)',self._bundlename,self._bundledir) end,
  __gc=function(self) end,
  __eq=function(b1,b2) return hmtype(b2)=='hm.applications#appBundle' and b1._path==b2._path end,
}})
local log=applications.log


---Type for running application objects.
-- @type application
-- @extends hm#module.object
-- @class
local app=applications._classes.application

local cachedApps=hm._core.cacheValues()
local function clearCache(_,info,pid)
  pid=pid or tolua(info:objectForKey'NSApplicationProcessIdentifier')
  if not pid then log.e('Process terminated, but no pid in notification!')
  else
    if cachedApps[pid] then log.d('Cleared cache for pid',pid) cachedApps[pid]=nil
    else log.v('process terminated, but pid was not cached:',pid) end
  end
end

local NSRunningApplication=c.NSRunningApplication
local AXUIElementCreateApplication=c.AXUIElementCreateApplication
local newElement=require'hm._os.uielements'._newElement
local function newApp(nsapp,pid,info)
  if not nsapp then
    if not pid then return nil
    elseif cachedApps[pid] then return cachedApps[pid] end
    nsapp=NSRunningApplication:runningApplicationWithProcessIdentifier(pid)
    if not nsapp then cachedApps[pid]=nil return nil end
  elseif not pid then pid=nsapp.processIdentifier end
  assert(pid or nsapp)-- and applications[nsapp.processIdentifier])
  local o=cachedApps[pid]
  if o then return o end
  o=pid==-1 and {} or {_ax=newElement(AXUIElementCreateApplication(pid),pid,{role='AXApplication'}),_pid=pid}
  o._name=tolua(nsapp.localizedName or (info and info:objectForKey'NSApplicationName'))
  o._bundleid=tolua(nsapp.bundleIdentifier or (info and info:objectForKey'NSApplicationBundleIdentifier'))
  o._nsapp=nsapp
  o=app._new(o)
  if pid~=-1 then cachedApps[pid]=o log.v('cached pid',pid) end
  return o
end

local function getAppFromNotif(info)
  local pid=tolua(info:objectForKey'NSApplicationProcessIdentifier')
  if pid and cachedApps[pid] then return cachedApps[pid] end
  local nsapp=info:objectForKey'NSWorkspaceApplicationKey'
  return newApp(nsapp,pid,info)
end

-- Accessibility attributes:
--NSAccessibilityFocusedUIElementAttribute    --TODO
--NSAccessibilityFocusedWindowAttribute       focusedWindow
--NSAccessibilityFrontmostAttribute           active
--NSAccessibilityHiddenAttribute              hidden
--NSAccessibilityMainWindowAttribute          mainWindow
--NSAccessibilityWindowsAttribute             allWindows
--NSAccessibilityMenuBarAttribute             --TODO
--NSAccessibilityExtrasMenuBarAttribute

--NSRunningApplication attributes:
--active                    (using AX)
--activationPolicy          kind
--hidden                    (using AX)
--localizedName             (constructor)
--icon                      --TODO
--bundleIdentifier          (constructor)
--bundleURL
--executableArchitecture
--executableURL
--launchDate                --TODO
--finishedLaunching
--processIdentifier         (constructor)
--ownsMenuBar               ownsMenuBar
--terminated                running

---The application process identifier.
-- @field [parent=#application] #number pid
-- @readonlyproperty
property(app,'pid',function(self)return self._pid end)

---The application bundle identifier.
-- @field [parent=#application] #string bundleID
-- @readonlyproperty
property(app,'bundleID',function(self)return self._bundleid end)

---The application name.
-- @field [parent=#application] #string name
-- @readonlyproperty
property(app,'name',function(self)return self._name end)

---The application bundle's path.
-- @field [parent=#application] #string path
-- @readonlyproperty
property(app,'path',function(self)return applications.pathForBundleID(self._bundleid)end)

---Whether this application currently owns the menu bar.
-- @field [parent=#application] #boolean ownsMenuBar
-- @readonlyproperty
property(app,'ownsMenuBar',
  function(self) return self._ax:getBooleanProp(c.NSAccessibilityFrontmostAttribute) end,false)

---A string describing an application's kind.
-- Valid values are:
-- * `"standard"`: the application has a main window, a menu bar, and (usually) appears in the Dock
-- * `"accessory"`: the application has a transient user interface (for example a menulet)
-- * `"background"`: the application does not have any user interface (for example daemons and helpers)
-- @type applicationKind
-- @extends #string
local KIND={
  [c.NSApplicationActivationPolicyRegular]='standard',
  [c.NSApplicationActivationPolicyAccessory]='accessory',
  [c.NSApplicationActivationPolicyProhibited]='prohibited',
}

---The application's kind.
-- @field [parent=#application] #applicationKind kind
-- @readonlyproperty
property(app,'kind',function(self) return KIND[self._nsapp.activationPolicy] end)


---Quits the application.
-- @function [parent=#application] quit
-- @param #application self
-- @return #application self
function app:quit()
  if self._nsapp.terminated then return self end
  self._nsapp:terminate() clearCache(nil,nil,self._pid)
  return self
end
---Force quits the application.
-- @function [parent=#application] forceQuit
-- @param #application self
-- @param #number gracePeriod (optional) number of seconds to wait for the app to quit normally before forcequitting;
-- pass `0` to force quit immediately. If omitted defaults to `10`.
-- @return #application self
function app:forceQuit(gracePeriod)
  if self._nsapp.terminated then return self end
  self._nsapp:terminate()
  require'hm.timer'.new(function()
    if not self._nsapp.terminated then self._nsapp:forceTerminate() end
    clearCache(nil,nil,self._pid)
  end):runIn(gracePeriod or 10)
  return self
end

---Whether the application is currently running.
-- This property can be set to `false` to terminate the application.
-- @field [parent=#application] #boolean running
-- @property
property(app,'running',function(self)
  if self._nsapp.terminated then return clearCache(nil,nil,self._pid) or false
  else return true end
end,app.quit,'false')

---Whether the application is currently hidden.
-- @field [parent=#application] #boolean hidden
-- @property
property(app,'hidden',
  function(self)return self._ax:getBooleanProp(c.NSAccessibilityHiddenAttribute) end,
  function(self,v)
    if not self.running then return log.e(self,'is not running, cannot hide') end
    return self._ax:setBooleanProp(c.NSAccessibilityHiddenAttribute,v)
  end,'boolean')
---Hides the application.
-- @function [parent=#application] hide
-- @param #application self
-- @return #application self
function app:hide()self.hidden=true return self end
---Unhides the application.
-- @function [parent=#application] unhide
-- @param #application self
-- @return #application self
function app:unhide()self.hidden=false return self end

---Whether this is the active application.
-- The active application is the one currently receiving input events.
-- @field [parent=#application] #boolean active
-- @property
property(app,'active',
  function(self) return self._ax:getBooleanProp(c.NSAccessibilityFrontmostAttribute) end,
  function(self,v) --FIXME
    if not self.running then return log.e(self,'is not running, cannot activate') end
    return self._ax:setBooleanProp(c.NSAccessibilityFrontmostAttribute,v)
  end,'boolean')

---Makes this the active application.
-- @function [parent=#application] activate
-- @param #application self
-- @return #application self
function app:activate()
  self._nsapp:activateWithOptions(c.NSApplicationActivateIgnoringOtherApps(0))
  return self
end
---Activates this application and puts all its windows on top of other windows.
-- @function [parent=#application] bringToFront
-- @param #application self
-- @return #application self
function app:bringToFront()
  self._nsapp:activateWithOptions(c.NSApplicationActivateIgnoringOtherApps(c.NSApplicationActivateAllWindows))
  return self
end
package.loaded['hm.applications']=applications
local newWindow=require'hm.windows'._newWindow

---The application's main window.
-- @field [parent=#application] hm.windows#window mainWindow
-- @property
property(app,'mainWindow',
  function(self)return newWindow(self._ax:getRawProp(c.NSAccessibilityMainWindowAttribute),self._pid) end,
  function(self,win)
    if win.application~=self then return log.e(win,'belongs to another application, cannot set as main window for',self) end
    self._ax:setRawProp(c.NSAccessibilityMainWindowAttribute,win)
  end,'hm.windows#window')

property(app,'focusedWindow',
  function(self)return newWindow(self._ax:getRawProp(c.NSAccessibilityFocusedWindowAttribute),self._pid)end,
  function(self,win)
    if win.application~=self then return log.e(win,'belongs to another application, cannot set as focused window for',self) end
    self._ax:setRawProp(c.NSAccessibilityMainWindowAttribute,win)
  end,'hm.windows#window')

---@type windowList
-- @list <hm.windows#window>

local axref=ffi.typeof'AXUIElementRef'
---The application's windows.
-- @field [parent=#application] #windowList windows
-- @readonlyproperty
property(app,'windows',function(self)
  local r=list()
  for i,axwin in ipairs(self._ax:getArrayProp(c.NSAccessibilityWindowsAttribute)) do
    tinsert(r,newWindow(cast(axref,axwin),self._pid))
  end
  return r
end,false)
---The application's visible windows (not minimized).
-- When the application is hidden this property is an empty list.
-- @field [parent=#application] #windowList visibleWindows
-- @readonlyproperty
property(app,'visibleWindows',function(self)
  return self.hidden and list() or self.windows:ifilter(function(win)return not win.minimized end)
end,false)


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

local workspace=require'hm._os'.sharedWorkspace

---The active application.
-- This is the application that currently receives input events.
-- @field [parent=#hm.applications] #application activeApplication
-- @property
property(applications,'activeApplication',
  function() return newApp(workspace.frontmostApplication) end,
  function(app)
    if not app.running then return log.e(app,'is not running, cannot activate')
    elseif app.kind=='background' then return log.e(app,' has no GUI, cannot activate') end
    app.active=true
  end,'hm.applications#application')

---The application owning the menu bar.
-- Note that this is not necessarily the same as @{activeApplication}.
-- @field [parent=#hm.applications] #application menuBarOwningApplication
-- @property
property(applications,'menuBarOwningApplication',
  function() return newApp(workspace.menuBarOwningApplication) end,
  function(app)
    if not app.running then return log.e(app,'is not running, cannot activate')
    elseif app.kind~='standard' then return log.e(app,' cannot own the menu bar') end
    app.active=true
  end,'hm.applications#application')

---@type applicationList
-- @list <#application>

local NSApplicationActivationPolicyProhibited=c.NSApplicationActivationPolicyProhibited
---The currently running GUI applications.
-- This list only includes applications of @{<#applicationKind>} `"standard"` and `"accessory"`.
-- @field [parent=#hm.applications] #applicationList runningApplications
-- @readonlyproperty
property(applications,'runningApplications',function()
  local r,nsapps=list(),tolua(workspace:runningApplications())
  for _,nsapp in ipairs(nsapps) do
    if nsapp.activationPolicy~=NSApplicationActivationPolicyProhibited then r[#r+1]=newApp(nsapp) end
  end
  return r
end,false)

---The currently running background applications.
-- This list only includes applications of @{<#applicationKind>} `"background"`.
-- @field [parent=#hm.applications] #applicationList runningBackgroundApplications
-- @readonlyproperty
property(applications,'runningBackgroundApplications',function()
  local r,nsapps=list(),tolua(workspace:runningApplications())
  for _,nsapp in ipairs(nsapps) do
    if nsapp.activationPolicy==NSApplicationActivationPolicyProhibited then r[#r+1]=newApp(nsapp) end
  end
  return r
end,false)

function applications.applicationsForBundleID(bid)
  local apps=tolua(c.NSRunningApplication:runningApplicationsWithBundleIdentifier(bid))
  for i,nsapp in ipairs(apps) do apps[i]=newApp(nsapp) end
  return apps
end
function applications.launchOrFocus(name) return workspace:launchApplication(name) end
function applications.launchOrFocusByBundleID(bid)
  --  return workspace:launchAppWithBundleIdentifier_options_additionalEventParamDescriptor_launchIdentifier(bid,c.NSWorkspaceLaunchDefault,nil,nil)
  return workspace:launchAppWithBundleIdentifier(bid,c.NSWorkspaceLaunchDefault,nil,nil)
end
function applications.pathForBundleID(bid) return workspace:absolutePathForAppBundleWithIdentifier(bid) end
function applications.nameForBundleID(bid)
  local path=applications.pathForBundleID(bid)
  local bundle=path and c.NSBundle:bundleWithPath(path)
  local info=bundle and bundle.infoDictionary
  return info and tolua(info:objectForKey'CFBundleName') or nil
end

--- watcher

applications.watcher={launching=0,launched=1,terminated=2,hidden=3,unhidden=4,activated=5,deactivated=6}
local watcher={}
applications.watcher._object=watcher

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


function applications.watcher.new(cb)
  return setmetatable({_isRunning=false,_cb=cb},{__index=watcher,__tostring=watcher.tostring})
end
function watcher:tostring() return sformat('hs.application.watcher: %s',self._cb) end
function watcher:isRunning() return self._isRunning end
function watcher:start()
  self._isRunning=true
  if not next(runningWatchers) then
    for event in pairs(NStoHSnotifications) do
      hm._os.wsNotificationCenter:register(event,workspaceObserverCallback)
    end
    hm._os.wsNotificationCenter:register('NSWorkspaceDidTerminateApplicationNotification',clearCache)
  end
  runningWatchers[self]=true -- retain ref to avoid gc
  return self
end
function watcher:stop()
  self._isRunning=false
  runningWatchers[self]=nil -- can be gc'ed now
end




---Type for application bundle objects.
-- @type appBundle
-- @extends hm#module.object
-- @apichange Clear distinction between running applications and app bundles on disk.
local bundle=applications._classes.appBundle

local function newBundle(path)
  return bundle._new{_path=path}
end
local function bundleFromNSUrl(nsurl) return newBundle(tolua(nsurl.path)) end

property(bundle,'_bundledir',function(self) return self._path:match('(.+)/[^/]+')end)
property(bundle,'_bundlename',function(self) return self._path:match('.+/([^/]+)')end)



-- @apichange returns all bundles for a given bundle id
function applications.bundlesForBundleID(bid) checkargs'string'
  return list(tolua(c.LSCopyApplicationURLsForBundleIdentifier(toobj(bid),nil))):imap(bundleFromNSUrl)
end

function applications.bundlesForURLScheme(url)
  local r=list()
  for i,nsurl in ipairs(tolua(c.LSCopyApplicationRULsForURL(url,nil))) do
    r:append(newBundle(tolua(nsurl.path)))
  end
end

function applications._hmdestroy()
  for w in pairs(runningWatchers) do w:stop() end
end



return applications

