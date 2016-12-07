# Module `hm.windows`

Manage windows



## Overview


* Module [`hm.windows`](hm.windows.md#module-hmwindows)
  * [`orderedWindows`](hm.windows.md#property-read-only-hmwindowsorderedwindows-window-) : `{`[_`<#window>`_](hm.windows.md#class-window)`, ...}` - property (read-only)
  * [`visibleWindows`](hm.windows.md#property-read-only-hmwindowsvisiblewindows-window-) : `{`[_`<#window>`_](hm.windows.md#class-window)`, ...}` - property (read-only)
  * [`windows`](hm.windows.md#property-read-only-hmwindowswindows-window-) : `{`[_`<#window>`_](hm.windows.md#class-window)`, ...}` - property (read-only)
  * [`focusedWindow`](hm.windows.md#property-hmwindowsfocusedwindow-window) : [_`<#window>`_](hm.windows.md#class-window) - property
  * [`frontmostWindow`](hm.windows.md#field-hmwindowsfrontmostwindow-window) : [_`<#window>`_](hm.windows.md#class-window) - field
  * [`newWindow(ax,pid,wid)`](hm.windows.md#function-hmwindowsnewwindowaxpidwid---window) -> [_`<#window>`_](hm.windows.md#class-window) - function


* Class [`window`](hm.windows.md#class-window)
  * [`application`](hm.windows.md#property-read-only-windowapplication-hmapplicationsapplication) : [_`<hm.applications#application>`_](hm.applications.md#class-application) - property (read-only)
  * [`cancelButton`](hm.windows.md#property-read-only-windowcancelbutton-hmosuielementsuielement) : [_`<hm._os.uielements#uielement>`_](hm._os.uielements.md#class-uielement) - property (read-only)
  * [`closeButton`](hm.windows.md#property-read-only-windowclosebutton-hmosuielementsuielement) : [_`<hm._os.uielements#uielement>`_](hm._os.uielements.md#class-uielement) - property (read-only)
  * [`defaultButton`](hm.windows.md#property-read-only-windowdefaultbutton-hmosuielementsuielement) : [_`<hm._os.uielements#uielement>`_](hm._os.uielements.md#class-uielement) - property (read-only)
  * [`fullscreenButton`](hm.windows.md#property-read-only-windowfullscreenbutton-hmosuielementsuielement) : [_`<hm._os.uielements#uielement>`_](hm._os.uielements.md#class-uielement) - property (read-only)
  * [`id`](hm.windows.md#property-read-only-windowid-number) : _`<#number>`_ - property (read-only)
  * [`minimizeButton`](hm.windows.md#property-read-only-windowminimizebutton-hmosuielementsuielement) : [_`<hm._os.uielements#uielement>`_](hm._os.uielements.md#class-uielement) - property (read-only)
  * [`role`](hm.windows.md#property-read-only-windowrole-string) : _`<#string>`_ - property (read-only)
  * [`standard`](hm.windows.md#property-read-only-windowstandard-boolean) : _`<#boolean>`_ - property (read-only)
  * [`subrole`](hm.windows.md#property-read-only-windowsubrole-string) : _`<#string>`_ - property (read-only)
  * [`title`](hm.windows.md#property-read-only-windowtitle-string) : _`<#string>`_ - property (read-only)
  * [`zoomButton`](hm.windows.md#property-read-only-windowzoombutton-hmosuielementsuielement) : [_`<hm._os.uielements#uielement>`_](hm._os.uielements.md#class-uielement) - property (read-only)
  * [`focused`](hm.windows.md#property-windowfocused-boolean) : _`<#boolean>`_ - property
  * [`frame`](hm.windows.md#property-windowframe-hmtypesgeometryrect) : [_`<hm.types.geometry#rect>`_](hm.types.geometry.md#type-rect) - property
  * [`fullscreen`](hm.windows.md#property-windowfullscreen-boolean) : _`<#boolean>`_ - property
  * [`hidden`](hm.windows.md#property-windowhidden-boolean) : _`<#boolean>`_ - property
  * [`minimized`](hm.windows.md#property-windowminimized-boolean) : _`<#boolean>`_ - property
  * [`visible`](hm.windows.md#property-windowvisible-boolean) : _`<#boolean>`_ - property
  * [`close()`](hm.windows.md#method-windowclose---boolean) -> _`<#boolean>`_ - method
  * [`focus()`](hm.windows.md#method-windowfocus---self) -> `self` - method
  * [`minimize()`](hm.windows.md#method-windowminimize---self) -> `self` - method
  * [`newWatcher(fn,data)`](hm.windows.md#method-windownewwatcherfndata---hmosuielementswatcher) -> [_`<hm._os.uielements#watcher>`_](hm._os.uielements.md#class-watcher) - method
  * [`startWatcher(events,fn,data)`](hm.windows.md#method-windowstartwatchereventsfndata---hmosuielementswatcher) -> [_`<hm._os.uielements#watcher>`_](hm._os.uielements.md#class-watcher) - method
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




### Function `hm.windows.newWindow(ax,pid,wid)` -> [_`<#window>`_](hm.windows.md#class-window)

> **Internal/advanced use only**



* `ax`: _`<#cdata>`_ `AXUIElementRef`
* `pid`: _`<#number>`_ 
* `wid`: _`<#number>`_ (optional)



* Returns [_`<#window>`_](hm.windows.md#class-window): 






------------------

## Class `window`

> Extends [_`<hm#module.object>`_](hm.md#class-moduleobject)

Type for window objects



### Property (read-only) `<#window>.application`: [_`<hm.applications#application>`_](hm.applications.md#class-application)
The application owning this window




### Property (read-only) `<#window>.cancelButton`: [_`<hm._os.uielements#uielement>`_](hm._os.uielements.md#class-uielement)
> **Internal/advanced use only**

The (dialog) window's cancel button, if present.

If absent, this property is `false`.


### Property (read-only) `<#window>.closeButton`: [_`<hm._os.uielements#uielement>`_](hm._os.uielements.md#class-uielement)
> **Internal/advanced use only**

The window's close button, if present.

If absent, this property is `false`.


### Property (read-only) `<#window>.defaultButton`: [_`<hm._os.uielements#uielement>`_](hm._os.uielements.md#class-uielement)
> **Internal/advanced use only**

The (dialog) window's default button, if present.

If absent, this property is `false`.


### Property (read-only) `<#window>.fullscreenButton`: [_`<hm._os.uielements#uielement>`_](hm._os.uielements.md#class-uielement)
> **Internal/advanced use only**

The window's fullscreen button, if present.

If absent, this property is `false`.


### Property (read-only) `<#window>.id`: _`<#number>`_
The window's unique identifier.




### Property (read-only) `<#window>.minimizeButton`: [_`<hm._os.uielements#uielement>`_](hm._os.uielements.md#class-uielement)
> **Internal/advanced use only**

The window's minimize button, if present.

If absent, this property is `false`.


### Property (read-only) `<#window>.role`: _`<#string>`_
> **Internal/advanced use only**

The window's accessibility role.

For *most* windows, this will be `"AXWindow"`.


### Property (read-only) `<#window>.standard`: _`<#boolean>`_
Whether this is a standard window.




### Property (read-only) `<#window>.subrole`: _`<#string>`_
> **Internal/advanced use only**

The window's accessibility subrole.




### Property (read-only) `<#window>.title`: _`<#string>`_
The window title.




### Property (read-only) `<#window>.zoomButton`: [_`<hm._os.uielements#uielement>`_](hm._os.uielements.md#class-uielement)
> **Internal/advanced use only**

The window's zoom button, if present.

If absent, this property is `false`.


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




### Method `<#window>:newWatcher(fn,data)` -> [_`<hm._os.uielements#watcher>`_](hm._os.uielements.md#class-watcher)

> **Internal/advanced use only**

Creates a new watcher for this window.

* `fn`: [_`<hm._os.uielements#watcherCallback>`_](hm._os.uielements.md#function-prototype-watchercallbackelementeventwatcherdata) callback function
* `data`: _`<?>`_ (optional)



* Returns [_`<hm._os.uielements#watcher>`_](hm._os.uielements.md#class-watcher): the new watcher




### Method `<#window>:startWatcher(events,fn,data)` -> [_`<hm._os.uielements#watcher>`_](hm._os.uielements.md#class-watcher)

> **Internal/advanced use only**

Creates and starts a new watcher for this window.

* `events`: `{`[_`<hm._os.uielements#eventName>`_](hm._os.uielements.md#type-eventname)`, ...}` 
* `fn`: _`<#function>`_ callback function
* `data`: _`<?>`_ (optional)



* Returns [_`<hm._os.uielements#watcher>`_](hm._os.uielements.md#class-watcher): the new watcher

This method is a shortcut for `window:newWatcher():start()`


### Method `<#window>:unminimize()` -> `self`

Unminimizes this window.



* Returns `self`: [_`<#window>`_](hm.windows.md#class-window)





