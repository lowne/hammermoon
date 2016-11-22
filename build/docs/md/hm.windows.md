# Module `hm.windows`

Manage windows



## Overview


* Module [`hm.windows`](hm.windows.md#module-hmwindows)
  * [`_newWindow(ax,pid,wid)`](hm.windows.md#function-hmwindowsnewwindowaxpidwid---window) -> [_`<#window>`_](hm.windows.md#class-window) - function
  * [`allWindows`](hm.windows.md#property-read-only-hmwindowsallwindows-window-) : `{`[_`<#window>`_](hm.windows.md#class-window)`, ...}` - property (read-only)
  * [`focusedWindow`](hm.windows.md#property-hmwindowsfocusedwindow-window) : [_`<#window>`_](hm.windows.md#class-window) - property
  * [`visibleWindows`](hm.windows.md#property-read-only-hmwindowsvisiblewindows-window-) : `{`[_`<#window>`_](hm.windows.md#class-window)`, ...}` - property (read-only)


* Class [`window`](hm.windows.md#class-window)
  * [`newWatcher(fn,data)`](hm.windows.md#method-windownewwatcherfndata---hmosuielementswatcher) -> [_`<hm._os.uielements#watcher>`_](hm._os.uielements.md#class-watcher) - method
  * [`startWatcher(events,fn,data)`](hm.windows.md#method-windowstartwatchereventsfndata---hmosuielementswatcher) -> [_`<hm._os.uielements#watcher>`_](hm._os.uielements.md#class-watcher) - method
  * [`application`](hm.windows.md#property-read-only-windowapplication-hmapplicationsapplication) : [_`<hm.applications#application>`_](hm.applications.md#class-application) - property (read-only)
  * [`frame`](hm.windows.md#property-windowframe-hmtypesgeometryrect) : [_`<hm.types.geometry#rect>`_](hm.types.geometry.md#type-rect) - property
  * [`hidden`](hm.windows.md#property-windowhidden-boolean) : _`<#boolean>`_ - property
  * [`id`](hm.windows.md#property-read-only-windowid-number) : _`<#number>`_ - property (read-only)
  * [`minimized`](hm.windows.md#property-windowminimized-boolean) : _`<#boolean>`_ - property
  * [`standard`](hm.windows.md#property-read-only-windowstandard-boolean) : _`<#boolean>`_ - property (read-only)
  * [`visible`](hm.windows.md#property-windowvisible-boolean) : _`<#boolean>`_ - property






------------------

## Module `hm.windows`

> extends [_`<hm#module>`_](hm.md#class-module)






### Function `hm.windows._newWindow(ax,pid,wid)` -> [_`<#window>`_](hm.windows.md#class-window)

> **Internal/advanced use only** (e.g. for extension developers)



* `ax`: _`<#cdata>`_ `AXUIElementRef`
* `pid`: _`<#number>`_ 
* `wid`: _`<#number>`_ (optional)



* Returns [_`<#window>`_](hm.windows.md#class-window): 




### Property (read-only) `hm.windows.allWindows`: `{`[_`<#window>`_](hm.windows.md#class-window)`, ...}`
All current windows.

This property only includes windows in the current Mission Control space.


### Property `hm.windows.focusedWindow`: [_`<#window>`_](hm.windows.md#class-window)
The currently focused window.




### Property (read-only) `hm.windows.visibleWindows`: `{`[_`<#window>`_](hm.windows.md#class-window)`, ...}`
All currently visible windows.

This property only includes windows in the current Mission Control space.



------------------

## Class `window`

> extends [_`<hm#module.object>`_](hm.md#class-moduleobject)

Type for window objects




### Method `<#window>:newWatcher(fn,data)` -> [_`<hm._os.uielements#watcher>`_](hm._os.uielements.md#class-watcher)

> **Internal/advanced use only** (e.g. for extension developers)

Creates a new watcher for this window.

* `fn`: [_`<hm._os.uielements#watcherCallback>`_](hm._os.uielements.md#function-prototype-watchercallbackelementeventwatcherdata) callback function
* `data`: _`<?>`_ (optional)



* Returns [_`<hm._os.uielements#watcher>`_](hm._os.uielements.md#class-watcher): the new watcher




### Method `<#window>:startWatcher(events,fn,data)` -> [_`<hm._os.uielements#watcher>`_](hm._os.uielements.md#class-watcher)

> **Internal/advanced use only** (e.g. for extension developers)

Creates and starts a new watcher for this window.

* `events`: `{`[_`<hm._os.uielements#eventName>`_](hm._os.uielements.md#type-eventname)`, ...}` 
* `fn`: _`<#function>`_ callback function
* `data`: _`<?>`_ (optional)



* Returns [_`<hm._os.uielements#watcher>`_](hm._os.uielements.md#class-watcher): the new watcher

This method is a shortcut for `window:newWatcher():start()`


### Property (read-only) `<#window>.application`: [_`<hm.applications#application>`_](hm.applications.md#class-application)
The application owning this window




### Property `<#window>.frame`: [_`<hm.types.geometry#rect>`_](hm.types.geometry.md#type-rect)
The window's frame in screen coordinates.




### Property `<#window>.hidden`: _`<#boolean>`_
Whether the window's parent application is hidden.




### Property (read-only) `<#window>.id`: _`<#number>`_
The window's unique identifier.




### Property `<#window>.minimized`: _`<#boolean>`_
Whether the window is currently minimized.




### Property (read-only) `<#window>.standard`: _`<#boolean>`_
Whether this is a standard window.




### Property `<#window>.visible`: _`<#boolean>`_
Whether the window is currently visible.

A window is not visible if it's minimized or its parent application is hidden.
Setting this value to `true` will unminimize the window and unhide the parent application.
Setting this value to `false` will hide the parent application, unless the window is already minimized.


