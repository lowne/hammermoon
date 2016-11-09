# Module `hm`

Hammermoon main module



-----------

## Table `hm._core`



> **Internal/advanced use only** (e.g. for extension developers)

Hammermoon core facilities for use by extensions.




### Function `hm._core.deprecate(module,fieldname,replacement)`

> **API CHANGE**: Doesn't exist in Hammerspoon

Deprecate a field or function of a module

**Parameters:**

* `module`: [`<#module>`](hm.md#type-module) 
* `fieldname`: `<#string>` 
* `replacement`: `<#string>` The replacement field or function to direct users to




### Function `hm._core.disallow(module,fieldname,replacement)`

> **API CHANGE**: Doesn't exist in Hammerspoon

Disallow a field or function of a module (after deprecation)

**Parameters:**

* `module`: [`<#module>`](hm.md#type-module) 
* `fieldname`: `<#string>` 
* `replacement`: `<#string>` The replacement field or function to direct users to




### Function `hm._core.module(name,classmt)` -> [`<#module>`](hm.md#type-module)

> **API CHANGE**: Doesn't exist in Hammerspoon

Declare a new Hammermoon extension.

**Parameters:**

* `name`: `<#string>` module name (without the '`hm.` prefix)
* `classmt`: `<#table>` initial metatable for the module's class (if any); can contain `__tostring`, `__eq`, `__gc`, etc

**Returns:**

* [`<#module>`](hm.md#type-module) the "naked" table for the new module, ready to be filled with functions

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

* `module`: [`<#module>`](hm.md#type-module) 
* `fieldname`: `<#string>` 
* `getter`: `<#function>` 
* `setter`: `<#function>` 






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

-----------



# Module `hm.logger`

Simple logger for debugging purposes.



-----------

## Module `hm.logger`







### Field `hm.logger.historySize`: `<#number>`
> **API CHANGE**: function hm.logger.historySize([v]) -> field hm.logger.historySize

The number of log entries to keep in the history.

The starting value is 0 (history is disabled). To enable the log history, set this at the top of your userscript.
If you change history size (other than from 0) after creating any logger instances, things will likely break.



-----------

## Type `<#logger>`



A logger instance.




### Function `<#logger>.fd(fmt,...)`

> **API CHANGE**: logger.df -> logger.fd

Logs formatted debug info to the console

**Parameters:**

* `fmt`: `<#string>` formatting string as per `string.format`
* `...`: `?` one or more message strings




### Function `<#logger>.fe(fmt,...)`

> **API CHANGE**: logger.ef -> logger.fe

Logs a formatted error to the console

**Parameters:**

* `fmt`: `<#string>` formatting string as per `string.format`
* `...`: `?` one or more message strings




### Function `<#logger>.fi(fmt,...)`

> **API CHANGE**: logger.f -> logger.fi

Logs formatted info to the console

**Parameters:**

* `fmt`: `<#string>` formatting string as per `string.format`
* `...`: `?` one or more message strings




### Function `<#logger>.fv(fmt,...)`

> **API CHANGE**: logger.vf -> logger.fv

Logs formatted verbose info to the console

**Parameters:**

* `fmt`: `<#string>` formatting string as per `string.format`
* `...`: `?` one or more message strings




### Function `<#logger>.fw(fmt,...)`

> **API CHANGE**: logger.wf -> logger.fw

Logs a formatted warning to the console

**Parameters:**

* `fmt`: `<#string>` formatting string as per `string.format`
* `...`: `?` one or more message strings






-----------

-----------



# Module `hm.screen`





-----------

## Type `<#screen>`








### Method `<#screen>:currentMode()` -> `<#string>`

> **API CHANGE**: Returns a string instead of a table

Get the current display mode

**Returns:**

* `<#string>` 






-----------

-----------

