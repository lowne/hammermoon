---Manipulate screens (monitors).
-- The OSX coordinate system used by Hammermoon assumes a grid that spans all the screens (positioned as per
-- System Preferences->Displays->Arrangement). The origin `0,0` is at the top left corner of the *primary screen*.
-- Screens to the top or the left of the primary screen, and windows on these screens, will have negative coordinates.
-- @module hm.screen
-- @static

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

local geom=hm.geometry
local type,ipairs,pairs,next=type,ipairs,pairs,next
local tonumber,sformat,tinsert=tonumber,string.format,table.insert
local coll=require'lib.coll'
local band=require'bit'.band

---@type hm.screen
--@extends hm#module
local screen=hm._core.module('screen',{
  __tostring=function(self) return sformat('screen: [#%d] %s',self._sid,self._name) end,
  __gc=function(self)end, --TODO
})

---@type screen
--@extends hm#module.class
local scr=screen._class

---@type screenList
--@list <#screen>

--@type screenmap
--@map <#number,#screen> haha
local new,log=scr._new,screen.log


local function getid(nsscreen) return tolua(nsscreen.deviceDescription:objectForKey'NSScreenNumber') end

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
    _frame=geom._fromNSRect(nsscreen.frame)
  }
  screens[sid]=o return o
end
local allScreens --#table
local function cacheScreens() allScreens=coll.imap(tolua(NSScreen:screens()),newScreen) end
cacheScreens()
hm._core.defaultNotificationCenter:register('NSApplicationDidChangeScreenParametersNotification',cacheScreens)

--TODO enable/disable screen

---Returns all the screens currently connected and enabled.
-- @return #screenList
-- @internalchange The screen list is cached (and kept up to date by an internal watcher)
function screen.allScreens() return allScreens end

---Returns the main screen.
-- The main screen is the one containing the currently focused window.
-- @return #screen
function screen.mainScreen() return newScreen(NSScreen:mainScreen()) end
function screen.primaryScreen() return allScreens[1] end

---Transform a `geometry.rect` object from HS/HM coordinate system (origin at top left of primary screen)
-- to Cocoa coordinate system (origin at bottom left of primary screen)
-- @param hm.geometry#rect rect
-- @return hm.geometry#rect transformed rect
-- @dev
function screen._toCocoa(rect) rect=geom.copy(rect) rect.y=allScreens[1]._frame._h-rect._y-rect._h return rect end

---Returns the screen's name.
-- The screen's name is set by the manufacturer.
-- @return #string the screen name
function scr:name() return self._name end
---Returns a screen's unique ID.
-- @return #number the screen ID
function scr:id() return self._sid end
function scr:frame() return self._frame end
function scr:visibleFrame()
  if not self._visibleFrame then self._visibleFrame=geom._fromNSRect(self._nsscreen.visibleFrame) end
  return self._visibleFrame
end


-------------- Screen mode ---------------------

---A string describing a screen mode.
-- The format of the string is `WWWWxHHHH@Sx/RR`, where WWWW is the width in points, HHHH the height in points,
-- S is the scaling factor, i.e. 2 for HiDPI (a.k.a "retina") mode or 1 for native mode, and RR is the refresh
-- rate in Hz; the `/RR` part is optional. E.g.: `"1440x900@2x/60"`.
-- Note that "points" are not necessarily the same as pixels, because they take the scale factor into account
-- (e.g. "1440x900@2x" is a 2880x1800 screen resolution, with a scaling factor of 2, i.e. with HiDPI pixel-doubled
-- rendering enabled), however, they are far more useful to work with than native pixel modes, when a Retina screen
-- is involved. For non-retina screens, points and pixels are equivalent.
-- @type screenMode
-- @extends #string
checkers['hm.screen#screenMode']=function(s) return type(s)=='string' and s:match('^%d+x%d+@[12]x/?%d*%^?[48]?$') and true or false end
---@type screenModeList
-- @list <#screenMode>

local function screenMode(mode)
  local freq=mode.freq and mode.freq>0 and '/'..mode.freq or ''
  local depth=mode.depth and '^'..mode.depth or ''
  return sformat('%dx%d@%.0fx%s%s',mode.width,mode.height,mode.density,freq,depth)
end
local idx_out=ffi.new'int[1]'
local mode_out=ffi.new'CGSDisplayMode[1]'
local config_out=ffi.new'CGDisplayConfigRef[1]'
---Returns the screen's current mode.
-- The screen's mode indicates its current resolution and scaling factor.
-- @return #screenMode
-- @apichange Returns a string instead of a table
function scr:currentMode() checks('hm.screen#screen')
  c.CGSGetCurrentDisplayMode(self._sid,idx_out)
  c.CGSGetDisplayModeDescriptionOfLength(self._sid,idx_out[0],mode_out,CGSDisplayMode_size)
  --  print(mode_out[0].modeNumber,'<<<<<<<<<<')
  return screenMode(mode_out[0])
end

---Returns a list of the modes supported by the screen.
-- @param #screen self
-- @param #string pattern A pattern to filter the modes as per `string.find`; e.g. passing `"/60" will only return modes with a refresh rate of 60Hz
-- @return #screenModeList
-- @apichange Returns a plain list of strings
function scr:availableModes(pattern) checks('hm.screen#screen','?string')
  pattern=pattern or ''
  c.CGSGetNumberOfDisplayModes(self._sid,idx_out)
  local r={}
  for i=1,idx_out[0] do
    c.CGSGetDisplayModeDescriptionOfLength(self._sid,i,mode_out,CGSDisplayMode_size)
    local m=screenMode(mode_out[0])
    --    print(mode_out[0].modeNumber,m,mode_out[0].flags)
    if m:find(pattern,1,true) then tinsert(r,m) end
  end
  return r
end

function scr:isModeAvailable(mode) checks('hm.screen#screen','hm.screen#screenMode')
  return coll.index(self:availableModes(),mode) and true or false
end

---
-- @param #screen self
-- @param #screenMode mode
-- @apichange Refresh rate is supported
-- @internalchange Will pick the highest refresh rate (if not specified) and color depth=4 (if available, and unless specified to 8).
-- @internalchange depth==8 isn't supported in HS!
function scr:setMode(mode) checks('hm.screen#screen','hm.screen#screenMode|table')
  if type(mode)=='table' then mode=screenMode(mode) end -- hs compat
  local w,h,s,f,d=mode:match('^(%d+)x(%d+)@([12])x/?(%d*)%^?([48]?)$')
  w,h,s,f,d=tonumber(w),tonumber(h),tonumber(s),tonumber(f),tonumber(d)
  local maxdepth,maxfreq,best,bestmode=0,-1
  c.CGSGetNumberOfDisplayModes(self._sid,idx_out)
  for i=1,idx_out[0] do
    c.CGSGetDisplayModeDescriptionOfLength(self._sid,i,mode_out,CGSDisplayMode_size)
    local m=mode_out[0]
    if (not d and (m.depth==4 or m.depth==8) or m.depth==d) and m.width==w and m.height==h and m.density==s and (not f or m.freq==f) then
      if (m.depth==4 and maxdepth~=4) or not maxdepth then maxdepth=m.depth maxfreq=m.freq best=i bestmode=screenMode(m) log.v('Found candidate mode',screenMode(m),'on',self)
      elseif m.depth==maxdepth and m.freq>maxfreq then maxfreq=m.freq best=i bestmode=screenMode(m) log.v('Found candidate mode',screenMode(m),'on',self) end
    end
  end
  if not best then return log.e('No viable screen modes found for desired mode',mode,'on',self) end
  if bestmode==self:currentMode() then log.i('Screen',self,'already on the desired mode',bestmode,'- skipping') return true end
  log.d('Setting screen mode',bestmode,'on',self)
  c.CGBeginDisplayConfiguration(config_out)
  c.CGSConfigureDisplayMode(config_out[0],self._sid,best)
  local ok=c.CGCompleteDisplayConfiguration(config_out[0],c.kCGConfigurePermanently)
  if not ok then return log.e('Error',ok,'setting screen mode to',bestmode,'on',self) end
  log.i('Screen mode set to',bestmode,'on',self) return true
end


----------------- Gamma ----------------------

local gammaTable_t=ffi.typeof('float[?]')
local function getGammaTable(sid)
  local size=c.CGDisplayGammaTableCapacity(sid)
  local g={gammaTable_t(size),gammaTable_t(size),gammaTable_t(size)}
  local ok=c.CGGetDisplayTransferByTable(sid,size,g[1],g[2],g[3],idx_out)
  if not ok then return log.e('Error',ok,'getting gamma table on',screens[sid]) end
  g.size=idx_out[0]
  return g
end
local function setGammaTable(sid,g)
  local ok=c.CGSetDisplayTransferByTable(sid,g.size,g[1],g[2],g[3])
  if not ok then return log.e('Error',ok,'setting gamma table on',screens[sid]) end
end

local originalGammas,currentGammas={},{}
local function storeOriginalGamma(sid)originalGammas[sid]=getGammaTable(sid)end

checkers['hm.screen#gammaAdjustTable']=function(t)
  local function color(p) return type(p)=='number' and p>=0 and p<=1 end
  local function point(t) return type(t)=='table' and color(t[1]) and color(t[2]) and color(t[3]) end
  return type(t)=='table' and coll.every(t,point) and #t==2 --for now, just blackpoint and whitepoint allowed
end

local function hsGammaPoint(t) if t[3] then return t else return {t.red,t.green,t.blue} end end
local function setGamma(sid,gammaTable) checks('uint','hm.screen#gammaAdjustTable')
  local black,white=gammaTable[1],gammaTable[2]
  local orig=originalGammas[sid] if not orig then return log.e('Cannot find gamma table for',screens[sid]) end
  local size=orig.size
  local newg={gammaTable_t(size),gammaTable_t(size),gammaTable_t(size),size=size}
  for i=0,size-1 do
    for c=1,3 do newg[c][i]=black[c]+(white[c]-black[c])*orig[c][i] end
  end
  local ok,err=setGammaTable(sid,newg) if not ok then return nil,err end
  currentGammas[sid]=newg
  log.fi('Gamma set to %.2f,%.2f,%.2f -> %.2f,%.2f,%.2f on %s',black[1],black[2],black[3],white[1],white[2],white[3],screens[sid])
  return true
end

local function reapplyGammas()
  for sid,gammaTable in pairs(currentGammas) do setGammaTable(sid,gammaTable) end
end
local function restoreGammas() c.CGDisplayRestoreColorSyncSettings() currentGammas={} end

local gammaLoaded,reapplyGammaTimer
local kCGDisplayBeginConfigurationFlag = 2^0
local kCGDisplayMovedFlag              = 2^1
local kCGDisplaySetMainFlag            = 2^2
local kCGDisplaySetModeFlag            = 2^3
local kCGDisplayAddFlag                = 2^4
local kCGDisplayRemoveFlag             = 2^5
local kCGDisplayEnabledFlag            = 2^8
local kCGDisplayDisabledFlag           = 2^9
local kCGDisplayMirrorFlag             = 2^10
local kCGDisplayUnMirrorFlag           = 2^11
local kCGDisplayDesktopShapeChangedFlag = 2^12
local function displayReconfigurationCallback(id,flags,_)
  if band(flags,kCGDisplayAddFlag) then storeOriginalGamma(id)
  elseif band(flags,kCGDisplayRemoveFlag) then originalGammas[id]=nil currentGammas[id]=nil
  elseif band(flags,kCGDisplayDisabledFlag) then currentGammas[id]=nil
  elseif band(flags,kCGDisplayEnabledFlag) then
  elseif band(flags,kCGDisplayBeginConfigurationFlag) then
  else reapplyGammaTimer:start() end
end
local function gammaInit()
  if gammaLoaded then return end
  for _,scr in ipairs(allScreens) do storeOriginalGamma(scr._sid) end
  reapplyGammaTimer=hm.timer.delayed.new(3,reapplyGammas)
  log.d'Registering reconfiguration callback'
  c.CGDisplayRegisterReconfigurationCallback(displayReconfigurationCallback,nil)
  gammaLoaded=true
end

function scr:getGamma() checks'hm.screen#screen'
  local g,err=getGammaTable(self._sid) if not g then return nil,err end
  local last=g.size-1
  return {{g[1][0],g[2][0],g[3][0]},{g[1][last],g[2][last],g[3][last]}}
end
function scr:setGamma(gammaTable,_hscompat) checks'hm.screen#screen' --other args later
  gammaInit()
  if _hscompat then gammaTable={hsGammaPoint(_hscompat),hsGammaPoint(gammaTable)} end
  return setGamma(self._sid,gammaTable)
end



---@private
function screen.__gc()
  if gammaLoaded then
    log.d'Removing reconfiguration callback'
    c.CGDisplayRemoveReconfigurationCallback(displayReconfigurationCallback,nil)
    log.i'Restoring original gamma tables'
    restoreGammas()
  end
end

return screen
