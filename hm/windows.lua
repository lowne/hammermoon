---Manage windows
-- @module hm.windows
-- @static

local c=require'objc'
c.load'CoreFoundation'

local tolua,toobj,nptr=c.tolua,c.toobj,c.nptr
-- private API yeah!
c.addfunction('_AXUIElementGetWindow',{retval='i','^{__AXUIElement=}','^i'},false)
--c.addfunction('_AXUIElementGetWindow',{retval='i','^v','^i'},false)
--local AXUIElementGetPid=c.AXUIElementGetPid
local geometry=require'hm.types.geometry'
local pairs,ipairs,next,setmetatable=pairs,ipairs,next,setmetatable
local sformat=string.format
local property=hm._core.property
local hmtype=hm.type

---@type hm.windows
-- @extends hm#module
local windows=hm._core.module('window',{window={
  __tostring=function(self) return sformat('window: [id:%s] %s',self._wid or '?',self.title) end,
  __gc=function(self) end, --TODO
  __eq=function(w1,w2) return hmtype(w2)=='hm.windows#window' and w1._ax==w2._ax end,
}})
local log=windows.log

---Type for window objects
-- @type window
-- @extends hm#module.object
-- @class
local win=windows._classes.window
local new=win._new


local value_out=require'ffi'.new'int[1]'
--local function getPid(axelem)
--    local result=AXGetPid(axelem,value_out)
--    return result==0 and value_out[0] or error'cannot get pid from axuielement'
--end
local _AXUIElementGetWindow=c._AXUIElementGetWindow
local function getwid(axwin,pid)
  local result=_AXUIElementGetWindow(axwin,value_out)
  return result==0 and value_out[0] or
    log.wf('%s: window ID <= [pid:%d]',require'bridge.axerror'[result],pid)
end

local newElement=require'hm._os.uielements'._newElement
local cachedWindows=hm._core.cacheValues()
local function newWin(axwin,pid,wid)
  if not axwin then return nil end
  assert(pid>0)
  wid=wid or getwid(axwin,pid)
  local o=cachedWindows[wid] if o then return o end
  o={_ax=newElement(axwin),_pid=pid,_wid=wid}
  if wid then cachedWindows[wid]=o log.v('Cached wid',wid)
  else log.v('no wid for',pid) end
  return new(o)
end
---@function [parent=#hm.windows] _newWindow
-- @param #cdata ax `AXUIElementRef`
-- @param #number pid
-- @param #number wid (optional)
-- @return #window
-- @dev
windows._newWindow=newWin

package.loaded['hm.windows']=windows
local applications=require'hm.applications'

---The window's unique identifier.
-- @field [parent=#window] #number id
-- @readonlyproperty
property(win,'id',function(self)self._wid=self._wid or getwid(self._ax) return self._wid end,false)

---The application owning this window
-- @field [parent=#window] hm.applications#application application
-- @readonlyproperty
property(win,'application',function(self)return applications.applicationForPID(self._pid)end)
---Whether this is a standard window.
-- @field [parent=#window] #boolean standard
-- @readonlyproperty
property(win,'standard',function(self)return self._ax.subrole=='AXStandardWindow'end,false)
---Whether the window is currently minimized.
-- @field [parent=#window] #boolean minimized
-- @property
property(win,'minimized',
  function(self)return self._ax:getBooleanAttribute(c.NSAccessibilityMinimizedAttribute)end,
  function(self,v) self._ax:setBooleanAttribute(c.NSAccessibilityMinimizedAttribute,v) end,'boolean')
---Whether the window is currently visible.
-- A window is not visible if it's minimized or its parent application is hidden.
-- Setting this value to `true` will unminimize the window and unhide the parent application.
-- Setting this value to `false` will hide the parent application, unless the window is already minimized.
-- @field [parent=#window] #boolean visible
-- @property
property(win,'visible',
  function(self) return not self.application.hidden and not self.minimized end,
  function(self,v)
    if v==true then self.application.hidden=false self.minimized=false
    elseif not self.minimized then self.parent.hidden=true end
  end,'boolean')
---Whether the window's parent application is hidden.
-- @field [parent=#window] #boolean hidden
-- @property
property(win,'hidden',
  function(self) return self.application.hidden end,
  function(self,v) self.application.hidden=v end,'boolean')

---The window's frame in screen coordinates.
-- @field [parent=#window] hm.types.geometry#rect frame
-- @property
property(win,'frame',
  function(self)return geometry(self._ax.topLeft,self._ax.size) end,
  function(self,v) self._ax.topleft=v.topleft self._ax.size=v.size end,'hm.types.geometry#rect')

-- so apparently OSX enforces a 6s limit on apps to respond to AX queries;
-- Karabiner's AXNotifier and Adobe Update Notifier fail in that fashion
local SKIP_APPS={
  ['com.apple.WebKit.WebContent']=true,['com.apple.qtserver']=true,['com.google.Chrome.helper']=true,
  ['org.pqrs.Karabiner-AXNotifier']=true,['com.adobe.PDApp.AAMUpdatesNotifier']=true,
  ['com.adobe.csi.CS5.5ServiceManager']=true,
  ['org.hammerspoon.Hammerspoon']=true, --funnily enough
}
---@type windowList
-- @list <#window>

---All current windows.
-- This property only includes windows in the current Mission Control space.
-- @field [parent=#hm.windows] #windowList allWindows
-- @readonlyproperty
property(windows,'allWindows',function()
  local r={}
  for _,app in ipairs(applications.runningApplications) do
    if app.kind()>=0 then
      local bid=app.bundleID or 'N/A' --just for safety; universalaccessd has no bundleid (but it's kind()==-1 anyway)
      if bid=='com.apple.finder' then --exclude the desktop "window"
        -- check the role explicitly, instead of relying on absent :id() - sometimes minimized windows have no :id() (El Cap Notes.app)
        for _,w in ipairs(app.allWindows) do if w.role=='AXWindow' then r[#r+1]=w end end
      elseif not SKIP_APPS[bid] then for _,w in ipairs(app.allWindows) do r[#r+1]=w end end
    end
  end
  return r
end,false)

---All currently visible windows.
-- This property only includes windows in the current Mission Control space.
-- @field [parent=#hm.windows] #windowList visibleWindows
-- @readonlyproperty
property(windows,'visibleWindows',function()
  local r={}
  for _,app in ipairs(applications.runningApplications) do
    if app.kind>0 and not app.hidden then for _,w in ipairs(app.visibleWindows) do r[#r+1]=w end end -- speedup by excluding hidden apps
  end
  return r
end,false)

---The currently focused window.
-- @field [parent=#hm.windows] #window focusedWindow
-- @property
property(windows,'focusedWindow',function()
  local app=applications.frontmostApplication
  return app and app.focusedWindow or log.e'no frontmost app or window!'
end,function(w) w:focus() end,'hm.windows#window')




---@type eventNameList
-- @list <hm._os.uielements#eventName>


---Creates a new watcher for this window.
-- @function [parent=#window] newWatcher
-- @param #window self
-- @param hm._os.uielements#watcherCallback fn callback function
-- @param data (optional)
-- @return hm._os.uielements#watcher the new watcher
-- @dev
function win:newWatcher(fn,data) hmchecks('hm.windows#window','callable') return self._ax:newWatcher(fn,data) end

---Creates and starts a new watcher for this window.
-- This method is a shortcut for `window:newWatcher():start()`
-- @function [parent=#window] startWatcher
-- @param #window self
-- @param #eventNameList events
-- @param #function fn callback function
-- @param data (optional)
-- @return hm._os.uielements#watcher the new watcher
-- @dev
function win:startWatcher(events,fn,data) return self:newWatcher(fn,data):start() end

---@private
function windows.__gc()
--TODO stop watchers
end
return windows


