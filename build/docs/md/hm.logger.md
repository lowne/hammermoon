# Module `hm.logger`

Simple logger for debugging purposes.



## Overview


| Module [hm.logger](#module-hmlogger) |  |
| :--- | :---
Function [`hm.logger.new(id,loglevel)`](#function-hmloggernewidloglevel---logger) -> [`<#logger>`](#type-logger) | Create a new logger instance.
Function [`hm.logger.setGlobalLogLevel(lvl)`](#function-hmloggersetgloballoglevellvl) | Sets the log level for all logger instances (including objects' loggers)
Function [`hm.logger.setModulesLogLevel(lvl)`](#function-hmloggersetmodulesloglevellvl) | Sets the log level for all currently loaded modules.
Field [`hm.logger.defaultLogLevel`](#field-hmloggerdefaultloglevel-loglevel) : [`<#loglevel>`](#type-loglevel) | Default log level for new logger instances.
Field [`hm.logger.historySize`](#field-hmloggerhistorysize-number) : `<#number>` | The number of log entries to keep in the history.


| Type [<#logger>](#type-logger) | A logger instance. |
| :--- | :---
Function [`<#logger>.d(...)`](#function-loggerd) | Logs debug info to the console
Function [`<#logger>.e(...)`](#function-loggere) | Logs an error to the console
Function [`<#logger>.fd(fmt,...)`](#function-loggerfdfmt) | Logs formatted debug info to the console
Function [`<#logger>.fe(fmt,...)`](#function-loggerfefmt) | Logs a formatted error to the console
Function [`<#logger>.fi(fmt,...)`](#function-loggerfifmt) | Logs formatted info to the console
Function [`<#logger>.fv(fmt,...)`](#function-loggerfvfmt) | Logs formatted verbose info to the console
Function [`<#logger>.fw(fmt,...)`](#function-loggerfwfmt) | Logs a formatted warning to the console
Function [`<#logger>.getLogLevel()`](#function-loggergetloglevel---number) -> `<#number>` | Gets the log level of the logger instance
Function [`<#logger>.i(...)`](#function-loggeri) | Logs info to the console
Function [`<#logger>.setLogLevel(loglevel)`](#function-loggersetloglevelloglevel) | Sets the log level of the logger instance
Function [`<#logger>.v(...)`](#function-loggerv) | Logs verbose info to the console
Function [`<#logger>.w(...)`](#function-loggerw) | Logs a warning to the console
Field [`<#logger>.level`](#field-loggerlevel-number) : `<#number>` | The log level of the logger instance, as a number between 0 and 5


| Type [<#loglevel>](#type-loglevel) | A string or number describing a log level. |
| :--- | :---






-----------

## Module `hm.logger`








### Function `hm.logger.new(id,loglevel)` -> [`<#logger>`](#type-logger)

Create a new logger instance.

**Parameters:**

* `id`: `<#string>` a string identifier for the instance (usually the module name)
* `loglevel`: [`<#loglevel>`](#type-loglevel) (optional) can be 'nothing', 'error', 'warning', 'info', 'debug', or 'verbose',
or a corresponding number between 0 and 5; uses `hs.logger.defaultLogLevel` if omitted

**Returns:**

* [`<#logger>`](#type-logger) the new logger instance

The logger instance created by this method is not a regular object, but a plain table with "static" functions;
therefore, do *not* use the colon syntax for so-called "methods" in this module (as in `mylogger:setLogLevel(3)`);
you must instead use the regular dot syntax: `mylogger.setLogLevel(3)`

**Usage**:

```lua
local log = hs.logger.new('mymodule','debug')
log.i('Initializing') -- will print "[mymodule] Initializing" to the console
```
### Function `hm.logger.setGlobalLogLevel(lvl)`

Sets the log level for all logger instances (including objects' loggers)

**Parameters:**

* `lvl`: [`<#loglevel>`](#type-loglevel) 




### Function `hm.logger.setModulesLogLevel(lvl)`

Sets the log level for all currently loaded modules.

**Parameters:**

* `lvl`: [`<#loglevel>`](#type-loglevel) 

This function only affects *module*-level loggers, object instances with their own loggers (e.g. windowfilters) won't be affected;
you can use `hs.logger.setGlobalLogLevel()` for those


### Field `hm.logger.defaultLogLevel`: [`<#loglevel>`](#type-loglevel)
Default log level for new logger instances.

The starting value is 'warning'; set this (to e.g. 'info') at the top of your `init.lua` to affect
all logger instances created without specifying a `loglevel` parameter


### Field `hm.logger.historySize`: `<#number>`
> **API CHANGE**: function hm.logger.historySize([v]) -> field hm.logger.historySize

The number of log entries to keep in the history.

The starting value is 0 (history is disabled). To enable the log history, set this at the top of your userscript.
If you change history size (other than from 0) after creating any logger instances, things will likely break.



-----------

## Type `<#logger>`



A logger instance.




### Function `<#logger>.d(...)`

Logs debug info to the console

**Parameters:**

* `...`: `?` one or more message strings




### Function `<#logger>.e(...)`

Logs an error to the console

**Parameters:**

* `...`: `?` one or more message strings




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




### Function `<#logger>.getLogLevel()` -> `<#number>`

Gets the log level of the logger instance

**Returns:**

* `<#number>` The log level of this logger as a number between 0 ('nothing') and 5 ('verbose')




### Function `<#logger>.i(...)`

Logs info to the console

**Parameters:**

* `...`: `?` one or more message strings




### Function `<#logger>.setLogLevel(loglevel)`

Sets the log level of the logger instance

**Parameters:**

* `loglevel`: [`<#loglevel>`](#type-loglevel) can be 'nothing', 'error', 'warning', 'info', 'debug', or 'verbose'; or a corresponding number between 0 and 5




### Function `<#logger>.v(...)`

Logs verbose info to the console

**Parameters:**

* `...`: `?` one or more message strings




### Function `<#logger>.w(...)`

Logs a warning to the console

**Parameters:**

* `...`: `?` one or more message strings




### Field `<#logger>.level`: `<#number>`
The log level of the logger instance, as a number between 0 and 5





-----------

## Type `<#loglevel>`



A string or number describing a log level.

Can be `'nothing'`, `'error'`, `'warning'`, `'info'`, `'debug'`, or `'verbose'`, or a corresponding number between 0 and 5.


