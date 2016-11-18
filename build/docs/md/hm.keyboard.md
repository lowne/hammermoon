# Module `hm.keyboard`

Create and manage keyboard shortcuts.



## Overview


| Module [hm.keyboard](hm.keyboard.md#module-hmkeyboard-extends-hmmodule) |  |
| :--- | :---
Function [`hm.keyboard.bind(keys,fn)`](hm.keyboard.md#function-hmkeyboardbindkeysfn) | 
Function [`hm.keyboard.newContext(name,windowfilter)`](hm.keyboard.md#function-hmkeyboardnewcontextnamewindowfilter---context) -> [_`<#context>`_](hm.keyboard.md#class-context-extends-hmmoduleobject) | 
Field [`hm.keyboard.globalContext`](hm.keyboard.md#field-hmkeyboardglobalcontext-) : _`<?>`_ | 
Field [`hm.keyboard.keys`](hm.keyboard.md#field-hmkeyboardkeys-hmkeyboardkeys) : [_`hm.keyboard.keys`_](hm.keyboard.keys.md#module-hmkeyboardkeys) | 
Field [`hm.keyboard.symbols`](hm.keyboard.md#field-hmkeyboardsymbols-hmkeyboardsymbols) : [_`hm.keyboard.symbols`_](hm.keyboard.symbols.md#module-hmkeyboardsymbols) | 


| Class [<#context>](hm.keyboard.md#class-context-extends-hmmoduleobject) | Type for context objects |
| :--- | :---
Method [`<#context>:bind(keys,fn)`](hm.keyboard.md#method-contextbindkeysfn) | 
Method [`<#context>:disable()`](hm.keyboard.md#method-contextdisable) | 
Method [`<#context>:enable()`](hm.keyboard.md#method-contextenable) | 
Method [`<#context>:newHotkey(keys,message)`](hm.keyboard.md#method-contextnewhotkeykeysmessage) | 


| Class [<#hotkey>](hm.keyboard.md#class-hotkey-extends-hmmoduleobject) | Type for hotkey objects |
| :--- | :---
Method [`<#hotkey>:disable(self)`](hm.keyboard.md#method-hotkeydisableself) | 
Method [`<#hotkey>:enable()`](hm.keyboard.md#method-hotkeyenable) | 
Method [`<#hotkey>:onPress(fn)`](hm.keyboard.md#method-hotkeyonpressfn) | 






------------------

## Module `hm.keyboard` (extends [_`<hm#module>`_](hm.md#class-module))






### Function `hm.keyboard.bind(keys,fn)`



**Parameters:**

* _`<?>`_ `keys`: 
* _`<?>`_ `fn`: 




### Function `hm.keyboard.newContext(name,windowfilter)` -> [_`<#context>`_](hm.keyboard.md#class-context-extends-hmmoduleobject)



**Parameters:**

* _`<?>`_ `name`: 
* _`<?>`_ `windowfilter`: 

**Returns:**

* [_`<#context>`_](hm.keyboard.md#class-context-extends-hmmoduleobject) 




### Field `hm.keyboard.globalContext`: _`<?>`_





### Field `hm.keyboard.keys`: [_`hm.keyboard.keys`_](hm.keyboard.keys.md#module-hmkeyboardkeys)





### Field `hm.keyboard.symbols`: [_`hm.keyboard.symbols`_](hm.keyboard.symbols.md#module-hmkeyboardsymbols)






------------------

## Class `<#context>` (extends [_`<hm#module.object>`_](hm.md#class-moduleobject))

Type for context objects




### Method `<#context>:bind(keys,fn)`



**Parameters:**

* _`<?>`_ `keys`: 
* _`<?>`_ `fn`: 




### Method `<#context>:disable()`






### Method `<#context>:enable()`






### Method `<#context>:newHotkey(keys,message)`



**Parameters:**

* _`<?>`_ `keys`: 
* _`<?>`_ `message`: 






------------------

## Class `<#hotkey>` (extends [_`<hm#module.object>`_](hm.md#class-moduleobject))

Type for hotkey objects




### Method `<#hotkey>:disable(self)`



**Parameters:**

* _`<?>`_ `self`: 




### Method `<#hotkey>:enable()`






### Method `<#hotkey>:onPress(fn)`



**Parameters:**

* _`<?>`_ `fn`: 





