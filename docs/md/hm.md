# Module `hm`

Hammermoon main module



## Overview

* Global fields
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

Type for Hammermoon modules.

Hammermoon modules (usually created via `hm._core.module()`) can be `require`d normally
(`local somemod=require'hm.somemod'`) or loaded directly via the the global `hm` namespace
(`hm.somemod.somefn(...)`).

### Field `<#module>._classes`: `{ [`_`<#string>`_`] =`[_`<#module.class>`_](hm.md#class-moduleclass)`, ...}`
The classes (i.e., object metatables) declared by this module




### Field `<#module>.log`: [_`<hm.logger#logger>`_](hm.logger.md#type-logger)
The extension's module-level logger instance




