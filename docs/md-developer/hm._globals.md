# Module `hm._globals`

Additions to the global namespace



## Overview

* Global functions
  * [`assertf(v,fmt,...)`](hm._globals.md#global-function-assertfvfmt) - global function
  * [`checkargs(...)`](hm._globals.md#global-function-checkargs) - global function
  * [`errorf(fmt,...)`](hm._globals.md#global-function-errorffmt) - global function
  * [`hmassert(v,msg)`](hm._globals.md#global-function-hmassertvmsg) - global function
  * [`hmassertf(v,fmt,...)`](hm._globals.md#global-function-hmassertfvfmt) - global function
  * [`inspect(t,inline,depth)`](hm._globals.md#global-function-inspecttinlinedepth) - global function
  * [`printf(fmt,...)`](hm._globals.md#global-function-printffmt) - global function

* Global fields
  * [`checkers`](hm._globals.md#global-field-checkers--string-function-) : `{ [`_`<#string>`_`] =`_`<#function>`_`, ...}` - global field


* Module [`hm._globals`](hm._globals.md#module-hmglobals)






------------------

## Global functions

### Global function `assertf(v,fmt,...)`



* `v`: _`<?>`_ 
* `fmt`: _`<#string>`_ 
* `...`: _`<?>`_ 



### Global function `checkargs(...)`



* `...`: _`<?>`_ 



### Global function `errorf(fmt,...)`



* `fmt`: _`<#string>`_ 
* `...`: _`<?>`_ 



### Global function `hmassert(v,msg)`

> **Internal/advanced use only**

`assert`.

* `v`: _`<?>`_ 
* `msg`: _`<#string>`_ 

Modules should use this (instead of `assert`), as it can be disabled via `hm.debug`

### Global function `hmassertf(v,fmt,...)`

> **Internal/advanced use only**

`assertf`.

* `v`: _`<?>`_ 
* `fmt`: _`<#string>`_ 
* `...`: _`<?>`_ 

Modules should use this (instead of `assertf`), as it can be disabled via `hm.debug`

### Global function `inspect(t,inline,depth)`



* `t`: _`<#table>`_ 
* `inline`: _`<#boolean>`_ 
* `depth`: _`<#number>`_ -@dev



### Global function `printf(fmt,...)`



* `fmt`: _`<#string>`_ 
* `...`: _`<?>`_ 







------------------

## Global fields

### Global field `checkers`: `{ [`_`<#string>`_`] =`_`<#function>`_`, ...}`
Assign functions to this dict for custom type checkers.







------------------

## Module `hm._globals`






