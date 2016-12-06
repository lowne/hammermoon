local next=next
local ffi=require'ffi'
local C=ffi.C
local c=require'objc' -- lib.objc#objc
local bridge,IN,OUT,OUT_R=c.bridge,c.bridge.IN,c.bridge.OUT,c.bridge.OUT_RETAINED
local tolua,toobj=c.tolua,c.toobj
c.load'CoreGraphics'
c.load'IOKit'
--c.cdef'CGDisplayIOServicePort'
-- CoreGraphics private APIs with support for scaled (retina) display modes
c.addfunction('CGSGetCurrentDisplayMode',{'I','^i'},false);
c.addfunction('CGSConfigureDisplayMode',{'^v','I','i'},false)
c.addfunction('CGSGetNumberOfDisplayModes',{'I','^i'},false)
c.addfunction('CGSGetDisplayModeDescriptionOfLength',{'I','i','^v','i'},false)
--c.addfunction('IODisplayCreateInfoDictionary',{retval='@"NSDictionary"','U','U'})

-- CoreGraphics DisplayMode struct used in private APIs
ffi.cdef[[
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


local cgdisplay=hm._core.module('hm._os.cgdisplay')

cgdisplay.getIOPort=c.CGDisplayIOServicePort

--c.cdef'kIODisplayOnlyPreferredName'
--local displayGetInfoDict=bridge.fn(OUT_R('CFDictionaryRef','CFStringRef','CFDictionaryRef'),'IODisplayCreateInfoDictionary','I','I')
local displayInfoDictTypes={
  ['DisplayProductName']=OUT('CFDictionaryRef','CFStringRef','CFStringRef'),
--  ['DisplayHorizontalImageSize']='CFNumberRef',
--  ['DisplayVerticalImageSize']='CFNumberRef',
}

local displayGetInfoDict=bridge.fn(OUT_R('CFDictionaryRef','CFStringRef',displayInfoDictTypes),'IODisplayCreateInfoDictionary','I','I')
--local displayGetInfoDict=bridge.fn(OUT_R('CFDictionaryRef:lazytable',IN'CFStringRef',displayInfoDictTypes),'IODisplayCreateInfoDictionary','I','I')
function cgdisplay.getInfo(sid,flags) return displayGetInfoDict(cgdisplay.getIOPort(sid),flags) end
function cgdisplay.getName(sid)
  local locale,name=next(cgdisplay.getInfo(sid,c.kIODisplayOnlyPreferredName).DisplayProductName)
  --  local locale,name=next(cgdisplay.getInfo(sid,c.kIODisplayOnlyPreferredName)[c.kDisplayProductName])
  return name
end

local idx_out=ffi.new'int[1]'
local mode_out=ffi.new'CGSDisplayMode[1]'
local config_out=ffi.new'CGDisplayConfigRef[1]'


local screenModes={}

function cgdisplay.currentMode(sid)
  if not screenModes[sid] then cgdisplay.availableModes(sid) end
  C.CGSGetCurrentDisplayMode(sid,idx_out)
  return screenModes[sid][idx_out[0]]
    --  C.CGSGetDisplayModeDescriptionOfLength(sid,idx_out[0],mode_out,CGSDisplayMode_size)
    --  return mode_out[0]
end

function cgdisplay.availableModes(sid)
  if screenModes[sid] then return screenModes[sid] end
  local r={}
  C.CGSGetNumberOfDisplayModes(sid,idx_out)
  for i=0,idx_out[0]-1 do
    C.CGSGetDisplayModeDescriptionOfLength(sid,i,mode_out,CGSDisplayMode_size)
    local m=mode_out[0]
    r[m.modeNumber]={idx=m.modeNumber,width=m.width,height=m.height,depth=m.depth,freq=m.freq,scale=m.density}
  end
  screenModes[sid]=r
  return r
end

local kCGConfigurePermanently=c.kCGConfigurePermanently
---
-- @return #boolean `true` on success
-- @return #nil,#string on error
function cgdisplay.setMode(sid,mode_idx)
  C.CGBeginDisplayConfiguration(config_out)
  C.CGSConfigureDisplayMode(config_out[0],sid,mode_idx)
  local res=C.CGCompleteDisplayConfiguration(config_out[0],kCGConfigurePermanently)
  if res==0 then return true else return nil,require'hm._os.bridge.cgerror'[res] end
end
return cgdisplay
