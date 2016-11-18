# Module `hm.screen`

Manipulate screens (monitors).

The OSX coordinate system used by Hammermoon assumes a grid that spans all the screens (positioned as per
System Preferences->Displays->Arrangement). The origin `0,0` is at the top left corner of the *primary screen*.
Screens to the top or the left of the primary screen, and windows on these screens, will have negative coordinates.

## Overview


| Module [hm.screen](hm.screen.md#module-hmscreen-extends-hmmodule) |  |
| :--- | :---
Function [`hm.screen._toCocoa(rect)`](hm.screen.md#function-hmscreentococoarect---hmgeometryrect) -> [_`<hm.geometry#rect>`_](hm.geometry.md#type-rect) | Transform a `geometry.rect` object from HS/HM coordinate system (origin at top left of primary screen)
to Cocoa coordinate system (origin at bottom left of primary screen)
Function [`hm.screen.allScreens()`](hm.screen.md#function-hmscreenallscreens---screen-) -> `{`[_`<#screen>`_](hm.screen.md#type-screen-extends-hmmoduleclass)`, ...}` | Returns all the screens currently connected and enabled.
Function [`hm.screen.mainScreen()`](hm.screen.md#function-hmscreenmainscreen---screen) -> [_`<#screen>`_](hm.screen.md#type-screen-extends-hmmoduleclass) | Returns the main screen.
Function [`hm.screen.primaryScreen()`](hm.screen.md#function-hmscreenprimaryscreen) | 


| Type [<#screen>](hm.screen.md#type-screen-extends-hmmoduleclass) |  |
| :--- | :---
Method [`<#screen>:availableModes(pattern)`](hm.screen.md#method-screenavailablemodespattern---screenmode-) -> `{`[_`<#screenMode>`_](hm.screen.md#type-screenmode-extends-string)`, ...}` | Returns a list of the modes supported by the screen.
Method [`<#screen>:currentMode()`](hm.screen.md#method-screencurrentmode---screenmode) -> [_`<#screenMode>`_](hm.screen.md#type-screenmode-extends-string) | Returns the screen's current mode.
Method [`<#screen>:frame()`](hm.screen.md#method-screenframe) | 
Method [`<#screen>:getGamma()`](hm.screen.md#method-screengetgamma) | 
Method [`<#screen>:id()`](hm.screen.md#method-screenid---number) -> _`<#number>`_ | Returns a screen's unique ID.
Method [`<#screen>:isModeAvailable(mode)`](hm.screen.md#method-screenismodeavailablemode) | 
Method [`<#screen>:name()`](hm.screen.md#method-screenname---string) -> _`<#string>`_ | Returns the screen's name.
Method [`<#screen>:setGamma(gammaTable,_hscompat)`](hm.screen.md#method-screensetgammagammatablehscompat) | 
Method [`<#screen>:setMode(mode)`](hm.screen.md#method-screensetmodemode) | 
Method [`<#screen>:visibleFrame()`](hm.screen.md#method-screenvisibleframe) | 


| Type [<#screenMode>](hm.screen.md#type-screenmode-extends-string) | A string describing a screen mode. |
| :--- | :---






------------------

## Module `hm.screen` (extends [_`<hm#module>`_](hm.md#class-module))






### Function `hm.screen._toCocoa(rect)` -> [_`<hm.geometry#rect>`_](hm.geometry.md#type-rect)

> **Internal/advanced use only** (e.g. for extension developers)

Transform a `geometry.rect` object from HS/HM coordinate system (origin at top left of primary screen)
to Cocoa coordinate system (origin at bottom left of primary screen)

**Parameters:**

* [_`<hm.geometry#rect>`_](hm.geometry.md#type-rect) `rect`: 

**Returns:**

* [_`<hm.geometry#rect>`_](hm.geometry.md#type-rect) transformed rect




### Function `hm.screen.allScreens()` -> `{`[_`<#screen>`_](hm.screen.md#type-screen-extends-hmmoduleclass)`, ...}`

Returns all the screens currently connected and enabled.

**Returns:**

* `{`[_`<#screen>`_](hm.screen.md#type-screen-extends-hmmoduleclass)`, ...}` 




### Function `hm.screen.mainScreen()` -> [_`<#screen>`_](hm.screen.md#type-screen-extends-hmmoduleclass)

Returns the main screen.

**Returns:**

* [_`<#screen>`_](hm.screen.md#type-screen-extends-hmmoduleclass) 

The main screen is the one containing the currently focused window.


### Function `hm.screen.primaryScreen()`








------------------

### Type `<#screen>` (extends [_`<hm#module.class>`_](hm.md#class-moduleclass))






### Method `<#screen>:availableModes(pattern)` -> `{`[_`<#screenMode>`_](hm.screen.md#type-screenmode-extends-string)`, ...}`

> **API CHANGE**: Returns a plain list of strings. Allows filtering.

Returns a list of the modes supported by the screen.

**Parameters:**

* _`<#string>`_ `pattern`: A pattern to filter the modes as per `string.find`; e.g. passing `"/60" will only return modes with a refresh rate of 60Hz

**Returns:**

* `{`[_`<#screenMode>`_](hm.screen.md#type-screenmode-extends-string)`, ...}` 




### Method `<#screen>:currentMode()` -> [_`<#screenMode>`_](hm.screen.md#type-screenmode-extends-string)

> **API CHANGE**: Returns a string instead of a table

Returns the screen's current mode.

**Returns:**

* [_`<#screenMode>`_](hm.screen.md#type-screenmode-extends-string) 

The screen's mode indicates its current resolution and scaling factor.


### Method `<#screen>:frame()`






### Method `<#screen>:getGamma()`






### Method `<#screen>:id()` -> _`<#number>`_

Returns a screen's unique ID.

**Returns:**

* _`<#number>`_ the screen ID




### Method `<#screen>:isModeAvailable(mode)`



**Parameters:**

* _`<?>`_ `mode`: 




### Method `<#screen>:name()` -> _`<#string>`_

Returns the screen's name.

**Returns:**

* _`<#string>`_ the screen name

The screen's name is set by the manufacturer.


### Method `<#screen>:setGamma(gammaTable,_hscompat)`



**Parameters:**

* _`<?>`_ `gammaTable`: 
* _`<?>`_ `_hscompat`: 




### Method `<#screen>:setMode(mode)`

> **API CHANGE**: Refresh rate, color depth are supported.



**Parameters:**

* [_`<#screenMode>`_](hm.screen.md#type-screenmode-extends-string) `mode`: 




### Method `<#screen>:visibleFrame()`








------------------

### Type `<#screenMode>` (extends _`<#string>`_)

A string describing a screen mode.

The format of the string is `WWWWxHHHH@Sx/RR`, where WWWW is the width in points, HHHH the height in points,
 S is the scaling factor, i.e. 2 for HiDPI (a.k.a "retina") mode or 1 for native mode, and RR is the refresh
 rate in Hz; the `/RR` part is optional. E.g.: `"1440x900@2x/60"`.
 Note that "points" are not necessarily the same as pixels, because they take the scale factor into account
 (e.g. "1440x900@2x" is a 2880x1800 screen resolution, with a scaling factor of 2, i.e. with HiDPI pixel-doubled
 rendering enabled), however, they are far more useful to work with than native pixel modes, when a Retina screen
 is involved. For non-retina screens, points and pixels are equivalent.


