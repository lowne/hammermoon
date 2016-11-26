---Run, stop, query and manage applications.
-- @module hm.applications
-- @static
-- @apichange Running applications and app bundles are distinct objects. Edge cases with multiple bundles with the same id are solved.

local c=require'objc'
c.load'CoreFoundation'
c.load'CoreServices.LaunchServices'
c.load'ApplicationServices.HIServices'
-- CFStringRef to NSString, return value CFArrayRef to NSArray
c.addfunction('LSCopyApplicationURLsForBundleIdentifier',{retval='@"NSArray"','@"NSString"','^^v'},false)
c.addfunction('LSCopyApplicationURLsForURL',{retval='@"NSArray"','@"NSURL"','I'},false)
c.addfunction('_LSCopyAllApplicationURLs',{'^^v'})
local tolua,toobj,nptr=c.tolua,c.toobj,c.nptr
local ffi=require'ffi'
local cast=ffi.cast

local pairs,ipairs,next,setmetatable,tonumber=pairs,ipairs,next,setmetatable,tonumber
local sformat,unpack=string.format,unpack
local coll=require'hm.types.coll'
local list,dict=coll.list,coll.dict
local property=hm._core.property
local hmtype=hm.type
local timer=require'hm.timer'
local newTimer=timer.new


---@type hm.applications
-- @extends hm#module
local applications=hm._core.module('hm.applications',{application={
  __tostring=function(self) return sformat('application: [pid:%d] %s',self._pid or -1,self._name or '<?>') end,
  __gc=function(self) end,
  __eq=function(a1,a2) return hmtype(a2)=='hm.applications#application' and a1._pid==a2._pid end,
},bundle={
  __tostring=function(self) return sformat('app bundle: %s (in %s)',self.name,self.folder) end,
  __gc=function(self) end,
  __eq=function(b1,b2) return hmtype(b2)=='hm.applications#bundle' and b1._path==b2._path end,
},watcher={
  __tostring=function(self) return sformat('%s (%s)',self._name,self._isActive) end,
  __gc=function(self) end,
}})
local log=applications.log


---Type for running application objects.
-- @type application
-- @extends hm#module.object
-- @class
-- @checker hm.applications#application
-- @checker application
local app=applications._classes.application
checkers['application']='hm.applications#application'

local cachedApps=hm._core.cacheValues()
local function clearCache(pid) checkargs'uint'
  if cachedApps[pid] then log.d('Cleared cache for pid',pid) cachedApps[pid]=nil
  else log.v('process terminated, but pid was not cached:',pid) end
end

local NSRunningApplication=c.NSRunningApplication
local elemForApp=require'hm._os.uielements'.newElementForApplication
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
  o=pid==-1 and {} or {_ax=elemForApp(pid),_pid=pid}
  o._name=tolua(nsapp.localizedName or (info and info:objectForKey'NSApplicationName'))
  o._bundleid=tolua(nsapp.bundleIdentifier or (info and info:objectForKey'NSApplicationBundleIdentifier'))
  o._launchTime=nsapp.launchDate and nsapp.launchDate.timeIntervalSinceReferenceDate or 0
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

---@return #application
-- @dev
function applications.applicationForPID(pid) checkargs'uint' return newApp(nil,pid) end

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

---The currently running GUI applications.
-- This list only includes applications of @{<#applicationKind>} `"standard"` and `"accessory"`.
-- @field [parent=#hm.applications] #applicationList runningApplications
-- @readonlyproperty
property(applications,'runningApplications',function()
  return list(tolua(workspace:runningApplications()))
    :ifilterByField('activationPolicy',c.NSApplicationActivationPolicyProhibited,'~=')
    :imap(newApp):sortByField('_launchTime',true,true)
  --  local r,nsapps=list(),tolua(workspace:runningApplications())
  --  for _,nsapp in ipairs(nsapps) do
  --    if nsapp.activationPolicy~=NSApplicationActivationPolicyProhibited then r[#r+1]=newApp(nsapp) end
  --  end
  --  return r:sortByField('_launchTime',true,true)
end,false)

---The currently running background applications.
-- This list only includes applications of @{<#applicationKind>} `"background"`.
-- @field [parent=#hm.applications] #applicationList runningBackgroundApplications
-- @readonlyproperty
property(applications,'runningBackgroundApplications',function()
  return list(tolua(workspace:runningApplications()))
    :ifilterByField('activationPolicy',c.NSApplicationActivationPolicyProhibited)
    :imap(newApp):sortByField('_launchTime',true,true)
  --  local r,nsapps=list(),tolua(workspace:runningApplications())
  --  for _,nsapp in ipairs(nsapps) do
  --    if nsapp.activationPolicy==NSApplicationActivationPolicyProhibited then r[#r+1]=newApp(nsapp) end
  --  end
  --  return r:sortByField('_launchTime',true,true)
end,false)

function applications.launchOrFocus(name) return workspace:launchApplication(name) end
function applications.launchOrFocusByBundleID(bid)
  --  return workspace:launchAppWithBundleIdentifier_options_additionalEventParamDescriptor_launchIdentifier(bid,c.NSWorkspaceLaunchDefault,nil,nil)
  return workspace:launchAppWithBundleIdentifier(bid,c.NSWorkspaceLaunchDefault,nil,nil)
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
--active                    active (no longer using AX)
--activationPolicy          kind
--hidden                    hidden (no longer using AX)
--localizedName             (constructor)
--icon                      --TODO
--bundleIdentifier          (constructor)
--bundleURL
--executableArchitecture
--executableURL
--launchDate                (constructor)
--finishedLaunching
--processIdentifier         (constructor)
--ownsMenuBar               ownsMenuBar
--terminated                running

---The application process identifier.
-- @field [parent=#application] #number pid
-- @readonlyproperty
property(app,'pid',function(self)return self._pid end)

---The application bundle identifier.
-- This is a shortcut for `app.bundle.id`.
-- @field [parent=#application] #string bundleID
-- @readonlyproperty
property(app,'bundleID',function(self)return self._bundleid end)

---The absolute time when the application was launched.
-- @field [parent=#application] #number launchTime
-- @readonlyproperty
property(app,'launchTime',function(self)return self._launchTime end)

---The application name.
-- @field [parent=#application] #string name
-- @readonlyproperty
property(app,'name',function(self)return self._name end)

---The application bundle's path.
-- This is a shortcut for `app.bundle.path`.
-- @field [parent=#application] #string path
-- @readonlyproperty
property(app,'path',function(self)return self.bundle.path end)

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
  [c.NSApplicationActivationPolicyProhibited]='background',
}

---The application's kind.
-- @field [parent=#application] #applicationKind kind
-- @readonlyproperty
property(app,'kind',function(self) return KIND[tonumber(self._nsapp.activationPolicy)] end)

---Quits the application.
-- @function [parent=#application] quit
-- @param #application self
-- @return #application self
function app:quit()
  clearCache(self._pid)
  if self._nsapp.terminated then return self end
  self._nsapp:terminate()
  return self
end

local forceQuitTimer=newTimer(function(self)
  if not self._nsapp.terminated then self._nsapp:forceTerminate() end
  clearCache(self._pid)
end)
---Force quits the application.
-- @function [parent=#application] forceQuit
-- @param #application self
-- @param #number gracePeriod (optional) number of seconds to wait for the app to quit normally before forcequitting;
-- pass `0` to force quit immediately. If omitted defaults to `10`.
-- @return #application self
function app:forceQuit(gracePeriod)
  if self._nsapp.terminated then return self end
  self._nsapp:terminate()
  forceQuitTimer:runIn(gracePeriod or 10,self)
  return self
end

---Whether the application is currently running.
-- This property can be set to `false` to terminate the application.
-- @field [parent=#application] #boolean running
-- @property
property(app,'running',function(self)
  if self._nsapp.terminated then return clearCache(self._pid) or false
  else return true end
end,app.quit,'false')

---Whether the application is currently hidden.
-- @field [parent=#application] #boolean hidden
-- @property
property(app,'hidden',
  function(self)return self._nsapp.hidden end,
  function(self,v)
    if not self.running then return log.e(self,'is not running, cannot hide') end
    if v then self._nsapp:hide() else self._nsapp:unhide() end
    --    return self._ax:setBooleanProp(c.NSAccessibilityHiddenAttribute,v)
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
  function(self) return self._nsapp.active end,
  function(self,v)
    if not self.running then return log.e(self,'is not running, cannot activate') end
    return self:activate()
      --    return self._ax:setBooleanProp(c.NSAccessibilityFrontmostAttribute,v)
  end,'boolean')

---Makes this the active application.
-- @function [parent=#application] activate
-- @param #application self
-- @return #application self
function app:activate()
  if not self._nsapp:activateWithOptions(c.NSApplicationActivateIgnoringOtherApps) then log.e('Failed to activate ',self) end
  return self
end
---Activates this application and puts all its windows on top of other windows.
-- @function [parent=#application] bringToFront
-- @param #application self
-- @return #application self
function app:bringToFront()
  if not self._nsapp:activateWithOptions(c.NSApplicationActivateIgnoringOtherApps+c.NSApplicationActivateAllWindows) then
    log.e('Failed to activate ',self)
  end
  return self
end
package.loaded['hm.applications']=applications
local newWindow=require'hm.windows'.newWindow

---The application's main window.
-- @field [parent=#application] hm.windows#window mainWindow
-- @property
property(app,'mainWindow',
  function(self)return newWindow(self._ax:getRawProp(c.NSAccessibilityMainWindowAttribute),self._pid) end,
  function(self,win)
    if win.application~=self then return log.e(win,'belongs to another application, cannot set as main window for',self) end
    self._ax:setRawProp(c.NSAccessibilityMainWindowAttribute,win._ax)
  end,'hm.windows#window')

---The application's focused window.
-- @field [parent=#application] hm.windows#window focusedWindow
-- @property
property(app,'focusedWindow',
  function(self)return newWindow(self._ax:getRawProp(c.NSAccessibilityFocusedWindowAttribute),self._pid)end,
  function(self,win)
    if win.application~=self then return log.e(win,'belongs to another application, cannot set as focused window for',self) end
    self._ax:setRawProp(c.NSAccessibilityFocusedWindowAttribute,win._ax)
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
    r:append(newWindow(cast(axref,axwin),self._pid))
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



---Type for application bundle objects.
-- @type bundle
-- @extends hm#module.object
-- @class
-- @checker hm.applications#bundle
-- @checker appBundle
local bundle=applications._classes.bundle
checkers['appBundle']='hm.applications#bundle'

local NSBundle=c.NSBundle

local cachedBundles=hm._core.cacheValues()
local function newBundle(nsurl)
  if not nsurl then return nil end
  local absurl=tolua(nsurl.URLByStandardizingPath.absoluteString)
  local o=cachedBundles[absurl]
  if o then return o end
  local nsbundle=NSBundle:bundleWithURL(nsurl)
  if not nsbundle then return nil end
  local path=tolua(nsbundle.bundlePath)
  o=bundle._new{_nsbundle=nsbundle,_path=path}
  cachedBundles[absurl]=o log.v('cached bundle',absurl)
  return o
end

---@type bundleList
-- @list <#bundle>

local array_out=ffi.new'void*[1]'
---All application bundles in the filesystem.
-- This property is cached, so it won't reflect changes in the filesystem after the first time it's requested.
-- @field [parent=#hm.applications] #bundleList allBundles
-- @readonlyproperty
property(applications,'allBundles',function()
  c._LSCopyAllApplicationURLs(array_out)
  return list(tolua(c.NSArray:arrayWithArray(array_out[0]))):imap(newBundle):sort(function(a,b)
    local laf,lbf=#a.folder,#b.folder
    if laf<lbf then return true elseif laf==lbf then return a._path<b._path end
  end,true)
  --  :sortByField('_path',true)
end)

---The application bundle.
-- If the application does not have a bundle structure, this property is `nil`.
-- @field [parent=#application] #bundle bundle
-- @readonlyproperty
property(app,'bundle',function(self) return newBundle(self._nsapp.bundleURL) end)

---The path of the folder containing the bundle.
-- @field [parent=#bundle] #string name
-- @readonlyproperty
property(bundle,'folder',function(self) return self._path:match('(.+)/[^/]+')end)
---The name of the bundle on the filesystem.
-- @field [parent=#bundle] #string name
-- @readonlyproperty
property(bundle,'name',function(self) return self._path:match('.+/([^/]+)')end)
---The bundle ID.
-- @field [parent=#bundle] #string id
-- @readonlyproperty
property(bundle,'id',function(self)return tolua(self._nsbundle.bundleIdentifier) or '' end)
---The bundle full path.
-- @field [parent=#bundle] #string path
-- @readonlyproperty
property(bundle,'path',function(self)return self._path end)
---The name of the bundled application.
-- @field [parent=#bundle] #string appName
-- @readonlyproperty
property(bundle,'appName',function(self) return tolua(self._nsbundle:objectForInfoDictionaryKey'CFBundleName') or '' end)

---The application object for this bundle.
-- If this app bundle isn't currently running, this property is `nil`.
-- @field [parent=#bundle] #application application
-- @readonlyproperty
property(bundle,'application',function(self)
  --  if not self._nsbundle.loaded then return end --TODO check
  local apps=list(tolua(c.NSRunningApplication:runningApplicationsWithBundleIdentifier(self.id))):imap(newApp)
  return (apps:ifindByField('bundle',self))
end,false)


--                              CFURLRef      CFArrayRef      ----                  int              ----
ffi.cdef[[struct LSLaunchURLSpec_ {void* appURL; void* itemURLs; void* passThruParams; int launchFlags; void* asyncRefCon;};]]
local launchURLSpec_t=ffi.typeof('struct LSLaunchURLSpec_')
local launchURLSpec_p=ffi.new'struct LSLaunchURLSpec_[1]'
--local launchedAppURL_out=ffi.new'CFURLRef[1]'
c.addfunction('LSOpenFromURLSpec',{retval='i','^v,^v'})
---Launches this bundle.
-- @function [parent=#bundle] launch
-- @param #bundle self
-- @return #application the running application object for this bundle
function bundle:launch()
  local spec=launchURLSpec_t{appURL=self._nsbundle.bundleURL,launchFlags=c.kLSLaunchDontSwitch+c.kLSLaunchInhibitBGOnly}
  launchURLSpec_p[0]=spec
  local res=c.LSOpenFromURLSpec(launchURLSpec_p,nil)
  hmassertf(res==0,'LSOpen error %d',res)
  return self.application
end

function applications.getBundle(bid)
  local bundles=applications.allBundles
  return unpack(bundles:ifilter(function(bnd)return bnd.id==bid end))
end

function applications.findBundle(hint,ignoreCase) checkargs'string'
  hint=ignoreCase and hint:lower() or hint
  local fn=ignoreCase and function(bnd)
    return bnd.id:lower():find(hint,1,true) or bnd.appName:lower():find(hint,1,true) or bnd.path:lower():find(hint,1,true)
  end
  or function(bnd)
    return bnd.id:find(hint,1,true) or bnd.appName:find(hint,1,true) or bnd.path:find(hint,1,true)
  end
  return unpack(applications.allBundles:ifilter(fn))
end

---@return #bundle
-- @dev
function applications.defaultBundleForBundleID(bid)
  return newBundle(workspace:URLForApplicationWithBundleIdentifier(bid))
end

---@return #bundleList
-- @internalchange returns all bundles for a given bundle id
-- @dev
function applications.bundlesForBundleID(bid) checkargs'string'
  return list(tolua(c.LSCopyApplicationURLsForBundleIdentifier(toobj(bid),nil))):imap(newBundle):sortByField('_path',true)
end

local nsurl=require'hm._os.nsurl'

---@return #bundle
-- @dev
function applications.defaultBundleForURL(url) sanitizeargs'url:NSURL'
  return newBundle(c.LSCopyDefaultApplicationURLForURL(url,nil))
end

---@return #bundleList
-- @dev
function applications.bundlesForURL(url) sanitizeargs'url:NSURL'
  return list(tolua(c.LSCopyApplicationURLsForURL(url,nil))):imap(newBundle)
end

---The required role for finding app bundles.
-- Valid values are `"viewer"`, `"editor"`, `"all"` or `nil` (same as `"all"`)
-- @type bundleRole
-- @extends #string
-- @checker hm.applications#bundleRole
checkers['hm.applications#bundleRole']=function(v)
  if v==nil or v=='all' then return c.kLSRolesAll
  elseif v=='editor' then return c.kLSRolesEditor
  elseif v=='viewer' then return c.kLSRolesViewer end
end

---@return #bundle
-- @dev
function applications.defaultBundleForFile(path,role) sanitizeargs('path:NSURL','hm.applications#bundleRole')
  return newBundle(c.LSCopyDefaultApplicationURLForURL(path,role,nil))
end

---@return #bundleList
-- @dev
function applications.bundlesForFile(path,role) sanitizeargs('path:NSURL','hm.applications#bundleRole')
  return list(tolua(c.LSCopyApplicationURLsForURL(path,role))):imap(newBundle)
end




---Type for application watcher objects.
-- @type watcher
-- @extends hm#module.object
-- @class
-- @checker hm.applications#watcher
-- @dev
local watcher=applications._classes.watcher
local newWatcher=watcher._new
local runningWatchers,watcherCount={},0

---Application event name.
-- Valid values are `"launching"`,`"launched"`,`"activated"`,`"deactivated"`,`"hidden"`,`"unhidden"`,`"terminated"`.
-- @type eventName
-- @extends #string
-- @checker hm.applications#eventName
-- @dev

---@type eventNameList
-- @list <#eventName>

local workspaceEvents=dict{
  launching   = tolua(c.NSWorkspaceWillLaunchApplicationNotification),
  launched    = tolua(c.NSWorkspaceDidLaunchApplicationNotification),
  activated   = tolua(c.NSWorkspaceDidActivateApplicationNotification),
  deactivated = tolua(c.NSWorkspaceDidDeactivateApplicationNotification),
  hidden      = tolua(c.NSWorkspaceDidHideApplicationNotification),
  unhidden    = tolua(c.NSWorkspaceDidUnhideApplicationNotification),
  terminated  = tolua(c.NSWorkspaceDidTerminateApplicationNotification),
}
checkers['applications#eventName']=function(s) return workspaceEvents[s] end
local watcherEvents=workspaceEvents:toIndex()

---Callback for application watchers.
-- @function [parent=#hm.applications] watcherCallback
-- @param #application application the application that caused the event
-- @param #eventName event the event
-- @param data
-- @prototype
-- @dev

local function workspaceObserverCallback(notif,info)
  if not next(runningWatchers) then return end
  local event=hmassertf(watcherEvents[notif],'received unknown workspace notification: %s',notif)
  --DEBUG
  log.d('received notification',notif)
  local userInfo=c.tolua(info)
  for k,v in pairs(userInfo) do log.v(k,':',v) end
  --ENDDEBUG
  local app=getAppFromNotif(info)
  for w in pairs(runningWatchers) do
    if w._events[notif] then
      w.log.v('received event',event,'from',app)
      w._cb(app,event,w._data)
    end
  end
end
local clearCacheTimer=newTimer(clearCache)
local function terminatedCallback(notif,info)
  workspaceObserverCallback(notif,info)
  local pid=hmassert(tolua(info:objectForKey'NSApplicationProcessIdentifier'))
  clearCacheTimer:runIn(0.3,pid)
end
---Creates a new watcher for application events.
-- @function [parent=#hm.applications] newWatcher
-- @param #watcherCallback fn (optional) callback function
-- @param data (optional)
-- @param #eventNameList events (optional)
-- @param #string name
-- @return #watcher the new watcher
-- @dev
function applications.newWatcher(fn,data,events,name) sanitizeargs('?callable','?','?listOrValue(applications#eventName)','?string')
  watcherCount=watcherCount+1
  log.d('Creating application watcher')
  local o=newWatcher({_isActive=false,_events=events and events:toSet(),_cb=fn,_data=data,_ref=watcherCount},name or sformat('app watcher: [#%d]',watcherCount))
  o.log.i('created')
  return o
end
---Whether this watcher is currently active.
-- @field [parent=#watcher] #boolean active
-- @property
property(watcher,'active',
  function(self) return self._isActive end,
  function(self,v) if v then self:start() else self:stop() end end,'boolean')

---Starts the watcher.
-- @function [parent=#watcher] start
-- @param #watcher self
-- @param #eventNameList events (optional)
-- @param #watcherCallback fn (optional)
-- @param data (optional)
-- @return #watcher self

local registeredNotifications={}
function watcher:start(fn,data,events) sanitizeargs('hm.applications#watcher','?callable','?','?listOrValue(applications#eventName)')
  if events then self._events=events:toSet()
  elseif not self._events then self._events=workspaceEvents:listValues():toSet() end
  if fn then self._cb=fn self._data=data
  elseif not self._cb then return log.e('Cannot start watcher, missing callback') end
  if events or fn or not self._isActive then
    if not next(runningWatchers) then
      hm._os.wsNotificationCenter:register('NSWorkspaceDidTerminateApplicationNotification',terminatedCallback)
    end
    for event in pairs(self._events) do
      if event~='NSWorkspaceDidTerminateApplicationNotification' then
        if not registeredNotifications[event] then
          hm._os.wsNotificationCenter:register(event,workspaceObserverCallback)
        end
        registeredNotifications[event]=true
      end
    end
    runningWatchers[self]=true -- retain ref to avoid gc
    self.log.d(self,self._isActive and 'restarted' or 'started')
    self._isActive=true
  end
  return self
end

---Stops the watcher.
-- @function [parent=#watcher] stop
-- @param #watcher self
-- @return #watcher self

function watcher:stop() checkargs'hm.applications#watcher'
  if self._isActive then
    self._isActive=false
    runningWatchers[self]=nil -- can be gc'ed now
    self.log.d(self,'stopped')
  end
  return self
end

---@private
function applications.__gc()
  for w in pairs(runningWatchers) do w:stop() end
end


return applications

