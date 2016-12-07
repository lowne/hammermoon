# Module `hm.windows`

Manage windows



## Overview


* Module [`hm.windows`](hm.windows.md#module-hmwindows)
  * [`orderedWindows`](hm.windows.md#property-read-only-hmwindowsorderedwindows-window-) : `{`[_`<#window>`_](hm.windows.md#class-window)`, ...}` - property (read-only)
  * [`visibleWindows`](hm.windows.md#property-read-only-hmwindowsvisiblewindows-window-) : `{`[_`<#window>`_](hm.windows.md#class-window)`, ...}` - property (read-only)
  * [`windows`](hm.windows.md#property-read-only-hmwindowswindows-window-) : `{`[_`<#window>`_](hm.windows.md#class-window)`, ...}` - property (read-only)
  * [`focusedWindow`](hm.windows.md#property-hmwindowsfocusedwindow-window) : [_`<#window>`_](hm.windows.md#class-window) - property
  * [`frontmostWindow`](hm.windows.md#field-hmwindowsfrontmostwindow-window) : [_`<#window>`_](hm.windows.md#class-window) - field


* Class [`window`](hm.windows.md#class-window)
  * [`application`](hm.windows.md#property-read-only-windowapplication-hmapplicationsapplication) : [_`<hm.applications#application>`_](hm.applications.md#class-application) - property (read-only)
  * [`id`](hm.windows.md#property-read-only-windowid-number) : _`<#number>`_ - property (read-only)
  * [`standard`](hm.windows.md#property-read-only-windowstandard-boolean) : _`<#boolean>`_ - property (read-only)
  * [`title`](hm.windows.md#property-read-only-windowtitle-string) : _`<#string>`_ - property (read-only)
  * [`focused`](hm.windows.md#property-windowfocused-boolean) : _`<#boolean>`_ - property
  * [`frame`](hm.windows.md#property-windowframe-hmtypesgeometryrect) : [_`<hm.types.geometry#rect>`_](hm.types.geometry.md#type-rect) - property
  * [`fullscreen`](hm.windows.md#property-windowfullscreen-boolean) : _`<#boolean>`_ - property
  * [`hidden`](hm.windows.md#property-windowhidden-boolean) : _`<#boolean>`_ - property
  * [`minimized`](hm.windows.md#property-windowminimized-boolean) : _`<#boolean>`_ - property
  * [`visible`](hm.windows.md#property-windowvisible-boolean) : _`<#boolean>`_ - property
  * [`close()`](hm.windows.md#method-windowclose---boolean) -> _`<#boolean>`_ - method
  * [`focus()`](hm.windows.md#method-windowfocus---self) -> `self` - method
  * [`minimize()`](hm.windows.md#method-windowminimize---self) -> `self` - method
  * [`unminimize()`](hm.windows.md#method-windowunminimize---self) -> `self` - method






------------------

## Module `hm.windows`

> Extends [_`<hm#module>`_](hm.md#class-module)





### Property (read-only) `hm.windows.orderedWindows`: `{`[_`<#window>`_](hm.windows.md#class-window)`, ...}`
All visible windows, ordered front to back.

This property only includes windows in the current Mission Control space.


### Property (read-only) `hm.windows.visibleWindows`: `{`[_`<#window>`_](hm.windows.md#class-window)`, ...}`
All currently visible windows.

This property only includes windows in the current Mission Control space.


### Property (read-only) `hm.windows.windows`: `{`[_`<#window>`_](hm.windows.md#class-window)`, ...}`
All current windows.

This property only includes windows in the current Mission Control space.


### Property `hm.windows.focusedWindow`: [_`<#window>`_](hm.windows.md#class-window)
The currently focused window.




### Field `hm.windows.frontmostWindow`: [_`<#window>`_](hm.windows.md#class-window)
The currently focused or frontmost window.





------------------

## Class `window`

> Extends [_`<hm#module.object>`_](hm.md#class-moduleobject)

Type for window objects



### Property (read-only) `<#window>.application`: [_`<hm.applications#application>`_](hm.applications.md#class-application)
The application owning this window




### Property (read-only) `<#window>.id`: _`<#number>`_
The window's unique identifier.




### Property (read-only) `<#window>.standard`: _`<#boolean>`_
Whether this is a standard window.




### Property (read-only) `<#window>.title`: _`<#string>`_
The window title.




### Property `<#window>.focused`: _`<#boolean>`_
Whether the window is currently focused.




### Property `<#window>.frame`: [_`<hm.types.geometry#rect>`_](hm.types.geometry.md#type-rect)
The window's frame in screen coordinates.




### Property `<#window>.fullscreen`: _`<#boolean>`_
Whether the window is currently fullscreen.




### Property `<#window>.hidden`: _`<#boolean>`_
Whether the window's parent application is hidden.




### Property `<#window>.minimized`: _`<#boolean>`_
Whether the window is currently minimized.




### Property `<#window>.visible`: _`<#boolean>`_
Whether the window is currently visible.

A window is not visible if it's minimized or its parent application is hidden.
Setting this value to `true` will unminimize the window and unhide the parent application.
Setting this value to `false` will hide the parent application, unless the window is already minimized.


### Method `<#window>:close()` -> _`<#boolean>`_

Closes this window



* Returns _`<#boolean>`_: `true` if successful




### Method `<#window>:focus()` -> `self`

Focuses this window.



* Returns `self`: [_`<#window>`_](hm.windows.md#class-window)




### Method `<#window>:minimize()` -> `self`

Minimizes this window.



* Returns `self`: [_`<#window>`_](hm.windows.md#class-window)




### Method `<#window>:unminimize()` -> `self`

Unminimizes this window.



* Returns `self`: [_`<#window>`_](hm.windows.md#class-window)





