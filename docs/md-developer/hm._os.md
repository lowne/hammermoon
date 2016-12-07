# Module `hm._os`

> **Internal/advanced use only**

Low level access to macOS



## Overview


* Module [`hm._os`](hm._os.md#module-hmos)
  * [`defaultNotificationCenter`](hm._os.md#field-hmosdefaultnotificationcenter-notificationcenter) : [_`<#notificationCenter>`_](hm._os.md#class-notificationcenter) - field
  * [`events`](hm._os.md#field-hmosevents-hmoseventshmosevents) : [_`<hm._os.events#hm._os.events>`_](hm._os.events.md#module-hmosevents) - field
  * [`runLoop`](hm._os.md#field-hmosrunloop-cdata) : _`<#cdata>`_ - field
  * [`sharedWorkspace`](hm._os.md#field-hmossharedworkspace-cdata) : _`<#cdata>`_ - field
  * [`systemWideAccessibility`](hm._os.md#field-hmossystemwideaccessibility-cdata) : _`<#cdata>`_ - field
  * [`wsNotificationCenter`](hm._os.md#field-hmoswsnotificationcenter-notificationcenter) : [_`<#notificationCenter>`_](hm._os.md#class-notificationcenter) - field
  * [`runLoopAddSource(src,mode)`](hm._os.md#function-hmosrunloopaddsourcesrcmode) - function
  * [`runLoopRemoveSource(src,mode)`](hm._os.md#function-hmosrunloopremovesourcesrcmode) - function


* Class [`notificationCenter`](hm._os.md#class-notificationcenter)
  * [`register(event,cb,priority)`](hm._os.md#method-notificationcenterregistereventcbpriority) - method






------------------

## Module `hm._os`

> Extends [_`<hm#module>`_](hm.md#class-module)





### Field `hm._os.defaultNotificationCenter`: [_`<#notificationCenter>`_](hm._os.md#class-notificationcenter)
The default Notification Center.




### Field `hm._os.events`: [_`<hm._os.events#hm._os.events>`_](hm._os.events.md#module-hmosevents)





### Field `hm._os.runLoop`: _`<#cdata>`_
The `CFRunLoop` object for HM's (only) thread.




### Field `hm._os.sharedWorkspace`: _`<#cdata>`_
The shared `NSWorkspace` instance




### Field `hm._os.systemWideAccessibility`: _`<#cdata>`_
> INTERNAL CHANGE: Instance to be used by extensions.

`AXUIElementCreateSystemWide()` instance




### Field `hm._os.wsNotificationCenter`: [_`<#notificationCenter>`_](hm._os.md#class-notificationcenter)
The shared workspace's Notification Center.




### Function `hm._os.runLoopAddSource(src,mode)`



* `src`: _`<?>`_ 
* `mode`: _`<?>`_ 




### Function `hm._os.runLoopRemoveSource(src,mode)`



* `src`: _`<?>`_ 
* `mode`: _`<?>`_ 






------------------

## Class `notificationCenter`






### Method `<#notificationCenter>:register(event,cb,priority)`

> **Internal/advanced use only**

> INTERNAL CHANGE: Centralized callback registry for notification centers, to be used by extensions.



* `event`: _`<#string>`_ 
* `cb`: _`<#function>`_ 
* `priority`: _`<#boolean>`_ 





