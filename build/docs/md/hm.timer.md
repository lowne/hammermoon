# Module `hm.timer`

> **API CHANGE**: Fully overhauled module; all timers are of the 'delayed' sort for maximum flexibility.

Schedule asynchronous execution of functions in the future.



## Overview


| Module [hm.timer](hm.timer.md#module-hmtimer) |  |
| :--- | :---
Function [`hm.timer.absoluteTime()`](hm.timer.md#function-hmtimerabsolutetime---number) -> _`<#number>`_ | Returns the number of seconds since an arbitrary point in the distant past.
Function [`hm.timer.localTime()`](hm.timer.md#function-hmtimerlocaltime---number) -> _`<#number>`_ | Returns the number of seconds since midnight local time.
Function [`hm.timer.new(fn,data)`](hm.timer.md#function-hmtimernewfndata---timer) -> [_`<#timer>`_](hm.timer.md#class-timer) | Creates a new timer.
Function [`hm.timer.sleep(s)`](hm.timer.md#function-hmtimersleeps) | 
Function [`hm.timer.toSeconds(timeString)`](hm.timer.md#function-hmtimertosecondstimestring---number) -> _`<#number>`_ | Converts to number of seconds


| Class [<#timer>](hm.timer.md#class-timer) | Type for timer objects. |
| :--- | :---
Method [`<#timer>:cancel()`](hm.timer.md#method-timercancel) | Unschedule a timer.
Method [`<#timer>:run()`](hm.timer.md#method-timerrun) | Executes the timer now.
Method [`<#timer>:runAfter(predicateFn,checkInterval,continueOnError)`](hm.timer.md#method-timerrunafterpredicatefncheckintervalcontinueonerror) | Schedules execution of the timer after a given predicate becomes false.
Method [`<#timer>:runEvery(repeatInterval,delayOrStartTime,continueOnError)`](hm.timer.md#method-timerruneveryrepeatintervaldelayorstarttimecontinueonerror) | Schedules repeated execution of the timer.
Method [`<#timer>:runIn(delay)`](hm.timer.md#method-timerrunindelay) | Schedules execution of the timer after a given delay.
Method [`<#timer>:runWhen(predicateFn,checkInterval,continueOnError)`](hm.timer.md#method-timerrunwhenpredicatefncheckintervalcontinueonerror) | Schedules execution of the timer every time a given predicate is true.
Method [`<#timer>:runWhile(predicateFn,checkInterval,continueOnError)`](hm.timer.md#method-timerrunwhilepredicatefncheckintervalcontinueonerror) | Schedules repeated execution of the timer while a given predicate remains true.
Property (read-only) [`<#timer>.lastRun`](hm.timer.md#property-read-only-timerlastrun-number) : _`<#number>`_ | The timer's last execution time, in seconds since.
Property [`<#timer>.nextRun`](hm.timer.md#property-timernextrun-number) : _`<#number>`_ | The timer's scheduled next execution time, in seconds from now.
Property [`<#timer>.scheduled`](hm.timer.md#property-timerscheduled-boolean) : _`<#boolean>`_ | `true` if the timer is scheduled for execution.


| Type [<#intervalString>](hm.timer.md#type-intervalstring) | A string describing a time interval. |
| :--- | :---


| Type [<#timeOfDayString>](hm.timer.md#type-timeofdaystring) | A string describing a time of day. |
| :--- | :---




| Function prototypes | |
| :--- | :--- |
Function prototype [`predicateFunction(data)`](hm.timer.md#function-prototype-predicatefunctiondata---boolean) -> _`<#boolean>`_ | A predicate function that controls conditional execution of a timer.
Function prototype [`timerFunction(timer,data)`](hm.timer.md#function-prototype-timerfunctiontimerdata) | A function that will be executed by a timer.



------------------

## Module `hm.timer`






### Function `hm.timer.absoluteTime()` -> _`<#number>`_

Returns the number of seconds since an arbitrary point in the distant past.

**Returns:**

* _`<#number>`_ number of seconds, with millisecond precision or better

This function should only be used for measuring time intervals. The starting point is Jan 1 2001 00:00:00 GMT, so *not* the UNIX epoch.


### Function `hm.timer.localTime()` -> _`<#number>`_

Returns the number of seconds since midnight local time.

**Returns:**

* _`<#number>`_ number of seconds, with millisecond precision or better




### Function `hm.timer.new(fn,data)` -> [_`<#timer>`_](hm.timer.md#class-timer)

> **API CHANGE**: All `hs.timer` constructors are covered by the new `:run...()` methods

Creates a new timer.

**Parameters:**

* [_`<#timerFunction>`_](hm.timer.md#function-prototype-timerfunctiontimerdata) `fn`: a function to be executed later
* _`<?>`_ `data`: (optional) arbitrary data that will be passed to `fn`; if the special string `"elapsed"`, `fn` will be passed the time in seconds since the previous execution (or creation)

**Returns:**

* [_`<#timer>`_](hm.timer.md#class-timer) a new timer object




### Function `hm.timer.sleep(s)`



**Parameters:**

* _`<?>`_ `s`: 




### Function `hm.timer.toSeconds(timeString)` -> _`<#number>`_

Converts to number of seconds

**Parameters:**

* _`<#string>`_ `timeString`: a [_`<#timeOfDayString>`_](hm.timer.md#type-timeofdaystring) or [_`<#intervalString>`_](hm.timer.md#type-intervalstring)

**Returns:**

* _`<#number>`_ number of seconds in the interval (if [_`<#intervalString>`_](hm.timer.md#type-intervalstring)) or after midnight (if [_`<#timeOfDayString>`_](hm.timer.md#type-timeofdaystring))






------------------

## Class `<#timer>`

Type for timer objects.

A timer holds an execution unit that can be scheduled for running later in time in various ways via its `:run...()` methods.
 After being scheduled a timer can be unscheduled (thus prevented from running) via its [`:cancel()`](hm.timer.md#method-timercancel) method.


### Method `<#timer>:cancel()`

> **API CHANGE**: Timers can be rescheduled freely without needing to create new ones (unlike with `hs.timer:stop()`)

Unschedule a timer.

The timer's [_`<#timerFunction>`_](hm.timer.md#function-prototype-timerfunctiontimerdata) will not be executed again until you call one of its `:run...()` methods.


### Method `<#timer>:run()`

Executes the timer now.




### Method `<#timer>:runAfter(predicateFn,checkInterval,continueOnError)`

Schedules execution of the timer after a given predicate becomes false.

**Parameters:**

* [_`<#predicateFunction>`_](hm.timer.md#function-prototype-predicatefunctiondata---boolean) `predicateFn`: A predicate function that determines whether to contine waiting before executing the timer
* [_`<#intervalString>`_](hm.timer.md#type-intervalstring) `checkInterval`: interval between predicate checks
* _`<#boolean>`_ `continueOnError`: (optional) if `true`, `predicateFn` will keep being checked even if it causes an error

The given `predicateFn` will start being checked right away. As soon as it returns `false`, the timer will
execute (once).


### Method `<#timer>:runEvery(repeatInterval,delayOrStartTime,continueOnError)`

> **API CHANGE**: This replaces all repeating timers, whether created via `hs.timer.new()`, `hs.timer.doEvery()`, or `hs.timer.doAt()`

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

### Method `<#timer>:runWhen(predicateFn,checkInterval,continueOnError)`

Schedules execution of the timer every time a given predicate is true.

**Parameters:**

* [_`<#predicateFunction>`_](hm.timer.md#function-prototype-predicatefunctiondata---boolean) `predicateFn`: A predicate function that determines whether to execute the timer
* [_`<#intervalString>`_](hm.timer.md#type-intervalstring) `checkInterval`: interval between predicate checks (and potential timer executions)
* _`<#boolean>`_ `continueOnError`: (optional) if `true`, `predicateFn` will keep being checked even if it - or the
       timer's [_`<#timerFunction>`_](hm.timer.md#function-prototype-timerfunctiontimerdata) - causes an error

The given `predicateFn` will start being checked right away. Every time it returns `true`, the timer will
execute.


### Method `<#timer>:runWhile(predicateFn,checkInterval,continueOnError)`

Schedules repeated execution of the timer while a given predicate remains true.

**Parameters:**

* [_`<#predicateFunction>`_](hm.timer.md#function-prototype-predicatefunctiondata---boolean) `predicateFn`: A predicate function that determines whether to contine executing the timer
* [_`<#intervalString>`_](hm.timer.md#type-intervalstring) `checkInterval`: interval between predicate checks (and timer executions)
* _`<#boolean>`_ `continueOnError`: (optional) if `true`, the timer will keep repeating (and executing) even if
       its [_`<#timerFunction>`_](hm.timer.md#function-prototype-timerfunctiontimerdata) or `predicateFn` cause an error

The given `predicateFn` will start being checked right away. While it returns `true`, the timer will
execute; as soon as it returns `false` the timer will be canceled.


### Property (read-only) `<#timer>.lastRun`: _`<#number>`_
The timer's last execution time, in seconds since.

If the timer has never been executed, this value is the time since creation.


### Property `<#timer>.nextRun`: _`<#number>`_
The timer's scheduled next execution time, in seconds from now.

If this value is `nil`, the timer is currently unscheduled.
You cannot set this value to a negative number; setting it to `0` triggers timer execution right away;
setting it to `nil` unschedules the timer.


### Property `<#timer>.scheduled`: _`<#boolean>`_
`true` if the timer is scheduled for execution.

Setting this to `false` or `nil` unschedules the timer.



------------------

### Type `<#intervalString>`

A string describing a time interval.

The following are valid formats: `"DDdHHh"`, `"HHhMMm"`, `"MMmSSs"`, `"DDd"`, `"HHh"`, `"MMm"`, `"SSs"`, `"NNNNms"` - they represent
an interval in days, hours, minutes, seconds and/or milliseconds.
You can also use a plain number (in seconds) wherever this type is expected.

Examples: `"1m30s"` or `90` (in seconds); `"1500ms"` or `1.5`.



------------------

### Type `<#timeOfDayString>`

A string describing a time of day.

The following are valid formats: `"HH:MM:SS"`, `"HH:MM"` or `"HHMM"` - they represent a time of day in hours, minutes, seconds (24-hour clock)
You can also use a plain number (in seconds after midnight) wherever this type is expected.

Examples: `"8:00:00"` or `"800"` or `28800` (in seconds).




------------------

### Function prototype `predicateFunction(data)` -> _`<#boolean>`_

> **API CHANGE**: Predicate functions can receive arbitrary data (or the elapsed time) as argument.

A predicate function that controls conditional execution of a timer.

**Parameters:**

* _`<?>`_ `data`: `data` passed to `timer.new()` or, if `data` was `"elapsed"`, elapsed time in seconds since last execution

**Returns:**

* _`<#boolean>`_ the return value will determine wheter to run, repeat, skip or cancel altogether the timer's execution, depending on what method was used





### Function prototype `timerFunction(timer,data)`

> **API CHANGE**: Timer callbacks can receive the timer itself and arbitrary data (or the elapsed time) as arguments.

A function that will be executed by a timer.

**Parameters:**

* [_`<#timer>`_](hm.timer.md#class-timer) `timer`: the timer that scheduled execution of this function
* _`<?>`_ `data`: `data` passed to `timer.new()` or, if `data` was `"elapsed"`, elapsed time in seconds since last execution




