# Module `hm.keyboard`

Create and manage keyboard shortcuts.



## Overview


* Module [`hm.keyboard`](hm.keyboard.md#module-hmkeyboard)
  * [`globalContext`](hm.keyboard.md#field-hmkeyboardglobalcontext-) : _`<?>`_ - field
  * [`keys`](hm.keyboard.md#field-hmkeyboardkeys-hmkeyboardkeys) : [_`hm.keyboard.keys`_](hm.keyboard.keys.md#module-hmkeyboardkeys) - field
  * [`symbols`](hm.keyboard.md#field-hmkeyboardsymbols-hmkeyboardsymbols) : [_`hm.keyboard.symbols`_](hm.keyboard.symbols.md#module-hmkeyboardsymbols) - field
  * [`bind(keys,fn)`](hm.keyboard.md#function-hmkeyboardbindkeysfn) - function
  * [`newContext(name,windowfilter)`](hm.keyboard.md#function-hmkeyboardnewcontextnamewindowfilter---context) -> [_`<#context>`_](hm.keyboard.md#class-context) - function


* Class [`context`](hm.keyboard.md#class-context)
  * [`bind(keys,fn)`](hm.keyboard.md#method-contextbindkeysfn) - method
  * [`disable()`](hm.keyboard.md#method-contextdisable) - method
  * [`enable()`](hm.keyboard.md#method-contextenable) - method
  * [`newHotkey(keys,message)`](hm.keyboard.md#method-contextnewhotkeykeysmessage) - method


* Class [`hotkey`](hm.keyboard.md#class-hotkey)
  * [`disable(self)`](hm.keyboard.md#method-hotkeydisableself) - method
  * [`enable()`](hm.keyboard.md#method-hotkeyenable) - method
  * [`onPress(fn)`](hm.keyboard.md#method-hotkeyonpressfn) - method






------------------

## Module `hm.keyboard`

> Extends [_`<hm#module>`_](hm.md#class-module)





### Field `hm.keyboard.globalContext`: _`<?>`_





### Field `hm.keyboard.keys`: [_`hm.keyboard.keys`_](hm.keyboard.keys.md#module-hmkeyboardkeys)





### Field `hm.keyboard.symbols`: [_`hm.keyboard.symbols`_](hm.keyboard.symbols.md#module-hmkeyboardsymbols)





### Function `hm.keyboard.bind(keys,fn)`



* `keys`: _`<?>`_ 
* `fn`: _`<?>`_ 




### Function `hm.keyboard.newContext(name,windowfilter)` -> [_`<#context>`_](hm.keyboard.md#class-context)



* `name`: _`<?>`_ 
* `windowfilter`: _`<?>`_ 



* Returns [_`<#context>`_](hm.keyboard.md#class-context): 






------------------

## Class `context`

> Extends [_`<hm#module.object>`_](hm.md#class-moduleobject)

Type for context objects




### Method `<#context>:bind(keys,fn)`



* `keys`: _`<?>`_ 
* `fn`: _`<?>`_ 




### Method `<#context>:disable()`






### Method `<#context>:enable()`






### Method `<#context>:newHotkey(keys,message)`



* `keys`: _`<?>`_ 
* `message`: _`<?>`_ 






------------------

## Class `hotkey`

> Extends [_`<hm#module.object>`_](hm.md#class-moduleobject)

Type for hotkey objects




### Method `<#hotkey>:disable(self)`



* `self`: _`<?>`_ 




### Method `<#hotkey>:enable()`






### Method `<#hotkey>:onPress(fn)`



* `fn`: _`<?>`_ 





