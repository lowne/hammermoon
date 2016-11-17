local c=require'objc'
c.load'AppKit'

local NSApp=c.class('NSApp','NSApplication <NSApplicationDelegate>')
function NSApp:applicationWillFinishLaunching() end
function NSApp:applicationDidFinishLaunching() hm._lua_setup() end
function NSApp:applicationShouldTerminateAfterLastWindowClosed() return true end
function NSApp:applicationShouldTerminate()  os.exit(1,1) end

local app=NSApp:sharedApplication()
app:setDelegate(app)
app:setActivationPolicy(c.NSApplicationActivationPolicyRegular)

local NSWin=c.class('NSWin','NSWindow <NSWindowDelegate>')
function NSWin:windowWillClose()
--  print'window will close...'
end

local style = bit.bor(
  c.NSTitledWindowMask,
  c.NSClosableWindowMask,
  c.NSMiniaturizableWindowMask,
  c.NSResizableWindowMask)

local win = NSWin:alloc():initWithContentRect_styleMask_backing_defer(
  c.NSMakeRect(300, 300, 500, 300), style, c.NSBackingStoreBuffered, false)
win:setReleasedWhenClosed(false)
win:setDelegate(win)
win:setTitle"Hammermoon"

app:activateIgnoringOtherApps(true)
win:makeKeyAndOrderFront(nil)
win.alphaValue=0.5


local ok,err=pcall(app.run,app)
if not ok then
  local s,e=err:find('[NSApp run]',1,true)
  if e then err=err:sub(e+1) end
  io.stderr:write('\n\n[RUNTIME ERROR] ------------\n'..err..'\n----------------------------\n\n')
  io.stderr:flush()
  os.exit(1,1)
end

