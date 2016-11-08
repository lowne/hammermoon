# Module `hm`

> INTERNAL CHANGE: Using the 'checks' library for userscript argument checking.
Using the 'compat53' library, but syntax-level things (such as # not using __len) are still Lua 5.1

Hammermoon main module



-----------

## Table `hm._core`



> **Internal/advanced use only** (e.g. for extension developers)

Hammermoon core facilities for use by extensions.




### Function `hm._core.deprecate(module,fieldname,replacement)`

> **API CHANGE**: Doesn't exist in Hammerspoon

> INTERNAL CHANGE: Deprecation facility

Deprecate a field or function of a module

**Parameters:**

* `module`: [`<#module>`](hm.md#type-module) 
* `fieldname`: `<#string>` 
* `replacement`: `<#string>` The replacement field or function to direct users to




### Function `hm._core.disallow(module,fieldname,replacement)`

> **API CHANGE**: Doesn't exist in Hammerspoon

> INTERNAL CHANGE: Deprecation facility

Disallow a field or function of a module (after deprecation)

**Parameters:**

* `module`: [`<#module>`](hm.md#type-module) 
* `fieldname`: `<#string>` 
* `replacement`: `<#string>` The replacement field or function to direct users to




### Function `hm._core.module(name,classmt)` -> [`<#module>`](hm.md#type-module)

> **API CHANGE**: Doesn't exist in Hammerspoon

> INTERNAL CHANGE: Allows allocation tracking, properties, deprecation; handled by core

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

> INTERNAL CHANGE: Modules don't need to handle properties internally.

Add a user-facing field to a module with a custom getter and setter

**Parameters:**

* `module`: [`<#module>`](hm.md#type-module) 
* `fieldname`: `<#string>` 
* `getter`: `<#function>` 
* `setter`: `<#function>` 




### Field `hm._core.systemWideAccessibility`: `<#cdata>`
> INTERNAL CHANGE: Instance to be used by extensions.

`AXUIElementCreateSystemWide()` instance





-----------

## Table `hm.debug`



> **Internal/advanced use only** (e.g. for extension developers)

> **API CHANGE**: Doesn't exist in Hammerspoon

Debug options



### Field `hm.debug.cache_uielements`: `<#boolean>`
> INTERNAL CHANGE: Uielements are cached

Cache uielement objects (default `true`).

Uielement objects (including applications and windows) are cached internally for performance; this can be disabled.


### Field `hm.debug.retain_user_objects`: `<#boolean>`
> INTERNAL CHANGE: User objects are retained

Retain user objects internally (default `true`).

User objects (timers, watchers, etc.) are retained internally by default, so
userscripts needn't worry about their lifecycle.
If falsy, they will get gc'ed unless the userscript keeps a global reference.



-----------

## Type `<#notificationCenter>`








### Method `<#notificationCenter>:register(event,cb,priority)`

> **Internal/advanced use only** (e.g. for extension developers)

> INTERNAL CHANGE: Centralized callback registry for notification centers, to be used by extensions.



**Parameters:**

* `event`: `<#string>` 
* `cb`: `<#function>` 
* `priority`: `<#boolean>` 






-----------

-----------

