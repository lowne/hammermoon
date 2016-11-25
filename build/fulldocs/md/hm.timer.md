# Module `hm.timer`

> **API CHANGE**: All timers are of the 'delayed' sort for maximum flexibility.

> INTERNAL CHANGE: Don't bother with NSTimer intermediates, we abstract directly from CFRunLoopTimer

Schedule asynchronous execution of functions in the future.



## Overview


* Module [`hm.timer`](hm.timer.md#module-hmtimer)
  * [`absoluteTime()`](hm.timer.md#function-hmtimerabsolutetime---number) -> _`<#number>`_ - function
  * [`localTime()`](hm.timer.md#function-hmtimerlocaltime---number) -> _`<#number>`_ - function
  * [`new(fn,data)`](hm.timer.md#function-hmtimernewfndata---timer) -> [_`<#timer>`_](hm.timer.md#class-timer) - function
  * [`sleep(s)`](hm.timer.md#function-hmtimersleeps) - function
  * [`toSeconds(timeString)`](hm.timer.md#function-hmtimertosecondstimestring---number) -> _`<#number>`_ - function


* Class [`timer`](hm.timer.md#class-timer)
  * [`elapsed`](hm.timer.md#property-read-only-timerelapsed-number) : _`<#number>`_ - property (read-only)
  * [`nextRun`](hm.timer.md#property-timernextrun-number) : _`<#number>`_ - property
  * [`scheduled`](hm.timer.md#property-timerscheduled-boolean) : _`<#boolean>`_ - property
  * [`cancel()`](hm.timer.md#method-timercancel) - method
  * [`run()`](hm.timer.md#method-timerrun) - method
  * [`runAfter(predicateFn,checkInterval,continueOnError,data)`](hm.timer.md#method-timerrunafterpredicatefncheckintervalcontinueonerrordata) - method
  * [`runEvery(repeatInterval,delayOrStartTime,continueOnError,data)`](hm.timer.md#method-timerruneveryrepeatintervaldelayorstarttimecontinueonerrordata) - method
  * [`runIn(delay,data)`](hm.timer.md#method-timerrunindelaydata) - method
  * [`runWhen(predicateFn,checkInterval,continueOnError,data)`](hm.timer.md#method-timerrunwhenpredicatefncheckintervalcontinueonerrordata) - method
  * [`runWhile(predicateFn,checkInterval,continueOnError,data)`](hm.timer.md#method-timerrunwhilepredicatefncheckintervalcontinueonerrordata) - method
  * [`setFn(fn)`](hm.timer.md#method-timersetfnfn---self) -> `self` - method


* Type [`intervalString`](hm.timer.md#type-intervalstring)


* Type [`timeOfDayString`](hm.timer.md#type-timeofdaystring)




* Function prototypes:
  * [`predicateFunction(data)`](hm.timer.md#function-prototype-predicatefunctiondata---boolean) -> _`<#boolean>`_ - function prototype
  * [`timerFunction(timer,data)`](hm.timer.md#function-prototype-timerfunctiontimerdata) - function prototype



------------------

## Module `hm.timer`

> Extends [_`<hm#module>`_](hm.md#class-module)






### Function `hm.timer.absoluteTime()` -> _`<#number>`_

Returns the number of seconds since an arbitrary point in the distant past.



* Returns _`<#number>`_: number of seconds, with millisecond precision or better

This function should only be used for measuring time intervals. The starting point is Jan 1 2001 00:00:00 GMT, so *not* the UNIX epoch.


### Function `hm.timer.localTime()` -> _`<#number>`_

> INTERNAL CHANGE: high precision

Returns the number of seconds since midnight local time.



* Returns _`<#number>`_: number of seconds, with millisecond precision or better




### Function `hm.timer.new(fn,data)` -> [_`<#timer>`_](hm.timer.md#class-timer)

> **API CHANGE**: All `hs.timer` constructors are covered by the new `:run...()` methods

Creates a new timer.

* `fn`: [_`<#timerFunction>`_](hm.timer.md#function-prototype-timerfunctiontimerdata) (optional) a function to be executed later
* `data`: _`<?>`_ (optional) arbitrary data that will be passed to `fn`; as a convenience, you can use the special string `"timer"`
       to have `fn` receive the timer object being created



* Returns [_`<#timer>`_](hm.timer.md#class-timer): a new timer object

If `fn` is not provided here, it must be set via [`timer:setFn()`](hm.timer.md#method-timersetfnfn---self) before calling any of the `:run...()` methods.
`data` can be overridden (and dynamically changed) later when calling the `:run...()` methods.


### Function `hm.timer.sleep(s)`

Halts all processing for a given interval.

* `s`: _`<#number>`_ interval in seconds

**WARNING**: this function will stop *all* processing by Hammermoon.
For anything other than very short intervals, use [`hm.timer.new()`](hm.timer.md#function-hmtimernewfndata---timer) with a callback instead.


### Function `hm.timer.toSeconds(timeString)` -> _`<#number>`_

Converts to number of seconds

* `timeString`: _`<#string>`_ a [_`<#timeOfDayString>`_](hm.timer.md#type-timeofdaystring) or [_`<#intervalString>`_](hm.timer.md#type-intervalstring)



* Returns _`<#number>`_: number of seconds in the interval (if [_`<#intervalString>`_](hm.timer.md#type-intervalstring)) or after midnight (if [_`<#timeOfDayString>`_](hm.timer.md#type-timeofdaystring))






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


### Method `<#timer>:run()`

Executes the timer now.




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

> INTERNAL CHANGE: High frequency timers (less than 1s repeat interval) are like `hs.timer`s, i.e. the repeat schedule is managed
                internally by the `CFRunLoopTimer` for performance. Other timers behave like `hs.timer.delayed`s,
                i.e. they are rescheduled "manually" after every trigger.

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

> INTERNAL CHANGE: These timers technically "repeat" into the distant future, so they can be reused at will, but are
                transparently added to and removed from the run loop as needed

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


### Method `<#timer>:setFn(fn)` -> `self`

Sets the function for this timer.

* `fn`: _`<#function>`_ 



* Returns `self`: [_`<#timer>`_](hm.timer.md#class-timer)






------------------

### Type `intervalString`

> Extends _`<#string>`_

A string describing a time interval.

The following are valid formats: `"DDdHHh"`, `"HHhMMm"`, `"MMmSSs"`, `"DDd"`, `"HHh"`, `"MMm"`, `"SSs"`, `"NNNNms"` - they represent
an interval in days, hours, minutes, seconds and/or milliseconds.
You can also use a plain number (in seconds) wherever this type is expected.

Examples: `"1m30s"` or `90` (in seconds); `"1500ms"` or `1.5`.



------------------

### Type `timeOfDayString`

> Extends _`<#string>`_

A string describing a time of day.

The following are valid formats: `"HH:MM:SS"`, `"HH:MM"` or `"HHMM"` - they represent a time of day in hours, minutes, seconds (24-hour clock)
You can also use a plain number (in seconds after midnight) wherever this type is expected.

Examples: `"8:00:00"` or `"800"` or `28800` (in seconds).




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




