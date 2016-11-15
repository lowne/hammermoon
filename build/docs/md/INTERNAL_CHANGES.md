# Module `hm`

> INTERNAL CHANGE: Using the 'checks' library for userscript argument checking.
Using the 'compat53' library, but syntax-level things (such as # not using __len) are still Lua 5.1

Hammermoon main module



------------------

## Class `<#notificationCenter>`






### Method `<#notificationCenter>:register(event,cb,priority)`

> **Internal/advanced use only** (e.g. for extension developers)

> INTERNAL CHANGE: Centralized callback registry for notification centers, to be used by extensions.



**Parameters:**

* _`<#string>`_ `event`: 
* _`<#function>`_ `cb`: 
* _`<#boolean>`_ `priority`: 






------------------

## Table `hm._core`

> **Internal/advanced use only** (e.g. for extension developers)

Hammermoon core facilities for use by extensions.




### Function `hm._core.deprecate(module,fieldname,replacement)`

> **API CHANGE**: Doesn't exist in Hammerspoon

> INTERNAL CHANGE: Deprecation facility

Deprecate a field or function of a module or class

**Parameters:**

* [_`<#module>`_](hm.md#class-module) `module`: [_`<#module>`_](hm.md#class-module) table or [_`<#module.class>`_](hm.md#class-moduleclass) table
* _`<#string>`_ `fieldname`: field or function name
* _`<#string>`_ `replacement`: the replacement field or function to direct users to




### Function `hm._core.disallow(module,fieldname,replacement)`

> **API CHANGE**: Doesn't exist in Hammerspoon

> INTERNAL CHANGE: Deprecation facility

Disallow a field or function of a module or class (after deprecation)

**Parameters:**

* [_`<#module>`_](hm.md#class-module) `module`: [_`<#module>`_](hm.md#class-module) table or [_`<#module.class>`_](hm.md#class-moduleclass) table
* _`<#string>`_ `fieldname`: field or function name
* _`<#string>`_ `replacement`: the replacement field or function to direct users to




### Function `hm._core.module(name,classmt)` -> [_`<#module>`_](hm.md#class-module)

> **API CHANGE**: Doesn't exist in Hammerspoon

> INTERNAL CHANGE: Allows allocation tracking, properties, deprecation; handled by core

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

> INTERNAL CHANGE: Modules don't need to handle properties internally.

Add a property to a module or class.

**Parameters:**

* [_`<#module>`_](hm.md#class-module) `module`: [_`<#module>`_](hm.md#class-module) table or [_`<#module.class>`_](hm.md#class-moduleclass) table
* _`<#string>`_ `fieldname`: desired field name
* _`<#function>`_ `getter`: getter function
* _`<#function>`_ `setter`: setter function or `false` (to make the property read-only)

This function will add to the module or class a user-facing field that uses custom getter and setter.


### Field `hm._core.systemWideAccessibility`: _`<#cdata>`_
> INTERNAL CHANGE: Instance to be used by extensions.

`AXUIElementCreateSystemWide()` instance





------------------

## Table `hm.debug`

> **Internal/advanced use only** (e.g. for extension developers)

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




# Module `hm.screen`

Manipulate screens (monitors).



------------------

## Module `hm.screen`






### Function `hm.screen.allScreens()` -> `{`[_`<#screen>`_](hm.screen.md#type-screen)`, ...}`

> INTERNAL CHANGE: The screen list is cached (and kept up to date by an internal watcher)

Returns all the screens currently connected and enabled.

**Returns:**

* `{`[_`<#screen>`_](hm.screen.md#type-screen)`, ...}` 






------------------

### Type `<#screen>`






### Method `<#screen>:setMode(mode)`

> **API CHANGE**: Refresh rate, color depth are supported.

> INTERNAL CHANGE: Will pick the highest refresh rate (if not specified) and color depth=4 (if available, and unless specified to 8).
depth==8 isn't supported in HS!



**Parameters:**

* [_`<#screenMode>`_](hm.screen.md#type-screenmode) `mode`: 







# Module `hm.timer`

> **API CHANGE**: Fully overhauled module; all timers are of the 'delayed' sort for maximum flexibility.

> INTERNAL CHANGE: Don't bother with NSTimer intermediates, we abstract directly from CFRunLoopTimer

Schedule asynchronous execution of functions in the future.



------------------

## Module `hm.timer`






### Function `hm.timer.localTime()` -> _`<#number>`_

> INTERNAL CHANGE: high precision

Returns the number of seconds since midnight local time.

**Returns:**

* _`<#number>`_ number of seconds, with millisecond precision or better






------------------

## Class `<#timer>`

Type for timer objects.

A timer holds an execution unit that can be scheduled for running later in time in various ways via its `:run...()` methods.
 After being scheduled a timer can be unscheduled (thus prevented from running) via its [`:cancel()`](hm.timer.md#method-timercancel) method.


### Method `<#timer>:runEvery(repeatInterval,delayOrStartTime,continueOnError)`

> **API CHANGE**: This replaces all repeating timers, whether created via `hs.timer.new()`, `hs.timer.doEvery()`, or `hs.timer.doAt()`

> INTERNAL CHANGE: High frequency timers (less than 1s repeat interval) are like `hs.timer`s, i.e. the repeat schedule is managed
                internally by the `CFRunLoopTimer` for performance. Other timers behave like `hs.timer.delayed`s,
                i.e. they are rescheduled "manually" after every trigger.

Schedules repeated execution of the timer.

**Parameters:**

* [_`<#intervalString>`_](hm.timer.md#type-intervalstring) `repeatInterval`: 
* _`<?>`_ `delayOrStartTime`: (optional) the timer will start executing: if omitted or `nil`, right away; if an [_`<#intervalString>`_](hm.timer.md#type-intervalstring) or a number (in seconds),
       after the given delay; if a [_`<#timeOfDayString>`_](hm.timer.md#type-timeofdaystring), at the earliest occurrence for given time
* _`<#boolean>`_ `continueOnError`: (optional) if `true`, the timer will keep repeating (and executing) even if its [_`<#timerFunction>`_](hm.timer.md#function-prototype-timerfunctiontimerdata) causes an error

If `delayOrStartTime` is a [_`<#timeOfDayString>`_](hm.timer.md#type-timeofdaystring), the timer will be scheduled to execute for the first time at the earliest occurrence
given the `repeatInterval`, e.g.:

  * If it's 17:00, `myTimer:runEvery("6h","0:00")` will set the timer 1 hour from now (at 18:00)
  * If it's 19:00, `myTimer:runEvery("6h","0:00")` will set the timer 5 hour from now (at 0:00 tomorrow)
  * If it's 21:00, `myTimer:runEvery("6h","20:00")` will set the timer 5 hours from now (at 2:00 tomorrow)

**Usage**:

```lua
-- run a job every day at 8, regardless of when Hammermoon was (re)started:
hm.timer.new(doThisEveryMorning,myData):runEvery("1d","8:00")

-- run a job every hour on the hour from 8:00 to 20:00:
for h=8,20 do hm.timer.new(runJob):runEvery("1d",h..":00") end

-- start doing something every second in 5 seconds:
local myTimer=hm.timer.new(mustDoThisVeryOften)
myTimer:runEvery(1,5)
-- and later (maybe in some event callback), stop:
myTimer:cancel()
```

### Method `<#timer>:runIn(delay)`

> **API CHANGE**: This replaces non-repeating timers (`hs.timer.new()` and `hs.timer.doAfter()`) as well as `hs.timer.delayed`s

> INTERNAL CHANGE: These timers technically "repeat" into the distant future, so they can be reused at will, but are
                transparently added to and removed from the run loop as needed

Schedules execution of the timer after a given delay.

**Parameters:**

* [_`<#intervalString>`_](hm.timer.md#type-intervalstring) `delay`: 

Every time you call this method the "execution countdown" is restarted - i.e. any previous schedule (created
with any of the `:run...()` methods) is overwritten. This can be useful
to coalesce processing of unpredictable asynchronous events into a single
callback; for example, if you have an event stream that happens in "bursts" of dozens of events at once,
use an appropriate `delay` to wait for things to settle down, and then your callback will run just once.

**Usage**:

```lua
local coalesceTimer=hm.timer.new(doSomethingExpensiveOnlyOnce)
local function burstyEventCallback(...)
  coalesceTimer:runIn(2.5) -- wait 2.5 seconds after the last event in the burst
end
```


