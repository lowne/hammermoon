local ffi=require'ffi'
local c=require'objc'
local tolua,toobj=c.tolua,c.toobj
c.load'CoreFoundation'
c.load'CoreGraphics'
c.addfunction('CGWindowListCreate',{retval='^v','I','I'})

local cgwindow=hm._core.module('hm._os.cgwindow')

--local array_ret=ffi.new'CFArrayRef'
local array_uint32=require'hm._os.cf'.array_uint32

function cgwindow.getWIDList(visibleOnly)
  local array_ret=c.CGWindowListCreate(c.kCGWindowListExcludeDesktopElements+(visibleOnly and c.kCGWindowListOptionOnScreenOnly or 0),c.kCGNullWindowID)
  local r=array_uint32(array_ret)
  c.CFRelease(array_ret)
  return r
end
return cgwindow
