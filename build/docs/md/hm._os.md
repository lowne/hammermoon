# Module `hm._os`

Low level access to macOS



## Overview


| Module [hm._os](hm._os.md#module-hmos-extends-hmmodule) |  |
| :--- | :---
Function [`hm._os.runLoopAddSource(src,mode)`](hm._os.md#function-hmosrunloopaddsourcesrcmode) | 
Function [`hm._os.runLoopRemoveSource(src,mode)`](hm._os.md#function-hmosrunloopremovesourcesrcmode) | 
Field [`hm._os.defaultNotificationCenter`](hm._os.md#field-hmosdefaultnotificationcenter-notificationcenter) : [_`<#notificationCenter>`_](hm._os.md#class-notificationcenter) | The default Notification Center.
Field [`hm._os.events`](hm._os.md#field-hmosevents-hmoseventshmosevents) : [_`<hm._os.events#hm._os.events>`_](hm._os.events.md#module-hmosevents-extends-hmmodule) | 
Field [`hm._os.runLoop`](hm._os.md#field-hmosrunloop-cdata) : _`<#cdata>`_ | The `CFRunLoop` object for HM's (only) thread.
Field [`hm._os.sharedWorkspace`](hm._os.md#field-hmossharedworkspace-cdata) : _`<#cdata>`_ | The shared `NSWorkspace` instance
Field [`hm._os.systemWideAccessibility`](hm._os.md#field-hmossystemwideaccessibility-cdata) : _`<#cdata>`_ | `AXUIElementCreateSystemWide()` instance
Field [`hm._os.wsNotificationCenter`](hm._os.md#field-hmoswsnotificationcenter-notificationcenter) : [_`<#notificationCenter>`_](hm._os.md#class-notificationcenter) | The shared workspace's Notification Center.


| Class [<#notificationCenter>](hm._os.md#class-notificationcenter) |  |
| :--- | :---
Method [`<#notificationCenter>:register(event,cb,priority)`](hm._os.md#method-notificationcenterregistereventcbpriority) | 






------------------

## Module `hm._os` (extends [_`<hm#module>`_](hm.md#class-module))






### Function `hm._os.runLoopAddSource(src,mode)`



**Parameters:**

* _`<?>`_ `src`: 
* _`<?>`_ `mode`: 




### Function `hm._os.runLoopRemoveSource(src,mode)`



**Parameters:**

* _`<?>`_ `src`: 
* _`<?>`_ `mode`: 




### Field `hm._os.defaultNotificationCenter`: [_`<#notificationCenter>`_](hm._os.md#class-notificationcenter)
The default Notification Center.




### Field `hm._os.events`: [_`<hm._os.events#hm._os.events>`_](hm._os.events.md#module-hmosevents-extends-hmmodule)





### Field `hm._os.runLoop`: _`<#cdata>`_
The `CFRunLoop` object for HM's (only) thread.




### Field `hm._os.sharedWorkspace`: _`<#cdata>`_
The shared `NSWorkspace` instance




### Field `hm._os.systemWideAccessibility`: _`<#cdata>`_
`AXUIElementCreateSystemWide()` instance




### Field `hm._os.wsNotificationCenter`: [_`<#notificationCenter>`_](hm._os.md#class-notificationcenter)
The shared workspace's Notification Center.





------------------

## Class `<#notificationCenter>`






### Method `<#notificationCenter>:register(event,cb,priority)`

> **Internal/advanced use only** (e.g. for extension developers)



**Parameters:**

* _`<#string>`_ `event`: 
* _`<#function>`_ `cb`: 
* _`<#boolean>`_ `priority`: 





