# Module `hm.types.coll`

Some utilities for collections in Lua tables.

You can call the methods in this module as functions on "plain" tables, via the syntax
`new_table=coll.filter(coll.map(my_table, map_fn),filter_fn)`.
Alternatively, you can use the constructors and then call methods directly on the table, like this:
`new_table=coll.dict(my_table):map(map_fn):filter(filter_fn)`.
All tables or lists returned by coll methods, unless otherwise noted, will accept further coll methods.

The methods in this module can be used on these types of collections:
  - *lists*: ordered collections (also known as linear arrays) where the (non-unique) elements are stored as *values* for sequential integer keys starting from 1
  - *sets*: unordered sets where the (unique) elements are stored as *keys* whose value is the boolean `true` (or another constant)
  - *dicts*: associative tables (also known as maps) where both keys and their values are arbitrary; they can have a list part as well
  - *trees*, tables with multiple levels of nesting

## Overview


* Module [`hm.types.coll`](hm.types.coll.md#module-hmtypescoll)
  * [`CtoNumberList(n,array)`](hm.types.coll.md#function-hmtypescollctonumberlistnarray---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist) - function
  * [`dict(table)`](hm.types.coll.md#function-hmtypescolldicttable---colldict) -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict) - function
  * [`list(table)`](hm.types.coll.md#function-hmtypescolllisttable---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist) - function
  * [`set(table)`](hm.types.coll.md#function-hmtypescollsettable---collset) -> [_`<#coll.set>`_](hm.types.coll.md#class-collset) - function


* Class [`coll.dict`](hm.types.coll.md#class-colldict)
  * [`byKeys(fn)`](hm.types.coll.md#method-colldictbykeysfn---function) -> _`<#function>`_ - method
  * [`byValues(fn)`](hm.types.coll.md#method-colldictbyvaluesfn---function) -> _`<#function>`_ - method
  * [`contains(element,maxDepth)`](hm.types.coll.md#method-colldictcontainselementmaxdepth---number-or-nil) -> _`<#number>`_ or _`nil`_ - method
  * [`copy(maxDepth)`](hm.types.coll.md#method-colldictcopymaxdepth---colldict) -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict) - method
  * [`every(fn)`](hm.types.coll.md#method-colldicteveryfn---boolean) -> _`<#boolean>`_ - method
  * [`everykv(fn)`](hm.types.coll.md#method-colldicteverykvfn---boolean) -> _`<#boolean>`_ - method
  * [`filter(fn)`](hm.types.coll.md#method-colldictfilterfn---colldict) -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict) - method
  * [`filterkv(fn)`](hm.types.coll.md#method-colldictfilterkvfn---colldict) -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict) - method
  * [`find(fn)`](hm.types.coll.md#method-colldictfindfn----or-nil) -> _`<#?>`_,_`<#?>`_ or _`nil`_ - method
  * [`findkv(fn)`](hm.types.coll.md#method-colldictfindkvfn----or-nil) -> _`<#?>`_,_`<#?>`_ or _`nil`_ - method
  * [`foreach(fn)`](hm.types.coll.md#method-colldictforeachfn) - method
  * [`foreachkv(fn)`](hm.types.coll.md#method-colldictforeachkvfn) - method
  * [`key(element)`](hm.types.coll.md#method-colldictkeyelement---) -> _`<?>`_ - method
  * [`keys()`](hm.types.coll.md#method-colldictkeys---functioncolldict) -> _`<#function>`_,[_`<#coll.dict>`_](hm.types.coll.md#class-colldict) - method
  * [`keysByValues(fn)`](hm.types.coll.md#method-colldictkeysbyvaluesfn---function) -> _`<#function>`_ - method
  * [`listKeys()`](hm.types.coll.md#method-colldictlistkeys---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist) - method
  * [`listValues()`](hm.types.coll.md#method-colldictlistvalues---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist) - method
  * [`map(fn)`](hm.types.coll.md#method-colldictmapfn---colldict) -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict) - method
  * [`mapkv(fn)`](hm.types.coll.md#method-colldictmapkvfn---colldict) -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict) - method
  * [`mapmerge(fn)`](hm.types.coll.md#method-colldictmapmergefn---colldict) -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict) - method
  * [`mapmergekv(fn)`](hm.types.coll.md#method-colldictmapmergekvfn---colldict) -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict) - method
  * [`merge(otherDict,inPlace)`](hm.types.coll.md#method-colldictmergeotherdictinplace---colldict) -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict) - method
  * [`pairs()`](hm.types.coll.md#method-colldictpairs) - method
  * [`reduce(fn,initialValue)`](hm.types.coll.md#method-colldictreducefninitialvalue---) -> _`<#?>`_,_`...`_ - method
  * [`remove(value)`](hm.types.coll.md#method-colldictremovevalue---colldict) -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict) - method
  * [`replace(otherDict)`](hm.types.coll.md#method-colldictreplaceotherdict---colldict) -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict) - method
  * [`toIndex()`](hm.types.coll.md#method-colldicttoindex---colldict) -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict) - method
  * [`values()`](hm.types.coll.md#method-colldictvalues---function) -> _`<#function>`_ - method
  * [`valuesByKeys(fn)`](hm.types.coll.md#method-colldictvaluesbykeysfn---function) -> _`<#function>`_ - method


* Class [`coll.list`](hm.types.coll.md#class-colllist)
  * [`append(value)`](hm.types.coll.md#method-colllistappendvalue---self) -> `self` - method
  * [`byValues(fn)`](hm.types.coll.md#method-colllistbyvaluesfn---function) -> _`<#function>`_ - method
  * [`compact(inPlace)`](hm.types.coll.md#method-colllistcompactinplace---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist) - method
  * [`concat(otherList,inPlace)`](hm.types.coll.md#method-colllistconcatotherlistinplace---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist) - method
  * [`dedupe(inPlace)`](hm.types.coll.md#method-colllistdedupeinplace---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist) - method
  * [`icopy()`](hm.types.coll.md#method-colllisticopy---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist) - method
  * [`ievery(fn)`](hm.types.coll.md#method-colllistieveryfn---boolean) -> _`<#boolean>`_ - method
  * [`ifilter(fn)`](hm.types.coll.md#method-colllistifilterfn---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist) - method
  * [`ifilterByField(fieldName,value,unequal)`](hm.types.coll.md#method-colllistifilterbyfieldfieldnamevalueunequal---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist) - method
  * [`ifind(fn)`](hm.types.coll.md#method-colllistifindfn---number-or-nil) -> _`<#?>`_,_`<#number>`_ or _`nil`_ - method
  * [`ifindByField(fieldName,value,unequal)`](hm.types.coll.md#method-colllistifindbyfieldfieldnamevalueunequal---number-or-nil) -> _`<#?>`_,_`<#number>`_ or _`nil`_ - method
  * [`ifindLast(fn)`](hm.types.coll.md#method-colllistifindlastfn---number-or-nil) -> _`<#?>`_,_`<#number>`_ or _`nil`_ - method
  * [`iforeach(fn)`](hm.types.coll.md#method-colllistiforeachfn) - method
  * [`imap(fn)`](hm.types.coll.md#method-colllistimapfn---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist) - method
  * [`imapToField(fieldName)`](hm.types.coll.md#method-colllistimaptofieldfieldname---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist) - method
  * [`imapcat(fn)`](hm.types.coll.md#method-colllistimapcatfn---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist) - method
  * [`imapkv(fn)`](hm.types.coll.md#method-colllistimapkvfn---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist) - method
  * [`index(element)`](hm.types.coll.md#method-colllistindexelement---number) -> _`<#number>`_ - method
  * [`insert(value,index)`](hm.types.coll.md#method-colllistinsertvalueindex---self) -> `self` - method
  * [`ipairs()`](hm.types.coll.md#method-colllistipairs---functioncolllist) -> _`<#function>`_,[_`<#coll.list>`_](hm.types.coll.md#class-colllist) - method
  * [`ireduce(fn,initialValue)`](hm.types.coll.md#method-colllistireducefninitialvalue---) -> _`<#?>`_,_`...`_ - method
  * [`iremove(element)`](hm.types.coll.md#method-colllistiremoveelement---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist) - method
  * [`keysByValues(fn)`](hm.types.coll.md#method-colllistkeysbyvaluesfn---function) -> _`<#function>`_ - method
  * [`lastIndex(element)`](hm.types.coll.md#method-colllistlastindexelement---number) -> _`<#number>`_ - method
  * [`replace(otherList)`](hm.types.coll.md#method-colllistreplaceotherlist---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist) - method
  * [`sort(fn,inPlace)`](hm.types.coll.md#method-colllistsortfninplace---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist) - method
  * [`sortByField(fieldName,inPlace,reverse)`](hm.types.coll.md#method-colllistsortbyfieldfieldnameinplacereverse---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist) - method
  * [`toDict(fn)`](hm.types.coll.md#method-colllisttodictfn---colldict) -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict) - method
  * [`toDictByField(fieldName)`](hm.types.coll.md#method-colllisttodictbyfieldfieldname---colldict) -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict) - method
  * [`toSet(value)`](hm.types.coll.md#method-colllisttosetvalue---collset) -> [_`<#coll.set>`_](hm.types.coll.md#class-collset) - method
  * [`tostring(separator)`](hm.types.coll.md#method-colllisttostringseparator---string) -> _`<#string>`_ - method
  * [`unpack()`](hm.types.coll.md#method-colllistunpack---) -> _`<?>`_ - method


* Class [`coll.set`](hm.types.coll.md#class-collset)
  * [`everyk(fn)`](hm.types.coll.md#method-collseteverykfn---boolean) -> _`<#boolean>`_ - method
  * [`filterk(fn)`](hm.types.coll.md#method-collsetfilterkfn---collset) -> [_`<#coll.set>`_](hm.types.coll.md#class-collset) - method
  * [`findk(fn)`](hm.types.coll.md#method-collsetfindkfn----or-nil) -> _`<#?>`_ or _`nil`_ - method
  * [`foreachk(fn)`](hm.types.coll.md#method-collsetforeachkfn) - method
  * [`mapk(fn)`](hm.types.coll.md#method-collsetmapkfn---collset) -> [_`<#coll.set>`_](hm.types.coll.md#class-collset) - method
  * [`merge(otherSet,inPlace)`](hm.types.coll.md#method-collsetmergeothersetinplace---collset) -> [_`<#coll.set>`_](hm.types.coll.md#class-collset) - method
  * [`toList()`](hm.types.coll.md#method-collsettolist---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist) - method


* Type [`dict`](hm.types.coll.md#type-dict)
  * [`tostringShowsKeys()`](hm.types.coll.md#method-dicttostringshowskeys---self) -> `self` - method
  * [`tostringShowsValues()`](hm.types.coll.md#method-dicttostringshowsvalues---self) -> `self` - method






------------------

## Module `hm.types.coll`






### Function `hm.types.coll.CtoNumberList(n,array)` -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Creates a list object from a C array of numbers

* `n`: _`<#number>`_ length of `array`
* `array`: _`<#cdata>`_ C array



* Returns [_`<#coll.list>`_](hm.types.coll.md#class-colllist): the new list




### Function `hm.types.coll.dict(table)` -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict)

Creates a dict object.

* `table`: _`<#table>`_ (optional) if omitted a new empty table will be created



* Returns [_`<#coll.dict>`_](hm.types.coll.md#class-colldict): the table, that will now accept the [_`<#coll.dict>`_](hm.types.coll.md#class-colldict) methods

You can also use the shortcut `coll(table)`.


### Function `hm.types.coll.list(table)` -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Creates a list object.

* `table`: _`<#table>`_ (optional) if omitted a new empty table will be created



* Returns [_`<#coll.list>`_](hm.types.coll.md#class-colllist): the table, that will now accept the [_`<#coll.list>`_](hm.types.coll.md#class-colllist) methods




### Function `hm.types.coll.set(table)` -> [_`<#coll.set>`_](hm.types.coll.md#class-collset)

Creates a set object.

* `table`: _`<#table>`_ (optional) if omitted a new empty table will be created



* Returns [_`<#coll.set>`_](hm.types.coll.md#class-collset): the table, that will now accept the [_`<#coll.set>`_](hm.types.coll.md#class-collset) methods






------------------

## Class `coll.dict`

An associative table (also known as dictionary) where both keys and their values are arbitrary; it can have a list part as well




### Method `<#coll.dict>:byKeys(fn)` -> _`<#function>`_

Returns an iterator that returns `key,value` at every iteration, sorted by keys.

* `fn`: _`<#function>`_ (optional) a comparator function to determine the sorting order;
if omitted, uses `<`; if `true`, uses `>`



* Returns _`<#function>`_: an iterator function meant for "for" loops: `for k,v in my_coll:byKeys() do...`




### Method `<#coll.dict>:byValues(fn)` -> _`<#function>`_

Returns an iterator that returns `value,key` at every iteration, sorted by values.

* `fn`: _`<#function>`_ (optional) a comparator function to determine the sorting order;
if omitted, uses `<`; if `true`, uses `>`



* Returns _`<#function>`_: an iterator function meant for "for" loops: `for v,k in my_coll:byValues() do...`




### Method `<#coll.dict>:contains(element,maxDepth)` -> _`<#number>`_ or _`nil`_

Determines if a dict or tree contains a given object.

* `element`: _`<?>`_ a value or object to search the collection for
* `maxDepth`: _`<#number>`_ (optional) on a tree, look for the element until this nesting level is reached; if omitted, defaults to 1



* Returns _`<#number>`_: the nesting level where the element was found
* Returns _`nil`_: if not found

This function does *not* handle cycles; use the `maxDepth` parameter with care.
When maxDepth>1, the tree is traversed depth-first.


### Method `<#coll.dict>:copy(maxDepth)` -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict)

Returns a copy of the collection.

* `maxDepth`: _`<#number>`_ (optional) on a tree, create a copy of every node until this nesting level is reached; if omitted, defaults
to 1; if 0, returns the input table (no copy will be performed)



* Returns [_`<#coll.dict>`_](hm.types.coll.md#class-colldict): a new collection containing the same data as this collection

This function does *not* handle cycles; use the `maxDepth` parameter with care.


### Method `<#coll.dict>:every(fn)` -> _`<#boolean>`_

Checks if a predicate function is satisfied by every element of a dict.

* `fn`: _`<#function>`_ a function that accepts two parameters, a table value and its key, and returns a boolean



* Returns _`<#boolean>`_: `true` if `fn(value,key)` returns `true` for every element; `false` otherwise




### Method `<#coll.dict>:everykv(fn)` -> _`<#boolean>`_

Checks if a predicate function is satisfied by every element of a dict.

* `fn`: _`<#function>`_ a function that accepts two parameters, a table key and its value, and returns a boolean



* Returns _`<#boolean>`_: `true` if `fn(key,value)` returns `true` for every element; `false` otherwise




### Method `<#coll.dict>:filter(fn)` -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict)

Filters a dict by running a predicate function on its elements, in arbitrary order.

* `fn`: _`<#function>`_ a function that accepts two parameters, a dict value and its key, and returns a boolean
value: `true` if the element should be kept, `false` if it should be discarded



* Returns [_`<#coll.dict>`_](hm.types.coll.md#class-colldict): a dict containing the elements for which `fn(value,key)` returns true




### Method `<#coll.dict>:filterkv(fn)` -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict)

Filters a dict by running a predicate function on its elements, in arbitrary order.

* `fn`: _`<#function>`_ a function that accepts two parameters, a dict key and its value, and returns a boolean
value: `true` if the element should be kept, `false` if it should be discarded



* Returns [_`<#coll.dict>`_](hm.types.coll.md#class-colldict): a dict containing the elements for which `fn(value,key)` returns true




### Method `<#coll.dict>:find(fn)` -> _`<#?>`_,_`<#?>`_ or _`nil`_

Executes a predicate function across a dict, in arbitrary order, and returns the first element where that function returns true.

* `fn`: _`<#function>`_ a function that accepts two parameters, a dict value and its index, and returns a boolean



* Returns _`<#?>`_,_`<#?>`_: the first value of this dict that caused `fn(value,key)` to return `true`, and its key
* Returns _`nil`_: if not found




### Method `<#coll.dict>:findkv(fn)` -> _`<#?>`_,_`<#?>`_ or _`nil`_

Executes a predicate function across a dict, in arbitrary order, and returns the first element where that function returns true.

* `fn`: _`<#function>`_ a function that accepts two parameters, a dict key and its value, and returns a boolean



* Returns _`<#?>`_,_`<#?>`_: the first key of this dict that caused `fn(key,value)` to return `true`, and its value
* Returns _`nil`_: if not found




### Method `<#coll.dict>:foreach(fn)`

Executes a function with side effects across a dict, in arbitrary order, discarding any results.

* `fn`: _`<#function>`_ a function that accepts two parameters, a dict value and its key




### Method `<#coll.dict>:foreachkv(fn)`

Executes a function with side effects across a dict, in arbitrary order, discarding any results.

* `fn`: _`<#function>`_ a function that accepts two parameters, a dict key and its value




### Method `<#coll.dict>:key(element)` -> _`<?>`_

Finds the key of a given element in a dict.

* `element`: _`<?>`_ an object or value to search the table for



* Returns _`<?>`_: the first key in the dict (in arbitrary order) whose associated value is `element`; `nil` if the element is not found

The table is traversed via `pairs` in arbitrary order; if `element` is associated to multiple keys
in the table, the first key found will be returned; subsequent calls to this method from the same
table *might* return a different key.


### Method `<#coll.dict>:keys()` -> _`<#function>`_,[_`<#coll.dict>`_](hm.types.coll.md#class-colldict)

Returns an iterator that returns `key,value` at every iteration, in arbitrary order.



* Returns _`<#function>`_,[_`<#coll.dict>`_](hm.types.coll.md#class-colldict): an iterator function and this collection, meant for "for" loops: `for k,v in my_coll:keys() do...`




### Method `<#coll.dict>:keysByValues(fn)` -> _`<#function>`_

Returns an iterator that returns `key,value` at every iteration, sorted by values.

* `fn`: _`<#function>`_ (optional) a comparator function to determine the sorting order;
if omitted, uses `<`; if `true`, uses `>`



* Returns _`<#function>`_: an iterator function meant for "for" loops: `for k,v in my_coll:keysByValues() do...`




### Method `<#coll.dict>:listKeys()` -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Creates a list of the keys in this dict.



* Returns [_`<#coll.list>`_](hm.types.coll.md#class-colllist): 

This method returns a list containing the all the *keys* in this collection in arbitrary order.


### Method `<#coll.dict>:listValues()` -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Creates a list of the values in this dict.



* Returns [_`<#coll.list>`_](hm.types.coll.md#class-colllist): 

This method returns a list containing the all the *values* in this collection in arbitrary order.


### Method `<#coll.dict>:map(fn)` -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict)

Executes a function across a dict (in arbitrary order) and collects the results.

* `fn`: _`<#function>`_ a function that accepts two parameters, a dict value and its key, and returns
a new value for the element and, optionally, a new key. The key/value pair returned from
this function will be added to the result dict.



* Returns [_`<#coll.dict>`_](hm.types.coll.md#class-colldict): a dict containing the results of calling the function on every element in this dict

Notes:
* if `fn` doesn't return keys, the transformed values returned by it will be assigned to their respective original keys
* if `fn` *does* return keys, and they are not unique, the previous element with the same key will be overwritten;
  keep in mind that the iteration order, and therefore which value will ultimately be associated to a
  conflicted key, is arbitrary
* if `fn` returns `nil`, the respective key in the result dict will be absent


### Method `<#coll.dict>:mapkv(fn)` -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict)

Executes a function across a dict (in arbitrary order) and collects the results.

* `fn`: _`<#function>`_ a function that accepts two parameters, a dict key and its value, and returns
a new key and a new value. The key/value pair returned from this function will be added to the result dict.



* Returns [_`<#coll.dict>`_](hm.types.coll.md#class-colldict): a dict containing the results of calling the function on every element in this dict




### Method `<#coll.dict>:mapmerge(fn)` -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict)

Executes, in arbitrary order across a dict, a function that returns dicts, and merges all of those dicts together.

* `fn`: _`<#function>`_ a function that accepts two parameters, a dict value and its key, and returns a dict



* Returns [_`<#coll.dict>`_](hm.types.coll.md#class-colldict): a dict containing the merged results of calling `fn(value,key)` for every element in this dict

Exercise caution if the tables returned by `fn` can contain the same keys: see the caveat in [`coll.dict.merge`](hm.types.coll.md#method-colldictmergeotherdictinplace---colldict).


### Method `<#coll.dict>:mapmergekv(fn)` -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict)

Executes, in arbitrary order across a dict, a function that returns dicts, and merges all of those dicts together.

* `fn`: _`<#function>`_ a function that accepts two parameters, a dict key and its value, and returns a dict



* Returns [_`<#coll.dict>`_](hm.types.coll.md#class-colldict): a dict containing the merged results of calling `fn(key,value)` for every element in this dict

Exercise caution if the tables returned by `fn` can contain the same keys: see the caveat in [`coll.dict.merge`](hm.types.coll.md#method-colldictmergeotherdictinplace---colldict).


### Method `<#coll.dict>:merge(otherDict,inPlace)` -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict)

Merges elements from two dicts into one.

* `otherDict`: [_`<#coll.dict>`_](hm.types.coll.md#class-colldict) a dict
* `inPlace`: _`<#boolean>`_ (optional) if `true`, this dict will be modified in-place, merging all the elements from `otherDict`,
and returned; otherwise a new dict will be created and returned



* Returns [_`<#coll.dict>`_](hm.types.coll.md#class-colldict): a dict containing both the key/value pairs in this dict and those in `otherDict`

If `otherDict` has keys that are also present in this dict, the corresponding key/value pairs from this dict
will be *overwritten* in the result dict; *this is also true for the list parts of the tables*, if present.


### Method `<#coll.dict>:pairs()`

Alias for `:keys()`




### Method `<#coll.dict>:reduce(fn,initialValue)` -> _`<#?>`_,_`...`_

Reduces a dict to a value (or tuple), using a function.

* `fn`: _`<#function>`_ a function that takes three or more parameters:
  * the result(s) emitted from the previous iteration, or `initialValue`(s) for the first iteration
  * an element value from this dict, in arbitrary order
  * the element key
* `initialValue`: _`<?>`_ (optional) the value(s) to pass to `fn` for the first iteration; if omitted, `fn` will
be passed `value1,value2,key2` (then `result,value3,key3` on the second iteration, and so on)



* Returns _`<#?>`_,_`...`_: the result(s) emitted by `fn` after the last iteration

`fn` can simply return one of the two values passed (e.g. a custom "max" function) or calculate a wholly new
value from them (e.g. a custom "sum" function).


### Method `<#coll.dict>:remove(value)` -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict)

Removes all occurrences of a given value from this dict.

* `value`: _`<?>`_ the value to remove



* Returns [_`<#coll.dict>`_](hm.types.coll.md#class-colldict): this dict with the given element removed




### Method `<#coll.dict>:replace(otherDict)` -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict)

Replace all the key value pairs in this dict with key value pairs from another dict

* `otherDict`: [_`<#coll.dict>`_](hm.types.coll.md#class-colldict) 



* Returns [_`<#coll.dict>`_](hm.types.coll.md#class-colldict): this dict




### Method `<#coll.dict>:toIndex()` -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict)

Creates a dict with keys and values swapped.



* Returns [_`<#coll.dict>`_](hm.types.coll.md#class-colldict): the resulting dict

Returns a dict where keys and values of this dict are swapped (i.e. an index table).
Any duplicates among the values in this dict will be discarded, as the keys in a Lua table are unique.


### Method `<#coll.dict>:values()` -> _`<#function>`_

Returns an iterator that returns `value,key` at every iteration, in arbitrary order.



* Returns _`<#function>`_: an iterator function meant for "for" loops: `for v,k in my_coll:values() do...`




### Method `<#coll.dict>:valuesByKeys(fn)` -> _`<#function>`_

Returns an iterator that returns `value,key` at every iteration, sorted by keys.

* `fn`: _`<#function>`_ (optional) a comparator function to determine the sorting order;
if omitted, uses `<`; if `true`, uses `>`



* Returns _`<#function>`_: an iterator function meant for "for" loops: `for v,k in my_coll:valuesByKeys() do...`






------------------

## Class `coll.list`

> Extends [_`<#coll.dict>`_](hm.types.coll.md#class-colldict)

An ordered collection (also known as linear array) where the (non-unique) elements are stored as *values* for sequential integer keys starting from 1.




### Method `<#coll.list>:append(value)` -> `self`

Appends an element at the end of this list.

* `value`: _`<?>`_ the new element



* Returns `self`: [_`<#coll.list>`_](hm.types.coll.md#class-colllist)




### Method `<#coll.list>:byValues(fn)` -> _`<#function>`_

Returns an iterator that returns `value,index` at every iteration, sorted by values.

* `fn`: _`<#function>`_ (optional) a comparator function to determine the sorting order;
if omitted, uses `<`; if `true`, uses `>`



* Returns _`<#function>`_: an iterator function meant for "for" loops: `for v,i in my_coll:byValues() do...`




### Method `<#coll.list>:compact(inPlace)` -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Removes holes in a list table.

* `inPlace`: _`<#boolean>`_ 



* Returns [_`<#coll.list>`_](hm.types.coll.md#class-colllist): the list with all the holes removed




### Method `<#coll.list>:concat(otherList,inPlace)` -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Concatenates two lists into one.

* `otherList`: [_`<#coll.list>`_](hm.types.coll.md#class-colllist) a list
* `inPlace`: _`<#boolean>`_ (optional) if `true`, this list will be modified in-place, appending all the elements from `otherList`,
and returned; otherwise a new list will be created and returned



* Returns [_`<#coll.list>`_](hm.types.coll.md#class-colllist): a list with all the elements from this list followed by all the elements from `otherList`




### Method `<#coll.list>:dedupe(inPlace)` -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Removes duplicates from a list

* `inPlace`: _`<#boolean>`_ (optional) if `true` modifies and returns this list



* Returns [_`<#coll.list>`_](hm.types.coll.md#class-colllist): a list without duplicate elements




### Method `<#coll.list>:icopy()` -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Returns a copy of this list.



* Returns [_`<#coll.list>`_](hm.types.coll.md#class-colllist): a new list containing the same elements as this collection




### Method `<#coll.list>:ievery(fn)` -> _`<#boolean>`_

Checks if a predicate function is satisfied by every element of a list.

* `fn`: _`<#function>`_ a function that accepts two parameters, a list value and its index, and returns a boolean



* Returns _`<#boolean>`_: `true` if `fn(value,index)` returns `true` for every element; `false` otherwise




### Method `<#coll.list>:ifilter(fn)` -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Filters a list by running a predicate function on its elements in order.

* `fn`: _`<#function>`_ a function that accepts two parameters, a list element and its index, and returns a boolean
value: `true` if the element should be kept, `false` if it should be discarded



* Returns [_`<#coll.list>`_](hm.types.coll.md#class-colllist): a list containing the elements for which `fn(element,index)` returns true




### Method `<#coll.list>:ifilterByField(fieldName,value,unequal)` -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Filters a list by an elements' field.

* `fieldName`: _`<#string>`_ the elements' field to use for filtering
* `value`: _`<?>`_ if the element's `fieldName` doesn't have this value the element will be discarded
* `unequal`: _`<#boolean>`_ (optional) if `true`, `fieldName` must be *not* equal to `value` to allow the element



* Returns [_`<#coll.list>`_](hm.types.coll.md#class-colllist): the resulting filtered list

Returns a new list containing only the elements whose `fieldName` equals (or if `unequal`
is not equal to) `value`


### Method `<#coll.list>:ifind(fn)` -> _`<#?>`_,_`<#number>`_ or _`nil`_

Executes a predicate function across a list, in order, and returns the first element where that function returns true.

* `fn`: _`<#function>`_ a function that accepts two parameters, a list element and its index, and returns a boolean



* Returns _`<#?>`_,_`<#number>`_: the first element of this list that caused `fn(value,index)` to return `true`, and its index
* Returns _`nil`_: if not found




### Method `<#coll.list>:ifindByField(fieldName,value,unequal)` -> _`<#?>`_,_`<#number>`_ or _`nil`_

Returns the first element in this list whose field is equal to a given value.

* `fieldName`: _`<#string>`_ the elements' field to use for filtering
* `value`: _`<?>`_ the desired value
* `unequal`: _`<#boolean>`_ (optional) if `true`, `fieldName` must be *not* equal to `value` to be a match



* Returns _`<#?>`_,_`<#number>`_: the first element of this list that caused `fn(value,index)` to return `true`, and its index
* Returns _`nil`_: if not found




### Method `<#coll.list>:ifindLast(fn)` -> _`<#?>`_,_`<#number>`_ or _`nil`_

Executes a predicate function across a list, in reverse order, and returns the first element where that function returns true.

* `fn`: _`<#function>`_ a function that accepts two parameters, a list element and its index, and returns a boolean



* Returns _`<#?>`_,_`<#number>`_: the highest-index element of this list that caused `fn(value,index)` to return `true`, and its index
* Returns _`nil`_: if not found




### Method `<#coll.list>:iforeach(fn)`

Executes a function with side effects across a list in order, discarding any results.

* `fn`: _`<#function>`_ a function that accepts two parameters, a list element and its index




### Method `<#coll.list>:imap(fn)` -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Executes a function across a list in order, and collects the results.

* `fn`: _`<#function>`_ a function that accepts a list element and returns a value.
The values returned from this function will be collected, in order, into the result list; when `nil` is
returned the relevant element is discarded - the result list will *not* have "holes".



* Returns [_`<#coll.list>`_](hm.types.coll.md#class-colllist): a list containing the results of calling the function on every element in this list

If this table has "holes", all elements after the first hole will be lost, as the table is iterated over with `ipairs`;
you can use `hs.func:dict()` if necessary.


### Method `<#coll.list>:imapToField(fieldName)` -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Creates a list by collecting a field from each element in this list.

* `fieldName`: _`<#string>`_ the name of the field to collect



* Returns [_`<#coll.list>`_](hm.types.coll.md#class-colllist): a list containing `fieldName` for each of the elements in this list




### Method `<#coll.list>:imapcat(fn)` -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Executes, in order across a list, a function that returns lists, and concatenates all of those lists together.

* `fn`: _`<#function>`_ a function that accepts two parameters, a list element and its index, and returns a list



* Returns [_`<#coll.list>`_](hm.types.coll.md#class-colllist): a list containing the concatenated results of calling `fn(element,index)` for every element in this list




### Method `<#coll.list>:imapkv(fn)` -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Executes a function across a list in order, and collects the results.

* `fn`: _`<#function>`_ a function that accepts two parameters, a list index and its element, and returns a value.
The values returned from this function will be collected, in order, into the result list; when `nil` is
returned the relevant element is discarded - the result list will *not* have "holes".



* Returns [_`<#coll.list>`_](hm.types.coll.md#class-colllist): a list containing the results of calling the function on every element in this list

If this table has "holes", all elements after the first hole will be lost, as the table is iterated over with `ipairs`;
you can use `hs.func:dict()` if necessary.


### Method `<#coll.list>:index(element)` -> _`<#number>`_

Finds the index of a given element in a list.

* `element`: _`<?>`_ an object or value to search the list for



* Returns _`<#number>`_: a positive integer, the index of the first occurence of `element` in the list; `nil` if the element is not found

The table is traversed via `ipairs` in order; if `element` is associated to multiple indices
in the list, this funciton will always return the lowest one.


### Method `<#coll.list>:insert(value,index)` -> `self`

Inserts an element to this list.

* `value`: _`<?>`_ the new element
* `index`: _`<#number>`_ (optional) the index for the new element; if omitted, `value` is appended at the end of this list



* Returns `self`: [_`<#coll.list>`_](hm.types.coll.md#class-colllist)




### Method `<#coll.list>:ipairs()` -> _`<#function>`_,[_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Returns a list iterator that returns `key,value` at every iteration, in order.



* Returns _`<#function>`_,[_`<#coll.list>`_](hm.types.coll.md#class-colllist): an iterator function and this list, meant for "for" loops: `for i,v in my_coll:ipairs() do...`




### Method `<#coll.list>:ireduce(fn,initialValue)` -> _`<#?>`_,_`...`_

Reduces a list to a value (or tuple), using a function.

* `fn`: _`<#function>`_ A function that takes three or more parameters:
  * the result(s) emitted from the previous iteration, or `initialValue`(s) for the first iteration
  * an element from this list, iterating in order
  * the element index
* `initialValue`: _`<?>`_ (optional) the value(s) to pass to `fn` for the first iteration; if omitted, `fn` will
be passed `elem1,elem2,2` (then `result,elem3,3` on the second iteration, and so on)



* Returns _`<#?>`_,_`...`_: the result emitted by `fn` after the last iteration

`fn` can simply return one of the two elements passed (e.g. a "max" function) or calculate a wholly new
value from them (e.g. a "sum" function).


### Method `<#coll.list>:iremove(element)` -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Removes all occurrences of a given element from this list.

* `element`: _`<?>`_ the element to remove



* Returns [_`<#coll.list>`_](hm.types.coll.md#class-colllist): this list with the given element removed

This method will not create holes in the list.


### Method `<#coll.list>:keysByValues(fn)` -> _`<#function>`_

Returns an iterator that returns `index,value` at every iteration, sorted by values.

* `fn`: _`<#function>`_ (optional) a comparator function to determine the sorting order;
if omitted, uses `<`; if `true`, uses `>`



* Returns _`<#function>`_: an iterator function meant for "for" loops: `for i,v in my_coll:keysByValues() do...`




### Method `<#coll.list>:lastIndex(element)` -> _`<#number>`_

Finds the index of a given element in a list.

* `element`: _`<?>`_ an object or value to search the list for



* Returns _`<#number>`_: a positive integer, the index of the last occurence of `element` in the list; `nil` if the element is not found

The table is traversed in *reverse* order; if `element` is associated to multiple indices
in the list, this funciton will always return the highest one.


### Method `<#coll.list>:replace(otherList)` -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Replace all the elements in this list with elements from another list

* `otherList`: [_`<#coll.list>`_](hm.types.coll.md#class-colllist) 



* Returns [_`<#coll.list>`_](hm.types.coll.md#class-colllist): this list, with all elements replaced




### Method `<#coll.list>:sort(fn,inPlace)` -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Returns a sorted copy of this list.

* `fn`: _`<#function>`_ (optional) a function that accepts two list elements, and returns `true` if the first should come
-    before the second in the sorted return list; if `nil`, the `<` (less than) operator is used
* `inPlace`: _`<#boolean>`_ (optional) if `true` modifies and returns this list



* Returns [_`<#coll.list>`_](hm.types.coll.md#class-colllist): a list with the same elements of this list, sorted according to `fn`

Unlike `table.sort`, this method can return a new list (in other words, the original list can be left untouched).


### Method `<#coll.list>:sortByField(fieldName,inPlace,reverse)` -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Returns a sorted copy of this list.

* `fieldName`: _`<#string>`_ The elements' field to use as sorting key; the `<` (less than) operator is used as comparator
* `inPlace`: _`<#boolean>`_ (optional) if `true` modifies and returns this list
* `reverse`: _`<#boolean>`_ (optional) if `true`, the `>` operator is used instead



* Returns [_`<#coll.list>`_](hm.types.coll.md#class-colllist): a list with the same elements of this list, sorted by `fieldName`




### Method `<#coll.list>:toDict(fn)` -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict)

Creates a dict from a list.

* `fn`: _`<#function>`_ a function that accepts a list element and returns a key for it



* Returns [_`<#coll.dict>`_](hm.types.coll.md#class-colldict): the resulting dict

Returns a dict where the values are this list's values, and each key is determined
by a given function on each element.


### Method `<#coll.list>:toDictByField(fieldName)` -> [_`<#coll.dict>`_](hm.types.coll.md#class-colldict)

Creates a dict from a list, using a field of each element for its key.

* `fieldName`: _`<#string>`_ the name of the field to use as each element's key



* Returns [_`<#coll.dict>`_](hm.types.coll.md#class-colldict): the resulting dict

Returns a dict where the values are this list's values, and each key is a given field
of each element.


### Method `<#coll.list>:toSet(value)` -> [_`<#coll.set>`_](hm.types.coll.md#class-collset)

Creates a set from a list.

* `value`: _`<?>`_ the constant value to assign to every key in the result table; if omitted, defaults to `true`



* Returns [_`<#coll.set>`_](hm.types.coll.md#class-collset): the resulting set

Returns a set whose keys are all the (unique) elements from this list.
Any duplicates among the elements in this list will be discarded, as the keys in a Lua table are unique.


### Method `<#coll.list>:tostring(separator)` -> _`<#string>`_

Returns a string representation of this list.

* `separator`: _`<#string>`_ (optional) if omitted defaults to `","`



* Returns _`<#string>`_: 




### Method `<#coll.list>:unpack()` -> _`<?>`_

Unpacks the elements in this list.



* Returns _`<?>`_: ?,... all the elements in this list






------------------

## Class `coll.set`

> Extends [_`<#coll.dict>`_](hm.types.coll.md#class-colldict)

An unordered set where the (unique) elements are stored as *keys* whose value is the boolean `true` (or another constant)




### Method `<#coll.set>:everyk(fn)` -> _`<#boolean>`_

Checks if a predicate function is satisfied by every key of a set

* `fn`: _`<#function>`_ a function that accepts a set key and returns a boolean



* Returns _`<#boolean>`_: `true` if `fn(key)` returns `true` for every element; `false` otherwise




### Method `<#coll.set>:filterk(fn)` -> [_`<#coll.set>`_](hm.types.coll.md#class-collset)

Filters a set by running a predicate function on its elements, in arbitrary order.

* `fn`: _`<#function>`_ a function that accepts a key and returns a boolean
value: `true` if the key should be kept, `false` if it should be discarded



* Returns [_`<#coll.set>`_](hm.types.coll.md#class-collset): a set containing the keys for which `fn(key)` returns true




### Method `<#coll.set>:findk(fn)` -> _`<#?>`_ or _`nil`_

Executes a predicate function across a set and returns the first key where that function returns true.

* `fn`: _`<#function>`_ a function that accepts a set key and returns a boolean



* Returns _`<#?>`_: the first key of this set that caused `fn(key)` to return `true`
* Returns _`nil`_: if not found




### Method `<#coll.set>:foreachk(fn)`

Executes a function with side effects across a set, in arbitrary order, discarding any results.

* `fn`: _`<#function>`_ a function that accepts a set key




### Method `<#coll.set>:mapk(fn)` -> [_`<#coll.set>`_](hm.types.coll.md#class-collset)

Executes a function across a set (in arbitrary order) and collects the results.

* `fn`: _`<#function>`_ a function that a key and returns a new key, that will be added to the result set



* Returns [_`<#coll.set>`_](hm.types.coll.md#class-collset): a set containing the results of calling the function on every key in this set

Notes:
* the keys returned by `fn` may be not unique, but a set doesn't allow duplicates


### Method `<#coll.set>:merge(otherSet,inPlace)` -> [_`<#coll.set>`_](hm.types.coll.md#class-collset)

Merges elements from two sets into one.

* `otherSet`: [_`<#coll.set>`_](hm.types.coll.md#class-collset) a dict
* `inPlace`: _`<#boolean>`_ (optional) if `true`, this set will be modified in-place



* Returns [_`<#coll.set>`_](hm.types.coll.md#class-collset): a set containing both the keys in this set and those in `otherSet`




### Method `<#coll.set>:toList()` -> [_`<#coll.list>`_](hm.types.coll.md#class-colllist)

Creates a list from a set.



* Returns [_`<#coll.list>`_](hm.types.coll.md#class-colllist): the resulting list

Returns a list containing the all the *keys* in this set in arbitrary order.




------------------

### Type `dict`






### Method `<#dict>:tostringShowsKeys()` -> `self`

Sets `tostring` of this dict to only print keys.



* Returns `self`: [_`<#dict>`_](hm.types.coll.md#type-dict)




### Method `<#dict>:tostringShowsValues()` -> `self`

Sets `tostring` of this dict to only print values.



* Returns `self`: [_`<#dict>`_](hm.types.coll.md#type-dict)





