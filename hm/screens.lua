---Manipulate screens (monitors).
-- The OSX coordinate system used by Hammermoon assumes a grid that spans all the screens (positioned as per
-- System Preferences->Displays->Arrangement). The origin `0,0` is at the top left corner of the *primary screen*.
-- Screens to the top or the left of the primary screen, and windows on these screens, will have negative coordinates.
-- @module hm.screens
-- @static

------ OBJC -------
local c=require'objc'
c.load'AppKit'
local tolua,toobj,nptr=c.tolua,c.toobj,c.nptr

local NSScreen=c.NSScreen

local type,ipairs,pairs,next,setmetatable=type,ipairs,pairs,next,setmetatable
local tonumber,tostring,sformat,tinsert=tonumber,tostring,string.format,table.insert
local band=bit.band
local coll=require'hm.types.coll'
local list,dict=coll.list,coll.dict
local geom=hm.types.geometry
local property=hm._core.property
local cgdisplay=require'hm._os.cgdisplay'

---@type hm.screens
-- @extends hm#module
local screens=hm._core.module('hm.screens',{screen={
  __tostring=function(self) return sformat('screen: [#%d] %s',self._sid,self._name) end,
  __gc=function(self)end, --TODO
},watcher={
  __tostring=function(self) return sformat('watcher: [#%d] %s',self._sid,self._name) end,
  __gc=function(self)end, --TODO
}})

---@type screen
-- @extends hm#module.class
-- @class
local scr=screens._classes.screen

---@type screenList
-- @list <#screen>

--@type screenmap
--@map <#number,#screen> haha
local new,log=scr._new,screens.log


local function getid(nsscreen) return tolua(nsscreen.deviceDescription:objectForKey'NSScreenNumber') end

local cachedScreens={} --cache
local function newScreen(nsscreen)
  local sid=hmassert(getid(nsscreen),'cannot get screen id')
  local o=cachedScreens[sid]
  if o then return o end
  o=new{_nsscreen=nsscreen,_sid=sid,_name=cgdisplay.getName(sid),_frame=geom._fromNSRect(nsscreen.frame)}
  cachedScreens[sid]=o return o
end
local currentScreens --#table
local function updateScreens()
  currentScreens=list(tolua(NSScreen:screens())):imap(newScreen)
  currentScreens:iforeach(function(scr) scr._frame=geom._fromNSRect(scr._nsscreen.frame) end)
end
updateScreens()
hm._os.defaultNotificationCenter:register('NSApplicationDidChangeScreenParametersNotification',updateScreens)

--TODO enable/disable screen

---The currently connected and enabled screens.
-- @field [parent=#hm.screens] #screenList screens
-- @readonlyproperty
-- @internalchange The screen list is cached and kept up to date by an internal watcher
property(screens,'screens',function() return currentScreens end,false)


---The currently focused screen.
-- The focused screen is the one containing the currently focused window.
-- @field [parent=#hm.screens] #screen focusedScreen
-- @readonlyproperty
-- @apichange main->active
property(screens,'focusedScreen',function() return newScreen(NSScreen:mainScreen()) end,false)
---The primary screen.
-- The primary screen is the one containing the menubar and dock.
-- @field [parent=#hm.screens] #screen primaryScreen
-- @readonlyproperty
property(screens,'primaryScreen',function() return currentScreens[1] end,false) --TODO writable?

---Transform a @{<hm.types.geometry#rect>} object from HS/HM coordinate system (origin at top left of primary screen)
-- to Cocoa coordinate system (origin at bottom left of primary screen)
-- @param hm.types.geometry#rect rect
-- @return hm.types.geometry#rect transformed rect
-- @dev
function screens._toCocoa(rect) rect=geom.copy(rect) rect.y=currentScreens[1]._frame._h-rect._y-rect._h return rect end

---The screen's name.
-- The screen's name is set by the manufacturer.
-- @field [parent=#screen] #string name
-- @readonlyproperty
property(scr,'name',function(self) return self._name end)
---The screen's unique ID.
-- @field [parent=#screen] #number id
-- @readonlyproperty
property(scr,'id',function(self) return self._sid end)
---The screen frame.
-- @field [parent=#screen] hm.types.geometry#rect fullFrame
-- @readonlyproperty
property(scr,'fullFrame',function(self) return self._frame end,false)
---The screen's usable frame.
-- The usable frame excludes the area currently occupied by the dock and menubar.
-- Even with dock and menubar hiding enabled, this rectangle may be smaller than the full frame.
-- @field [parent=#screen] hm.types.geometry#rect frame
-- @readonlyproperty
property(scr,'frame',function(self) return geom._fromNSRect(self._nsscreen.visibleFrame) end,false)


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
local screenMode_mt={__tostring=function(mode)
  local freq=mode.freq and mode.freq>0 and '/'..mode.freq or ''
  local depth=mode.depth and '^'..mode.depth or ''
  return sformat('%dx%d@%.0fx%s%s',mode.width,mode.height,mode.scale,freq,depth)
end}
local modesCache={}
local function makeScreenMode(mode)
  if modesCache[mode] then return modesCache[mode] end
  local r={}
  if type(mode)=='table' then
    r.width=type(mode.width)=='number' and mode.width or nil
    r.height=type(mode.height)=='number' and mode.height or nil
    r.scale=type(mode.scale)=='number' and mode.scale or nil
    r.freq=type(mode.freq)=='number' and mode.freq or nil
    r.depth=type(mode.depth)=='number' and mode.depth or nil
  elseif type(mode)=='string' then
    local w,h,s,f,d=mode:match('^(%d+)x(%d+)@([12])x/?(%d*)%^?([48]?)$')
    r.width,r.height,r.scale,r.freq,r.depth=tonumber(w),tonumber(h),tonumber(s),tonumber(f),tonumber(d)
  end
  if r.width and r.height and r.scale then r=setmetatable(r,screenMode_mt) modesCache[mode]=r return r end
end
checkers['hm.screens#screenMode']=makeScreenMode

---@type screenModeList
-- @list <#screenMode>

---The screen's available modes.
-- @field [parent=#screen] #screenModeList availableModes
-- @readonlyproperty
property(scr,'availableModes',function(self) return dict(cgdisplay.availableModes(self._sid)):listValues():map(makeScreenMode):map(tostring) end)

---Returns a list of modes supported by the screen, filtered by a given search criterion.
-- @param #screen self
-- @param #string pattern A pattern to filter the modes as per `string.find`; e.g. passing `"/60" will only return modes with a refresh rate of 60Hz
-- @return #screenModeList
function scr:findModes(pattern) checkargs('hm.screens#screen','string')
  return self.availableModes:imap(function(mode)return mode:find(pattern,1,true) end)
end

---The screen's current mode.
-- @field [parent=#screen] #screenMode mode
-- @property
-- @apichange A user-facing string instead of a table. Refresh rate, color depth are supported.
-- @internalchange Will pick the highest refresh rate (if not specified) and color depth=4 (if available, and unless specified to 8).
-- @internalchange depth==8 isn't supported in HS!
property(scr,'mode',
  function(self) return tostring(makeScreenMode(cgdisplay.currentMode(self._sid))) end,
  function(self,mode)
    local w,h,s,f,d=mode.width,mode.height,mode.scale,mode.freq,mode.depth
    local maxdepth,maxfreq,best,bestmode=0,-1
    for i,m in pairs(cgdisplay.availableModes(self._sid)) do
      if (not d and (m.depth==4 or m.depth==8) or m.depth==d) and m.width==w and m.height==h and m.scale==s and (not f or m.freq==f) then
        if (m.depth==4 and maxdepth~=4) or not maxdepth then
          maxdepth=m.depth maxfreq=m.freq best=i bestmode=makeScreenMode(m) log.v('Found candidate mode',bestmode,'on',self)
        elseif m.depth==maxdepth and m.freq>maxfreq then
          maxfreq=m.freq best=i bestmode=makeScreenMode(m) log.v('Found candidate mode',bestmode,'on',self)
        end
      end
    end
    if not best then return log.e('No viable screen modes found for desired mode',mode,'on',self) end
    if tostring(bestmode)==self.mode then log.i('Screen',self,'already on the desired mode',bestmode,'- skipping') return true end
    log.d('Setting screen mode',bestmode,'on',self)
    local ok,err=cgdisplay.setMode(self._sid,best)
    if ok then log.i('Screen mode set to',bestmode,'on',self)
    else log.e('Error',err,'setting screen mode to',bestmode,'on',self) end
  end,'hm.screens#screenMode',true)

--[[
local ffi=require'ffi'
local gammaTable_t=ffi.typeof('float[?]')
local function getGammaTable(sid)
  local size=c.CGDisplayGammaTableCapacity(sid)
  local g={gammaTable_t(size),gammaTable_t(size),gammaTable_t(size)}
  local ok=c.CGGetDisplayTransferByTable(sid,size,g[1],g[2],g[3],idx_out)
  if not ok then return log.e('Error',require'bridge.cgerror'[ok],'getting gamma table on',cachedScreens[sid]) end
  g.size=idx_out[0]
  return g
end
local function setGammaTable(sid,g)
  local ok=c.CGSetDisplayTransferByTable(sid,g.size,g[1],g[2],g[3])
  if not ok then return log.e('Error',require'bridge.cgerror'[ok],'setting gamma table on',cachedScreens[sid]) end
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
  local orig=originalGammas[sid] if not orig then return log.e('Cannot find gamma table for',cachedScreens[sid]) end
  local size=orig.size
  local newg={gammaTable_t(size),gammaTable_t(size),gammaTable_t(size),size=size}
  for i=0,size-1 do
    for c=1,3 do newg[c][i]=black[c]+(white[c]-black[c])*orig[c][i] end
  end
  local ok,err=setGammaTable(sid,newg) if not ok then return nil,err end
  currentGammas[sid]=newg
  log.fi('Gamma set to %.2f,%.2f,%.2f -> %.2f,%.2f,%.2f on %s',black[1],black[2],black[3],white[1],white[2],white[3],cachedScreens[sid])
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
  elseif band(flags,kCGDisplayEnabledFlag) then -- should this restore our desired gamma?
  elseif band(flags,kCGDisplayBeginConfigurationFlag) then
  else reapplyGammaTimer:start() end
end
local function gammaInit()
  if gammaLoaded then return end
  for _,scr in ipairs(currentScreens) do storeOriginalGamma(scr._sid) end
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
function scr:setGamma(gammaTable,_hscompat) checks'hm.screen#screen' --other args checked in setgamma
  gammaInit()
  if _hscompat then gammaTable={hsGammaPoint(_hscompat),hsGammaPoint(gammaTable)} end
  return setGamma(self._sid,gammaTable)
end
--]]

----------------- Gamma ----------------------

local originalGammas,currentGammas={},{}
local function storeOriginalGamma(sid)originalGammas[sid]=cgdisplay.getGammaTable(sid)end

checkers['hm.screen#gammaAdjustTable']=function(t)
  local function color(p) return type(p)=='number' and p>=0 and p<=1 end
  local function point(t) return type(t)=='table' and color(t[1]) and color(t[2]) and color(t[3]) end
  return type(t)=='table' and coll.every(t,point) and #t==2 --for now, just blackpoint and whitepoint allowed
end

local function hsGammaPoint(t) if t[3] then return t else return {t.red,t.green,t.blue} end end
local function setGamma(sid,gammaTable) checks('uint','hm.screen#gammaAdjustTable')
  local black,white=gammaTable[1],gammaTable[2]
  local orig=originalGammas[sid] if not orig then return log.e('Cannot find gamma table for',cachedScreens[sid]) end
  local size=orig.size
  local newg=cgdisplay.makeEmptyGammaTable(size)
  for i=0,size-1 do
    for c=1,3 do newg[c][i]=black[c]+(white[c]-black[c])*orig[c][i] end
  end
  local ok,err=cgdisplay.setGammaTable(sid,newg) if not ok then return log.e('Error getting gamma table on',currentScreens[sid],':',err) end
  currentGammas[sid]=newg
  log.fi('Gamma set to %.2f,%.2f,%.2f -> %.2f,%.2f,%.2f on %s',black[1],black[2],black[3],white[1],white[2],white[3],cachedScreens[sid])
  return true
end

local function reapplyGammas()
  for sid,gammaTable in pairs(currentGammas) do cgdisplay.setGammaTable(sid,gammaTable) end
end
local function restoreGammas() cgdisplay.restoreGammaTables() currentGammas={} end

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
  elseif band(flags,kCGDisplayEnabledFlag) then -- should this restore our desired gamma?
  elseif band(flags,kCGDisplayBeginConfigurationFlag) then
  else reapplyGammaTimer:runIn(3) end
end
local function gammaInit()
  if gammaLoaded then return end
  for _,scr in ipairs(currentScreens) do storeOriginalGamma(scr._sid) end
  reapplyGammaTimer=require'hm.timer'.new(reapplyGammas)
  log.d'Registering reconfiguration callback'
  c.CGDisplayRegisterReconfigurationCallback(displayReconfigurationCallback,nil)
  gammaLoaded=true
end

function scr:getGamma() checks'hm.screen#screen'
  local g,err=cgdisplay.getGammaTable(self._sid) if not g then return log.e('Error setting gamma table on',currentScreens[sid],':',err) end
  local last=g.size-1
  return {{g[1][0],g[2][0],g[3][0]},{g[1][last],g[2][last],g[3][last]}}
end
function scr:setGamma(gammaTable,_hscompat) checks'hm.screen#screen' --other args checked in setgamma
  gammaInit()
  if _hscompat then gammaTable={hsGammaPoint(_hscompat),hsGammaPoint(gammaTable)} end
  return setGamma(self._sid,gammaTable)
end



---@private
function screens.__gc()
  if gammaLoaded then
    log.d'Removing reconfiguration callback'
    c.CGDisplayRemoveReconfigurationCallback(displayReconfigurationCallback,nil)
    log.i'Restoring original gamma tables'
    restoreGammas()
  end
end

return screens
