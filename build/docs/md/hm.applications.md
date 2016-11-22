# Module `hm.applications`

Run, stop, query and manage applications.



## Overview


* Module [`hm.applications`](hm.applications.md#module-hmapplications)
  * [`_hmdestroy()`](hm.applications.md#function-hmapplicationshmdestroy) - function
  * [`applicationsForBundleID(bid)`](hm.applications.md#function-hmapplicationsapplicationsforbundleidbid) - function
  * [`launchOrFocus(name)`](hm.applications.md#function-hmapplicationslaunchorfocusname) - function
  * [`launchOrFocusByBundleID(bid)`](hm.applications.md#function-hmapplicationslaunchorfocusbybundleidbid) - function
  * [`nameForBundleID(bid)`](hm.applications.md#function-hmapplicationsnameforbundleidbid) - function
  * [`pathForBundleID(bid)`](hm.applications.md#function-hmapplicationspathforbundleidbid) - function
  * [`activeApplication`](hm.applications.md#property-hmapplicationsactiveapplication-application) : [_`<#application>`_](hm.applications.md#class-application) - property
  * [`runningApplications`](hm.applications.md#property-read-only-hmapplicationsrunningapplications-application-) : `{`[_`<#application>`_](hm.applications.md#class-application)`, ...}` - property (read-only)
  * [`runningBackgroundApplications`](hm.applications.md#property-read-only-hmapplicationsrunningbackgroundapplications-application-) : `{`[_`<#application>`_](hm.applications.md#class-application)`, ...}` - property (read-only)
  * [`watcher`](hm.applications.md#field-hmapplicationswatcher-table) : _`<#table>`_ - field


* Class [`application`](hm.applications.md#class-application)
  * [`activate()`](hm.applications.md#method-applicationactivate---self) -> `self` - method
  * [`bringToFront()`](hm.applications.md#method-applicationbringtofront---self) -> `self` - method
  * [`forceQuit(gracePeriod)`](hm.applications.md#method-applicationforcequitgraceperiod---self) -> `self` - method
  * [`hide()`](hm.applications.md#method-applicationhide---self) -> `self` - method
  * [`quit()`](hm.applications.md#method-applicationquit---self) -> `self` - method
  * [`unhide()`](hm.applications.md#method-applicationunhide---self) -> `self` - method
  * [`active`](hm.applications.md#property-applicationactive-boolean) : _`<#boolean>`_ - property
  * [`bundleID`](hm.applications.md#property-read-only-applicationbundleid-string) : _`<#string>`_ - property (read-only)
  * [`hidden`](hm.applications.md#property-applicationhidden-boolean) : _`<#boolean>`_ - property
  * [`kind`](hm.applications.md#property-read-only-applicationkind-applicationkind) : [_`<#applicationKind>`_](hm.applications.md#type-applicationkind) - property (read-only)
  * [`mainWindow`](hm.applications.md#property-applicationmainwindow-hmwindowswindow) : [_`<hm.windows#window>`_](hm.windows.md#class-window) - property
  * [`name`](hm.applications.md#property-read-only-applicationname-string) : _`<#string>`_ - property (read-only)
  * [`ownsMenuBar`](hm.applications.md#property-read-only-applicationownsmenubar-boolean) : _`<#boolean>`_ - property (read-only)
  * [`path`](hm.applications.md#property-read-only-applicationpath-string) : _`<#string>`_ - property (read-only)
  * [`pid`](hm.applications.md#property-read-only-applicationpid-number) : _`<#number>`_ - property (read-only)
  * [`running`](hm.applications.md#property-applicationrunning-boolean) : _`<#boolean>`_ - property
  * [`visibleWindows`](hm.applications.md#property-read-only-applicationvisiblewindows-hmwindowswindow-) : `{`[_`<hm.windows#window>`_](hm.windows.md#class-window)`, ...}` - property (read-only)
  * [`windows`](hm.applications.md#property-read-only-applicationwindows-hmwindowswindow-) : `{`[_`<hm.windows#window>`_](hm.windows.md#class-window)`, ...}` - property (read-only)


* Type [`applicationKind`](hm.applications.md#type-applicationkind)






------------------

## Module `hm.applications`

> extends [_`<hm#module>`_](hm.md#class-module)






### Function `hm.applications._hmdestroy()`






### Function `hm.applications.applicationsForBundleID(bid)`



* `bid`: _`<?>`_ 




### Function `hm.applications.launchOrFocus(name)`



* `name`: _`<?>`_ 




### Function `hm.applications.launchOrFocusByBundleID(bid)`



* `bid`: _`<?>`_ 




### Function `hm.applications.nameForBundleID(bid)`



* `bid`: _`<?>`_ 




### Function `hm.applications.pathForBundleID(bid)`



* `bid`: _`<?>`_ 




### Property `hm.applications.activeApplication`: [_`<#application>`_](hm.applications.md#class-application)
The active application.

This is the application that currently receives input events.


### Property (read-only) `hm.applications.runningApplications`: `{`[_`<#application>`_](hm.applications.md#class-application)`, ...}`
The currently running GUI applications.

This list only includes applications of [_`<#applicationKind>`_](hm.applications.md#type-applicationkind) `"standard"` and `"accessory"`.


### Property (read-only) `hm.applications.runningBackgroundApplications`: `{`[_`<#application>`_](hm.applications.md#class-application)`, ...}`
The currently running background applications.

This list only includes applications of [_`<#applicationKind>`_](hm.applications.md#type-applicationkind) `"background"`.


### Field `hm.applications.watcher`: _`<#table>`_






------------------

## Class `application`

> extends [_`<hm#module.object>`_](hm.md#class-moduleobject)

Type for application objects.




### Method `<#application>:activate()` -> `self`

Makes this the active application.



* Returns `self`: [_`<#application>`_](hm.applications.md#class-application)




### Method `<#application>:bringToFront()` -> `self`

Activates this application and puts all its windows on top of other windows.



* Returns `self`: [_`<#application>`_](hm.applications.md#class-application)




### Method `<#application>:forceQuit(gracePeriod)` -> `self`

Force quits the application.

* `gracePeriod`: _`<#number>`_ (optional) number of seconds to wait for the app to quit normally before forcequitting;
pass `0` to force quit immediately. If omitted defaults to `10`.



* Returns `self`: [_`<#application>`_](hm.applications.md#class-application)




### Method `<#application>:hide()` -> `self`

Hides the application.



* Returns `self`: [_`<#application>`_](hm.applications.md#class-application)




### Method `<#application>:quit()` -> `self`

Quits the application.



* Returns `self`: [_`<#application>`_](hm.applications.md#class-application)




### Method `<#application>:unhide()` -> `self`

Unhides the application.



* Returns `self`: [_`<#application>`_](hm.applications.md#class-application)




### Property `<#application>.active`: _`<#boolean>`_
Whether this is the active application.

The active application is the one currently receiving input events.


### Property (read-only) `<#application>.bundleID`: _`<#string>`_
The application bundle identifier.




### Property `<#application>.hidden`: _`<#boolean>`_
Whether the application is currently hidden.




### Property (read-only) `<#application>.kind`: [_`<#applicationKind>`_](hm.applications.md#type-applicationkind)
The application's kind.




### Property `<#application>.mainWindow`: [_`<hm.windows#window>`_](hm.windows.md#class-window)
The application's main window.




### Property (read-only) `<#application>.name`: _`<#string>`_
The application name.




### Property (read-only) `<#application>.ownsMenuBar`: _`<#boolean>`_
Whether this application currently owns the menu bar.




### Property (read-only) `<#application>.path`: _`<#string>`_
The application bundle's path.




### Property (read-only) `<#application>.pid`: _`<#number>`_
The application process identifier.




### Property `<#application>.running`: _`<#boolean>`_
Whether the application is currently running.

This property can be set to `false` to terminate the application.


### Property (read-only) `<#application>.visibleWindows`: `{`[_`<hm.windows#window>`_](hm.windows.md#class-window)`, ...}`
The application's visible windows (not minimized).

When the application is hidden this property is an empty list.


### Property (read-only) `<#application>.windows`: `{`[_`<hm.windows#window>`_](hm.windows.md#class-window)`, ...}`
The application's windows.





------------------

### Type `applicationKind`

> extends _`<#string>`_

A string describing an application's kind.

Valid values are:
* `"standard"`: the application has a main window, a menu bar, and (usually) appears in the Dock
* `"accessory"`: the application has a transient user interface (for example a menulet)
* `"background"`: the application does not have any user interface (for example daemons and helpers)


