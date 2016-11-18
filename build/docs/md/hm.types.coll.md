# Module `hm.types.coll`

Some utilities for collections in Lua tables.

You can call the methods in this module as functions on "plain" tables, via the syntax
`new_table=coll.filter(coll.map(my_table, map_fn),filter_fn)`.
Alternatively, you can use the `new` constructor and then call methods directly on the table, like this:
`new_table=coll.new(my_table):map(map_fn):filter(filter_fn)`.
All tables or lists returned by coll methods, unless otherwise noted, will accept further coll methods.

The methods in this module can be used on these types of collections:
  - *lists*: ordered collections (also known as linear arrays) where the (non-unique) elements are stored as *values* for sequential integer keys starting from 1
  - *sets*: unordered sets where the (unique) elements are stored as *keys* whose value is the boolean `true` (or another constant)
  - *maps*: associative tables (also known as dictionaries) where both keys and their values are arbitrary; they can have a list part as well
  - *trees*, tables with multiple levels of nesting

## Overview


| Module [hm.types.coll](hm.types.coll.md#module-hmtypescoll) |  |
| :--- | :---
Method [`hm.types.coll:flatten()`](hm.types.coll.md#method-hmtypescollflatten) | 
Function [`hm.types.coll.new(table)`](hm.types.coll.md#function-hmtypescollnewtable---coll) -> [_`<#coll>`_](hm.types.coll.md#type-coll) | Creates a collection object.


| Type [<#coll>](hm.types.coll.md#type-coll) | Base type for collection objects |
| :--- | :---
Method [`<#coll>:byKeys(fn)`](hm.types.coll.md#method-collbykeysfn---function) -> _`<#function>`_ | Returns an iterator that returns `key,value` at every iteration, sorted by keys.
Method [`<#coll>:byValues(fn)`](hm.types.coll.md#method-collbyvaluesfn---function) -> _`<#function>`_ | Returns an iterator that returns `value,key` at every iteration, sorted by values.
Method [`<#coll>:concat(otherList,inPlace)`](hm.types.coll.md#method-collconcatotherlistinplace---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll) | Concatenates two lists into one.
Method [`<#coll>:contains(element,maxDepth)`](hm.types.coll.md#method-collcontainselementmaxdepth---booleannumber) -> _`<#boolean>`_,_`<#number>`_ | Determines if a list, map or tree contains a given object.
Method [`<#coll>:copy(maxDepth)`](hm.types.coll.md#method-collcopymaxdepth---coll) -> [_`<#coll>`_](hm.types.coll.md#type-coll) | Returns a copy of the collection.
Method [`<#coll>:each(fn)`](hm.types.coll.md#method-colleachfn) | Executes a function with side effects across a map, in arbitrary order, discarding any results.
Method [`<#coll>:every(fn)`](hm.types.coll.md#method-colleveryfn---boolean) -> _`<#boolean>`_ | Checks if a predicate function is satisfied by every element of a collection.
Method [`<#coll>:filter(fn)`](hm.types.coll.md#method-collfilterfn---collmap) -> [_`<#coll.map>`_](hm.types.coll.md#type-collmap-extends-coll) | Filters a map by running a predicate function on its elements, in arbitrary order.
Method [`<#coll>:find(fn)`](hm.types.coll.md#method-collfindfn---number-or-nil) -> _`<#?>`_,_`<#number>`_ or _`nil`_ | Executes a predicate function across a map, in arbitrary order, and returns the first element where that function returns true.
Method [`<#coll>:flatten()`](hm.types.coll.md#method-collflatten---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll) | Creates a list from a map or from a list with holes.
Method [`<#coll>:ieach(fn)`](hm.types.coll.md#method-collieachfn) | Executes a function with side effects across a list in order, discarding any results.
Method [`<#coll>:ifilter(fn)`](hm.types.coll.md#method-collifilterfn---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll) | Filters a list by running a predicate function on its elements in order.
Method [`<#coll>:ifind(fn)`](hm.types.coll.md#method-collifindfn---number-or-nil) -> _`<#?>`_,_`<#number>`_ or _`nil`_ | Executes a predicate function across a list, in order, and returns the first element where that function returns true.
Method [`<#coll>:ifindLast(fn)`](hm.types.coll.md#method-collifindlastfn---number-or-nil) -> _`<#?>`_,_`<#number>`_ or _`nil`_ | Executes a predicate function across a list, in reverse order, and returns the first element where that function returns true.
Method [`<#coll>:imap(fn)`](hm.types.coll.md#method-collimapfn---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll) | Executes a function across a list in order, and collects the results.
Method [`<#coll>:index(element)`](hm.types.coll.md#method-collindexelement---number) -> _`<#number>`_ | Finds the index of a given element in a list.
Method [`<#coll>:insert(element,key)`](hm.types.coll.md#method-collinsertelementkey---coll) -> [_`<#coll>`_](hm.types.coll.md#type-coll) | Inserts an element into a collection.
Method [`<#coll>:ipairs()`](hm.types.coll.md#method-collipairs---functioncoll) -> _`<#function>`_,[_`<#coll>`_](hm.types.coll.md#type-coll) | Returns a list iterator that returns `key,value` at every iteration, in order.
Method [`<#coll>:ireduce(fn,initialValue)`](hm.types.coll.md#method-collireducefninitialvalue---) -> _`<#?>`_,_`...`_ | Reduces a list to a value (or tuple), using a function.
Method [`<#coll>:iremove(element)`](hm.types.coll.md#method-colliremoveelement---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll) | Removes the highest-index given element from this list.
Method [`<#coll>:key(element)`](hm.types.coll.md#method-collkeyelement---) -> _`<?>`_ | Finds the key of a given element in a map.
Method [`<#coll>:keys()`](hm.types.coll.md#method-collkeys---functioncoll) -> _`<#function>`_,[_`<#coll>`_](hm.types.coll.md#type-coll) | Returns an iterator that returns `key,value` at every iteration, in arbitrary order.
Method [`<#coll>:keysByValues(fn)`](hm.types.coll.md#method-collkeysbyvaluesfn---function) -> _`<#function>`_ | Returns an iterator that returns `key,value` at every iteration, sorted by values.
Method [`<#coll>:lastIndex(element)`](hm.types.coll.md#method-colllastindexelement---number) -> _`<#number>`_ | Finds the index of a given element in a list.
Method [`<#coll>:map(fn)`](hm.types.coll.md#method-collmapfn---collmap) -> [_`<#coll.map>`_](hm.types.coll.md#type-collmap-extends-coll) | Executes a function across a map (in arbitrary order) and collects the results.
Method [`<#coll>:mapcat(fn)`](hm.types.coll.md#method-collmapcatfn---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll) | Executes, in order across a list, a function that returns lists, and concatenates all of those lists together.
Method [`<#coll>:mapmerge(fn)`](hm.types.coll.md#method-collmapmergefn---collmap) -> [_`<#coll.map>`_](hm.types.coll.md#type-collmap-extends-coll) | Executes, in arbitrary order across a map, a function that returns maps, and merges all of those maps together.
Method [`<#coll>:merge(otherMap,inPlace)`](hm.types.coll.md#method-collmergeothermapinplace---collmap) -> [_`<#coll.map>`_](hm.types.coll.md#type-collmap-extends-coll) | Merges elements from two maps into one.
Function [`<#coll>.pairs()`](hm.types.coll.md#function-collpairs) | Alias for `:keys()`
Method [`<#coll>:reduce(fn,initialValue)`](hm.types.coll.md#method-collreducefninitialvalue---) -> _`<#?>`_,_`...`_ | Reduces a map to a value (or tuple), using a function.
Method [`<#coll>:remove(key)`](hm.types.coll.md#method-collremovekey---coll) -> [_`<#coll>`_](hm.types.coll.md#type-coll) | Removes the element associated with a given key or index from this collection.
Method [`<#coll>:removeElement(element)`](hm.types.coll.md#method-collremoveelementelement---coll) -> [_`<#coll>`_](hm.types.coll.md#type-coll) | Removes all occurrences of a given element from this collection.
Method [`<#coll>:setmetatable(mt)`](hm.types.coll.md#method-collsetmetatablemt---coll) -> [_`<#coll>`_](hm.types.coll.md#type-coll) | Sets a custom metatable on a hs.func collection
Method [`<#coll>:some(fn)`](hm.types.coll.md#method-collsomefn---boolean) -> _`<#boolean>`_ | Checks if a predicate function is satisfied by at least one element of a collection.
Method [`<#coll>:sort(fn,removeDuplicates)`](hm.types.coll.md#method-collsortfnremoveduplicates---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll) | Sorts a list.
Method [`<#coll>:toIndex()`](hm.types.coll.md#method-colltoindex---collmap) -> [_`<#coll.map>`_](hm.types.coll.md#type-collmap-extends-coll) | Creates an index table.
Method [`<#coll>:toList()`](hm.types.coll.md#method-colltolist---colllist) -> [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll) | Creates a list from a set (i.e.
Method [`<#coll>:toSet(value)`](hm.types.coll.md#method-colltosetvalue---collset) -> [_`<#coll.set>`_](hm.types.coll.md#type-collset-extends-coll) | Creates a set from a list.
Method [`<#coll>:values()`](hm.types.coll.md#method-collvalues---function) -> _`<#function>`_ | Returns an iterator that returns `value,key` at every iteration, in arbitrary order.
Method [`<#coll>:valuesByKeys(fn)`](hm.types.coll.md#method-collvaluesbykeysfn---function) -> _`<#function>`_ | Returns an iterator that returns `value,key` at every iteration, sorted by keys.


| Type [<#coll.list>](hm.types.coll.md#type-colllist-extends-coll) | An ordered collection (also known as linear array) where the (non-unique) elements are stored as *values* for sequential integer keys starting from 1. |
| :--- | :---


| Type [<#coll.map>](hm.types.coll.md#type-collmap-extends-coll) | An associative table (also known as dictionary) where both keys and their values are arbitrary; it can have a list part as well |
| :--- | :---


| Type [<#coll.set>](hm.types.coll.md#type-collset-extends-coll) | An unordered set where the (unique) elements are stored as *keys* whose value is the boolean `true` (or another constant) |
| :--- | :---






------------------

## Module `hm.types.coll`






### Method `hm.types.coll:flatten()`






### Function `hm.types.coll.new(table)` -> [_`<#coll>`_](hm.types.coll.md#type-coll)

Creates a collection object.

**Parameters:**

* _`<#table>`_ `table`: (optional) a Lua table holding a collection of elements, if omitted a new empty table will be created

**Returns:**

* [_`<#coll>`_](hm.types.coll.md#type-coll) the table, that will now accept the `coll` methods

You can also use the shortcut `coll(table)`.

If the table already has a metatable, the metatable for coll will be appended at the end of the `__index` chain, to ensure
that coll methods don't shadow your table object methods.
For the same reason, if you need to set the metatable to an already existing coll table, you can use
the `coll:setmetatable()` method, it will *insert* the new metatable at the top of the chain.




------------------

### Type `<#coll>`

Base type for collection objects




### Method `<#coll>:byKeys(fn)` -> _`<#function>`_

Returns an iterator that returns `key,value` at every iteration, sorted by keys.

**Parameters:**

* _`<#function>`_ `fn`: (optional) a comparator function to determine the sorting order

**Returns:**

* _`<#function>`_ an iterator function meant for "for" loops: `for k,v in my_coll:byKeys() do...`




### Method `<#coll>:byValues(fn)` -> _`<#function>`_

Returns an iterator that returns `value,key` at every iteration, sorted by values.

**Parameters:**

* _`<#function>`_ `fn`: (optional) a comparator function to determine the sorting order

**Returns:**

* _`<#function>`_ an iterator function meant for "for" loops: `for v,k in my_coll:byValues() do...`




### Method `<#coll>:concat(otherList,inPlace)` -> [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll)

Concatenates two lists into one.

**Parameters:**

* [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll) `otherList`: a list
* _`<#boolean>`_ `inPlace`: (optional) if `true`, this list will be modified in-place, appending all the elements from `otherList`,
and returned; otherwise a new list will be created and returned

**Returns:**

* [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll) a list with all the elements from this list followed by all the elements from `otherList`




### Method `<#coll>:contains(element,maxDepth)` -> _`<#boolean>`_,_`<#number>`_

Determines if a list, map or tree contains a given object.

**Parameters:**

* _`<?>`_ `element`: a value or object to search the collection for
* _`<#number>`_ `maxDepth`: (optional) on a tree, look for the element until this nesting level is reached; if omitted, defaults to 1

**Returns:**

* _`<#boolean>`_,_`<#number>`_ if the element could be found in the collection, `true, depth`, where depth is the nesting level
where the element was found; otherwise `false`

This function does *not* handle cycles; use the `maxDepth` parameter with care.

When maxDepth>1, the tree is traversed depth-first.


### Method `<#coll>:copy(maxDepth)` -> [_`<#coll>`_](hm.types.coll.md#type-coll)

Returns a copy of the collection.

**Parameters:**

* _`<#number>`_ `maxDepth`: (optional) on a tree, create a copy of every node until this nesting level is reached; if omitted, defaults
to 1; if 0, returns the input table (no copy will be performed)

**Returns:**

* [_`<#coll>`_](hm.types.coll.md#type-coll) a new collection containing the same data as this collection

This function does *not* handle cycles; use the `maxDepth` parameter with care.


### Method `<#coll>:each(fn)`

Executes a function with side effects across a map, in arbitrary order, discarding any results.

**Parameters:**

* _`<#function>`_ `fn`: a function that accepts two parameters, a map value and its key




### Method `<#coll>:every(fn)` -> _`<#boolean>`_

Checks if a predicate function is satisfied by every element of a collection.

**Parameters:**

* _`<#function>`_ `fn`: a function that accepts two parameters, a table value and its key, and returns a boolean

**Returns:**

* _`<#boolean>`_ `true` if `fn` returns `true` for every element; `false` otherwise




### Method `<#coll>:filter(fn)` -> [_`<#coll.map>`_](hm.types.coll.md#type-collmap-extends-coll)

Filters a map by running a predicate function on its elements, in arbitrary order.

**Parameters:**

* _`<#function>`_ `fn`: a function that accepts two parameters, a map value and its key, and returns a boolean
value: `true` if the element should be kept, `false` if it should be discarded

**Returns:**

* [_`<#coll.map>`_](hm.types.coll.md#type-collmap-extends-coll) a map containing the elements for which `fn(value,key)` returns true




### Method `<#coll>:find(fn)` -> _`<#?>`_,_`<#number>`_ or _`nil`_

Executes a predicate function across a map, in arbitrary order, and returns the first element where that function returns true.

**Parameters:**

* _`<#function>`_ `fn`: a function that accepts two parameters, a map value and its index, and returns a boolean

**Returns:**

* _`<#?>`_,_`<#number>`_ the first element of this map that caused `fn` to return `true`, and its key
* _`nil`_ if not found




### Method `<#coll>:flatten()` -> [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll)

Creates a list from a map or from a list with holes.

**Returns:**

* [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll) the resulting list

This method returns a list containing the all the *values* in this collection in arbitrary order
(you can sort it afterward if necessary); the keys are assumed to be uninteresting and discarded.
You can use this method to remove "holes" from lists; however the result list isn't guaranteed to be
in order.


### Method `<#coll>:ieach(fn)`

Executes a function with side effects across a list in order, discarding any results.

**Parameters:**

* _`<#function>`_ `fn`: a function that accepts two parameters, a list element and its index




### Method `<#coll>:ifilter(fn)` -> [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll)

Filters a list by running a predicate function on its elements in order.

**Parameters:**

* _`<#function>`_ `fn`: a function that accepts two parameters, a list element and its index, and returns a boolean
value: `true` if the element should be kept, `false` if it should be discarded

**Returns:**

* [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll) a list containing the elements for which `fn(element,index)` returns true




### Method `<#coll>:ifind(fn)` -> _`<#?>`_,_`<#number>`_ or _`nil`_

Executes a predicate function across a list, in order, and returns the first element where that function returns true.

**Parameters:**

* _`<#function>`_ `fn`: a function that accepts two parameters, a list element and its index, and returns a boolean

**Returns:**

* _`<#?>`_,_`<#number>`_ the first element of this list that caused `fn` to return `true`, and its index
* _`nil`_ if not found




### Method `<#coll>:ifindLast(fn)` -> _`<#?>`_,_`<#number>`_ or _`nil`_

Executes a predicate function across a list, in reverse order, and returns the first element where that function returns true.

**Parameters:**

* _`<#function>`_ `fn`: a function that accepts two parameters, a list element and its index, and returns a boolean

**Returns:**

* _`<#?>`_,_`<#number>`_ the highest-index element of this list that caused `fn` to return `true`, and its index
* _`nil`_ if not found




### Method `<#coll>:imap(fn)` -> [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll)

Executes a function across a list in order, and collects the results.

**Parameters:**

* _`<#function>`_ `fn`: a function that accepts two parameters, a list element and its index, and returns a value.
The values returned from this function will be collected, in order, into the result list; when `nil` is
returned the relevant element is discarded - the result list will *not* have "holes".

**Returns:**

* [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll) a list containing the results of calling the function on every element in this list

If this table has "holes", all elements after the first hole will be lost, as the table is iterated over with `ipairs`;
you can use `hs.func:map()` if necessary.


### Method `<#coll>:index(element)` -> _`<#number>`_

Finds the index of a given element in a list.

**Parameters:**

* _`<?>`_ `element`: an object or value to search the list for

**Returns:**

* _`<#number>`_ a positive integer, the index of the first occurence of `element` in the list; `nil` if the element is not found

The table is traversed via `ipairs` in order; if `element` is associated to multiple indices
in the list, this funciton will always return the lowest one.


### Method `<#coll>:insert(element,key)` -> [_`<#coll>`_](hm.types.coll.md#type-coll)

Inserts an element into a collection.

**Parameters:**

* _`<?>`_ `element`: the element to insert
* _`<?>`_ `key`: (optional) the key for the element:
  * if omitted, this is assumed to be a list, and `element` will be appended at the end
  * if a positive integer, this is assumed to be a list, and `element` will be inserted in that position; subsequent
    elements will be shifted up to make room
  * otherwise, this method simply executes `self[key]=element`

**Returns:**

* [_`<#coll>`_](hm.types.coll.md#type-coll) this collection, for method chaining




### Method `<#coll>:ipairs()` -> _`<#function>`_,[_`<#coll>`_](hm.types.coll.md#type-coll)

Returns a list iterator that returns `key,value` at every iteration, in order.

**Returns:**

* _`<#function>`_,[_`<#coll>`_](hm.types.coll.md#type-coll) an iterator function and this collection, meant for "for" loops: `for i,v in my_coll:ipairs() do...`




### Method `<#coll>:ireduce(fn,initialValue)` -> _`<#?>`_,_`...`_

Reduces a list to a value (or tuple), using a function.

**Parameters:**

* _`<#function>`_ `fn`: A function that takes three or more parameters:
  * the result(s) emitted from the previous iteration, or `initialValue`(s) for the first iteration
  * an element from this list, iterating in order
  * the element index
* _`<?>`_ `initialValue`: (optional) the value(s) to pass to `fn` for the first iteration; if omitted, `fn` will
be passed `elem1,elem2,2` (then `result,elem3,3` on the second iteration, and so on)

**Returns:**

* _`<#?>`_,_`...`_ the result emitted by `fn` after the last iteration

`fn` can simply return one of the two elements passed (e.g. a "max" function) or calculate a wholly new
value from them (e.g. a "sum" function).


### Method `<#coll>:iremove(element)` -> [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll)

Removes the highest-index given element from this list.

**Parameters:**

* _`<?>`_ `element`: the element to remove

**Returns:**

* [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll) this list, for method chaining

The list is traversed in reverse order.


### Method `<#coll>:key(element)` -> _`<?>`_

Finds the key of a given element in a map.

**Parameters:**

* _`<?>`_ `element`: an object or value to search the table for

**Returns:**

* _`<?>`_ the first key in the map (in arbitrary order) whose associated value is `element`; `nil` if the element is not found

The table is traversed via `pairs` in arbitrary order; if `element` is associated to multiple keys
in the table, the first key found will be returned; subsequent calls to this method from the same
table *might* return a different key.


### Method `<#coll>:keys()` -> _`<#function>`_,[_`<#coll>`_](hm.types.coll.md#type-coll)

Returns an iterator that returns `key,value` at every iteration, in arbitrary order.

**Returns:**

* _`<#function>`_,[_`<#coll>`_](hm.types.coll.md#type-coll) an iterator function and this collection, meant for "for" loops: `for k,v in my_coll:keys() do...`




### Method `<#coll>:keysByValues(fn)` -> _`<#function>`_

Returns an iterator that returns `key,value` at every iteration, sorted by values.

**Parameters:**

* _`<#function>`_ `fn`: (optional) a comparator function to determine the sorting order

**Returns:**

* _`<#function>`_ an iterator function meant for "for" loops: `for k,v in my_coll:keysByValues() do...`




### Method `<#coll>:lastIndex(element)` -> _`<#number>`_

Finds the index of a given element in a list.

**Parameters:**

* _`<?>`_ `element`: an object or value to search the list for

**Returns:**

* _`<#number>`_ a positive integer, the index of the last occurence of `element` in the list; `nil` if the element is not found

The table is traversed via `ipairs` in *reverse* order; if `element` is associated to multiple indices
in the list, this funciton will always return the highest one.


### Method `<#coll>:map(fn)` -> [_`<#coll.map>`_](hm.types.coll.md#type-collmap-extends-coll)

Executes a function across a map (in arbitrary order) and collects the results.

**Parameters:**

* _`<#function>`_ `fn`: a function that accepts two parameters, a map value and its key, and returns
a new value for the element and, optionally, a new key. The key/value pair returned from
this function will be added to the result map.

**Returns:**

* [_`<#coll.map>`_](hm.types.coll.md#type-collmap-extends-coll) a map containing the results of calling the function on every element in this map

Notes:
* if this table is a list (without holes) and you need guaranteed in-order processing you must use `hs.func:imap()`
* if `fn` doesn't return keys, the transformed values returned by it will be assigned to their respective original keys
* if `fn` *does* return keys, and they are not unique, the previous element with the same key will be overwritten;
  keep in mind that the iteration order, and therefore which value will ultimately be associated to a
  conflicted key, is arbitrary
* if `fn` returns `nil`, the respective key in the result map won't have any associated element


### Method `<#coll>:mapcat(fn)` -> [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll)

Executes, in order across a list, a function that returns lists, and concatenates all of those lists together.

**Parameters:**

* _`<#function>`_ `fn`: a function that accepts two parameters, a list element and its index, and returns a list

**Returns:**

* [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll) a list containing the concatenated results of calling `fn(element,index)` for every element in this list




### Method `<#coll>:mapmerge(fn)` -> [_`<#coll.map>`_](hm.types.coll.md#type-collmap-extends-coll)

Executes, in arbitrary order across a map, a function that returns maps, and merges all of those maps together.

**Parameters:**

* _`<#function>`_ `fn`: a function that accepts two parameters, a map value and its key, and returns a map

**Returns:**

* [_`<#coll.map>`_](hm.types.coll.md#type-collmap-extends-coll) a map containing the merged results of calling `fn(value,key)` for every element in this map

Exercise caution if the tables returned by `fn` can contain the same keys: see the caveat in [`coll.merge`](hm.types.coll.md#method-collmergeothermapinplace---collmap).


### Method `<#coll>:merge(otherMap,inPlace)` -> [_`<#coll.map>`_](hm.types.coll.md#type-collmap-extends-coll)

Merges elements from two maps into one.

**Parameters:**

* [_`<#coll.map>`_](hm.types.coll.md#type-collmap-extends-coll) `otherMap`: a map
* _`<#boolean>`_ `inPlace`: (optional) if `true`, this map will be modified in-place, merging all the elements from `otherMap`,
and returned; otherwise a new map will be created and returned

**Returns:**

* [_`<#coll.map>`_](hm.types.coll.md#type-collmap-extends-coll) a map containing both the key/value pairs in this map and those in `otherMap`

If `otherMap` has keys that are also present in this map, the corresponding key/value pairs from this map
will be *overwritten* in the result map; *this is also true for the list parts of the tables*, if present.


### Function `<#coll>.pairs()`

Alias for `:keys()`




### Method `<#coll>:reduce(fn,initialValue)` -> _`<#?>`_,_`...`_

Reduces a map to a value (or tuple), using a function.

**Parameters:**

* _`<#function>`_ `fn`: a function that takes three or more parameters:
  * the result(s) emitted from the previous iteration, or `initialValue`(s) for the first iteration
  * an element value from this map, in arbitrary order
  * the element key
* _`<?>`_ `initialValue`: (optional) the value(s) to pass to `fn` for the first iteration; if omitted, `fn` will
be passed `value1,value2,key2` (then `result,value3,key3` on the second iteration, and so on)

**Returns:**

* _`<#?>`_,_`...`_ the result(s) emitted by `fn` after the last iteration

`fn` can simply return one of the two values passed (e.g. a custom "max" function) or calculate a wholly new
value from them (e.g. a custom "sum" function).


### Method `<#coll>:remove(key)` -> [_`<#coll>`_](hm.types.coll.md#type-coll)

Removes the element associated with a given key or index from this collection.

**Parameters:**

* _`<?>`_ `key`: the key for the element to remove:
  * if a positive integer, this is assumed to be a list; the element in that position will be removed, and subsequent
  elements will be shifted down to fill the hole
  * otherwise, this method simply executes `self[key]=nil`

**Returns:**

* [_`<#coll>`_](hm.types.coll.md#type-coll) this collection, for method chaining




### Method `<#coll>:removeElement(element)` -> [_`<#coll>`_](hm.types.coll.md#type-coll)

Removes all occurrences of a given element from this collection.

**Parameters:**

* _`<?>`_ `element`: the element to remove

**Returns:**

* [_`<#coll>`_](hm.types.coll.md#type-coll) this collection, for method chaining




### Method `<#coll>:setmetatable(mt)` -> [_`<#coll>`_](hm.types.coll.md#type-coll)

Sets a custom metatable on a hs.func collection

**Parameters:**

* _`<#table>`_ `mt`: the metatable

**Returns:**

* [_`<#coll>`_](hm.types.coll.md#type-coll) this collection, with the specified metatable inserted at the top of the chain




### Method `<#coll>:some(fn)` -> _`<#boolean>`_

Checks if a predicate function is satisfied by at least one element of a collection.

**Parameters:**

* _`<#function>`_ `fn`: a function that accepts two parameters, a table value and its key, and returns a boolean

**Returns:**

* _`<#boolean>`_ `true` if `fn` returns `true` for at least one element; `false` otherwise




### Method `<#coll>:sort(fn,removeDuplicates)` -> [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll)

Sorts a list.

**Parameters:**

* _`<#function>`_ `fn`: a function that accepts two list elements, and returns `true` if the first should come
-    before the second in the sorted return list; if `nil`, the `<` (less than) operator is used
* _`<#boolean>`_ `removeDuplicates`: (optional) if `true` the result list won't have any duplicate elements; the
`==` (equality) operator is used to determine duplicates

**Returns:**

* [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll) a list with the same elements of this list, sorted according to `fn`

This method is basically a wrapper for `table.sort`; the only difference is that a new table is returned
(in other words, the original list is left untouched).


### Method `<#coll>:toIndex()` -> [_`<#coll.map>`_](hm.types.coll.md#type-collmap-extends-coll)

Creates an index table.

**Returns:**

* [_`<#coll.map>`_](hm.types.coll.md#type-collmap-extends-coll) the resulting map

Returns a map where keys and values of this map are swapped.
Any duplicates among the values in this map will be discarded, as the keys in a Lua table are unique.


### Method `<#coll>:toList()` -> [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll)

Creates a list from a set (i.e.

**Returns:**

* [_`<#coll.list>`_](hm.types.coll.md#type-colllist-extends-coll) the resulting list

from the keys of a table).
Returns a list containing the all the *keys* in this table in arbitrary order (you can sort it
afterward if necessary); the values are assumed to be uninteresting and discarded.


### Method `<#coll>:toSet(value)` -> [_`<#coll.set>`_](hm.types.coll.md#type-collset-extends-coll)

Creates a set from a list.

**Parameters:**

* _`<?>`_ `value`: the constant value to assign to every key in the result table; if omitted, defaults to `true`

**Returns:**

* [_`<#coll.set>`_](hm.types.coll.md#type-collset-extends-coll) the resulting set

Returns a set whose keys are all the (unique) elements from this list.
Any duplicates among the elements in this list will be discarded, as the keys in a Lua table are unique.


### Method `<#coll>:values()` -> _`<#function>`_

Returns an iterator that returns `value,key` at every iteration, in arbitrary order.

**Returns:**

* _`<#function>`_ an iterator function meant for "for" loops: `for v,k in my_coll:values() do...`




### Method `<#coll>:valuesByKeys(fn)` -> _`<#function>`_

Returns an iterator that returns `value,key` at every iteration, sorted by keys.

**Parameters:**

* _`<#function>`_ `fn`: (optional) a comparator function to determine the sorting order

**Returns:**

* _`<#function>`_ an iterator function meant for "for" loops: `for v,k in my_coll:valuesByKeys() do...`






------------------

### Type `<#coll.list>` (extends [_`<#coll>`_](hm.types.coll.md#type-coll))

An ordered collection (also known as linear array) where the (non-unique) elements are stored as *values* for sequential integer keys starting from 1.





------------------

### Type `<#coll.map>` (extends [_`<#coll>`_](hm.types.coll.md#type-coll))

An associative table (also known as dictionary) where both keys and their values are arbitrary; it can have a list part as well





------------------

### Type `<#coll.set>` (extends [_`<#coll>`_](hm.types.coll.md#type-coll))

An unordered set where the (unique) elements are stored as *keys* whose value is the boolean `true` (or another constant)




