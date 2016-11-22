local coll=require'hm.types.coll'
local events=coll.dict{
  applicationActivated   = "AXApplicationActivated",
  applicationDeactivated = "AXApplicationDeactivated",
  applicationHidden      = "AXApplicationHidden",
  applicationShown       = "AXApplicationShown",

  mainWindowChanged     = "AXMainWindowChanged",
  focusedWindowChanged  = "AXFocusedWindowChanged",
  focusedElementChanged = "AXFocusedUIElementChanged",

  windowCreated     = "AXWindowCreated",
  windowMoved       = "AXWindowMoved",
  windowResized     = "AXWindowResized",
  windowMinimized   = "AXWindowMiniaturized",
  windowUnminimized = "AXWindowDeminiaturized",

  elementDestroyed = "AXUIElementDestroyed",
  titleChanged     = "AXTitleChanged",
}

return setmetatable(events,{__tostring=function()return events:toList():tostring()end})
