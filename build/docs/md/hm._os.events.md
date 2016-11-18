# Module `hm._os.events`

Low level `CGEvent`/`NSEvent` interface



## Overview


| Module [hm._os.events](hm._os.events.md#module-hmosevents-extends-hmmodule) |  |
| :--- | :---
Function [`hm._os.events.eventtap(events,fn)`](hm._os.events.md#function-hmoseventseventtapeventsfn---eventtap) -> [_`<#eventtap>`_](hm._os.events.md#type-eventtap-extends-hmmoduleobject) | Creates an eventtap.
Function [`hm._os.events.key(code,isDown)`](hm._os.events.md#function-hmoseventskeycodeisdown) | 
Field [`hm._os.events.types`](hm._os.events.md#field-hmoseventstypes--eventtype-number-) : `{ [`[_`<#eventType>`_](hm._os.events.md#type-eventtype-extends-string)`] =`_`<#number>`_`, ...}` | 


| Type [<#event>](hm._os.events.md#type-event-extends-hmmoduleobject) |  |
| :--- | :---
Method [`<#event>:getFlags()`](hm._os.events.md#method-eventgetflags) | 
Method [`<#event>:getKeyCode()`](hm._os.events.md#method-eventgetkeycode) | 


| Type [<#eventType>](hm._os.events.md#type-eventtype-extends-string) | A string describing an event type. |
| :--- | :---


| Type [<#eventtap>](hm._os.events.md#type-eventtap-extends-hmmoduleobject) |  |
| :--- | :---






------------------

## Module `hm._os.events` (extends [_`<hm#module>`_](hm.md#class-module))






### Function `hm._os.events.eventtap(events,fn)` -> [_`<#eventtap>`_](hm._os.events.md#type-eventtap-extends-hmmoduleobject)

Creates an eventtap.

**Parameters:**

* _`<#table>`_ `events`: a list of [_`<#eventType>`_](hm._os.events.md#type-eventtype-extends-string)s of interest
* _`<#function>`_ `fn`: callback function that will receive the bare `CGEvent` as its sole argument

**Returns:**

* [_`<#eventtap>`_](hm._os.events.md#type-eventtap-extends-hmmoduleobject) 




### Function `hm._os.events.key(code,isDown)`



**Parameters:**

* _`<?>`_ `code`: 
* _`<?>`_ `isDown`: 




### Field `hm._os.events.types`: `{ [`[_`<#eventType>`_](hm._os.events.md#type-eventtype-extends-string)`] =`_`<#number>`_`, ...}`






------------------

### Type `<#event>` (extends [_`<hm#module.object>`_](hm.md#class-moduleobject))






### Method `<#event>:getFlags()`






### Method `<#event>:getKeyCode()`








------------------

### Type `<#eventType>` (extends _`<#string>`_)

A string describing an event type.

Valid values are: `"leftMouseDown"`,`"leftMouseUp"`,`"leftMouseDragged"`,`"rightMouseDown"`,`"rightMouseUp"`,`"rightMouseDragged"`,
`"middleMouseDown"`,`"middleMouseUp"`,`"middleMouseDragged"`,`"mouseMoved"`,`"flagsChanged"`,`"scrollWheel"`,`"keyDown"`,`"keyUp"`,
`"tabletPointer"`,`"tabletProximity"`,`"nullEvent"`,`"NSMouseEntered"`,`"NSMouseExited"`,`"NSAppKitDefined"`,`"NSSystemDefined"`,
`"NSApplicationDefined"`,`"NSPeriodic"`,`"NSCursorUpdate"`,`"NSEventTypeGesture"`,`"NSEventTypeMagnify"`,`"NSEventTypeSwipe"`,
`"NSEventTypeRotate"`,`"NSEventTypeBeginGesture"`,`"NSEventTypeEndGesture"`,`"NSEventTypeSmartMagnify"`,`"NSEventTypeQuickLook"`,
`"NSEventTypePressure"`,`"tapDisabledByTimeout"`,`"tapDisabledByUserInput"`



------------------

### Type `<#eventtap>` (extends [_`<hm#module.object>`_](hm.md#class-moduleobject))






