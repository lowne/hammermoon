local ffi=require'ffi'
local C,cast,gc=ffi.C,ffi.cast,ffi.gc
local c=require'objc'
--c.load'CoreFoundation'
c.load'CoreFoundation'
--release for all! \o/
--c.addfunction('CFRelease',{'^v'},false)
c.addfunction('CFHash',{retval='Q','^v'},false)

local tonumber=tonumber

local cf=hm._core.module('hm._os.cf')

local kCFNumberIntType=c.kCFNumberIntType
local int_out=ffi.new'int[1]'
--local CFNumberGetValue=c.CFNumberGetValue
--local function getNumber(CFNumberRef,CFNumberType)
--  C.CFNumberGetValue(CFNumberRef,CFNumberType,number_out)
--  return number_out[0]
--end
function cf.getInt(CFNumberRef)
  C.CFNumberGetValue(CFNumberRef,kCFNumberIntType,int_out)
  return int_out[0]
end
function cf.makeInt(v)
  int_out[0]=v
  return gc(C.CFNumberCreate(nil,kCFNumberIntType,int_out),C.CFRelease)
end

local kCFNumberDoubleType=c.kCFNumberDoubleType
local double_out=ffi.new'double[1]'
function cf.getDouble(CFNumberRef)
  C.CFNumberGetValue(CFNumberRef,kCFNumberDoubleType,double_out)
  return double_out[0]
end
function cf.makeDouble(v)
  double_out[0]=v
  return gc(C.CFNumberCreate(nil,kCFNumberDoubleType,int_out),C.CFRelease)
end

--function cf.getBoolean(CFBooleanRef) return getNumber(CFBooleanRef,9)~=0 end
--local CFBooleanGetValue=c.CFBooleanGetValue
function cf.getBoolean(CFBooleanRef) return C.CFBooleanGetValue(CFBooleanRef) end

local string_out=ffi.new'char[512]'
local ctostring=ffi.string
local kCFStringEncodingUTF8=c.kCFStringEncodingUTF8
c.cdef'CFStringGetCString'
function cf.getString(CFStringRef)
  C.CFStringGetCString(CFStringRef,string_out,512,kCFStringEncodingUTF8);
  return ctostring(string_out)
end

--bridgesupport mistakenly has char* instead of const char* for 2nd arg >:{
c.addfunction('CFStringCreateWithCString',{retval='^{__CFString=}','^{__CFAllocator=}','r*','I'},false)
function cf.makeString(s)
  return gc(C.CFStringCreateWithCString(nil,s,kCFStringEncodingUTF8),C.CFRelease)
end

--local interned={}
--function cf.makeString(s)
--  hmassert(not interned[s]) interned[s]=true --debug
--  return C.CFStringCreateWithCString(nil,s,kCFStringEncodingUTF8)
--end

--local CFArrayGetCount,CFArrayGetValueAtIndex=c.CFArrayGetCount,c.CFArrayGetValueAtIndex
c.cdef'CFArrayGetCount' c.cdef'CFArrayGetValueAtIndex'
function cf.getArray(CFArrayRef,ctype)
  local r,l={},C.CFArrayGetCount(CFArrayRef)
  if ctype then for i=0,tonumber(l)-1 do r[#r+1]=cast(ctype,C.CFArrayGetValueAtIndex(CFArrayRef,i)) end
  else for i=0,tonumber(l)-1 do r[#r+1]=C.CFArrayGetValueAtIndex(CFArrayRef,i) end end
  return r
end
local uint32_t=ffi.typeof'uint32_t'
function cf.getArray_uint32(CFArrayRef)
  local r,l={},C.CFArrayGetCount(CFArrayRef)
  for i=0,tonumber(l)-1 do r[#r+1]=tonumber(cast(uint32_t,C.CFArrayGetValueAtIndex(CFArrayRef,i))) end
  return r
end


return cf
