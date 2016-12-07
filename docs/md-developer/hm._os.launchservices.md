# Module `hm._os.launchservices`

> **Internal/advanced use only**

Launch Services interface



## Overview


* Module [`hm._os.launchservices`](hm._os.launchservices.md#module-hmoslaunchservices)
  * [`allApplicationPaths()`](hm._os.launchservices.md#function-hmoslaunchservicesallapplicationpaths---string-) -> `{`_`<#string>`_`, ...}` - function
  * [`allApplications()`](hm._os.launchservices.md#function-hmoslaunchservicesallapplications---nsurllist) -> [_`<#NSURLList>`_](hm._os.launchservices.md#type-nsurllist) - function
  * [`applicationPathsForBundleIdentifier(bundle)`](hm._os.launchservices.md#function-hmoslaunchservicesapplicationpathsforbundleidentifierbundle---string--or-nilstring) -> `{`_`<#string>`_`, ...}` or _`nil`_,_`<#string>`_ - function
  * [`applicationPathsForPath(path,role)`](hm._os.launchservices.md#function-hmoslaunchservicesapplicationpathsforpathpathrole---string--or-nilstring) -> `{`_`<#string>`_`, ...}` or _`nil`_,_`<#string>`_ - function
  * [`applicationPathsForURL(url)`](hm._os.launchservices.md#function-hmoslaunchservicesapplicationpathsforurlurl---string--or-nilstring) -> `{`_`<#string>`_`, ...}` or _`nil`_,_`<#string>`_ - function
  * [`applicationsForBundleIdentifier(bundle)`](hm._os.launchservices.md#function-hmoslaunchservicesapplicationsforbundleidentifierbundle---nsurllist-or-nilstring) -> [_`<#NSURLList>`_](hm._os.launchservices.md#type-nsurllist) or _`nil`_,_`<#string>`_ - function
  * [`applicationsForNSURL(nsurl,role)`](hm._os.launchservices.md#function-hmoslaunchservicesapplicationsfornsurlnsurlrole---nsurllist-or-nilstring) -> [_`<#NSURLList>`_](hm._os.launchservices.md#type-nsurllist) or _`nil`_,_`<#string>`_ - function
  * [`applicationsForPath(path,role)`](hm._os.launchservices.md#function-hmoslaunchservicesapplicationsforpathpathrole---nsurllist-or-nilstring) -> [_`<#NSURLList>`_](hm._os.launchservices.md#type-nsurllist) or _`nil`_,_`<#string>`_ - function
  * [`applicationsForURL(url)`](hm._os.launchservices.md#function-hmoslaunchservicesapplicationsforurlurl---nsurllist-or-nilstring) -> [_`<#NSURLList>`_](hm._os.launchservices.md#type-nsurllist) or _`nil`_,_`<#string>`_ - function
  * [`defaultApplicationForNSURL(nsurl,role)`](hm._os.launchservices.md#function-hmoslaunchservicesdefaultapplicationfornsurlnsurlrole---cdata-or-nilstring) -> _`<#cdata>`_ or _`nil`_,_`<#string>`_ - function
  * [`defaultApplicationForPath(path,role)`](hm._os.launchservices.md#function-hmoslaunchservicesdefaultapplicationforpathpathrole---cdata-or-nilstring) -> _`<#cdata>`_ or _`nil`_,_`<#string>`_ - function
  * [`defaultApplicationForURL(url)`](hm._os.launchservices.md#function-hmoslaunchservicesdefaultapplicationforurlurl---cdata-or-nilstring) -> _`<#cdata>`_ or _`nil`_,_`<#string>`_ - function
  * [`defaultApplicationPathForPath(path,role)`](hm._os.launchservices.md#function-hmoslaunchservicesdefaultapplicationpathforpathpathrole---string-or-nilstring) -> _`<#string>`_ or _`nil`_,_`<#string>`_ - function
  * [`defaultApplicationPathForURL(url)`](hm._os.launchservices.md#function-hmoslaunchservicesdefaultapplicationpathforurlurl---string-or-nilstring) -> _`<#string>`_ or _`nil`_,_`<#string>`_ - function
  * [`launch(nsurl)`](hm._os.launchservices.md#function-hmoslaunchserviceslaunchnsurl---boolean-or-nilstring) -> _`<#boolean>`_ or _`nil`_,_`<#string>`_ - function
  * [`launchPath(path)`](hm._os.launchservices.md#function-hmoslaunchserviceslaunchpathpath---boolean-or-nilstring) -> _`<#boolean>`_ or _`nil`_,_`<#string>`_ - function


* Type [`NSURLList`](hm._os.launchservices.md#type-nsurllist)






------------------

## Module `hm._os.launchservices`

> Extends [_`<hm#module>`_](hm.md#class-module)






### Function `hm._os.launchservices.allApplicationPaths()` -> `{`_`<#string>`_`, ...}`

Private API



* Returns `{`_`<#string>`_`, ...}`: paths of apps




### Function `hm._os.launchservices.allApplications()` -> [_`<#NSURLList>`_](hm._os.launchservices.md#type-nsurllist)

Private API



* Returns [_`<#NSURLList>`_](hm._os.launchservices.md#type-nsurllist): `NSURL`s of apps




### Function `hm._os.launchservices.applicationPathsForBundleIdentifier(bundle)` -> `{`_`<#string>`_`, ...}` or _`nil`_,_`<#string>`_



* `bundle`: _`<#string>`_ ID



* Returns `{`_`<#string>`_`, ...}`: paths of apps
* Returns _`nil`_,_`<#string>`_: on error




### Function `hm._os.launchservices.applicationPathsForPath(path,role)` -> `{`_`<#string>`_`, ...}` or _`nil`_,_`<#string>`_



* `path`: _`<#string>`_ path of file
* `role`: _`<#string>`_ 



* Returns `{`_`<#string>`_`, ...}`: paths of apps
* Returns _`nil`_,_`<#string>`_: if not found




### Function `hm._os.launchservices.applicationPathsForURL(url)` -> `{`_`<#string>`_`, ...}` or _`nil`_,_`<#string>`_



* `url`: _`<#string>`_ url



* Returns `{`_`<#string>`_`, ...}`: paths of apps
* Returns _`nil`_,_`<#string>`_: if not found




### Function `hm._os.launchservices.applicationsForBundleIdentifier(bundle)` -> [_`<#NSURLList>`_](hm._os.launchservices.md#type-nsurllist) or _`nil`_,_`<#string>`_



* `bundle`: _`<#string>`_ ID



* Returns [_`<#NSURLList>`_](hm._os.launchservices.md#type-nsurllist): `NSURL`s of apps
* Returns _`nil`_,_`<#string>`_: on error




### Function `hm._os.launchservices.applicationsForNSURL(nsurl,role)` -> [_`<#NSURLList>`_](hm._os.launchservices.md#type-nsurllist) or _`nil`_,_`<#string>`_



* `nsurl`: _`<#cdata>`_ `NSURL` of file
* `role`: _`<#string>`_ 



* Returns [_`<#NSURLList>`_](hm._os.launchservices.md#type-nsurllist): `NSURL`s of apps
* Returns _`nil`_,_`<#string>`_: if not found




### Function `hm._os.launchservices.applicationsForPath(path,role)` -> [_`<#NSURLList>`_](hm._os.launchservices.md#type-nsurllist) or _`nil`_,_`<#string>`_



* `path`: _`<#string>`_ path of file
* `role`: _`<#string>`_ 



* Returns [_`<#NSURLList>`_](hm._os.launchservices.md#type-nsurllist): `NSURL`s of apps
* Returns _`nil`_,_`<#string>`_: if not found




### Function `hm._os.launchservices.applicationsForURL(url)` -> [_`<#NSURLList>`_](hm._os.launchservices.md#type-nsurllist) or _`nil`_,_`<#string>`_



* `url`: _`<#string>`_ url



* Returns [_`<#NSURLList>`_](hm._os.launchservices.md#type-nsurllist): `NSURL`s of apps
* Returns _`nil`_,_`<#string>`_: if not found




### Function `hm._os.launchservices.defaultApplicationForNSURL(nsurl,role)` -> _`<#cdata>`_ or _`nil`_,_`<#string>`_



* `nsurl`: _`<#cdata>`_ `NSURL` of file
* `role`: _`<#string>`_ 



* Returns _`<#cdata>`_: `NSURL` of app
* Returns _`nil`_,_`<#string>`_: on error




### Function `hm._os.launchservices.defaultApplicationForPath(path,role)` -> _`<#cdata>`_ or _`nil`_,_`<#string>`_



* `path`: _`<#string>`_ of file
* `role`: _`<#string>`_ 



* Returns _`<#cdata>`_: `NSURL` of app
* Returns _`nil`_,_`<#string>`_: on error




### Function `hm._os.launchservices.defaultApplicationForURL(url)` -> _`<#cdata>`_ or _`nil`_,_`<#string>`_



* `url`: _`<#string>`_ 



* Returns _`<#cdata>`_: `NSURL` of app
* Returns _`nil`_,_`<#string>`_: on error




### Function `hm._os.launchservices.defaultApplicationPathForPath(path,role)` -> _`<#string>`_ or _`nil`_,_`<#string>`_



* `path`: _`<#string>`_ of file
* `role`: _`<#string>`_ 



* Returns _`<#string>`_: path of app
* Returns _`nil`_,_`<#string>`_: on error




### Function `hm._os.launchservices.defaultApplicationPathForURL(url)` -> _`<#string>`_ or _`nil`_,_`<#string>`_



* `url`: _`<#string>`_ 



* Returns _`<#string>`_: path of app
* Returns _`nil`_,_`<#string>`_: on error




### Function `hm._os.launchservices.launch(nsurl)` -> _`<#boolean>`_ or _`nil`_,_`<#string>`_



* `nsurl`: _`<#cdata>`_ `NSURL`



* Returns _`<#boolean>`_: `true` on success
* Returns _`nil`_,_`<#string>`_: on error




### Function `hm._os.launchservices.launchPath(path)` -> _`<#boolean>`_ or _`nil`_,_`<#string>`_



* `path`: _`<#string>`_ 



* Returns _`<#boolean>`_: `true` on success
* Returns _`nil`_,_`<#string>`_: on error






------------------

### Type `NSURLList`

List of `NSURL` cdata




