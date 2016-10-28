local c=require'objc'
c.load'AppKit'
local function appSetup(didFinishLaunchingCB,shouldTerminateCB)
  local NSApp=c.class('NSApp','NSApplication <NSApplicationDelegate>')
  function NSApp:applicationWillFinishLaunching()
  end
  function NSApp:applicationDidFinishLaunching()
    print'finished launching...'
    didFinishLaunchingCB()
  end
  function NSApp:applicationShouldTerminateAfterLastWindowClosed()
    print'last window closed...'
    collectgarbage()
    return true
  end
  function NSApp:applicationShouldTerminate()
    print'bye!'
    shouldTerminateCB()
    return true
  end
  local app=NSApp:sharedApplication()
  app:setDelegate(app)
  app:setActivationPolicy(c.NSApplicationActivationPolicyRegular)

  local NSWin=c.class('NSWin','NSWindow <NSWindowDelegate>')
  function NSWin:windowWillClose()
    print'window will close...'
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
  app:run()
end

return appSetup
