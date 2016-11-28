---Manage windows
-- @module hm.windows
-- @static

local c=require'objc'
c.load'CoreFoundation'

local pairs,ipairs,next,setmetatable=pairs,ipairs,next,setmetatable
local sformat=string.format
local property=hm._core.property
local hmtype=hm.type
local geometry=require'hm.types.geometry'
local coll=require'hm.types.coll'
local list=coll.list
local cgwindow=require'hm._os.cgwindow'

---@type hm.windows
-- @extends hm#module
local windows=hm._core.module('hm.windows',{window={
  __tostring=function(self) return sformat('window: [id:%s] %s',self.id or '?',self.title) end,
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


local newElement=require'hm._os.uielements'.newElement
local cachedWindows=hm._core.cacheValues()
local function newWin(axwin,pid,wid)
  if not axwin then return nil end
  assert(pid>0)
  local ax=newElement(axwin,pid)
  local ref=ax._ref
  local o=cachedWindows[ref] if o then return o end
  --  wid=wid or ax:getWindowID()
  o=new{_ax=ax,_pid=pid}
  cachedWindows[ref]=o
  log.v('cached axwin',ref)
  return o
end
---@function [parent=#hm.windows] newWindow
-- @param #cdata ax `AXUIElementRef`
-- @param #number pid
-- @param #number wid (optional)
-- @return #window
-- @dev
windows.newWindow=newWin

package.loaded['hm.windows']=windows
local applications=require'hm.applications'

---The window's unique identifier.
-- @field [parent=#window] #number id
-- @readonlyproperty
property(win,'id',function(self) return self._ax:getWindowID() end)
---The window title.
-- @field [parent=#window] #string title
-- @readonlyproperty
property(win,'title',function(self) return self._ax.title end,false)
---The window's accessibility role.
-- For *most* windows, this will be `"AXWindow"`.
-- @field [parent=#window] #string role
-- @readonlyproperty
-- @dev
property(win,'role',function(self) return self._ax.role end,false)
---The window's accessibility subrole.
-- @field [parent=#window] #string subrole
-- @readonlyproperty
-- @dev
property(win,'subrole',function(self) return self._ax.subrole end,false)
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
  function(self)return self._ax:getBool'minimized' end,
  function(self,v) self._ax:setBool('minimized',v) end,'boolean')
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
---Whether the window is currently fullscreen.
-- @field [parent=#window] #boolean fullscreen
-- @property
property(win,'fullscreen',
  function(self)return self._ax:getBool'fullscreen' end,
  function(self,v) self._ax:setBool('fullscreen',v) end,'boolean')
---Whether the window is currently visible.
-- A window is not visible if it's minimized or its parent application is hidden.
-- Setting this value to `true` will unminimize the window and unhide the parent application.
-- Setting this value to `false` will hide the parent application, unless the window is already minimized.
-- @field [parent=#window] #boolean visible
-- @property

---The window's frame in screen coordinates.
-- @field [parent=#window] hm.types.geometry#rect frame
-- @property
property(win,'frame',
  function(self)return geometry(self._ax.topleft,self._ax.size) end,
  function(self,v) self._ax.topleft=v.topleft self._ax.size=v.size end,'hm.types.geometry#rect',true)

---@type windowList
-- @list <#window>

---All current windows.
-- This property only includes windows in the current Mission Control space.
-- @field [parent=#hm.windows] #windowList windows
-- @readonlyproperty
property(windows,'windows',function()
  return applications.runningApplications:imapcat(function(app)return app.windows end)
end,false)

---All currently visible windows.
-- This property only includes windows in the current Mission Control space.
-- @field [parent=#hm.windows] #windowList visibleWindows
-- @readonlyproperty
property(windows,'visibleWindows',function()
  return applications.runningApplications:imapcat(function(app)return app.visibleWindows end)
end,false)

---All visible windows, ordered front to back.
-- This property only includes windows in the current Mission Control space.
-- @field [parent=#hm.windows] #windowList orderedWindows
-- @readonlyproperty
property(windows,'orderedWindows',function()
  local ids=list(cgwindow.getWIDList(true))
  local wins=windows.visibleWindows:toDictByField'id'
  return ids:imap(function(id)return wins[id] end)
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


