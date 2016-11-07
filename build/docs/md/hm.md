# Module `hm`

Hammermoon main module



## Overview

| Global fields | |
| :--- | :--- |
Global field [`hm`](#global-field-hm-hm) : [`<#hm>`](#module-hm) | Hammermoon's namespace, globally accessible from userscripts
Global field [`hs`](#global-field-hs-hm) : [`<#hm>`](#module-hm) | For compatibility with Hammerspoon userscripts

| Module [hm](#module-hm) |  |
| :--- | :---
Field [`hm._core`](#field-hm_core-hm_core) : [`hm._core`](#table-hm_core) | 
Field [`hm.debug`](#field-hmdebug-hmdebug) : [`hm.debug`](#table-hmdebug) | 


| Table [hm._core](#table-hm_core) | Hammermoon core facilities for use by extensions. |
| :--- | :---
Function [`hm._core.module(name,classmt)`](#function-hm_coremodulenameclassmt---module) -> [`<#module>`](#type-module) | Declare a new Hammermoon extension.
Field [`hm._core.defaultNotificationCenter`](#field-hm_coredefaultnotificationcenter-notificationcenter) : [`<#notificationCenter>`](#type-notificationcenter) | The default Notification Center.
Field [`hm._core.log`](#field-hm_corelog-hmloggerlogger) : [`<hm.logger#logger>`](hm.logger.md#type-logger) | Logger instance for Hammermoon's core
Field [`hm._core.systemWideAccessibility`](#field-hm_coresystemwideaccessibility-cdata) : `<#cdata>` | `AXUIElementCreateSystemWide()` instance
Field [`hm._core.wsNotificationCenter`](#field-hm_corewsnotificationcenter-notificationcenter) : [`<#notificationCenter>`](#type-notificationcenter) | The shared workspace's Notification Center.


| Table [hm.debug](#table-hmdebug) | Debug options |
| :--- | :---
Field [`hm.debug.cache_uielements`](#field-hmdebugcache_uielements-boolean) : `<#boolean>` | if false, uielement objects (including applications and windows) are not cached
Field [`hm.debug.retain_user_objects`](#field-hmdebugretain_user_objects-boolean) : `<#boolean>` | if false, user objects (timers, watchers, etc.) will get gc'ed unless the userscript keeps a global reference


| Type [<#module>](#type-module) | Type for Hammermoon extensions. |
| :--- | :---
Field [`<#module>._class`](#field-module_class-moduleclass) : [`<#module.class>`](#type-moduleclass) | The class for the extension's objects
Field [`<#module>.log`](#field-modulelog-hmloggerlogger) : [`<hm.logger#logger>`](hm.logger.md#type-logger) | The extension's module-level logger instance


| Type [<#module.class>](#type-moduleclass) | Type for Hammermoon objects |
| :--- | :---
Function [`<#module.class>._new(t)`](#function-moduleclass_newt---) -> `?` | Create a new instance.


| Type [<#notificationCenter>](#type-notificationcenter) |  |
| :--- | :---
Method [`<#notificationCenter>:register(event,cb,priority)`](#method-notificationcenterregistereventcbpriority) | 






-----------

## Global fields

### Global field `hm`: [`<#hm>`](#module-hm)
Hammermoon's namespace, globally accessible from userscripts



### Global field `hs`: [`<#hm>`](#module-hm)
For compatibility with Hammerspoon userscripts







-----------

## Module `hm`







### Field `hm._core`: [`hm._core`](#table-hm_core)





### Field `hm.debug`: [`hm.debug`](#table-hmdebug)






-----------

## Table `hm._core`



> **Internal/advanced use only** (e.g. for extension developers)

Hammermoon core facilities for use by extensions.




### Function `hm._core.module(name,classmt)` -> [`<#module>`](#type-module)

Declare a new Hammermoon extension.

**Parameters:**

* `name`: `<#string>` module name (without the '`hm.` prefix)
* `classmt`: `<#table>` initial metatable for the module's class (if any); can contain `__tostring`, `__eq`, `__gc`, etc

**Returns:**

* [`<#module>`](#type-module) the "naked" table for the new module, ready to be filled with functions

Use this function to create the table for your module.
If your module instantiates objects, you should pass `classmt` (even just an empty table),
and retrieve the metatable for your objects (and the constructor) via the `_class` field
of the returned module table. Note that the `__gc` operator, if present, *must* be already
in `classmt` (i.e. you cannot add it afterwards) for Hammermoon's allocation debugging to work.

**Usage**:

```lua
local mymodule=hm._core.module('mymodule',{})
local myclass=mymodule._class
function mymodule.myfunction(param) ... end
function mymodule.construct(args) ... return myclass._new(...) end
function myclass:mymethod() ... end
...
return mymodule -- at the end of the file
```
### Field `hm._core.defaultNotificationCenter`: [`<#notificationCenter>`](#type-notificationcenter)
The default Notification Center.




### Field `hm._core.log`: [`<hm.logger#logger>`](hm.logger.md#type-logger)
Logger instance for Hammermoon's core




### Field `hm._core.systemWideAccessibility`: `<#cdata>`
`AXUIElementCreateSystemWide()` instance




### Field `hm._core.wsNotificationCenter`: [`<#notificationCenter>`](#type-notificationcenter)
The shared workspace's Notification Center.





-----------

## Table `hm.debug`



> **Internal/advanced use only** (e.g. for extension developers)

> **API CHANGE**: doesn't exist in Hammerspoon

Debug options



### Field `hm.debug.cache_uielements`: `<#boolean>`
if false, uielement objects (including applications and windows) are not cached




### Field `hm.debug.retain_user_objects`: `<#boolean>`
if false, user objects (timers, watchers, etc.) will get gc'ed unless the userscript keeps a global reference





-----------

## Type `<#module>`



Type for Hammermoon extensions.

Hammermoon extensions (usually created via `hm._core.module()`) can be `require`d normally
(`local someext=require'hm.someext'`) or loaded directly via the the global `hm` namespace
(`hm.someext.somefn(...)`).

### Field `<#module>._class`: [`<#module.class>`](#type-moduleclass)
The class for the extension's objects




### Field `<#module>.log`: [`<hm.logger#logger>`](hm.logger.md#type-logger)
The extension's module-level logger instance





-----------

## Type `<#module.class>`



> **Internal/advanced use only** (e.g. for extension developers)

Type for Hammermoon objects




### Function `<#module.class>._new(t)` -> `?`

> **Internal/advanced use only** (e.g. for extension developers)

Create a new instance.

**Parameters:**

* `t`: `<#table>` initial values for the new object

**Returns:**

* `?` a new object instance

Objects created by this function have their lifecycle tracked by Hammermoon's core.




-----------

## Type `<#notificationCenter>`








### Method `<#notificationCenter>:register(event,cb,priority)`



**Parameters:**

* `event`: `<#string>` 
* `cb`: `<#function>` 
* `priority`: `<#boolean>` 





