# Module `hm.screens`

Manipulate screens (monitors).

The OSX coordinate system used by Hammermoon assumes a grid that spans all the screens (positioned as per
System Preferences->Displays->Arrangement). The origin `0,0` is at the top left corner of the *primary screen*.
Screens to the top or the left of the primary screen, and windows on these screens, will have negative coordinates.

## Overview


* Module [`hm.screens`](hm.screens.md#module-hmscreens)
  * [`focusedScreen`](hm.screens.md#property-read-only-hmscreensfocusedscreen-screen) : [_`<#screen>`_](hm.screens.md#class-screen) - property (read-only)
  * [`primaryScreen`](hm.screens.md#property-read-only-hmscreensprimaryscreen-screen) : [_`<#screen>`_](hm.screens.md#class-screen) - property (read-only)
  * [`screens`](hm.screens.md#property-read-only-hmscreensscreens-screen-) : `{`[_`<#screen>`_](hm.screens.md#class-screen)`, ...}` - property (read-only)


* Class [`screen`](hm.screens.md#class-screen)
  * [`availableModes`](hm.screens.md#property-read-only-screenavailablemodes-screenmode-) : `{`[_`<#screenMode>`_](hm.screens.md#type-screenmode)`, ...}` - property (read-only)
  * [`frame`](hm.screens.md#property-read-only-screenframe-hmtypesgeometryrect) : [_`<hm.types.geometry#rect>`_](hm.types.geometry.md#type-rect) - property (read-only)
  * [`fullFrame`](hm.screens.md#property-read-only-screenfullframe-hmtypesgeometryrect) : [_`<hm.types.geometry#rect>`_](hm.types.geometry.md#type-rect) - property (read-only)
  * [`id`](hm.screens.md#property-read-only-screenid-number) : _`<#number>`_ - property (read-only)
  * [`name`](hm.screens.md#property-read-only-screenname-string) : _`<#string>`_ - property (read-only)
  * [`mode`](hm.screens.md#property-screenmode-screenmode) : [_`<#screenMode>`_](hm.screens.md#type-screenmode) - property
  * [`findModes(pattern)`](hm.screens.md#method-screenfindmodespattern---screenmode-) -> `{`[_`<#screenMode>`_](hm.screens.md#type-screenmode)`, ...}` - method
  * [`getGamma()`](hm.screens.md#method-screengetgamma) - method
  * [`setGamma(gammaTable,_hscompat)`](hm.screens.md#method-screensetgammagammatablehscompat) - method


* Type [`screenMode`](hm.screens.md#type-screenmode)
  * [`__tostring(mode)`](hm.screens.md#function-screenmodetostringmode) - function






------------------

## Module `hm.screens`

> Extends [_`<hm#module>`_](hm.md#class-module)





### Property (read-only) `hm.screens.focusedScreen`: [_`<#screen>`_](hm.screens.md#class-screen)
The currently focused screen.

The focused screen is the one containing the currently focused window.


### Property (read-only) `hm.screens.primaryScreen`: [_`<#screen>`_](hm.screens.md#class-screen)
The primary screen.

The primary screen is the one containing the menubar and dock.


### Property (read-only) `hm.screens.screens`: `{`[_`<#screen>`_](hm.screens.md#class-screen)`, ...}`
The currently connected and enabled screens.





------------------

## Class `screen`

> Extends [_`<hm#module.class>`_](hm.md#class-moduleclass)





### Property (read-only) `<#screen>.availableModes`: `{`[_`<#screenMode>`_](hm.screens.md#type-screenmode)`, ...}`
The screen's available modes.




### Property (read-only) `<#screen>.frame`: [_`<hm.types.geometry#rect>`_](hm.types.geometry.md#type-rect)
The screen's usable frame.

The usable frame excludes the area currently occupied by the dock and menubar.
Even with dock and menubar hiding enabled, this rectangle may be smaller than the full frame.


### Property (read-only) `<#screen>.fullFrame`: [_`<hm.types.geometry#rect>`_](hm.types.geometry.md#type-rect)
The screen frame.




### Property (read-only) `<#screen>.id`: _`<#number>`_
The screen's unique ID.




### Property (read-only) `<#screen>.name`: _`<#string>`_
The screen's name.

The screen's name is set by the manufacturer.


### Property `<#screen>.mode`: [_`<#screenMode>`_](hm.screens.md#type-screenmode)
The screen's current mode.




### Method `<#screen>:findModes(pattern)` -> `{`[_`<#screenMode>`_](hm.screens.md#type-screenmode)`, ...}`

Returns a list of modes supported by the screen, filtered by a given search criterion.

* `pattern`: _`<#string>`_ A pattern to filter the modes as per `string.find`; e.g. passing `"/60" will only return modes with a refresh rate of 60Hz



* Returns `{`[_`<#screenMode>`_](hm.screens.md#type-screenmode)`, ...}`: 




### Method `<#screen>:getGamma()`






### Method `<#screen>:setGamma(gammaTable,_hscompat)`



* `gammaTable`: _`<?>`_ 
* `_hscompat`: _`<?>`_ 






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


### Function `<#screenMode>.__tostring(mode)`



* `mode`: _`<?>`_ 





