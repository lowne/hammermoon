# Module `hm._os.uielements`

`AXUIElement` interface



## Overview


* Module [`hm._os.uielements`](hm._os.uielements.md#module-hmosuielements)
  * [`_newElement(ax,pid)`](hm._os.uielements.md#function-hmosuielementsnewelementaxpid---uielement) -> [_`<#uielement>`_](hm._os.uielements.md#class-uielement) - function


* Class [`uielement`](hm._os.uielements.md#class-uielement)
  * [`pid`](hm._os.uielements.md#property-read-only-uielementpid-number) : _`<#number>`_ - property (read-only)
  * [`role`](hm._os.uielements.md#property-read-only-uielementrole-string) : _`<#string>`_ - property (read-only)
  * [`selectedText`](hm._os.uielements.md#property-read-only-uielementselectedtext-string) : _`<#string>`_ - property (read-only)
  * [`subrole`](hm._os.uielements.md#property-read-only-uielementsubrole-string) : _`<#string>`_ - property (read-only)
  * [`title`](hm._os.uielements.md#property-read-only-uielementtitle-string) : _`<#string>`_ - property (read-only)
  * [`size`](hm._os.uielements.md#property-uielementsize-hmtypesgeometrysize) : [_`<hm.types.geometry#size>`_](hm.types.geometry.md#type-size) - property
  * [`topLeft`](hm._os.uielements.md#property-uielementtopleft-hmtypesgeometrypoint) : [_`<hm.types.geometry#point>`_](hm.types.geometry.md#type-point) - property
  * [`getArrayProp(prop)`](hm._os.uielements.md#method-uielementgetarraypropprop---table) -> _`<#table>`_ - method
  * [`getBooleanProp(prop)`](hm._os.uielements.md#method-uielementgetbooleanpropprop---boolean) -> _`<#boolean>`_ - method
  * [`getIntegerProp(prop)`](hm._os.uielements.md#method-uielementgetintegerpropprop) - method
  * [`getPointProp(prop)`](hm._os.uielements.md#method-uielementgetpointpropprop---hmtypesgeometrypoint) -> [_`<hm.types.geometry#point>`_](hm.types.geometry.md#type-point) - method
  * [`getRawProp(prop)`](hm._os.uielements.md#method-uielementgetrawpropprop---cdata) -> _`<#cdata>`_ - method
  * [`getSizeProp(prop)`](hm._os.uielements.md#method-uielementgetsizepropprop---hmtypesgeometrysize) -> [_`<hm.types.geometry#size>`_](hm.types.geometry.md#type-size) - method
  * [`getStringProp(prop)`](hm._os.uielements.md#method-uielementgetstringpropprop---string) -> _`<#string>`_ - method
  * [`hasProp(prop)`](hm._os.uielements.md#method-uielementhaspropprop---boolean) -> _`<#boolean>`_ - method
  * [`newWatcher(fn,data)`](hm._os.uielements.md#method-uielementnewwatcherfndata---watcher) -> [_`<#watcher>`_](hm._os.uielements.md#class-watcher) - method
  * [`setArrayProp(prop)`](hm._os.uielements.md#method-uielementsetarraypropprop---boolean) -> _`<#boolean>`_ - method
  * [`setBooleanProp(prop,value)`](hm._os.uielements.md#method-uielementsetbooleanproppropvalue---boolean) -> _`<#boolean>`_ - method
  * [`setIntegerProp(prop,value)`](hm._os.uielements.md#method-uielementsetintegerproppropvalue---boolean) -> _`<#boolean>`_ - method
  * [`setPointProp(prop,value)`](hm._os.uielements.md#method-uielementsetpointproppropvalue---boolean) -> _`<#boolean>`_ - method
  * [`setRawProp(prop,value)`](hm._os.uielements.md#method-uielementsetrawproppropvalue---boolean) -> _`<#boolean>`_ - method
  * [`setSizeProp(prop,value)`](hm._os.uielements.md#method-uielementsetsizeproppropvalue---boolean) -> _`<#boolean>`_ - method
  * [`setStringProp(prop,value)`](hm._os.uielements.md#method-uielementsetstringproppropvalue---boolean) -> _`<#boolean>`_ - method
  * [`startWatcher(events,fn,data)`](hm._os.uielements.md#method-uielementstartwatchereventsfndata---watcher) -> [_`<#watcher>`_](hm._os.uielements.md#class-watcher) - method


* Class [`watcher`](hm._os.uielements.md#class-watcher)
  * [`_isActive`](hm._os.uielements.md#field-watcherisactive-boolean) : _`<#boolean>`_ - field
  * [`_watchingDestroyed`](hm._os.uielements.md#field-watcherwatchingdestroyed-) : _`<?>`_ - field
  * [`start(events)`](hm._os.uielements.md#method-watcherstartevents---watcher) -> [_`<#watcher>`_](hm._os.uielements.md#class-watcher) - method
  * [`stop()`](hm._os.uielements.md#method-watcherstop---watcher) -> [_`<#watcher>`_](hm._os.uielements.md#class-watcher) - method


* Type [`eventName`](hm._os.uielements.md#type-eventname)




* Function prototypes:
  * [`watcherCallback(element,event,watcher,data)`](hm._os.uielements.md#function-prototype-watchercallbackelementeventwatcherdata) - function prototype



------------------

## Module `hm._os.uielements`

> Extends [_`<hm#module>`_](hm.md#class-module)






### Function `hm._os.uielements._newElement(ax,pid)` -> [_`<#uielement>`_](hm._os.uielements.md#class-uielement)

> **Internal/advanced use only**



* `ax`: _`<#cdata>`_ `AXUIElementRef`
* `pid`: _`<#number>`_ (optional)



* Returns [_`<#uielement>`_](hm._os.uielements.md#class-uielement): 






------------------

## Class `uielement`

> Extends [_`<hm#module.object>`_](hm.md#class-moduleobject)





### Property (read-only) `<#uielement>.pid`: _`<#number>`_
The process identifier of the application owning this uielement.




### Property (read-only) `<#uielement>.role`: _`<#string>`_
The element's `AXRole`




### Property (read-only) `<#uielement>.selectedText`: _`<#string>`_
The element's selected text




### Property (read-only) `<#uielement>.subrole`: _`<#string>`_
The element's `AXSubrole`




### Property (read-only) `<#uielement>.title`: _`<#string>`_
The element's title




### Property `<#uielement>.size`: [_`<hm.types.geometry#size>`_](hm.types.geometry.md#type-size)
The element's size




### Property `<#uielement>.topLeft`: [_`<hm.types.geometry#point>`_](hm.types.geometry.md#type-point)
The element's top left corner




### Method `<#uielement>:getArrayProp(prop)` -> _`<#table>`_

Returns an AX property of type array

* `prop`: _`<#string>`_ property name



* Returns _`<#table>`_: 




### Method `<#uielement>:getBooleanProp(prop)` -> _`<#boolean>`_

Returns an AX property of type boolean

* `prop`: _`<#string>`_ property name



* Returns _`<#boolean>`_: 




### Method `<#uielement>:getIntegerProp(prop)`



* `prop`: _`<?>`_ 




### Method `<#uielement>:getPointProp(prop)` -> [_`<hm.types.geometry#point>`_](hm.types.geometry.md#type-point)

Returns an AX property of type point

* `prop`: _`<#string>`_ property name



* Returns [_`<hm.types.geometry#point>`_](hm.types.geometry.md#type-point): 




### Method `<#uielement>:getRawProp(prop)` -> _`<#cdata>`_

Returns an AX property without any conversion

* `prop`: _`<#string>`_ property name



* Returns _`<#cdata>`_: 




### Method `<#uielement>:getSizeProp(prop)` -> [_`<hm.types.geometry#size>`_](hm.types.geometry.md#type-size)

Returns an AX property of type size

* `prop`: _`<#string>`_ property name



* Returns [_`<hm.types.geometry#size>`_](hm.types.geometry.md#type-size): 




### Method `<#uielement>:getStringProp(prop)` -> _`<#string>`_

Returns an AX property of type string

* `prop`: _`<#string>`_ property name



* Returns _`<#string>`_: 




### Method `<#uielement>:hasProp(prop)` -> _`<#boolean>`_

Checks if this element has a given AX property

* `prop`: _`<#string>`_ 



* Returns _`<#boolean>`_: 




### Method `<#uielement>:newWatcher(fn,data)` -> [_`<#watcher>`_](hm._os.uielements.md#class-watcher)

Creates a new watcher for this element.

* `fn`: [_`<#watcherCallback>`_](hm._os.uielements.md#function-prototype-watchercallbackelementeventwatcherdata) callback function
* `data`: _`<?>`_ (optional)



* Returns [_`<#watcher>`_](hm._os.uielements.md#class-watcher): the new watcher




### Method `<#uielement>:setArrayProp(prop)` -> _`<#boolean>`_

Sets an AX property of type array

* `prop`: _`<#string>`_ property name



* Returns _`<#boolean>`_: `true` on success




### Method `<#uielement>:setBooleanProp(prop,value)` -> _`<#boolean>`_

Sets an AX property of type boolean

* `prop`: _`<#string>`_ property name
* `value`: _`<#boolean>`_ 



* Returns _`<#boolean>`_: `true` on success




### Method `<#uielement>:setIntegerProp(prop,value)` -> _`<#boolean>`_

Sets an AX property of type integer

* `prop`: _`<#string>`_ property name
* `value`: _`<#number>`_ 



* Returns _`<#boolean>`_: `true` on success




### Method `<#uielement>:setPointProp(prop,value)` -> _`<#boolean>`_

Sets an AX property of type point

* `prop`: _`<#string>`_ property name
* `value`: [_`<hm.types.geometry#point>`_](hm.types.geometry.md#type-point) 



* Returns _`<#boolean>`_: `true` on success




### Method `<#uielement>:setRawProp(prop,value)` -> _`<#boolean>`_

Sets an AX property without any conversion

* `prop`: _`<#string>`_ property name
* `value`: _`<#cdata>`_ 



* Returns _`<#boolean>`_: `true` on success




### Method `<#uielement>:setSizeProp(prop,value)` -> _`<#boolean>`_

Sets an AX property of type size

* `prop`: _`<#string>`_ property name
* `value`: [_`<hm.types.geometry#size>`_](hm.types.geometry.md#type-size) 



* Returns _`<#boolean>`_: `true` on success




### Method `<#uielement>:setStringProp(prop,value)` -> _`<#boolean>`_

Sets an AX property of type string

* `prop`: _`<#string>`_ property name
* `value`: _`<#string>`_ 



* Returns _`<#boolean>`_: `true` on success




### Method `<#uielement>:startWatcher(events,fn,data)` -> [_`<#watcher>`_](hm._os.uielements.md#class-watcher)

Creates and starts a new watcher for this element.

* `events`: `{`[_`<#eventName>`_](hm._os.uielements.md#type-eventname)`, ...}` 
* `fn`: _`<#function>`_ callback function
* `data`: _`<?>`_ (optional)



* Returns [_`<#watcher>`_](hm._os.uielements.md#class-watcher): the new watcher

This method is a shortcut for `uielem:newWatcher():start()`




------------------

## Class `watcher`

> Extends [_`<hm#module.object>`_](hm.md#class-moduleobject)

A uielement watcher



### Field `<#watcher>._isActive`: _`<#boolean>`_





### Field `<#watcher>._watchingDestroyed`: _`<?>`_





### Method `<#watcher>:start(events)` -> [_`<#watcher>`_](hm._os.uielements.md#class-watcher)

Starts this watcher

* `events`: `{`[_`<#eventName>`_](hm._os.uielements.md#type-eventname)`, ...}` events to watch



* Returns [_`<#watcher>`_](hm._os.uielements.md#class-watcher): this watcher




### Method `<#watcher>:stop()` -> [_`<#watcher>`_](hm._os.uielements.md#class-watcher)

Stops this watcher



* Returns [_`<#watcher>`_](hm._os.uielements.md#class-watcher): this watcher






------------------

### Type `eventName`

> Extends _`<#string>`_

An event name.

Valid event names are: `"applicationActivated"`, `"applicationDeactivated"`, `"applicationHidden"`, `"applicationShown"`,
`"mainWindowChanged"`, `"focusedWindowChanged"`, `"focusedElementChanged"`, `"windowCreated"`, `"windowMoved"`,
`"windowResized"`, `"windowMinimized"`, `"windowUnminimized"`, `"elementDestroyed"`, `"titleChanged"`.




------------------

### Function prototype `watcherCallback(element,event,watcher,data)`



* `element`: [_`<#uielement>`_](hm._os.uielements.md#class-uielement) that caused the event; note that this is not necessarily the same as the element being watched
* `event`: [_`<#eventName>`_](hm._os.uielements.md#type-eventname) 
* `watcher`: [_`<#watcher>`_](hm._os.uielements.md#class-watcher) that triggered the callback
* `data`: _`<?>`_ 




