local ffi=require'ffi'
local cast=ffi.cast
local c=require'objc'
c.load'CoreFoundation'
local tonumber=tonumber

local CFArrayGetCount,CFArrayGetValueAtIndex=c.CFArrayGetCount,c.CFArrayGetValueAtIndex

local cf=hm._core.module('hm._os.cf')

local function array(CFArrayRef,ctype)
  local r,l={},CFArrayGetCount(CFArrayRef)
  for i=0,tonumber(l)-1 do r[#r+1]=cast(ctype,CFArrayGetValueAtIndex(CFArrayRef,i)) end
  return r
end
local uint32_t=ffi.typeof'uint32_t'
function cf.array_uint32(CFArrayRef)
  local r,l={},CFArrayGetCount(CFArrayRef)
  for i=0,tonumber(l)-1 do r[#r+1]=tonumber(cast(uint32_t,CFArrayGetValueAtIndex(CFArrayRef,i))) end
  return r
end

return cf
