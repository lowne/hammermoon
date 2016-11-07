# Module `hm`

Hammermoon main module



## Overview


| Table [hm.debug](#table-hmdebug) | Debug options |
| :--- | :---
Field [`hm.debug.cache_uielements`](#field-hmdebugcache_uielements-boolean) : `<#boolean>` | if false, uielement objects (including applications and windows) are not cached
Field [`hm.debug.retain_user_objects`](#field-hmdebugretain_user_objects-boolean) : `<#boolean>` | if false, user objects (timers, watchers, etc.) will get gc'ed unless the userscript keeps a global reference






-----------

## Table `hm.debug`



> **Internal/advanced use only** (e.g. for extension developers)

> **API CHANGE**: doesn't exist in Hammerspoon

Debug options



### Field `hm.debug.cache_uielements`: `<#boolean>`
if false, uielement objects (including applications and windows) are not cached




### Field `hm.debug.retain_user_objects`: `<#boolean>`
if false, user objects (timers, watchers, etc.) will get gc'ed unless the userscript keeps a global reference






# Module `hm.logger`

Simple logger for debugging purposes.



## Overview


| Module [hm.logger](#module-hmlogger) |  |
| :--- | :---
Field [`hm.logger.historySize`](#field-hmloggerhistorysize-number) : `<#number>` | The number of log entries to keep in the history.


| Type [<#logger>](#type-logger) | A logger instance. |
| :--- | :---
Function [`<#logger>.fd(fmt,...)`](#function-loggerfdfmt) | Logs formatted debug info to the console
Function [`<#logger>.fe(fmt,...)`](#function-loggerfefmt) | Logs a formatted error to the console
Function [`<#logger>.fi(fmt,...)`](#function-loggerfifmt) | Logs formatted info to the console
Function [`<#logger>.fv(fmt,...)`](#function-loggerfvfmt) | Logs formatted verbose info to the console
Function [`<#logger>.fw(fmt,...)`](#function-loggerfwfmt) | Logs a formatted warning to the console






-----------

## Module `hm.logger`







### Field `hm.logger.historySize`: `<#number>`
> **API CHANGE**: function hm.logger.historySize([v]) -> field hm.logger.historySize

The number of log entries to keep in the history.

The starting value is 0 (history is disabled). To enable the log history, set this at the top of your userscript.
If you change history size (other than from 0) after creating any logger instances, things will likely break.



-----------

## Type `<#logger>`



A logger instance.




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





