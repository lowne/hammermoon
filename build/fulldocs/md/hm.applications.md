# Module `hm.applications`

> **API CHANGE**: Running applications and app bundles are distinct objects. Edge cases with multiple bundles with the same id are solved.

Run, stop, query and manage applications.



## Overview


* Module [`hm.applications`](hm.applications.md#module-hmapplications)
  * [`allBundles`](hm.applications.md#property-read-only-hmapplicationsallbundles-bundle-) : `{`[_`<#bundle>`_](hm.applications.md#class-bundle)`, ...}` - property (read-only)
  * [`runningApplications`](hm.applications.md#property-read-only-hmapplicationsrunningapplications-application-) : `{`[_`<#application>`_](hm.applications.md#class-application)`, ...}` - property (read-only)
  * [`runningBackgroundApplications`](hm.applications.md#property-read-only-hmapplicationsrunningbackgroundapplications-application-) : `{`[_`<#application>`_](hm.applications.md#class-application)`, ...}` - property (read-only)
  * [`activeApplication`](hm.applications.md#property-hmapplicationsactiveapplication-application) : [_`<#application>`_](hm.applications.md#class-application) - property
  * [`menuBarOwningApplication`](hm.applications.md#property-hmapplicationsmenubarowningapplication-application) : [_`<#application>`_](hm.applications.md#class-application) - property
  * [`applicationForPID(pid)`](hm.applications.md#function-hmapplicationsapplicationforpidpid---application) -> [_`<#application>`_](hm.applications.md#class-application) - function
  * [`bundlesForBundleID(bid)`](hm.applications.md#function-hmapplicationsbundlesforbundleidbid---bundle-) -> `{`[_`<#bundle>`_](hm.applications.md#class-bundle)`, ...}` - function
  * [`bundlesForFile(path,role)`](hm.applications.md#function-hmapplicationsbundlesforfilepathrole---bundle-) -> `{`[_`<#bundle>`_](hm.applications.md#class-bundle)`, ...}` - function
  * [`bundlesForURL(url)`](hm.applications.md#function-hmapplicationsbundlesforurlurl---bundle-) -> `{`[_`<#bundle>`_](hm.applications.md#class-bundle)`, ...}` - function
  * [`defaultBundleForBundleID(bid)`](hm.applications.md#function-hmapplicationsdefaultbundleforbundleidbid---bundle) -> [_`<#bundle>`_](hm.applications.md#class-bundle) - function
  * [`defaultBundleForFile(path,role)`](hm.applications.md#function-hmapplicationsdefaultbundleforfilepathrole---bundle) -> [_`<#bundle>`_](hm.applications.md#class-bundle) - function
  * [`defaultBundleForURL(url)`](hm.applications.md#function-hmapplicationsdefaultbundleforurlurl---bundle) -> [_`<#bundle>`_](hm.applications.md#class-bundle) - function
  * [`findBundle(hint,ignoreCase)`](hm.applications.md#function-hmapplicationsfindbundlehintignorecase) - function
  * [`getBundle(bid)`](hm.applications.md#function-hmapplicationsgetbundlebid) - function
  * [`launchOrFocus(name)`](hm.applications.md#function-hmapplicationslaunchorfocusname) - function
  * [`launchOrFocusByBundleID(bid)`](hm.applications.md#function-hmapplicationslaunchorfocusbybundleidbid) - function
  * [`newWatcher(fn,data,events,name)`](hm.applications.md#function-hmapplicationsnewwatcherfndataeventsname---watcher) -> [_`<#watcher>`_](hm.applications.md#class-watcher) - function


* Class [`application`](hm.applications.md#class-application)
  * [`bundle`](hm.applications.md#property-read-only-applicationbundle-bundle) : [_`<#bundle>`_](hm.applications.md#class-bundle) - property (read-only)
  * [`bundleID`](hm.applications.md#property-read-only-applicationbundleid-string) : _`<#string>`_ - property (read-only)
  * [`kind`](hm.applications.md#property-read-only-applicationkind-applicationkind) : [_`<#applicationKind>`_](hm.applications.md#type-applicationkind) - property (read-only)
  * [`launchTime`](hm.applications.md#property-read-only-applicationlaunchtime-number) : _`<#number>`_ - property (read-only)
  * [`name`](hm.applications.md#property-read-only-applicationname-string) : _`<#string>`_ - property (read-only)
  * [`ownsMenuBar`](hm.applications.md#property-read-only-applicationownsmenubar-boolean) : _`<#boolean>`_ - property (read-only)
  * [`path`](hm.applications.md#property-read-only-applicationpath-string) : _`<#string>`_ - property (read-only)
  * [`pid`](hm.applications.md#property-read-only-applicationpid-number) : _`<#number>`_ - property (read-only)
  * [`visibleWindows`](hm.applications.md#property-read-only-applicationvisiblewindows-hmwindowswindow-) : `{`[_`<hm.windows#window>`_](hm.windows.md#class-window)`, ...}` - property (read-only)
  * [`windows`](hm.applications.md#property-read-only-applicationwindows-hmwindowswindow-) : `{`[_`<hm.windows#window>`_](hm.windows.md#class-window)`, ...}` - property (read-only)
  * [`active`](hm.applications.md#property-applicationactive-boolean) : _`<#boolean>`_ - property
  * [`focusedWindow`](hm.applications.md#property-applicationfocusedwindow-hmwindowswindow) : [_`<hm.windows#window>`_](hm.windows.md#class-window) - property
  * [`hidden`](hm.applications.md#property-applicationhidden-boolean) : _`<#boolean>`_ - property
  * [`mainWindow`](hm.applications.md#property-applicationmainwindow-hmwindowswindow) : [_`<hm.windows#window>`_](hm.windows.md#class-window) - property
  * [`running`](hm.applications.md#property-applicationrunning-boolean) : _`<#boolean>`_ - property
  * [`activate()`](hm.applications.md#method-applicationactivate---self) -> `self` - method
  * [`bringToFront()`](hm.applications.md#method-applicationbringtofront---self) -> `self` - method
  * [`forceQuit(gracePeriod)`](hm.applications.md#method-applicationforcequitgraceperiod---self) -> `self` - method
  * [`hide()`](hm.applications.md#method-applicationhide---self) -> `self` - method
  * [`quit()`](hm.applications.md#method-applicationquit---self) -> `self` - method
  * [`unhide()`](hm.applications.md#method-applicationunhide---self) -> `self` - method


* Class [`bundle`](hm.applications.md#class-bundle)
  * [`appName`](hm.applications.md#property-read-only-bundleappname-string) : _`<#string>`_ - property (read-only)
  * [`application`](hm.applications.md#property-read-only-bundleapplication-application) : [_`<#application>`_](hm.applications.md#class-application) - property (read-only)
  * [`id`](hm.applications.md#property-read-only-bundleid-string) : _`<#string>`_ - property (read-only)
  * [`name`](hm.applications.md#property-read-only-bundlename-string) : _`<#string>`_ - property (read-only)
  * [`path`](hm.applications.md#property-read-only-bundlepath-string) : _`<#string>`_ - property (read-only)
  * [`launch()`](hm.applications.md#method-bundlelaunch---application) -> [_`<#application>`_](hm.applications.md#class-application) - method


* Class [`watcher`](hm.applications.md#class-watcher)
  * [`active`](hm.applications.md#property-watcheractive-boolean) : _`<#boolean>`_ - property
  * [`start(events,fn,data)`](hm.applications.md#method-watcherstarteventsfndata---self) -> `self` - method
  * [`stop()`](hm.applications.md#method-watcherstop---self) -> `self` - method


* Type [`applicationKind`](hm.applications.md#type-applicationkind)


* Type [`bundleRole`](hm.applications.md#type-bundlerole)


* Type [`eventName`](hm.applications.md#type-eventname)




* Function prototypes:
  * [`watcherCallback(application,event,data)`](hm.applications.md#function-prototype-watchercallbackapplicationeventdata) - function prototype



------------------

## Module `hm.applications`

> Extends [_`<hm#module>`_](hm.md#class-module)





### Property (read-only) `hm.applications.allBundles`: `{`[_`<#bundle>`_](hm.applications.md#class-bundle)`, ...}`
All application bundles in the filesystem.

This property is cached, so it won't reflect changes in the filesystem after the first time it's requested.


### Property (read-only) `hm.applications.runningApplications`: `{`[_`<#application>`_](hm.applications.md#class-application)`, ...}`
The currently running GUI applications.

This list only includes applications of [_`<#applicationKind>`_](hm.applications.md#type-applicationkind) `"standard"` and `"accessory"`.


### Property (read-only) `hm.applications.runningBackgroundApplications`: `{`[_`<#application>`_](hm.applications.md#class-application)`, ...}`
The currently running background applications.

This list only includes applications of [_`<#applicationKind>`_](hm.applications.md#type-applicationkind) `"background"`.


### Property `hm.applications.activeApplication`: [_`<#application>`_](hm.applications.md#class-application)
The active application.

This is the application that currently receives input events.


### Property `hm.applications.menuBarOwningApplication`: [_`<#application>`_](hm.applications.md#class-application)
The application owning the menu bar.

Note that this is not necessarily the same as [`activeApplication`](hm.applications.md#property-hmapplicationsactiveapplication-application).


### Function `hm.applications.applicationForPID(pid)` -> [_`<#application>`_](hm.applications.md#class-application)

> **Internal/advanced use only**



* `pid`: _`<?>`_ 



* Returns [_`<#application>`_](hm.applications.md#class-application): 




### Function `hm.applications.bundlesForBundleID(bid)` -> `{`[_`<#bundle>`_](hm.applications.md#class-bundle)`, ...}`

> **Internal/advanced use only**

> INTERNAL CHANGE: returns all bundles for a given bundle id



* `bid`: _`<?>`_ 



* Returns `{`[_`<#bundle>`_](hm.applications.md#class-bundle)`, ...}`: 




### Function `hm.applications.bundlesForFile(path,role)` -> `{`[_`<#bundle>`_](hm.applications.md#class-bundle)`, ...}`

> **Internal/advanced use only**



* `path`: _`<?>`_ 
* `role`: _`<?>`_ 



* Returns `{`[_`<#bundle>`_](hm.applications.md#class-bundle)`, ...}`: 




### Function `hm.applications.bundlesForURL(url)` -> `{`[_`<#bundle>`_](hm.applications.md#class-bundle)`, ...}`

> **Internal/advanced use only**



* `url`: _`<?>`_ 



* Returns `{`[_`<#bundle>`_](hm.applications.md#class-bundle)`, ...}`: 




### Function `hm.applications.defaultBundleForBundleID(bid)` -> [_`<#bundle>`_](hm.applications.md#class-bundle)

> **Internal/advanced use only**



* `bid`: _`<?>`_ 



* Returns [_`<#bundle>`_](hm.applications.md#class-bundle): 




### Function `hm.applications.defaultBundleForFile(path,role)` -> [_`<#bundle>`_](hm.applications.md#class-bundle)

> **Internal/advanced use only**



* `path`: _`<?>`_ 
* `role`: _`<?>`_ 



* Returns [_`<#bundle>`_](hm.applications.md#class-bundle): 




### Function `hm.applications.defaultBundleForURL(url)` -> [_`<#bundle>`_](hm.applications.md#class-bundle)

> **Internal/advanced use only**



* `url`: _`<?>`_ 



* Returns [_`<#bundle>`_](hm.applications.md#class-bundle): 




### Function `hm.applications.findBundle(hint,ignoreCase)`



* `hint`: _`<?>`_ 
* `ignoreCase`: _`<?>`_ 




### Function `hm.applications.getBundle(bid)`



* `bid`: _`<?>`_ 




### Function `hm.applications.launchOrFocus(name)`



* `name`: _`<?>`_ 




### Function `hm.applications.launchOrFocusByBundleID(bid)`



* `bid`: _`<?>`_ 




### Function `hm.applications.newWatcher(fn,data,events,name)` -> [_`<#watcher>`_](hm.applications.md#class-watcher)

> **Internal/advanced use only**

Creates a new watcher for application events.

* `fn`: [_`<#watcherCallback>`_](hm.applications.md#function-prototype-watchercallbackapplicationeventdata) (optional) callback function
* `data`: _`<?>`_ (optional)
* `events`: `{`[_`<#eventName>`_](hm.applications.md#type-eventname)`, ...}` (optional)
* `name`: _`<#string>`_ 



* Returns [_`<#watcher>`_](hm.applications.md#class-watcher): the new watcher






------------------

## Class `application`

> Extends [_`<hm#module.object>`_](hm.md#class-moduleobject)

> Defines type checker `hm.applications#application
application`

Type for running application objects.



### Property (read-only) `<#application>.bundle`: [_`<#bundle>`_](hm.applications.md#class-bundle)
The application bundle.

If the application does not have a bundle structure, this property is `nil`.


### Property (read-only) `<#application>.bundleID`: _`<#string>`_
The application bundle identifier.

This is a shortcut for `app.bundle.id`.


### Property (read-only) `<#application>.kind`: [_`<#applicationKind>`_](hm.applications.md#type-applicationkind)
The application's kind.




### Property (read-only) `<#application>.launchTime`: _`<#number>`_
The absolute time when the application was launched.




### Property (read-only) `<#application>.name`: _`<#string>`_
The application name.




### Property (read-only) `<#application>.ownsMenuBar`: _`<#boolean>`_
Whether this application currently owns the menu bar.




### Property (read-only) `<#application>.path`: _`<#string>`_
The application bundle's path.

This is a shortcut for `app.bundle.path`.


### Property (read-only) `<#application>.pid`: _`<#number>`_
The application process identifier.




### Property (read-only) `<#application>.visibleWindows`: `{`[_`<hm.windows#window>`_](hm.windows.md#class-window)`, ...}`
The application's visible windows (not minimized).

When the application is hidden this property is an empty list.


### Property (read-only) `<#application>.windows`: `{`[_`<hm.windows#window>`_](hm.windows.md#class-window)`, ...}`
The application's windows.




### Property `<#application>.active`: _`<#boolean>`_
Whether this is the active application.

The active application is the one currently receiving input events.


### Property `<#application>.focusedWindow`: [_`<hm.windows#window>`_](hm.windows.md#class-window)
The application's focused window.




### Property `<#application>.hidden`: _`<#boolean>`_
Whether the application is currently hidden.




### Property `<#application>.mainWindow`: [_`<hm.windows#window>`_](hm.windows.md#class-window)
The application's main window.




### Property `<#application>.running`: _`<#boolean>`_
Whether the application is currently running.

This property can be set to `false` to terminate the application.


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






------------------

## Class `bundle`

> Extends [_`<hm#module.object>`_](hm.md#class-moduleobject)

> Defines type checker `hm.applications#bundle
appBundle`

Type for application bundle objects.



### Property (read-only) `<#bundle>.appName`: _`<#string>`_
The name of the bundled application.




### Property (read-only) `<#bundle>.application`: [_`<#application>`_](hm.applications.md#class-application)
The application object for this bundle.

If this app bundle isn't currently running, this property is `nil`.


### Property (read-only) `<#bundle>.id`: _`<#string>`_
The bundle ID.




### Property (read-only) `<#bundle>.name`: _`<#string>`_
The name of the bundle on the filesystem.




### Property (read-only) `<#bundle>.path`: _`<#string>`_
The bundle full path.




### Method `<#bundle>:launch()` -> [_`<#application>`_](hm.applications.md#class-application)

Launches this bundle.



* Returns [_`<#application>`_](hm.applications.md#class-application): the running application object for this bundle






------------------

## Class `watcher`

> Extends [_`<hm#module.object>`_](hm.md#class-moduleobject)

> **Internal/advanced use only**

> Defines type checker `hm.applications#watcher`

Type for application watcher objects.



### Property `<#watcher>.active`: _`<#boolean>`_
Whether this watcher is currently active.




### Method `<#watcher>:start(events,fn,data)` -> `self`

Starts the watcher.

* `events`: `{`[_`<#eventName>`_](hm.applications.md#type-eventname)`, ...}` (optional)
* `fn`: [_`<#watcherCallback>`_](hm.applications.md#function-prototype-watchercallbackapplicationeventdata) (optional)
* `data`: _`<?>`_ (optional)



* Returns `self`: [_`<#watcher>`_](hm.applications.md#class-watcher)




### Method `<#watcher>:stop()` -> `self`

Stops the watcher.



* Returns `self`: [_`<#watcher>`_](hm.applications.md#class-watcher)






------------------

### Type `applicationKind`

> Extends _`<#string>`_

A string describing an application's kind.

Valid values are:
* `"standard"`: the application has a main window, a menu bar, and (usually) appears in the Dock
* `"accessory"`: the application has a transient user interface (for example a menulet)
* `"background"`: the application does not have any user interface (for example daemons and helpers)



------------------

### Type `bundleRole`

> Extends _`<#string>`_

> Defines type checker `hm.applications#bundleRole`

The required role for finding app bundles.

Valid values are `"viewer"`, `"editor"`, `"all"` or `nil` (same as `"all"`)



------------------

### Type `eventName`

> Extends _`<#string>`_

> **Internal/advanced use only**

> Defines type checker `hm.applications#eventName`

Application event name.

Valid values are `"launching"`,`"launched"`,`"activated"`,`"deactivated"`,`"hidden"`,`"unhidden"`,`"terminated"`.




------------------

### Function prototype `watcherCallback(application,event,data)`

> **Internal/advanced use only**

Callback for application watchers.

* `application`: [_`<#application>`_](hm.applications.md#class-application) the application that caused the event
* `event`: [_`<#eventName>`_](hm.applications.md#type-eventname) the event
* `data`: _`<?>`_ 




