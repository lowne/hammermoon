# Module `hm.screen`

Manipulate screens (monitors).

The OSX coordinate system used by Hammermoon assumes a grid that spans all the screens (positioned as per
System Preferences->Displays->Arrangement). The origin `0,0` is at the top left corner of the *primary screen*.
Screens to the top or the left of the primary screen, and windows on these screens, will have negative coordinates.

## Overview


* Module [`hm.screen`](hm.screen.md#module-hmscreen)
  * [`_toCocoa(rect)`](hm.screen.md#function-hmscreentococoarect---hmtypesgeometryrect) -> [_`<hm.types.geometry#rect>`_](hm.types.geometry.md#type-rect) - function
  * [`allScreens()`](hm.screen.md#function-hmscreenallscreens---screen-) -> `{`[_`<#screen>`_](hm.screen.md#type-screen)`, ...}` - function
  * [`mainScreen()`](hm.screen.md#function-hmscreenmainscreen---screen) -> [_`<#screen>`_](hm.screen.md#type-screen) - function
  * [`primaryScreen()`](hm.screen.md#function-hmscreenprimaryscreen) - function


* Type [`screen`](hm.screen.md#type-screen)
  * [`availableModes(pattern)`](hm.screen.md#method-screenavailablemodespattern---screenmode-) -> `{`[_`<#screenMode>`_](hm.screen.md#type-screenmode)`, ...}` - method
  * [`currentMode()`](hm.screen.md#method-screencurrentmode---screenmode) -> [_`<#screenMode>`_](hm.screen.md#type-screenmode) - method
  * [`frame()`](hm.screen.md#method-screenframe) - method
  * [`getGamma()`](hm.screen.md#method-screengetgamma) - method
  * [`id()`](hm.screen.md#method-screenid---number) -> _`<#number>`_ - method
  * [`isModeAvailable(mode)`](hm.screen.md#method-screenismodeavailablemode) - method
  * [`name()`](hm.screen.md#method-screenname---string) -> _`<#string>`_ - method
  * [`setGamma(gammaTable,_hscompat)`](hm.screen.md#method-screensetgammagammatablehscompat) - method
  * [`setMode(mode)`](hm.screen.md#method-screensetmodemode) - method
  * [`visibleFrame()`](hm.screen.md#method-screenvisibleframe) - method


* Type [`screenMode`](hm.screen.md#type-screenmode)






------------------

## Module `hm.screen`

> Extends [_`<hm#module>`_](hm.md#class-module)






### Function `hm.screen._toCocoa(rect)` -> [_`<hm.types.geometry#rect>`_](hm.types.geometry.md#type-rect)

> **Internal/advanced use only**

Transform a `geometry.rect` object from HS/HM coordinate system (origin at top left of primary screen)
to Cocoa coordinate system (origin at bottom left of primary screen)

* `rect`: [_`<hm.types.geometry#rect>`_](hm.types.geometry.md#type-rect) 



* Returns [_`<hm.types.geometry#rect>`_](hm.types.geometry.md#type-rect): transformed rect




### Function `hm.screen.allScreens()` -> `{`[_`<#screen>`_](hm.screen.md#type-screen)`, ...}`

> INTERNAL CHANGE: The screen list is cached (and kept up to date by an internal watcher)

Returns all the screens currently connected and enabled.



* Returns `{`[_`<#screen>`_](hm.screen.md#type-screen)`, ...}`: 




### Function `hm.screen.mainScreen()` -> [_`<#screen>`_](hm.screen.md#type-screen)

Returns the main screen.



* Returns [_`<#screen>`_](hm.screen.md#type-screen): 

The main screen is the one containing the currently focused window.


### Function `hm.screen.primaryScreen()`








------------------

### Type `screen`

> Extends [_`<hm#module.class>`_](hm.md#class-moduleclass)






### Method `<#screen>:availableModes(pattern)` -> `{`[_`<#screenMode>`_](hm.screen.md#type-screenmode)`, ...}`

> **API CHANGE**: Returns a plain list of strings. Allows filtering.

Returns a list of the modes supported by the screen.

* `pattern`: _`<#string>`_ A pattern to filter the modes as per `string.find`; e.g. passing `"/60" will only return modes with a refresh rate of 60Hz



* Returns `{`[_`<#screenMode>`_](hm.screen.md#type-screenmode)`, ...}`: 




### Method `<#screen>:currentMode()` -> [_`<#screenMode>`_](hm.screen.md#type-screenmode)

> **API CHANGE**: Returns a string instead of a table

Returns the screen's current mode.



* Returns [_`<#screenMode>`_](hm.screen.md#type-screenmode): 

The screen's mode indicates its current resolution and scaling factor.


### Method `<#screen>:frame()`






### Method `<#screen>:getGamma()`






### Method `<#screen>:id()` -> _`<#number>`_

Returns a screen's unique ID.



* Returns _`<#number>`_: the screen ID




### Method `<#screen>:isModeAvailable(mode)`



* `mode`: _`<?>`_ 




### Method `<#screen>:name()` -> _`<#string>`_

Returns the screen's name.



* Returns _`<#string>`_: the screen name

The screen's name is set by the manufacturer.


### Method `<#screen>:setGamma(gammaTable,_hscompat)`



* `gammaTable`: _`<?>`_ 
* `_hscompat`: _`<?>`_ 




### Method `<#screen>:setMode(mode)`

> **API CHANGE**: Refresh rate, color depth are supported.

> INTERNAL CHANGE: Will pick the highest refresh rate (if not specified) and color depth=4 (if available, and unless specified to 8).
depth==8 isn't supported in HS!



* `mode`: [_`<#screenMode>`_](hm.screen.md#type-screenmode) 




### Method `<#screen>:visibleFrame()`








------------------

### Type `screenMode`

> Extends _`<#string>`_

A string describing a screen mode.

The format of the string is `WWWWxHHHH@Sx/RR`, where WWWW is the width in points, HHHH the height in points,
 S is the scaling factor, i.e. 2 for HiDPI (a.k.a "retina") mode or 1 for native mode, and RR is the refresh
 rate in Hz; the `/RR` part is optional. E.g.: `"1440x900@2x/60"`.
 Note that "points" are not necessarily the same as pixels, because they take the scale factor into account
 (e.g. "1440x900@2x" is a 2880x1800 screen resolution, with a scaling factor of 2, i.e. with HiDPI pixel-doubled
 rendering enabled), however, they are far more useful to work with than native pixel modes, when a Retina screen
 is involved. For non-retina screens, points and pixels are equivalent.


