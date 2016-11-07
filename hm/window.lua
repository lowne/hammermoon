local c=require'objc'
c.load'CoreFoundation'

local tolua,toobj,nptr=c.tolua,c.toobj,c.nptr
-- private API yeah!
c.addfunction('_AXUIElementGetWindow',{retval='i','^{__AXUIElement=}','^i'},false)
--c.addfunction('_AXUIElementGetWindow',{retval='i','^v','^i'},false)
local AXGetPid,AXGetWindowID=c.AXUIElementGetPid,c._AXUIElementGetWindow

--local log=hm.logger.new'window'
local pairs,ipairs,next,setmetatable=pairs,ipairs,next,setmetatable
local sformat=string.format
--local tinsert=table.insert
--local hmobject=hm._core.hmobject
local geometry=hm.geometry

local window=hm._core.module('window',{
  __tostring=function(self) return sformat('hm.window: [wid:%s] %s',self._wid or '?',self:title()) end,
  __gc=function(self) end, --TODO
  __eq=function()error'shoud not happen'end,
})
local win,new=window._class,window._class._new
local log=window.log
--local win=setmetatable({},{__tostring=function()return'<window>'end}) -- object
--local window={log=log,_object=win} -- module


local value_out=require'ffi'.new'int[1]'
--local function getPid(axelem)
--    local result=AXGetPid(axelem,value_out)
--    return result==0 and value_out[0] or error'cannot get pid from axuielement'
--end
local function getwid(axwin,pid)
  local result=AXGetWindowID(axwin,value_out)
  return result==0 and value_out[0] or
    log.wf('%s: window ID <= [pid:%d]',require'bridge.axerror'[result],pid)
    --  error'AXError'
    --  return result==0 and tolua(NSNumber:numberWithInteger(id_out[0])) or error'AXError'
end
--local newElement=uielement._wrap

local windows=setmetatable({},{__mode='v'})
local function newWin(axwin,pid,wid)
  if not axwin then return nil end
  assert(pid>0)
  wid=wid or getwid(axwin,pid)
  --  assert(wid>0)
  local o=windows[wid]
  --  o=nil
  if o then return o end
  o={_ax=axwin,_pid=pid,_wid=wid}
  if wid then windows[wid]=o log.v('Cached wid',wid)
  else log.v('no wid for',pid)
  end
  --  return setmetatable({_ax=axwin,_pid=pid,_id=getid(axwin)},{__index=win,__tostring=win.tostring})
  o=new(o)
  --  assert(o:role()=='AXWindow')
  o._role='AXWindow'
  return o
    --  return hmobject(ret,win)
end
window._newWindow=newWin
--function win:__tostring() return sformat('hm.window: [wid:%s] %s',self._wid or '?',self:title()) end
----function win:__tostring() return'haha'end-- sformat('hm.window: [wid:%s] %s',self._wid or '?',self:title() or '<?>') end
--function win:__gc()end --TODO

package.loaded['extensions.window']=window
local application=hm.application

function win:id()
  self._wid=self._wid or getwid(self._ax)
  return self._wid
end
function win:application() return application.applicationForPID(self._pid) end
function win:isStandard() return self:subrole()=='AXStandardWindow' end
function win:isMinimized() return self:_getBooleanAttribute(c.NSAccessibilityMinimizedAttribute) end
function win:isVisible() return not self:application():isHidden() and not self:isMinimized() end

function win:frame() return geometry(self:topLeft(),self:size()) end


local SKIP_APPS={
  ['com.apple.WebKit.WebContent']=true,['com.apple.qtserver']=true,['com.google.Chrome.helper']=true,
  ['org.pqrs.Karabiner-AXNotifier']=true,['com.adobe.PDApp.AAMUpdatesNotifier']=true,
  ['com.adobe.csi.CS5.5ServiceManager']=true,
  ['org.hammerspoon.Hammerspoon']=true, --funnily enough
}
-- so apparently OSX enforces a 6s limit on apps to respond to AX queries;
-- Karabiner's AXNotifier and Adobe Update Notifier fail in that fashion
function window.allWindows()
  local r={}
  for _,app in ipairs(application.runningApplications()) do
    if app:kind()>=0 then
      local bid=app:bundleID() or 'N/A' --just for safety; universalaccessd has no bundleid (but it's kind()==-1 anyway)
      if bid=='com.apple.finder' then --exclude the desktop "window"
        -- check the role explicitly, instead of relying on absent :id() - sometimes minimized windows have no :id() (El Cap Notes.app)
        for _,w in ipairs(app:allWindows()) do if w:role()=='AXWindow' then r[#r+1]=w end end
      elseif not SKIP_APPS[bid] then for _,w in ipairs(app:allWindows()) do r[#r+1]=w end end
    end
  end
  return r
end

function window.visibleWindows()
  local r={}
  for _,app in ipairs(application.runningApplications()) do
    if app:kind()>0 and not app:isHidden() then for _,w in ipairs(app:visibleWindows()) do r[#r+1]=w end end -- speedup by excluding hidden apps
  end
  return r
end

function window.focusedWindow()
  local app=application.frontmostApplication()
  return app and app:focusedWindow() or error'no frontmost app or window!'
end

getmetatable(win).__index=hm.uielement._class
--win.__eq=function(a,b)
--  error'should not happen!'
--  --  return hm.uielement._object.__eq(a,b)
--end
return window


