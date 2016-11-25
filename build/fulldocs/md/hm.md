# Module `hm`

> INTERNAL CHANGE: Using the 'checks' library for userscript argument checking.
Using the 'compat53' library, but syntax-level things (such as # not using __len) are still Lua 5.1

Hammermoon main module



## Overview

* Global fields:
  * [`hm`](hm.md#global-field-hm-hm) : [_`<#hm>`_](hm.md#module-hm) - global field
  * [`hmassert`](hm.md#global-field-hmassert-) : _`<?>`_ - global field
  * [`hmassertf`](hm.md#global-field-hmassertf-) : _`<?>`_ - global field
  * [`hs`](hm.md#global-field-hs-) : _`<?>`_ - global field


* Module [`hm`](hm.md#module-hm)
  * [`_core`](hm.md#field-hmcore-hmcore) : [_`hm._core`_](hm.md#table-hmcore) - field
  * [`debug`](hm.md#field-hmdebug-hmdebug) : [_`hm.debug`_](hm.md#table-hmdebug) - field
  * [`quit()`](hm.md#function-hmquit) - function
  * [`type(obj)`](hm.md#function-hmtypeobj---string) -> _`<#string>`_ - function


* Class [`module`](hm.md#class-module)
  * [`_classes`](hm.md#field-moduleclasses--string-moduleclass-) : `{ [`_`<#string>`_`] =`[_`<#module.class>`_](hm.md#class-moduleclass)`, ...}` - field
  * [`log`](hm.md#field-modulelog-hmloggerlogger) : [_`<hm.logger#logger>`_](hm.logger.md#type-logger) - field
  * [`__gc()`](hm.md#function-modulegc) - function


* Class [`module.class`](hm.md#class-moduleclass)
  * [`_new(t,name)`](hm.md#function-moduleclassnewtname---moduleobject) -> [_`<#module.object>`_](hm.md#class-moduleobject) - function


* Class [`module.object`](hm.md#class-moduleobject)
  * [`log`](hm.md#field-moduleobjectlog-hmloggerlogger) : [_`<hm.logger#logger>`_](hm.logger.md#type-logger) - field


* Table [`hm._core`](hm.md#table-hmcore)
  * [`log`](hm.md#field-hmcorelog-hmloggerlogger) : [_`<hm.logger#logger>`_](hm.logger.md#type-logger) - field
  * [`rawrequire`](hm.md#field-hmcorerawrequire-) : _`<?>`_ - field
  * [`cacheKeys()`](hm.md#function-hmcorecachekeys) - function
  * [`cacheValues()`](hm.md#function-hmcorecachevalues) - function
  * [`deprecate(module,fieldname,replacement)`](hm.md#function-hmcoredeprecatemodulefieldnamereplacement) - function
  * [`disallow(module,fieldname,replacement)`](hm.md#function-hmcoredisallowmodulefieldnamereplacement) - function
  * [`module(name,classes,submodules)`](hm.md#function-hmcoremodulenameclassessubmodules---module) -> [_`<#module>`_](hm.md#class-module) - function
  * [`property(module,fieldname,getter,setter)`](hm.md#function-hmcorepropertymodulefieldnamegettersetter) - function
  * [`retainKeys()`](hm.md#function-hmcoreretainkeys) - function
  * [`retainValues()`](hm.md#function-hmcoreretainvalues) - function


* Table [`hm.debug`](hm.md#table-hmdebug)
  * [`cacheUIElements`](hm.md#field-hmdebugcacheuielements-boolean) : _`<#boolean>`_ - field
  * [`disableAssertions`](hm.md#field-hmdebugdisableassertions-boolean) : _`<#boolean>`_ - field
  * [`disableTypeChecks`](hm.md#field-hmdebugdisabletypechecks-boolean) : _`<#boolean>`_ - field
  * [`retainUserObjects`](hm.md#field-hmdebugretainuserobjects-boolean) : _`<#boolean>`_ - field






------------------

## Global fields

### Global field `hm`: [_`<#hm>`_](hm.md#module-hm)
Hammermoon's namespace, globally accessible from userscripts



### Global field `hmassert`: _`<?>`_




### Global field `hmassertf`: _`<?>`_




### Global field `hs`: _`<?>`_
For compatibility with Hammerspoon userscripts







------------------

## Module `hm`





### Field `hm._core`: [_`hm._core`_](hm.md#table-hmcore)





### Field `hm.debug`: [_`hm.debug`_](hm.md#table-hmdebug)





### Function `hm.quit()`

Quits Hammermoon.

This function will make sure to properly close the Lua state, so that all the __gc metamethods will run.


### Function `hm.type(obj)` -> _`<#string>`_

Returns the Hammermoon type of an object.

* `obj`: _`<?>`_ object to get the type of



* Returns _`<#string>`_: the object type

If `obj` is an Hammermoon [_`<#module>`_](hm.md#class-module), [_`<#module.class>`_](hm.md#class-moduleclass), or [_`<#module.object>`_](hm.md#class-moduleobject), this function will return its type name
instead of the generic `"table"`. In all other cases this function behaves like Lua's `type()`.




------------------

## Class `module`

> Defines type checker `hm#module`

Type for Hammermoon modules.

Hammermoon modules (usually created via `hm._core.module()`) can be `require`d normally
(`local somemod=require'hm.somemod'`) or loaded directly via the the global `hm` namespace
(`hm.somemod.somefn(...)`).

### Field `<#module>._classes`: `{ [`_`<#string>`_`] =`[_`<#module.class>`_](hm.md#class-moduleclass)`, ...}`
The classes (i.e., object metatables) declared by this module




### Field `<#module>.log`: [_`<hm.logger#logger>`_](hm.logger.md#type-logger)
The extension's module-level logger instance




### Function `<#module>.__gc()`

> **Internal/advanced use only**

Implement this function to perform any required cleanup when a module is unloaded






------------------

## Class `module.class`

> **Internal/advanced use only**

> Defines type checker `hm#module.class`

Type for Hammermoon object classes




### Function `<#module.class>._new(t,name)` -> [_`<#module.object>`_](hm.md#class-moduleobject)

> **Internal/advanced use only**

Create a new instance.

* `t`: _`<#table>`_ initial values for the new object
* `name`: _`<#string>`_ (optional) if provided, the object will have its own logger instance with the given name



* Returns [_`<#module.object>`_](hm.md#class-moduleobject): a new object instance

Objects created by this function have their lifecycle tracked by Hammermoon's core.




------------------

## Class `module.object`

> **Internal/advanced use only**

Type for Hammermoon objects



### Field `<#module.object>.log`: [_`<hm.logger#logger>`_](hm.logger.md#type-logger)
the object logger (only if created with a name)





------------------

## Table `hm._core`

> **Internal/advanced use only**

Hammermoon core facilities for use by extensions.



### Field `hm._core.log`: [_`<hm.logger#logger>`_](hm.logger.md#type-logger)
Logger instance for Hammermoon's core




### Field `hm._core.rawrequire`: _`<?>`_





### Function `hm._core.cacheKeys()`






### Function `hm._core.cacheValues()`






### Function `hm._core.deprecate(module,fieldname,replacement)`

> **API CHANGE**: Doesn't exist in Hammerspoon

> INTERNAL CHANGE: Deprecation facility

Deprecate a field or function of a module or class

* `module`: [_`<#module>`_](hm.md#class-module) [_`<#module>`_](hm.md#class-module) table or [_`<#module.class>`_](hm.md#class-moduleclass) table
* `fieldname`: _`<#string>`_ field or function name
* `replacement`: _`<#string>`_ the replacement field or function to direct users to




### Function `hm._core.disallow(module,fieldname,replacement)`

> **API CHANGE**: Doesn't exist in Hammerspoon

> INTERNAL CHANGE: Deprecation facility

Disallow a field or function of a module or class (after deprecation)

* `module`: [_`<#module>`_](hm.md#class-module) [_`<#module>`_](hm.md#class-module) table or [_`<#module.class>`_](hm.md#class-moduleclass) table
* `fieldname`: _`<#string>`_ field or function name
* `replacement`: _`<#string>`_ the replacement field or function to direct users to




### Function `hm._core.module(name,classes,submodules)` -> [_`<#module>`_](hm.md#class-module)

> **API CHANGE**: Doesn't exist in Hammerspoon

> INTERNAL CHANGE: Allows allocation tracking, properties, deprecation; handled by core

Declare a new Hammermoon module.

* `name`: _`<#string>`_ module name (without the `"hm."` prefix)
* `classes`: _`<#table>`_ a map with the initial metatables (as values) for the module's classes (whose names are the map's keys),
if any; the metatables can can contain `__tostring`, `__eq`, `__gc`, etc. This table, suitably instrumented, will be
available in the resuling module's `_classes` field
* `submodules`: _`<#table>`_ a plain list of submodule names, if any, that will be automatically required as the respective
fields in this module are accessed



* Returns [_`<#module>`_](hm.md#class-module): the "naked" table for the new module, ready to be filled with functions

Use this function to create the table for your module.
If your module instantiates objects, you should pass `classes` (the values can just be empty tables),
and retrieve the metatable for your objects (and the constructor) via the `_classes[<CLASSNAME>]` field
of the returned module table. Note that the `__gc` metamethod of a class, if used, must be *already*
in the class table passed to this function (i.e. you cannot add it afterwards) for Hammermoon's allocation debugging to work.

**Usage**:

```lua
local mymodule=hm._core.module('mymodule',{myclass={}})
local myclass=mymodule._class_myclass
function mymodule.myfunction(param) ... end
function mymodule.construct(args) ... return myclass._new(...) end
function myclass:mymethod() ... end
...
return mymodule -- at the end of the file
```

### Function `hm._core.property(module,fieldname,getter,setter)`

> **API CHANGE**: Doesn't exist in Hammerspoon; this also allows fields in modules and objects to be trivially type-checked.

> INTERNAL CHANGE: Modules don't need to handle properties internally.

Add a property to a module or class.

* `module`: [_`<#module>`_](hm.md#class-module) [_`<#module>`_](hm.md#class-module) table or [_`<#module.class>`_](hm.md#class-moduleclass) table
* `fieldname`: _`<#string>`_ desired field name
* `getter`: _`<#function>`_ getter function
* `setter`: _`<#function>`_ setter function; if `false` the property is read-only; if `nil` the property is
       immutable and will be cached after the first query.

This function will add to the module or class a user-facing field that uses custom getter and setter.


### Function `hm._core.retainKeys()`






### Function `hm._core.retainValues()`








------------------

## Table `hm.debug`

> **Internal/advanced use only**

> **API CHANGE**: Doesn't exist in Hammerspoon

Debug options



### Field `hm.debug.cacheUIElements`: _`<#boolean>`_
> INTERNAL CHANGE: Uielements are cached

Cache uielement objects (default `true`).

Uielement objects (including applications and windows) are cached internally for performance; this can be disabled.


### Field `hm.debug.disableAssertions`: _`<#boolean>`_
> INTERNAL CHANGE: Centralized switch for assertion checking - Hammermoon modules should all use `hmassert()`

Disable assertions (default `false`).

If set to `true`, assertions are disabled for slightly better performance.


### Field `hm.debug.disableTypeChecks`: _`<#boolean>`_
> INTERNAL CHANGE: Centralized switch for type checking - Hammermoon modules should all use `hmcheck()`

Disable type checks (default `false`).

If set to `true`, type checks are disabled for slightly better performance.


### Field `hm.debug.retainUserObjects`: _`<#boolean>`_
> INTERNAL CHANGE: User objects are retained

Retain user objects internally (default `true`).

User objects (timers, watchers, etc.) are retained internally by default, so
userscripts needn't worry about their lifecycle.
If falsy, they will get gc'ed unless the userscript keeps a global reference.


