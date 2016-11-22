# Module `hm._os.events`

`CGEvent`/`NSEvent` interface



## Overview


* Module [`hm._os.events`](hm._os.events.md#module-hmosevents)
  * [`eventtap(events,fn)`](hm._os.events.md#function-hmoseventseventtapeventsfn---eventtap) -> [_`<#eventtap>`_](hm._os.events.md#type-eventtap) - function
  * [`keyEvent(code,isDown)`](hm._os.events.md#function-hmoseventskeyeventcodeisdown---event) -> [_`<#event>`_](hm._os.events.md#type-event) - function
  * [`types`](hm._os.events.md#field-hmoseventstypes--eventtype-number-) : `{ [`[_`<#eventType>`_](hm._os.events.md#type-eventtype)`] =`_`<#number>`_`, ...}` - field


* Type [`event`](hm._os.events.md#type-event)
  * [`copy()`](hm._os.events.md#function-eventcopy---event) -> [_`<#event>`_](hm._os.events.md#type-event) - function
  * [`getCharacter(ignoreModifiers)`](hm._os.events.md#method-eventgetcharacterignoremodifiers---string-or-nil) -> _`<#string>`_ or _`nil`_ - method
  * [`getKeyCode()`](hm._os.events.md#method-eventgetkeycode---number) -> _`<#number>`_ - method
  * [`getMods()`](hm._os.events.md#method-eventgetmods---table) -> _`<#table>`_ - method
  * [`getType()`](hm._os.events.md#method-eventgettype---number) -> _`<#number>`_ - method
  * [`post(beforeTaps)`](hm._os.events.md#method-eventpostbeforetaps---event) -> [_`<#event>`_](hm._os.events.md#type-event) - method
  * [`postToApplication(application)`](hm._os.events.md#method-eventposttoapplicationapplication---event) -> [_`<#event>`_](hm._os.events.md#type-event) - method
  * [`setKeyCode(code)`](hm._os.events.md#method-eventsetkeycodecode---event) -> [_`<#event>`_](hm._os.events.md#type-event) - method
  * [`setMods(mods)`](hm._os.events.md#method-eventsetmodsmods---event) -> [_`<#event>`_](hm._os.events.md#type-event) - method


* Type [`eventType`](hm._os.events.md#type-eventtype)


* Type [`eventtap`](hm._os.events.md#type-eventtap)
  * [`isActive()`](hm._os.events.md#method-eventtapisactive) - method
  * [`start()`](hm._os.events.md#method-eventtapstart) - method
  * [`stop()`](hm._os.events.md#method-eventtapstop) - method






------------------

## Module `hm._os.events`

> extends [_`<hm#module>`_](hm.md#class-module)






### Function `hm._os.events.eventtap(events,fn)` -> [_`<#eventtap>`_](hm._os.events.md#type-eventtap)

Creates an eventtap.

* `events`: _`<#table>`_ a list of [_`<#eventType>`_](hm._os.events.md#type-eventtype)s of interest
* `fn`: _`<#function>`_ callback function that will receive the [_`<#event>`_](hm._os.events.md#type-event) as its sole argument



* Returns [_`<#eventtap>`_](hm._os.events.md#type-eventtap): 




### Function `hm._os.events.keyEvent(code,isDown)` -> [_`<#event>`_](hm._os.events.md#type-event)

Creates a new key event

* `code`: _`<#number>`_ 
* `isDown`: _`<#boolean>`_ `true` for key press, `false` for key release



* Returns [_`<#event>`_](hm._os.events.md#type-event): the new event




### Field `hm._os.events.types`: `{ [`[_`<#eventType>`_](hm._os.events.md#type-eventtype)`] =`_`<#number>`_`, ...}`






------------------

### Type `event`

> extends [_`<hm#module.object>`_](hm.md#class-moduleobject)






### Function `<#event>.copy()` -> [_`<#event>`_](hm._os.events.md#type-event)

Returns a copy of the event.



* Returns [_`<#event>`_](hm._os.events.md#type-event): a new copy of this event




### Method `<#event>:getCharacter(ignoreModifiers)` -> _`<#string>`_ or _`nil`_

Returns the Unicode representation of this keyboard event.

* `ignoreModifiers`: _`<#boolean>`_ if `true`, modifier keys in this event other than 'shift' will be ignored



* Returns _`<#string>`_: 
* Returns _`nil`_: if a character representation cannot be found




### Method `<#event>:getKeyCode()` -> _`<#number>`_

Returns the key code for this keyboard event.



* Returns _`<#number>`_: 




### Method `<#event>:getMods()` -> _`<#table>`_

Returns the modifier keys for this keyboard event.



* Returns _`<#table>`_: {modKeyCode=true,...}




### Method `<#event>:getType()` -> _`<#number>`_

Returns the event type



* Returns _`<#number>`_: 




### Method `<#event>:post(beforeTaps)` -> [_`<#event>`_](hm._os.events.md#type-event)

Posts the event to the OS or to an application.

* `beforeTaps`: _`<#boolean>`_ if `true`, running eventtaps will recapture the posted event



* Returns [_`<#event>`_](hm._os.events.md#type-event): this event




### Method `<#event>:postToApplication(application)` -> [_`<#event>`_](hm._os.events.md#type-event)

Posts the event to an application.

* `application`: [_`<hm.applications#application>`_](hm.applications.md#class-application) 



* Returns [_`<#event>`_](hm._os.events.md#type-event): this event




### Method `<#event>:setKeyCode(code)` -> [_`<#event>`_](hm._os.events.md#type-event)

Sets the key code for this keyboard event.

* `code`: _`<#number>`_ 



* Returns [_`<#event>`_](hm._os.events.md#type-event): this event




### Method `<#event>:setMods(mods)` -> [_`<#event>`_](hm._os.events.md#type-event)

Sets the modifier keys for this keyboard event.

* `mods`: _`<#table>`_ {modKeyCode=true,...}



* Returns [_`<#event>`_](hm._os.events.md#type-event): this event






------------------

### Type `eventType`

> extends _`<#string>`_

A string describing an event type.

Valid values are: `"leftMouseDown"`,`"leftMouseUp"`,`"leftMouseDragged"`,`"rightMouseDown"`,`"rightMouseUp"`,`"rightMouseDragged"`,
`"middleMouseDown"`,`"middleMouseUp"`,`"middleMouseDragged"`,`"mouseMoved"`,`"flagsChanged"`,`"scrollWheel"`,`"keyDown"`,`"keyUp"`,
`"tabletPointer"`,`"tabletProximity"`,`"nullEvent"`,`"NSMouseEntered"`,`"NSMouseExited"`,`"NSAppKitDefined"`,`"NSSystemDefined"`,
`"NSApplicationDefined"`,`"NSPeriodic"`,`"NSCursorUpdate"`,`"NSEventTypeGesture"`,`"NSEventTypeMagnify"`,`"NSEventTypeSwipe"`,
`"NSEventTypeRotate"`,`"NSEventTypeBeginGesture"`,`"NSEventTypeEndGesture"`,`"NSEventTypeSmartMagnify"`,`"NSEventTypeQuickLook"`,
`"NSEventTypePressure"`,`"tapDisabledByTimeout"`,`"tapDisabledByUserInput"`



------------------

### Type `eventtap`

> extends [_`<hm#module.object>`_](hm.md#class-moduleobject)






### Method `<#eventtap>:isActive()`

Returns `true` if the eventtap is currently active.




### Method `<#eventtap>:start()`

Starts the eventtap.




### Method `<#eventtap>:stop()`

Stops the eventtap.





