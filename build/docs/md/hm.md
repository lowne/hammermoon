# Module `hm`

Hammermoon main module



## Overview

| Global functions| |
| :--- | :--- |
Global function [`assertf(v,fmt,...)`](#global-function-assertfvfmt) | 
Global function [`errorf(fmt,...)`](#global-function-errorffmt) | 
Global function [`printf(fmt,...)`](#global-function-printffmt) | 

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
Function [`hm._core.cacheKeys()`](#function-hm_corecachekeys) | 
Function [`hm._core.cacheValues()`](#function-hm_corecachevalues) | 
Function [`hm._core.deprecate(module,fieldname,replacement)`](#function-hm_coredeprecatemodulefieldnamereplacement) | Deprecate a field or function of a module
Function [`hm._core.disallow(module,fieldname,replacement)`](#function-hm_coredisallowmodulefieldnamereplacement) | Disallow a field or function of a module (after deprecation)
Function [`hm._core.module(name,classmt)`](#function-hm_coremodulenameclassmt---module) -> [`<#module>`](#type-module) | Declare a new Hammermoon extension.
Function [`hm._core.property(module,fieldname,getter,setter)`](#function-hm_corepropertymodulefieldnamegettersetter) | Add a user-facing field to a module with a custom getter and setter
Function [`hm._core.protoModule()`](#function-hm_coreprotomodule) | 
Function [`hm._core.retainKeys()`](#function-hm_coreretainkeys) | 
Function [`hm._core.retainValues()`](#function-hm_coreretainvalues) | 
Field [`hm._core.defaultNotificationCenter`](#field-hm_coredefaultnotificationcenter-notificationcenter) : [`<#notificationCenter>`](#type-notificationcenter) | The default Notification Center.
Field [`hm._core.log`](#field-hm_corelog-hmloggerlogger) : [`<hm.logger#logger>`](hm.logger.md#type-logger) | Logger instance for Hammermoon's core
Field [`hm._core.rawrequire`](#field-hm_corerawrequire-) : `?` | 
Field [`hm._core.sharedWorkspace`](#field-hm_coresharedworkspace-cdata) : `<#cdata>` | The shared `NSWorkspace` instance
Field [`hm._core.systemWideAccessibility`](#field-hm_coresystemwideaccessibility-cdata) : `<#cdata>` | `AXUIElementCreateSystemWide()` instance
Field [`hm._core.wsNotificationCenter`](#field-hm_corewsnotificationcenter-notificationcenter) : [`<#notificationCenter>`](#type-notificationcenter) | The shared workspace's Notification Center.


| Table [hm.debug](#table-hmdebug) | Debug options |
| :--- | :---
Field [`hm.debug.cache_uielements`](#field-hmdebugcache_uielements-boolean) : `<#boolean>` | Cache uielement objects (default `true`).
Field [`hm.debug.retain_user_objects`](#field-hmdebugretain_user_objects-boolean) : `<#boolean>` | Retain user objects internally (default `true`).


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

## Global functions

### Global function `assertf(v,fmt,...)`



**Parameters:**

* `v`: `?` 
* `fmt`: `<#string>` 
* `...`: `?` 



### Global function `errorf(fmt,...)`



**Parameters:**

* `fmt`: `<#string>` 
* `...`: `?` 



### Global function `printf(fmt,...)`



**Parameters:**

* `fmt`: `<#string>` 
* `...`: `?` 







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




### Function `hm._core.cacheKeys()`






### Function `hm._core.cacheValues()`






### Function `hm._core.deprecate(module,fieldname,replacement)`

> **API CHANGE**: Doesn't exist in Hammerspoon

Deprecate a field or function of a module

**Parameters:**

* `module`: [`<#module>`](#type-module) 
* `fieldname`: `<#string>` 
* `replacement`: `<#string>` The replacement field or function to direct users to




### Function `hm._core.disallow(module,fieldname,replacement)`

> **API CHANGE**: Doesn't exist in Hammerspoon

Disallow a field or function of a module (after deprecation)

**Parameters:**

* `module`: [`<#module>`](#type-module) 
* `fieldname`: `<#string>` 
* `replacement`: `<#string>` The replacement field or function to direct users to




### Function `hm._core.module(name,classmt)` -> [`<#module>`](#type-module)

> **API CHANGE**: Doesn't exist in Hammerspoon

Declare a new Hammermoon extension.

**Parameters:**

* `name`: `<#string>` module name (without the '`hm.` prefix)
* `classmt`: `<#table>` initial metatable for the module's class (if any); can contain `__tostring`, `__eq`, `__gc`, etc

**Returns:**

* [`<#module>`](#type-module) the "naked" table for the new module, ready to be filled with functions

Use this function to create the table for your module.
If your module instantiates objects, you should pass `classmt` (even just an empty table),
and retrieve the metatable for your objects (and the constructor) via the `_class` field
of the returned module table. Note that the `__gc` metamethod, if present, *must* be already
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
### Function `hm._core.property(module,fieldname,getter,setter)`

> **API CHANGE**: Doesn't exist in Hammerspoon

Add a user-facing field to a module with a custom getter and setter

**Parameters:**

* `module`: [`<#module>`](#type-module) 
* `fieldname`: `<#string>` 
* `getter`: `<#function>` 
* `setter`: `<#function>` 




### Function `hm._core.protoModule()`






### Function `hm._core.retainKeys()`






### Function `hm._core.retainValues()`






### Field `hm._core.defaultNotificationCenter`: [`<#notificationCenter>`](#type-notificationcenter)
The default Notification Center.




### Field `hm._core.log`: [`<hm.logger#logger>`](hm.logger.md#type-logger)
Logger instance for Hammermoon's core




### Field `hm._core.rawrequire`: `?`





### Field `hm._core.sharedWorkspace`: `<#cdata>`
The shared `NSWorkspace` instance




### Field `hm._core.systemWideAccessibility`: `<#cdata>`
`AXUIElementCreateSystemWide()` instance




### Field `hm._core.wsNotificationCenter`: [`<#notificationCenter>`](#type-notificationcenter)
The shared workspace's Notification Center.





-----------

## Table `hm.debug`



> **Internal/advanced use only** (e.g. for extension developers)

> **API CHANGE**: Doesn't exist in Hammerspoon

Debug options



### Field `hm.debug.cache_uielements`: `<#boolean>`
Cache uielement objects (default `true`).

Uielement objects (including applications and windows) are cached internally for performance; this can be disabled.


### Field `hm.debug.retain_user_objects`: `<#boolean>`
Retain user objects internally (default `true`).

User objects (timers, watchers, etc.) are retained internally by default, so
userscripts needn't worry about their lifecycle.
If falsy, they will get gc'ed unless the userscript keeps a global reference.



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

> **Internal/advanced use only** (e.g. for extension developers)



**Parameters:**

* `event`: `<#string>` 
* `cb`: `<#function>` 
* `priority`: `<#boolean>` 






-----------

-----------

