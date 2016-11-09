# Module `hm.screen`





## Overview


| Module [hm.screen](#module-hmscreen) |  |
| :--- | :---
Function [`hm.screen._toCocoa(g)`](#function-hmscreen_tococoag) | 
Function [`hm.screen.allScreens()`](#function-hmscreenallscreens---screen-) -> `{`[`<#screen>`](#type-screen)`, ...}` | Returns all the screens currently connected and enabled.
Function [`hm.screen.mainScreen()`](#function-hmscreenmainscreen---screen) -> [`<#screen>`](#type-screen) | Returns the main screen.
Function [`hm.screen.primaryScreen()`](#function-hmscreenprimaryscreen) | 


| Type [<#screen>](#type-screen) |  |
| :--- | :---
Method [`<#screen>:currentMode()`](#method-screencurrentmode---string) -> `<#string>` | Get the current display mode
Method [`<#screen>:frame()`](#method-screenframe) | 
Method [`<#screen>:id()`](#method-screenid) | 
Method [`<#screen>:name()`](#method-screenname) | 
Method [`<#screen>:visibleFrame()`](#method-screenvisibleframe) | 






-----------

## Module `hm.screen`








### Function `hm.screen._toCocoa(g)`

> **Internal/advanced use only** (e.g. for extension developers)



**Parameters:**

* `g`: `?` 




### Function `hm.screen.allScreens()` -> `{`[`<#screen>`](#type-screen)`, ...}`

Returns all the screens currently connected and enabled.

**Returns:**

* `{`[`<#screen>`](#type-screen)`, ...}` 




### Function `hm.screen.mainScreen()` -> [`<#screen>`](#type-screen)

Returns the main screen.

**Returns:**

* [`<#screen>`](#type-screen) 

The main screen is the one containing the currently focused window


### Function `hm.screen.primaryScreen()`








-----------

## Type `<#screen>`








### Method `<#screen>:currentMode()` -> `<#string>`

> **API CHANGE**: Returns a string instead of a table

Get the current display mode

**Returns:**

* `<#string>` 




### Method `<#screen>:frame()`






### Method `<#screen>:id()`






### Method `<#screen>:name()`






### Method `<#screen>:visibleFrame()`








-----------

-----------

