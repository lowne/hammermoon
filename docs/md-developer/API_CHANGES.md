Module `hm`Hammermoon main module



------------------

## Table `hm._core`

> **Internal/advanced use only**

Hammermoon core facilities for use by extensions.




### Function `hm._core.deprecate(module,fieldname,replacement)`

> **API CHANGE**: Doesn't exist in Hammerspoon

Deprecate a field or function of a module or class

* `module`: [_`<#module>`_](hm.md#class-module) [_`<#module>`_](hm.md#class-module) table or [_`<#module.class>`_](hm.md#class-moduleclass) table
* `fieldname`: _`<#string>`_ field or function name
* `replacement`: _`<#string>`_ the replacement field or function to direct users to




### Function `hm._core.disallow(module,fieldname,replacement)`

> **API CHANGE**: Doesn't exist in Hammerspoon

Disallow a field or function of a module or class (after deprecation)

* `module`: [_`<#module>`_](hm.md#class-module) [_`<#module>`_](hm.md#class-module) table or [_`<#module.class>`_](hm.md#class-moduleclass) table
* `fieldname`: _`<#string>`_ field or function name
* `replacement`: _`<#string>`_ the replacement field or function to direct users to




### Function `hm._core.module(name,classes,submodules)` -> [_`<#module>`_](hm.md#class-module)

> **API CHANGE**: Doesn't exist in Hammerspoon

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
local myclass=mymodule._classes.myclass
function mymodule.myfunction(param) ... end
function mymodule.construct(args) ... return myclass._new(...) end
function myclass:mymethod() ... end
...
return mymodule -- at the end of the file
```

### Function `hm._core.property(module,fieldname,getter,setter,type,sanitize)`

> **API CHANGE**: Doesn't exist in Hammerspoon; this also allows fields in modules and objects to be trivially type-checked.

Add a property to a module or class.

* `module`: [_`<#module>`_](hm.md#class-module) [_`<#module>`_](hm.md#class-module) table or [_`<#module.class>`_](hm.md#class-moduleclass) table
* `fieldname`: _`<#string>`_ desired field name
* `getter`: _`<#function>`_ getter function
* `setter`: _`<#function>`_ setter function; if `false` the property is read-only; if `nil` the property is
       immutable and will be cached after the first query.
* `type`: _`<#string>`_ field type (for writable fields)
* `sanitize`: _`<#boolean>`_ if `true`, use `sanitizeargs` instead of `checkargs`

This function will add to the module or class a user-facing field that uses custom getter and setter.




------------------

## Table `hm.debug`

> **Internal/advanced use only**

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



Module `hm.applications`> **API CHANGE**: Running applications and app bundles are distinct objects. Edge cases with multiple bundles with the same id are solved.

Run, stop, query and manage applications.


Module `hm.logger`Simple logger for debugging purposes.



------------------

## Module `hm.logger`





### Field `hm.logger.historySize`: _`<#number>`_
> **API CHANGE**: function hm.logger.historySize([v]) -> field hm.logger.historySize

The number of log entries to keep in the history.

The starting value is 0 (history is disabled). To enable the log history, set this at the top of your userscript.
If you change history size (other than from 0) after creating any logger instances, things will likely break.



------------------

### Type `logger`

A logger instance.




### Function `<#logger>.e(...)` -> _`nil`_,_`<#string>`_

> **API CHANGE**: returns nil,error as per Lua informal standard; module functions can use the idiom `return log.e(...)` to fail

Logs an error to the console

* `...`: _`<?>`_ one or more message strings



* Returns _`nil`_,_`<#string>`_: nil and the error message




### Function `<#logger>.fd(fmt,...)`

> **API CHANGE**: logger.df -> logger.fd

Logs formatted debug info to the console

* `fmt`: _`<#string>`_ formatting string as per `string.format`
* `...`: _`<?>`_ one or more message strings




### Function `<#logger>.fe(fmt,...)` -> _`nil`_,_`<#string>`_

> **API CHANGE**: logger.ef -> logger.fe
returns nil,error as per Lua informal standard; module functions can use the idiom `return log.fe(fmt,...)` to fail

Logs a formatted error to the console

* `fmt`: _`<#string>`_ formatting string as per `string.format`
* `...`: _`<?>`_ one or more message strings



* Returns _`nil`_,_`<#string>`_: nil and the error message




### Function `<#logger>.fi(fmt,...)`

> **API CHANGE**: logger.f -> logger.fi

Logs formatted info to the console

* `fmt`: _`<#string>`_ formatting string as per `string.format`
* `...`: _`<?>`_ one or more message strings




### Function `<#logger>.fv(fmt,...)`

> **API CHANGE**: logger.vf -> logger.fv

Logs formatted verbose info to the console

* `fmt`: _`<#string>`_ formatting string as per `string.format`
* `...`: _`<?>`_ one or more message strings




### Function `<#logger>.fw(fmt,...)`

> **API CHANGE**: logger.wf -> logger.fw

Logs a formatted warning to the console

* `fmt`: _`<#string>`_ formatting string as per `string.format`
* `...`: _`<?>`_ one or more message strings






Module `hm.screens`Manipulate screens (monitors).



------------------

## Module `hm.screens`

> Extends [_`<hm#module>`_](hm.md#class-module)





### Property (read-only) `hm.screens.focusedScreen`: [_`<#screen>`_](hm.screens.md#class-screen)
> **API CHANGE**: main->active

The currently focused screen.

The focused screen is the one containing the currently focused window.



------------------

## Class `screen`

> Extends [_`<hm#module.class>`_](hm.md#class-moduleclass)





### Property `<#screen>.mode`: [_`<#screenMode>`_](hm.screens.md#type-screenmode)
> **API CHANGE**: A user-facing string instead of a table. Refresh rate, color depth are supported.

The screen's current mode.





Module `hm.timer`> **API CHANGE**: All timers are of the 'delayed' sort for maximum flexibility.

Schedule asynchronous execution of functions in the future.



------------------

## Module `hm.timer`

> Extends [_`<hm#module>`_](hm.md#class-module)






### Function `hm.timer.new(fn,data)` -> [_`<#timer>`_](hm.timer.md#class-timer)

> **API CHANGE**: All `hs.timer` constructors are covered by the new `:run...()` methods

Creates a new timer.

* `fn`: [_`<#timerFunction>`_](hm.timer.md#function-prototype-timerfunctiontimerdata) (optional) a function to be executed later
* `data`: _`<?>`_ (optional) arbitrary data that will be passed to `fn`; as a convenience, you can use the special string `"timer"`
       to have `fn` receive the timer object being created



* Returns [_`<#timer>`_](hm.timer.md#class-timer): a new timer object

If `fn` is not provided here, it must be set via [`timer:setFn()`](hm.timer.md#method-timersetfnfn---self) before calling any of the `:run...()` methods.
`data` can be overridden (and dynamically changed) later when calling the `:run...()` methods.




------------------

## Class `timer`

> Extends [_`<hm#module.object>`_](hm.md#class-moduleobject)

Type for timer objects.

A timer holds an execution unit that can be scheduled for running later in time in various ways via its `:run...()` methods.
 After being scheduled a timer can be unscheduled (thus prevented from running) via its [`:cancel()`](hm.timer.md#method-timercancel) method.

### Property (read-only) `<#timer>.elapsed`: _`<#number>`_
> **API CHANGE**: Was `<#hs.timer>:nextTrigger()` when negative, but only if the timer was not running.

The timer's last execution time, in seconds since.

If the timer has never been executed, this value is the time since creation.


### Property `<#timer>.nextRun`: _`<#number>`_
> **API CHANGE**: `<#hs.timer>:nextTrigger()`, with some differences.

The timer's scheduled next execution time, in seconds from now.

If this value is `nil`, the timer is currently unscheduled.
You cannot set this value to a negative number; setting it to `0` triggers timer execution right away;
setting it to `nil` unschedules the timer.


### Property `<#timer>.scheduled`: _`<#boolean>`_
> **API CHANGE**: `<#hs.timer>:running()`, with some differences.

`true` if the timer is scheduled for execution.

Setting this to `false` or `nil` unschedules the timer.


### Method `<#timer>:cancel()`

> **API CHANGE**: All timers can be rescheduled freely

Unschedule a timer.

The timer's [_`<#timerFunction>`_](hm.timer.md#function-prototype-timerfunctiontimerdata) will not be executed again until you call one of its `:run...()` methods.


### Method `<#timer>:runAfter(predicateFn,checkInterval,continueOnError,data)`

> **API CHANGE**: Replaces `hs.timer.waitWhile()` and `hs.timer.waitUntil()`

Schedules execution of the timer after a given predicate becomes false.

* `predicateFn`: [_`<#predicateFunction>`_](hm.timer.md#function-prototype-predicatefunctiondata---boolean) A predicate function that determines whether to contine waiting before executing the timer
* `checkInterval`: [_`<#intervalString>`_](hm.timer.md#type-intervalstring) interval between predicate checks
* `continueOnError`: _`<#boolean>`_ (optional) if `true`, `predicateFn` will keep being checked even if it causes an error
* `data`: _`<?>`_ (optional) arbitrary data that will be passed to the [_`<#predicateFunction>`_](hm.timer.md#function-prototype-predicatefunctiondata---boolean) and [_`<#timerFunction>`_](hm.timer.md#function-prototype-timerfunctiontimerdata)

The given `predicateFn` will start being checked right away. As soon as it returns `false`, the timer will
execute (once).


### Method `<#timer>:runEvery(repeatInterval,delayOrStartTime,continueOnError,data)`

> **API CHANGE**: This replaces all repeating timers, whether created via `hs.timer.new()`, `hs.timer.doEvery()`, or `hs.timer.doAt()`

Schedules repeated execution of the timer.

* `repeatInterval`: [_`<#intervalString>`_](hm.timer.md#type-intervalstring) 
* `delayOrStartTime`: _`<?>`_ (optional) the timer will start executing: if omitted or `nil`, right away; if an [_`<#intervalString>`_](hm.timer.md#type-intervalstring) or a number (in seconds),
       after the given delay; if a [_`<#timeOfDayString>`_](hm.timer.md#type-timeofdaystring), at the earliest occurrence for the given time
* `continueOnError`: _`<#boolean>`_ (optional) if `true`, the timer will keep repeating (and executing) even if its [_`<#timerFunction>`_](hm.timer.md#function-prototype-timerfunctiontimerdata) causes an error
* `data`: _`<?>`_ (optional) arbitrary data that will be passed to the [_`<#timerFunction>`_](hm.timer.md#function-prototype-timerfunctiontimerdata)

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

### Method `<#timer>:runIn(delay,data)`

> **API CHANGE**: This replaces non-repeating timers (`hs.timer.new()` and `hs.timer.doAfter()`) as well as `hs.timer.delayed`s

Schedules execution of the timer after a given delay.

* `delay`: [_`<#intervalString>`_](hm.timer.md#type-intervalstring) 
* `data`: _`<?>`_ (optional) arbitrary data that will be passed to the [_`<#timerFunction>`_](hm.timer.md#function-prototype-timerfunctiontimerdata)

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

### Method `<#timer>:runWhen(predicateFn,checkInterval,continueOnError,data)`

> **API CHANGE**: Not (directly) available in HS, but of dubious utility anyway.

Schedules execution of the timer every time a given predicate is true.

* `predicateFn`: [_`<#predicateFunction>`_](hm.timer.md#function-prototype-predicatefunctiondata---boolean) A predicate function that determines whether to execute the timer
* `checkInterval`: [_`<#intervalString>`_](hm.timer.md#type-intervalstring) interval between predicate checks (and potential timer executions)
* `continueOnError`: _`<#boolean>`_ (optional) if `true`, `predicateFn` will keep being checked even if it - or the
       timer's [_`<#timerFunction>`_](hm.timer.md#function-prototype-timerfunctiontimerdata) - causes an error
* `data`: _`<?>`_ (optional) arbitrary data that will be passed to the [_`<#predicateFunction>`_](hm.timer.md#function-prototype-predicatefunctiondata---boolean) and [_`<#timerFunction>`_](hm.timer.md#function-prototype-timerfunctiontimerdata)

The given `predicateFn` will start being checked right away. Every time it returns `true`, the timer will
execute.


### Method `<#timer>:runWhile(predicateFn,checkInterval,continueOnError,data)`

> **API CHANGE**: Replaces `hs.timer.doWhile()` and `hs.timer.doUntil()`

Schedules repeated execution of the timer while a given predicate remains true.

* `predicateFn`: [_`<#predicateFunction>`_](hm.timer.md#function-prototype-predicatefunctiondata---boolean) A predicate function that determines whether to contine executing the timer
* `checkInterval`: [_`<#intervalString>`_](hm.timer.md#type-intervalstring) interval between predicate checks (and timer executions)
* `continueOnError`: _`<#boolean>`_ (optional) if `true`, the timer will keep repeating (and executing) even if
       its [_`<#timerFunction>`_](hm.timer.md#function-prototype-timerfunctiontimerdata) or `predicateFn` cause an error
* `data`: _`<?>`_ (optional) arbitrary data that will be passed to the [_`<#predicateFunction>`_](hm.timer.md#function-prototype-predicatefunctiondata---boolean) and [_`<#timerFunction>`_](hm.timer.md#function-prototype-timerfunctiontimerdata)

The given `predicateFn` will start being checked right away. While it returns `true`, the timer will
execute; as soon as it returns `false` the timer will be canceled.





------------------

### Function prototype `predicateFunction(data)` -> _`<#boolean>`_

> **API CHANGE**: Predicate functions can receive arbitrary data.

A predicate function that controls conditional execution of a timer.

* `data`: _`<?>`_ the arbitrary data for this timer, or if `"timer"` was passed to [`new()`](hm.timer.md#function-hmtimernewfndata---timer), the timer itself



* Returns _`<#boolean>`_: the return value will determine wheter to run, repeat, skip or cancel altogether the timer's execution, depending on what method was used





### Function prototype `timerFunction(timer,data)`

> **API CHANGE**: Timer callbacks can receive arbitrary data.

A function that will be executed by a timer.

* `timer`: [_`<#timer>`_](hm.timer.md#class-timer) the timer that scheduled execution of this function
* `data`: _`<?>`_ the arbitrary data for this timer, or if `"timer"` was passed to [`new()`](hm.timer.md#function-hmtimernewfndata---timer), the timer itself





