---
--@module hm.screen
--@static

------ OBJC -------
local c=require'objc'
local tolua,toobj,nptr=c.tolua,c.toobj,c.nptr
c.load'Foundation'
c.load'IOKit'
c.load'CoreGraphics'
c.load'CoreFoundation'
--c.addfunction('IODisplayCreateInfoDictionary',{retval='@"NSDictionary"','U','U'})
local ffi=require'ffi'
ffi.cdef[[
// CoreGraphics DisplayMode struct used in private APIs
typedef struct {
    uint32_t modeNumber;
    uint32_t flags;
    uint32_t width;
    uint32_t height;
    uint32_t depth;
    uint8_t unknown[170];
    uint16_t freq;
    uint8_t more_unknown[16];
    float density;
} CGSDisplayMode;
]]
local CGSDisplayMode_size=ffi.sizeof'CGSDisplayMode'
-- CoreGraphics private APIs with support for scaled (retina) display modes
c.addfunction('CGSGetCurrentDisplayMode',{'I','^i'});
c.addfunction('CGSConfigureDisplayMode',{'^v','I','i'})
c.addfunction('CGSGetNumberOfDisplayModes',{'I','^i'})
c.addfunction('CGSGetDisplayModeDescriptionOfLength',{'I','i','^v','i'})


local NSScreen=c.NSScreen

local geomFromNSRect=hm.geometry._fromNSRect
local ipairs,pairs,next=ipairs,pairs,next
local sformat=string.format


---@type hm.screen
--@extends hm#module
local screen=hm._core.module('screen',{
  __tostring=function(self) return sformat('hm.screen: [#%d] %s',self._sid,self._name) end,
  __gc=function(self)end, --TODO
})

---@type hm.screen.object
--@extends hm#module.class
local scr=screen._class

local new,log=scr._new,screen.log


local function getid(nsscreen)
  return tolua(nsscreen.deviceDescription:objectForKey'NSScreenNumber')
end
local screens={} --cache
local function newScreen(nsscreen)
  local sid=getid(nsscreen)
  local o=screens[sid]
  if o then return o end
  local function getname(port)
    local dict=c.IODisplayCreateInfoDictionary(port,c.kIODisplayOnlyPreferredName)
    local names=c.NSDictionary:dictionaryWithDictionary(c.CFDictionaryGetValue(dict,toobj(c.kDisplayProductName)))
    local _,name=next(tolua(names))
    return name
  end
  local port=c.CGDisplayIOServicePort(sid)
  assert(sid and port)
  o=new{
    _nsscreen=nsscreen,
    _sid=sid,
    _name=getname(port),
    _frame=geomFromNSRect(nsscreen.frame)
  }
  screens[sid]=o return o
end
local allScreens --#table
local function cacheScreens()
  allScreens={}
  local nsscreens=tolua(NSScreen:screens())
  for i,nsscr in ipairs(nsscreens) do
    allScreens[i]=newScreen(nsscr)
  end
end
cacheScreens()
hm._core.defaultNotificationCenter:register('NSApplicationDidChangeScreenParametersNotification',cacheScreens)

function screen.allScreens() return allScreens end
function screen.mainScreen() return newScreen(NSScreen:mainScreen()) end
function screen.primaryScreen() return allScreens[1] end

---@dev
function screen._toCocoa(g) g.y=allScreens[1]._frame._h-g._y-g._h return g end

function scr:name() return self._name end
function scr:id() return self._sid end
function scr:frame() return self._frame end
function scr:visibleFrame()
  if not self._visibleFrame then self._visibleFrame=geomFromNSRect(self._nsscreen.visibleFrame) end
  return self._visibleFrame
end

local idx_out=ffi.new'int[1]'
local mode_out=ffi.new'CGSDisplayMode[1]'
---Get the current display mode
--@return #string
--@apichange Returns a string instead of a table
function scr:currentMode()
  c.CGSGetCurrentDisplayMode(self._sid,idx_out)
  c.CGSGetDisplayModeDescriptionOfLength(self._sid,idx_out[0],mode_out,CGSDisplayMode_size)
  return sformat('%dx%d@%.0fx',mode_out[0].width,mode_out[0].height,mode_out[0].density)
end

---@private
function screen._hmdestroy()
end

return screen
