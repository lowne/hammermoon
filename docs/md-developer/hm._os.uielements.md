# Module `hm._os.uielements`

`AXUIElement` interface



## Overview


* Module [`hm._os.uielements`](hm._os.uielements.md#module-hmosuielements)
  * [`newElement(ax,pid)`](hm._os.uielements.md#function-hmosuielementsnewelementaxpid---uielement) -> [_`<#uielement>`_](hm._os.uielements.md#class-uielement) - function
  * [`newElementForApplication(pid)`](hm._os.uielements.md#function-hmosuielementsnewelementforapplicationpid---uielement) -> [_`<#uielement>`_](hm._os.uielements.md#class-uielement) - function


* Class [`uielement`](hm._os.uielements.md#class-uielement)
  * [`pid`](hm._os.uielements.md#property-read-only-uielementpid-number) : _`<#number>`_ - property (read-only)
  * [`role`](hm._os.uielements.md#property-read-only-uielementrole-string) : _`<#string>`_ - property (read-only)
  * [`selectedText`](hm._os.uielements.md#property-read-only-uielementselectedtext-string) : _`<#string>`_ - property (read-only)
  * [`subrole`](hm._os.uielements.md#property-read-only-uielementsubrole-string) : _`<#string>`_ - property (read-only)
  * [`title`](hm._os.uielements.md#property-read-only-uielementtitle-string) : _`<#string>`_ - property (read-only)
  * [`actions`](hm._os.uielements.md#field-uielementactions-) : _`<?>`_ - field
  * [`attrs`](hm._os.uielements.md#field-uielementattrs-) : _`<?>`_ - field
  * [`size`](hm._os.uielements.md#property-uielementsize-hmtypesgeometrysize) : [_`<hm.types.geometry#size>`_](hm.types.geometry.md#type-size) - property
  * [`topLeft`](hm._os.uielements.md#property-uielementtopleft-hmtypesgeometrypoint) : [_`<hm.types.geometry#point>`_](hm.types.geometry.md#type-point) - property
  * [`cancel()`](hm._os.uielements.md#method-uielementcancel---boolean) -> _`<#boolean>`_ - method
  * [`click()`](hm._os.uielements.md#method-uielementclick---boolean) -> _`<#boolean>`_ - method
  * [`confirm()`](hm._os.uielements.md#method-uielementconfirm---boolean) -> _`<#boolean>`_ - method
  * [`getArray(attr,default)`](hm._os.uielements.md#method-uielementgetarrayattrdefault) - method
  * [`getBool(attr)`](hm._os.uielements.md#method-uielementgetboolattr---boolean) -> _`<#boolean>`_ - method
  * [`getInt(attr,default)`](hm._os.uielements.md#method-uielementgetintattrdefault---number) -> _`<#number>`_ - method
  * [`getPoint(attr)`](hm._os.uielements.md#method-uielementgetpointattr---hmtypesgeometrypoint) -> [_`<hm.types.geometry#point>`_](hm.types.geometry.md#type-point) - method
  * [`getRaw(attr)`](hm._os.uielements.md#method-uielementgetrawattr---cdata) -> _`<#cdata>`_ - method
  * [`getSize(attr)`](hm._os.uielements.md#method-uielementgetsizeattr---hmtypesgeometrysize) -> [_`<hm.types.geometry#size>`_](hm.types.geometry.md#type-size) - method
  * [`getString(attr,default)`](hm._os.uielements.md#method-uielementgetstringattrdefault) - method
  * [`getWindowID()`](hm._os.uielements.md#method-uielementgetwindowid) - method
  * [`hasAttr(attr)`](hm._os.uielements.md#method-uielementhasattrattr---boolean) -> _`<#boolean>`_ - method
  * [`newWatcher(fn,data)`](hm._os.uielements.md#method-uielementnewwatcherfndata---watcher) -> [_`<#watcher>`_](hm._os.uielements.md#class-watcher) - method
  * [`setBool(attr,value)`](hm._os.uielements.md#method-uielementsetboolattrvalue) - method
  * [`setInt(attr,value)`](hm._os.uielements.md#method-uielementsetintattrvalue---boolean) -> _`<#boolean>`_ - method
  * [`setPoint(prop,value)`](hm._os.uielements.md#method-uielementsetpointpropvalue) - method
  * [`setRaw(attr,value)`](hm._os.uielements.md#method-uielementsetrawattrvalue---boolean) -> _`<#boolean>`_ - method
  * [`setSize(prop,value)`](hm._os.uielements.md#method-uielementsetsizepropvalue) - method
  * [`setString(attr,value)`](hm._os.uielements.md#method-uielementsetstringattrvalue) - method
  * [`startWatcher(events,fn,data)`](hm._os.uielements.md#method-uielementstartwatchereventsfndata---watcher) -> [_`<#watcher>`_](hm._os.uielements.md#class-watcher) - method


* Class [`watcher`](hm._os.uielements.md#class-watcher)
  * [`_isActive`](hm._os.uielements.md#field-watcherisactive-boolean) : _`<#boolean>`_ - field
  * [`_watchingDestroyed`](hm._os.uielements.md#field-watcherwatchingdestroyed-) : _`<?>`_ - field
  * [`start(events)`](hm._os.uielements.md#method-watcherstartevents---watcher) -> [_`<#watcher>`_](hm._os.uielements.md#class-watcher) - method
  * [`stop()`](hm._os.uielements.md#method-watcherstop---watcher) -> [_`<#watcher>`_](hm._os.uielements.md#class-watcher) - method


* Type [`eventName`](hm._os.uielements.md#type-eventname)




* Function prototypes
  * [`watcherCallback(element,event,watcher,data)`](hm._os.uielements.md#function-prototype-watchercallbackelementeventwatcherdata) - function prototype



------------------

## Module `hm._os.uielements`

> Extends [_`<hm#module>`_](hm.md#class-module)






### Function `hm._os.uielements.newElement(ax,pid)` -> [_`<#uielement>`_](hm._os.uielements.md#class-uielement)



* `ax`: _`<#cdata>`_ `AXUIElementRef`
* `pid`: _`<#number>`_ (optional)



* Returns [_`<#uielement>`_](hm._os.uielements.md#class-uielement): 




### Function `hm._os.uielements.newElementForApplication(pid)` -> [_`<#uielement>`_](hm._os.uielements.md#class-uielement)



* `pid`: _`<#number>`_ 



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




### Field `<#uielement>.actions`: _`<?>`_





### Field `<#uielement>.attrs`: _`<?>`_





### Property `<#uielement>.size`: [_`<hm.types.geometry#size>`_](hm.types.geometry.md#type-size)
The element's size




### Property `<#uielement>.topLeft`: [_`<hm.types.geometry#point>`_](hm.types.geometry.md#type-point)
The element's top left corner




### Method `<#uielement>:cancel()` -> _`<#boolean>`_

Performs a cancel action on this element



* Returns _`<#boolean>`_: `true` if successful




### Method `<#uielement>:click()` -> _`<#boolean>`_

Clicks this element



* Returns _`<#boolean>`_: `true` if successful




### Method `<#uielement>:confirm()` -> _`<#boolean>`_

Performs a confirm action on this element



* Returns _`<#boolean>`_: `true` if successful




### Method `<#uielement>:getArray(attr,default)`



* `attr`: _`<?>`_ 
* `default`: _`<?>`_ 




### Method `<#uielement>:getBool(attr)` -> _`<#boolean>`_

Returns an AX attribute of type boolean

* `attr`: _`<#string>`_ attribute name



* Returns _`<#boolean>`_: 




### Method `<#uielement>:getInt(attr,default)` -> _`<#number>`_

Returns an AX attribute of type integer

* `attr`: _`<#string>`_ attribute name
* `default`: _`<?>`_ default value



* Returns _`<#number>`_: 




### Method `<#uielement>:getPoint(attr)` -> [_`<hm.types.geometry#point>`_](hm.types.geometry.md#type-point)

Returns an AX attribute of type point

* `attr`: _`<#string>`_ attribute name



* Returns [_`<hm.types.geometry#point>`_](hm.types.geometry.md#type-point): 




### Method `<#uielement>:getRaw(attr)` -> _`<#cdata>`_

Returns an AX attribute without any conversion

* `attr`: _`<#string>`_ attribute name



* Returns _`<#cdata>`_: 




### Method `<#uielement>:getSize(attr)` -> [_`<hm.types.geometry#size>`_](hm.types.geometry.md#type-size)

Returns an AX attribute of type size

* `attr`: _`<#string>`_ attribute name



* Returns [_`<hm.types.geometry#size>`_](hm.types.geometry.md#type-size): 




### Method `<#uielement>:getString(attr,default)`



* `attr`: _`<?>`_ 
* `default`: _`<?>`_ 




### Method `<#uielement>:getWindowID()`






### Method `<#uielement>:hasAttr(attr)` -> _`<#boolean>`_

Checks if this element has a given AX attribute

* `attr`: _`<#string>`_ 



* Returns _`<#boolean>`_: 




### Method `<#uielement>:newWatcher(fn,data)` -> [_`<#watcher>`_](hm._os.uielements.md#class-watcher)

Creates a new watcher for this element.

* `fn`: [_`<#watcherCallback>`_](hm._os.uielements.md#function-prototype-watchercallbackelementeventwatcherdata) callback function
* `data`: _`<?>`_ (optional)



* Returns [_`<#watcher>`_](hm._os.uielements.md#class-watcher): the new watcher




### Method `<#uielement>:setBool(attr,value)`



* `attr`: _`<?>`_ 
* `value`: _`<?>`_ 




### Method `<#uielement>:setInt(attr,value)` -> _`<#boolean>`_

Sets an AX attribute of type integer

* `attr`: _`<#string>`_ attribute name
* `value`: _`<#number>`_ 



* Returns _`<#boolean>`_: `true` on success




### Method `<#uielement>:setPoint(prop,value)`



* `prop`: _`<?>`_ 
* `value`: _`<?>`_ 




### Method `<#uielement>:setRaw(attr,value)` -> _`<#boolean>`_

Sets an AX attribute without any conversion

* `attr`: _`<#string>`_ attribute name
* `value`: _`<#cdata>`_ 



* Returns _`<#boolean>`_: `true` on success




### Method `<#uielement>:setSize(prop,value)`



* `prop`: _`<?>`_ 
* `value`: _`<?>`_ 




### Method `<#uielement>:setString(attr,value)`



* `attr`: _`<?>`_ 
* `value`: _`<?>`_ 




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




