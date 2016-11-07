local c=require'objc'
c.debug.logtopics.addmethod=true
--c.debug.logtopics.refcount=true
c.load'Foundation'
c.load'ApplicationServices.HIServices'
c.addfunction('AXIsProcessTrustedWithOptions', {retval='B','@"NSDict"'})
if not c.AXIsProcessTrustedWithOptions(c.toobj{AXTrustedCheckOptionPrompt=1}) then
  print'Please enable accessibility!'
  os.exit()
end
c.load'AppKit'

local tolua=c.tolua

---@function [parent=#global] errorf
--@param #string fmt
--@param ...
errorf=function(fmt,...)error(sformat(fmt,...))end

---@function [parent=#global] assertf
--@param #string fmt
--@param ...
assertf=function(v,fmt,...)if not v then errorf(fmt,...) end end

---@function [parent=#global] printf
--@param #string fmt
--@param ...
printf=function(fmt,...)return print(sformat(fmt,...)) end

require'hm'
--hm._lua_setup()
--while true do end
require'hammermoon_app'(hm._lua_setup,hm._lua_destroy)

