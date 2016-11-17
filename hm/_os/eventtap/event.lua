local c=require'objc'
local coll=require'hm.types.coll'
---Low level `CGEvent`/`NSEvent` interface
-- @module hm._os.eventtap.event
-- @static

---@type hm._os.eventtap.event
local event=hm._core.module('_os.eventtap.event',{})
local eventTypes={
  leftMouseDown=            c.kCGEventLeftMouseDown,
  leftMouseUp=              c.kCGEventLeftMouseUp,
  leftMouseDragged=         c.kCGEventLeftMouseDragged,
  rightMouseDown=           c.kCGEventRightMouseDown,
  rightMouseUp=             c.kCGEventRightMouseUp,
  rightMouseDragged=        c.kCGEventRightMouseDragged,
  middleMouseDown=          c.kCGEventOtherMouseDown,
  middleMouseUp=            c.kCGEventOtherMouseUp,
  middleMouseDragged=       c.kCGEventOtherMouseDragged,
  mouseMoved=               c.kCGEventMouseMoved,
  flagsChanged=             c.kCGEventFlagsChanged,
  scrollWheel=              c.kCGEventScrollWheel,
  keyDown=                  c.kCGEventKeyDown,
  keyUp=                    c.kCGEventKeyUp,
  tabletPointer=            c.kCGEventTabletPointer,
  tabletProximity=          c.kCGEventTabletProximity,
  nullEvent=                c.kCGEventNull,
  NSMouseEntered=           c.NSMouseEntered,
  NSMouseExited=            c.NSMouseExited,
  NSAppKitDefined=          c.NSAppKitDefined,
  NSSystemDefined=          c.NSSystemDefined,
  NSApplicationDefined=     c.NSApplicationDefined,
  NSPeriodic=               c.NSPeriodic,
  NSCursorUpdate=           c.NSCursorUpdate,
  NSEventTypeGesture=       c.NSEventTypeGesture,
  NSEventTypeMagnify=       c.NSEventTypeMagnify,
  NSEventTypeSwipe=         c.NSEventTypeSwipe,
  NSEventTypeRotate=        c.NSEventTypeRotate,
  NSEventTypeBeginGesture=  c.NSEventTypeBeginGesture,
  NSEventTypeEndGesture=    c.NSEventTypeEndGesture,
  NSEventTypeSmartMagnify=  c.NSEventTypeSmartMagnify,
  NSEventTypeQuickLook=     c.NSEventTypeQuickLook,
  NSEventTypePressure=      c.NSEventTypePressure,
--//     tapDisabledByTimeout=         c.kCGEventTapDisabledByTimeout,
--//     tapDisabledByUserInput=       c.kCGEventTapDisabledByUserInput,
}

event.types=coll.merge(eventTypes,coll.toIndex(eventTypes))

event.__gc=function()end
return event
