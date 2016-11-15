# Module `hm`

Hammermoon main module



## Overview

| Global functions| |
| :--- | :--- |
Global function [`assertf(v,fmt,...)`](hm.md#global-function-assertfvfmt) | 
Global function [`errorf(fmt,...)`](hm.md#global-function-errorffmt) | 
Global function [`inspect(t,inline,depth)`](hm.md#global-function-inspecttinlinedepth) | 
Global function [`printf(fmt,...)`](hm.md#global-function-printffmt) | 

| Global fields | |
| :--- | :--- |
Global field [`hm`](hm.md#global-field-hm-hm) : [_`<#hm>`_](hm.md#module-hm) | Hammermoon's namespace, globally accessible from userscripts
Global field [`hs`](hm.md#global-field-hs-) : _`<?>`_ | For compatibility with Hammerspoon userscripts


| Module [hm](hm.md#module-hm) |  |
| :--- | :---
Function [`hm.quit()`](hm.md#function-hmquit) | Quits Hammermoon.
Function [`hm.type(obj)`](hm.md#function-hmtypeobj---string) -> _`<#string>`_ | Returns the Hammermoon type of an object.
Field [`hm._core`](hm.md#field-hmcore-hmcore) : [_`hm._core`_](hm.md#table-hmcore) | 
Field [`hm.debug`](hm.md#field-hmdebug-hmdebug) : [_`hm.debug`_](hm.md#table-hmdebug) | 


| Class [<#module>](hm.md#class-module) | Type for Hammermoon extensions. |
| :--- | :---
Function [`<#module>.__gc()`](hm.md#function-modulegc) | Implement this function to perform any required cleanup when a module is unloaded
Field [`<#module>._class`](hm.md#field-moduleclass-moduleclass) : [_`<#module.class>`_](hm.md#class-moduleclass) | The class for the extension's objects
Field [`<#module>.log`](hm.md#field-modulelog-hmloggerlogger) : [_`<hm.logger#logger>`_](hm.logger.md#type-logger) | The extension's module-level logger instance


| Class [<#module.class>](hm.md#class-moduleclass) | Type for Hammermoon objects |
| :--- | :---
Function [`<#module.class>._new(t)`](hm.md#function-moduleclassnewt---) -> _`<?>`_ | Create a new instance.


| Class [<#notificationCenter>](hm.md#class-notificationcenter) |  |
| :--- | :---
Method [`<#notificationCenter>:register(event,cb,priority)`](hm.md#method-notificationcenterregistereventcbpriority) | 


| Table [hm._core](hm.md#table-hmcore) | Hammermoon core facilities for use by extensions. |
| :--- | :---
Function [`hm._core.cacheKeys()`](hm.md#function-hmcorecachekeys) | 
Function [`hm._core.cacheValues()`](hm.md#function-hmcorecachevalues) | 
Function [`hm._core.deprecate(module,fieldname,replacement)`](hm.md#function-hmcoredeprecatemodulefieldnamereplacement) | Deprecate a field or function of a module or class
Function [`hm._core.disallow(module,fieldname,replacement)`](hm.md#function-hmcoredisallowmodulefieldnamereplacement) | Disallow a field or function of a module or class (after deprecation)
Function [`hm._core.module(name,classmt)`](hm.md#function-hmcoremodulenameclassmt---module) -> [_`<#module>`_](hm.md#class-module) | Declare a new Hammermoon extension.
Function [`hm._core.property(module,fieldname,getter,setter)`](hm.md#function-hmcorepropertymodulefieldnamegettersetter) | Add a property to a module or class.
Function [`hm._core.retainKeys()`](hm.md#function-hmcoreretainkeys) | 
Function [`hm._core.retainValues()`](hm.md#function-hmcoreretainvalues) | 
Field [`hm._core.defaultNotificationCenter`](hm.md#field-hmcoredefaultnotificationcenter-notificationcenter) : [_`<#notificationCenter>`_](hm.md#class-notificationcenter) | The default Notification Center.
Field [`hm._core.log`](hm.md#field-hmcorelog-hmloggerlogger) : [_`<hm.logger#logger>`_](hm.logger.md#type-logger) | Logger instance for Hammermoon's core
Field [`hm._core.rawrequire`](hm.md#field-hmcorerawrequire-) : _`<?>`_ | 
Field [`hm._core.sharedWorkspace`](hm.md#field-hmcoresharedworkspace-cdata) : _`<#cdata>`_ | The shared `NSWorkspace` instance
Field [`hm._core.systemWideAccessibility`](hm.md#field-hmcoresystemwideaccessibility-cdata) : _`<#cdata>`_ | `AXUIElementCreateSystemWide()` instance
Field [`hm._core.wsNotificationCenter`](hm.md#field-hmcorewsnotificationcenter-notificationcenter) : [_`<#notificationCenter>`_](hm.md#class-notificationcenter) | The shared workspace's Notification Center.


| Table [hm.debug](hm.md#table-hmdebug) | Debug options |
| :--- | :---
Field [`hm.debug.cacheUIElements`](hm.md#field-hmdebugcacheuielements-boolean) : _`<#boolean>`_ | Cache uielement objects (default `true`).
Field [`hm.debug.disableAssertions`](hm.md#field-hmdebugdisableassertions-boolean) : _`<#boolean>`_ | Disable assertions (default `false`).
Field [`hm.debug.disableTypeChecks`](hm.md#field-hmdebugdisabletypechecks-boolean) : _`<#boolean>`_ | Disable type checks (default `false`).
Field [`hm.debug.retainUserObjects`](hm.md#field-hmdebugretainuserobjects-boolean) : _`<#boolean>`_ | Retain user objects internally (default `true`).






------------------

## Global functions

### Global function `assertf(v,fmt,...)`



**Parameters:**

* _`<?>`_ `v`: 
* _`<#string>`_ `fmt`: 
* _`<?>`_ `...`: 



### Global function `errorf(fmt,...)`



**Parameters:**

* _`<#string>`_ `fmt`: 
* _`<?>`_ `...`: 



### Global function `inspect(t,inline,depth)`

> **Internal/advanced use only** (e.g. for extension developers)



**Parameters:**

* _`<?>`_ `t`: 
* _`<?>`_ `inline`: 
* _`<?>`_ `depth`: 



### Global function `printf(fmt,...)`



**Parameters:**

* _`<#string>`_ `fmt`: 
* _`<?>`_ `...`: 







------------------

## Global fields

### Global field `hm`: [_`<#hm>`_](hm.md#module-hm)
Hammermoon's namespace, globally accessible from userscripts



### Global field `hs`: _`<?>`_
For compatibility with Hammerspoon userscripts







------------------

## Module `hm`






### Function `hm.quit()`

Quits Hammermoon.

This function will make sure to properly close the Lua state, so that all the __gc metamethods will run.


### Function `hm.type(obj)` -> _`<#string>`_

Returns the Hammermoon type of an object.

**Parameters:**

* _`<?>`_ `obj`: object to get the type of

**Returns:**

* _`<#string>`_ the object type

If `obj` is an Hammermoon [_`<#module>`_](hm.md#class-module), [_`<#module.class>`_](hm.md#class-moduleclass), or module object, this function will return its type name
instead of the generic `"table"`. In all other cases this function behaves like Lua's `type()`.


### Field `hm._core`: [_`hm._core`_](hm.md#table-hmcore)





### Field `hm.debug`: [_`hm.debug`_](hm.md#table-hmdebug)






------------------

## Class `<#module>`

Type for Hammermoon extensions.

Hammermoon extensions (usually created via `hm._core.module()`) can be `require`d normally
(`local someext=require'hm.someext'`) or loaded directly via the the global `hm` namespace
(`hm.someext.somefn(...)`).


### Function `<#module>.__gc()`

> **Internal/advanced use only** (e.g. for extension developers)

Implement this function to perform any required cleanup when a module is unloaded




### Field `<#module>._class`: [_`<#module.class>`_](hm.md#class-moduleclass)
The class for the extension's objects




### Field `<#module>.log`: [_`<hm.logger#logger>`_](hm.logger.md#type-logger)
The extension's module-level logger instance





------------------

## Class `<#module.class>`

> **Internal/advanced use only** (e.g. for extension developers)

Type for Hammermoon objects




### Function `<#module.class>._new(t)` -> _`<?>`_

> **Internal/advanced use only** (e.g. for extension developers)

Create a new instance.

**Parameters:**

* _`<#table>`_ `t`: initial values for the new object

**Returns:**

* _`<?>`_ a new object instance

Objects created by this function have their lifecycle tracked by Hammermoon's core.




------------------

## Class `<#notificationCenter>`






### Method `<#notificationCenter>:register(event,cb,priority)`

> **Internal/advanced use only** (e.g. for extension developers)



**Parameters:**

* _`<#string>`_ `event`: 
* _`<#function>`_ `cb`: 
* _`<#boolean>`_ `priority`: 






------------------

## Table `hm._core`

> **Internal/advanced use only** (e.g. for extension developers)

Hammermoon core facilities for use by extensions.




### Function `hm._core.cacheKeys()`






### Function `hm._core.cacheValues()`






### Function `hm._core.deprecate(module,fieldname,replacement)`

> **API CHANGE**: Doesn't exist in Hammerspoon

Deprecate a field or function of a module or class

**Parameters:**

* [_`<#module>`_](hm.md#class-module) `module`: [_`<#module>`_](hm.md#class-module) table or [_`<#module.class>`_](hm.md#class-moduleclass) table
* _`<#string>`_ `fieldname`: field or function name
* _`<#string>`_ `replacement`: the replacement field or function to direct users to




### Function `hm._core.disallow(module,fieldname,replacement)`

> **API CHANGE**: Doesn't exist in Hammerspoon

Disallow a field or function of a module or class (after deprecation)

**Parameters:**

* [_`<#module>`_](hm.md#class-module) `module`: [_`<#module>`_](hm.md#class-module) table or [_`<#module.class>`_](hm.md#class-moduleclass) table
* _`<#string>`_ `fieldname`: field or function name
* _`<#string>`_ `replacement`: the replacement field or function to direct users to




### Function `hm._core.module(name,classmt)` -> [_`<#module>`_](hm.md#class-module)

> **API CHANGE**: Doesn't exist in Hammerspoon

Declare a new Hammermoon extension.

**Parameters:**

* _`<#string>`_ `name`: module name (without the `"hm."` prefix)
* _`<#table>`_ `classmt`: initial metatable for the module's class (if any); can contain `__tostring`, `__eq`, `__gc`, etc

**Returns:**

* [_`<#module>`_](hm.md#class-module) the "naked" table for the new module, ready to be filled with functions

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

Add a property to a module or class.

**Parameters:**

* [_`<#module>`_](hm.md#class-module) `module`: [_`<#module>`_](hm.md#class-module) table or [_`<#module.class>`_](hm.md#class-moduleclass) table
* _`<#string>`_ `fieldname`: desired field name
* _`<#function>`_ `getter`: getter function
* _`<#function>`_ `setter`: setter function or `false` (to make the property read-only)

This function will add to the module or class a user-facing field that uses custom getter and setter.


### Function `hm._core.retainKeys()`






### Function `hm._core.retainValues()`






### Field `hm._core.defaultNotificationCenter`: [_`<#notificationCenter>`_](hm.md#class-notificationcenter)
The default Notification Center.




### Field `hm._core.log`: [_`<hm.logger#logger>`_](hm.logger.md#type-logger)
Logger instance for Hammermoon's core




### Field `hm._core.rawrequire`: _`<?>`_





### Field `hm._core.sharedWorkspace`: _`<#cdata>`_
The shared `NSWorkspace` instance




### Field `hm._core.systemWideAccessibility`: _`<#cdata>`_
`AXUIElementCreateSystemWide()` instance




### Field `hm._core.wsNotificationCenter`: [_`<#notificationCenter>`_](hm.md#class-notificationcenter)
The shared workspace's Notification Center.





------------------

## Table `hm.debug`

> **Internal/advanced use only** (e.g. for extension developers)

> **API CHANGE**: Doesn't exist in Hammerspoon

Debug options



### Field `hm.debug.cacheUIElements`: _`<#boolean>`_
Cache uielement objects (default `true`).

Uielement objects (including applications and windows) are cached internally for performance; this can be disabled.


### Field `hm.debug.disableAssertions`: _`<#boolean>`_
Disable assertions (default `false`).

If set to `true`, assertions are disabled for slightly better performance.


### Field `hm.debug.disableTypeChecks`: _`<#boolean>`_
Disable type checks (default `false`).

If set to `true`, type checks are disabled for slightly better performance.


### Field `hm.debug.retainUserObjects`: _`<#boolean>`_
Retain user objects internally (default `true`).

User objects (timers, watchers, etc.) are retained internally by default, so
userscripts needn't worry about their lifecycle.
If falsy, they will get gc'ed unless the userscript keeps a global reference.


