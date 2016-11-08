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

require'hm'

require'hammermoon_app'(hm._lua_setup,hm._lua_destroy)

