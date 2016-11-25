# Module `hm.logger`

Simple logger for debugging purposes.



## Overview


* Module [`hm.logger`](hm.logger.md#module-hmlogger)
  * [`defaultLogLevel`](hm.logger.md#field-hmloggerdefaultloglevel-loglevel) : [_`<#loglevel>`_](hm.logger.md#type-loglevel) - field
  * [`historySize`](hm.logger.md#field-hmloggerhistorysize-number) : _`<#number>`_ - field
  * [`history()`](hm.logger.md#function-hmloggerhistory---) -> _`<?>`_ - function
  * [`new(id,loglevel)`](hm.logger.md#function-hmloggernewidloglevel---logger) -> [_`<#logger>`_](hm.logger.md#type-logger) - function
  * [`printHistory(filter,level,caseSensitive,entries)`](hm.logger.md#function-hmloggerprinthistoryfilterlevelcasesensitiveentries) - function
  * [`setGlobalLogLevel(lvl)`](hm.logger.md#function-hmloggersetgloballoglevellvl) - function
  * [`setModulesLogLevel(lvl)`](hm.logger.md#function-hmloggersetmodulesloglevellvl) - function


* Type [`logger`](hm.logger.md#type-logger)
  * [`level`](hm.logger.md#field-loggerlevel-number) : _`<#number>`_ - field
  * [`d(...)`](hm.logger.md#function-loggerd) - function
  * [`e(...)`](hm.logger.md#function-loggere---nilstring) -> _`nil`_,_`<#string>`_ - function
  * [`fd(fmt,...)`](hm.logger.md#function-loggerfdfmt) - function
  * [`fe(fmt,...)`](hm.logger.md#function-loggerfefmt---nilstring) -> _`nil`_,_`<#string>`_ - function
  * [`fi(fmt,...)`](hm.logger.md#function-loggerfifmt) - function
  * [`fv(fmt,...)`](hm.logger.md#function-loggerfvfmt) - function
  * [`fw(fmt,...)`](hm.logger.md#function-loggerfwfmt) - function
  * [`getLogLevel()`](hm.logger.md#function-loggergetloglevel---number) -> _`<#number>`_ - function
  * [`i(...)`](hm.logger.md#function-loggeri) - function
  * [`setLogLevel(loglevel)`](hm.logger.md#function-loggersetloglevelloglevel) - function
  * [`v(...)`](hm.logger.md#function-loggerv) - function
  * [`w(...)`](hm.logger.md#function-loggerw) - function


* Type [`loglevel`](hm.logger.md#type-loglevel)






------------------

## Module `hm.logger`





### Field `hm.logger.defaultLogLevel`: [_`<#loglevel>`_](hm.logger.md#type-loglevel)
Default log level for new logger instances.

The starting value is `'warning'`; set this (to e.g. `'info'`) at the top of your userscript to affect
all logger instances created without specifying a `loglevel` parameter


### Field `hm.logger.historySize`: _`<#number>`_
> **API CHANGE**: function hm.logger.historySize([v]) -> field hm.logger.historySize

The number of log entries to keep in the history.

The starting value is 0 (history is disabled). To enable the log history, set this at the top of your userscript.
If you change history size (other than from 0) after creating any logger instances, things will likely break.


### Function `hm.logger.history()` -> _`<?>`_

Returns the global log history.



* Returns _`<?>`_: a list of (at most `hs.logger.historySize`) log entries produced by all the logger instances, in chronological order

Each log entry in the returned list is a table with the following fields:
  * time - timestamp in seconds since the epoch
  * level - a number between 1 (error) and 5 (verbose)
  * id - a string containing the id of the logger instance that produced this entry
  * message - a string containing the logged message


### Function `hm.logger.new(id,loglevel)` -> [_`<#logger>`_](hm.logger.md#type-logger)

Creates a new logger instance.

* `id`: _`<#string>`_ a string identifier for the instance (usually the module name)
* `loglevel`: [_`<#loglevel>`_](hm.logger.md#type-loglevel) (optional) can be 'nothing', 'error', 'warning', 'info', 'debug', or 'verbose',
or a corresponding number between 0 and 5; uses `hs.logger.defaultLogLevel` if omitted



* Returns [_`<#logger>`_](hm.logger.md#type-logger): the new logger instance

The logger instance created by this method is not a regular object, but a plain table with "static" functions;
therefore, do *not* use the colon syntax for so-called "methods" in this module (as in `mylogger:setLogLevel(3)`);
you must instead use the regular dot syntax: `mylogger.setLogLevel(3)`

**Usage**:

```lua
local log = hs.logger.new('mymodule','debug')
log.i('Initializing') -- will print "[mymodule] Initializing" to the console
```

### Function `hm.logger.printHistory(filter,level,caseSensitive,entries)`

Prints the global log history to the console.

* `filter`: _`<#string>`_ (optional) a string to filter the entries (by logger id or message) via `string.find` plain matching
* `level`: [_`<#loglevel>`_](hm.logger.md#type-loglevel) (optional) the desired log level; if omitted, defaults to `verbose`
* `caseSensitive`: _`<#boolean>`_ (optional) if true, filtering is case sensitive
* `entries`: _`<#number>`_ (optional) the maximum number of entries to print; if omitted, all entries in the history will be printed




### Function `hm.logger.setGlobalLogLevel(lvl)`

Sets the log level for all logger instances (including objects' loggers)

* `lvl`: [_`<#loglevel>`_](hm.logger.md#type-loglevel) 




### Function `hm.logger.setModulesLogLevel(lvl)`

Sets the log level for all currently loaded modules.

* `lvl`: [_`<#loglevel>`_](hm.logger.md#type-loglevel) 

This function only affects *module*-level loggers, object instances with their own loggers (e.g. windowfilters) won't be affected;
you can use `hs.logger.setGlobalLogLevel()` for those




------------------

### Type `logger`

A logger instance.



### Field `<#logger>.level`: _`<#number>`_
The log level of the logger instance, as a number between 0 and 5




### Function `<#logger>.d(...)`

Logs debug info to the console

* `...`: _`<?>`_ one or more message strings




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




### Function `<#logger>.getLogLevel()` -> _`<#number>`_

Gets the log level of the logger instance



* Returns _`<#number>`_: The log level of this logger as a number between 0 ('nothing') and 5 ('verbose')




### Function `<#logger>.i(...)`

Logs info to the console

* `...`: _`<?>`_ one or more message strings




### Function `<#logger>.setLogLevel(loglevel)`

Sets the log level of the logger instance

* `loglevel`: [_`<#loglevel>`_](hm.logger.md#type-loglevel) can be 'nothing', 'error', 'warning', 'info', 'debug', or 'verbose'; or a corresponding number between 0 and 5




### Function `<#logger>.v(...)`

Logs verbose info to the console

* `...`: _`<?>`_ one or more message strings




### Function `<#logger>.w(...)`

Logs a warning to the console

* `...`: _`<?>`_ one or more message strings






------------------

### Type `loglevel`

> Extends _`<#string>`_

A string or number describing a log level.

Can be `'nothing'`, `'error'`, `'warning'`, `'info'`, `'debug'`, or `'verbose'`, or a corresponding number between 0 and 5.


