-- 2016 Mark Lowne
--
-- This library is public domain.

---Some utilities for collections in Lua tables.
-- You can call the methods in this module as functions on "plain" tables, via the syntax
-- `new_table=coll.filter(coll.map(my_table, map_fn),filter_fn)`.
-- Alternatively, you can use the `new` constructor and then call methods directly on the table, like this:
-- `new_table=coll.new(my_table):map(map_fn):filter(filter_fn)`.
-- All tables or lists returned by coll methods, unless otherwise noted, will accept further coll methods.
--
-- The methods in this module can be used on these types of collections:
--   - *lists*: ordered collections (also known as linear arrays) where the (non-unique) elements are stored as *values* for sequential integer keys starting from 1
--   - *sets*: unordered sets where the (unique) elements are stored as *keys* whose value is the boolean `true` (or another constant)
--   - *maps*: associative tables (also known as dictionaries) where both keys and their values are arbitrary; they can have a list part as well
--   - *trees*, tables with multiple levels of nesting
-- @module hm.types.coll
-- @static

local getmetatable,setmetatable,rawequal=getmetatable,setmetatable,rawequal
local pairs,ipairs,next,type=pairs,ipairs,next,type
local tpack,tunpack,tsort,tinsert,tremove=table.pack,table.unpack,table.sort,table.insert,table.remove
local tostring=tostring


---An ordered collection (also known as linear array) where the (non-unique) elements are stored as *values* for sequential integer keys starting from 1.
-- @type coll.list
-- @extends #coll

---An unordered set where the (unique) elements are stored as *keys* whose value is the boolean `true` (or another constant)
-- @type coll.set
-- @extends #coll

---An associative table (also known as dictionary) where both keys and their values are arbitrary; it can have a list part as well
-- @type coll.map
-- @extends #coll

---Base type for collection objects
-- @type coll

---@type hm.types.coll
local f={} -- module/class
local mt_f={__index=f,__call=function(self)return next,self end}

---Creates a collection object.
-- You can also use the shortcut `coll(table)`.
--
-- If the table already has a metatable, the metatable for coll will be appended at the end of the `__index` chain, to ensure
-- that coll methods don't shadow your table object methods.
-- For the same reason, if you need to set the metatable to an already existing coll table, you can use
-- the `coll:setmetatable()` method, it will *insert* the new metatable at the top of the chain.
--
-- @function [parent=#hm.types.coll] new
-- @param #table table (optional) a Lua table holding a collection of elements, if omitted a new empty table will be created
-- @return #coll the table, that will now accept the `coll` methods
function f.new(table)
  if not table then table={} end
  local mt,nt=table,table
  while mt do
    if rawequal(mt_f,mt) then return table end
    nt,mt=mt,getmetatable(mt)
  end
  setmetatable(nt,mt_f) -- at the end of the metatable chain
  return table
end
local new=f.new

---Shortcut for @{hm.types.coll.new}
-- @callof #hm.types.coll
-- @param #table table
-- @return #coll

---Sets a custom metatable on a hs.func collection
-- @function [parent=#coll] setmetatable
-- @param #coll self
-- @param #table mt the metatable
-- @return #coll this collection, with the specified metatable inserted at the top of the chain

---@private
function f:setmetatable(mt) setmetatable(self,mt) return new(self) end

---Creates a list from a map or from a list with holes.
-- This method returns a list containing the all the *values* in this collection in arbitrary order
-- (you can sort it afterward if necessary); the keys are assumed to be uninteresting and discarded.
-- You can use this method to remove "holes" from lists; however the result list isn't guaranteed to be
-- in order.
-- @function [parent=#coll] flatten
-- @param #coll self
-- @return #coll.list the resulting list

---@private
function f:flatten() local nt=new() for _,v in pairs(self) do nt[#nt+1]=v end return nt end

---Creates a list from a set (i.e. from the keys of a table).
-- Returns a list containing the all the *keys* in this table in arbitrary order (you can sort it
-- afterward if necessary); the values are assumed to be uninteresting and discarded.
-- @function [parent=#coll] toList
-- @param #coll self
-- @return #coll.list the resulting list

---@private
function f:toList() local nt=new() for k in pairs(self) do nt[#nt+1]=k end return nt end

---Creates a set from a list.
-- Returns a set whose keys are all the (unique) elements from this list.
-- Any duplicates among the elements in this list will be discarded, as the keys in a Lua table are unique.
-- @function [parent=#coll] toSet
-- @param #coll self
-- @param value the constant value to assign to every key in the result table; if omitted, defaults to `true`
-- @return #coll.set the resulting set

---@private
function f:toSet(value)
  if value==nil then value=true end
  local nt=new() for _,v in ipairs(self) do nt[v]=value end return nt
end

---Creates an index table.
-- Returns a map where keys and values of this map are swapped.
-- Any duplicates among the values in this map will be discarded, as the keys in a Lua table are unique.
-- @function [parent=#coll] toIndex
-- @param #coll self
-- @return #coll.map the resulting map

---@private
function f:toIndex() local nt=new() for k,v in pairs(self) do nt[v]=k end return nt end

---Executes a function across a list in order, and collects the results.
-- If this table has "holes", all elements after the first hole will be lost, as the table is iterated over with `ipairs`;
-- you can use `hs.func:map()` if necessary.
-- @function [parent=#coll] imap
-- @param #coll self
-- @param #function fn a function that accepts two parameters, a list element and its index, and returns a value.
-- The values returned from this function will be collected, in order, into the result list; when `nil` is
-- returned the relevant element is discarded - the result list will *not* have "holes".
-- @return #coll.list a list containing the results of calling the function on every element in this list

---@private
function f:imap(fn)
  local nt=new()
  for k,v in ipairs(self) do nt[#nt+1]=fn(v,k) end
  return nt
end

---Executes a function across a map (in arbitrary order) and collects the results.
-- Notes:
-- * if this table is a list (without holes) and you need guaranteed in-order processing you must use `hs.func:imap()`
-- * if `fn` doesn't return keys, the transformed values returned by it will be assigned to their respective original keys
-- * if `fn` *does* return keys, and they are not unique, the previous element with the same key will be overwritten;
--   keep in mind that the iteration order, and therefore which value will ultimately be associated to a
--   conflicted key, is arbitrary
-- * if `fn` returns `nil`, the respective key in the result map won't have any associated element
-- @function [parent=#coll] map
-- @param #coll self
-- @param #function fn a function that accepts two parameters, a map value and its key, and returns
-- a new value for the element and, optionally, a new key. The key/value pair returned from
-- this function will be added to the result map.
-- @return #coll.map a map containing the results of calling the function on every element in this map

---@private
function f:map(fn)
  local nt=new()
  for k,v in pairs(self) do
    local nv,nk=fn(v,k)
    nt[nk~=nil and nk or k]=nv
  end
  return nt
end

---Executes a function with side effects across a list in order, discarding any results.
-- @function [parent=#coll] ieach
-- @param #coll self
-- @param #function fn a function that accepts two parameters, a list element and its index

---@private
function f:ieach(fn) for k,v in ipairs(self) do fn(v,k) end end

---Executes a function with side effects across a map, in arbitrary order, discarding any results.
-- @function [parent=#coll] each
-- @param #coll self
-- @param #function fn a function that accepts two parameters, a map value and its key

---@private
function f:each(fn) for k,v in pairs(self) do fn(v,k) end end

---Filters a list by running a predicate function on its elements in order.
-- @function [parent=#coll] ifilter
-- @param #coll self
-- @param #function fn a function that accepts two parameters, a list element and its index, and returns a boolean
-- value: `true` if the element should be kept, `false` if it should be discarded
-- @return #coll.list a list containing the elements for which `fn(element,index)` returns true

---@private
function f:ifilter(fn)
  local nt=new()
  for k,v in ipairs(self) do if fn(v,k) then nt[#nt+1]=v end end
  return nt
end

---Filters a map by running a predicate function on its elements, in arbitrary order.
-- @function [parent=#coll] filter
-- @param #coll self
-- @param #function fn a function that accepts two parameters, a map value and its key, and returns a boolean
-- value: `true` if the element should be kept, `false` if it should be discarded
-- @return #coll.map a map containing the elements for which `fn(value,key)` returns true

---@private
function f:filter(fn)
  local nt=new()
  for k,v in pairs(self) do if fn(v,k) then nt[k]=v end end
  return nt
end

local function copy(t,l)
  l=l or 1
  if l<=0 then return t end
  local nt=new()
  for k,v in pairs(t) do nt[k]=type(v)=='table' and copy(v,l-1) or v end
  return nt
end
---Returns a copy of the collection.
-- This function does *not* handle cycles; use the `maxDepth` parameter with care.
-- @function [parent=#coll] copy
-- @param #coll self
-- @param #number maxDepth (optional) on a tree, create a copy of every node until this nesting level is reached; if omitted, defaults
-- to 1; if 0, returns the input table (no copy will be performed)
-- @return #coll a new collection containing the same data as this collection

---@private
f.copy=copy

local function contains(t,el,l)
  if l<=0 then return t==el,0 end
  for _,v in pairs(t) do
    if v==el then return true,l
    elseif type(v)=='table' then
      if contains(v,el,l-1) then return true,l-1 end
    end
  end
  return false
end
---Determines if a list, map or tree contains a given object.
-- This function does *not* handle cycles; use the `maxDepth` parameter with care.
--
-- When maxDepth>1, the tree is traversed depth-first.
-- @function [parent=#coll] contains
-- @param #coll self
-- @param element a value or object to search the collection for
-- @param #number maxDepth (optional) on a tree, look for the element until this nesting level is reached; if omitted, defaults to 1
-- @return #boolean,#number if the element could be found in the collection, `true, depth`, where depth is the nesting level
-- where the element was found; otherwise `false`

---@private
function f:contains(self,element,maxDepth)
  maxDepth=maxDepth or 1
  local initial,res=maxDepth
  res,maxDepth=contains(self,element,maxDepth)
  return res,res and initial-maxDepth+1 or nil
end

---Finds the key of a given element in a map.
-- The table is traversed via `pairs` in arbitrary order; if `element` is associated to multiple keys
-- in the table, the first key found will be returned; subsequent calls to this method from the same
-- table *might* return a different key.
-- @function [parent=#coll] key
-- @param #coll self
-- @param element an object or value to search the table for
-- @return the first key in the map (in arbitrary order) whose associated value is `element`; `nil` if the element is not found

---@private
function f:key(element) for k,v in pairs(self) do if v==element then return k end end end

---Finds the index of a given element in a list.
-- The table is traversed via `ipairs` in order; if `element` is associated to multiple indices
-- in the list, this funciton will always return the lowest one.
-- @function [parent=#coll] index
-- @param #coll self
-- @param element an object or value to search the list for
-- @return #number a positive integer, the index of the first occurence of `element` in the list; `nil` if the element is not found

---@private
function f:index(element) for k,v in ipairs(self) do if v==element then return k end end end

---Finds the index of a given element in a list.
-- The table is traversed via `ipairs` in *reverse* order; if `element` is associated to multiple indices
-- in the list, this funciton will always return the highest one.
-- @function [parent=#coll] lastIndex
-- @param #coll self
-- @param element an object or value to search the list for
-- @return #number a positive integer, the index of the last occurence of `element` in the list; `nil` if the element is not found

---@private
function f:lastIndex(element) for i=#self,1,-1 do if element==self[i] then return i end end end

---Concatenates two lists into one.
-- @function [parent=#coll] concat
-- @param #coll self
-- @param #coll.list otherList a list
-- @param #boolean inPlace (optional) if `true`, this list will be modified in-place, appending all the elements from `otherList`,
-- and returned; otherwise a new list will be created and returned
-- @return #coll.list a list with all the elements from this list followed by all the elements from `otherList`

---@private
function f:concat(otherList,inPlace)
  local nt=new(inPlace and self or {})
  if not inPlace then for _,v in ipairs(self) do nt[#nt+1]=v end end
  for _,v in ipairs(otherList) do nt[#nt+1]=v end
  return nt
end

---Merges elements from two maps into one.
-- If `otherMap` has keys that are also present in this map, the corresponding key/value pairs from this map
-- will be *overwritten* in the result map; *this is also true for the list parts of the tables*, if present.
-- @function [parent=#coll] merge
-- @param #coll self
-- @param #coll.map otherMap a map
-- @param #boolean inPlace (optional) if `true`, this map will be modified in-place, merging all the elements from `otherMap`,
-- and returned; otherwise a new map will be created and returned
-- @return #coll.map a map containing both the key/value pairs in this map and those in `otherMap`

---@private
function f:merge(otherMap, inPlace)
  local nt=new(inPlace and self or {})
  if not inPlace then for k,v in pairs(self) do nt[k]=v end end
  for k,v in pairs(otherMap) do nt[k]=v end
  return nt
end

---Executes, in order across a list, a function that returns lists, and concatenates all of those lists together.
-- @function [parent=#coll] mapcat
-- @param #coll self
-- @param #function fn a function that accepts two parameters, a list element and its index, and returns a list
-- @return #coll.list a list containing the concatenated results of calling `fn(element,index)` for every element in this list

---@private
function f:mapcat(fn)
  local nt=new()
  for k,v in ipairs(self) do f.concat(nt,fn(v,k),true) end
  return nt
end

---Executes, in arbitrary order across a map, a function that returns maps, and merges all of those maps together.
-- Exercise caution if the tables returned by `fn` can contain the same keys: see the caveat in @{coll.merge}.
-- @function [parent=#coll] mapmerge
-- @param #coll self
-- @param #function fn a function that accepts two parameters, a map value and its key, and returns a map
-- @return #coll.map a map containing the merged results of calling `fn(value,key)` for every element in this map

---@private
function f:mapmerge(fn)
  local nt=new()
  for k,v in pairs(self) do f.merge(nt,fn(v,k),true) end
  return nt
end

---Reduces a list to a value (or tuple), using a function.
-- `fn` can simply return one of the two elements passed (e.g. a "max" function) or calculate a wholly new
-- value from them (e.g. a "sum" function).
-- @function [parent=#coll] ireduce
-- @param #coll self
-- @param #function fn A function that takes three or more parameters:
--   * the result(s) emitted from the previous iteration, or `initialValue`(s) for the first iteration
--   * an element from this list, iterating in order
--   * the element index
-- @param initialValue (optional) the value(s) to pass to `fn` for the first iteration; if omitted, `fn` will
-- be passed `elem1,elem2,2` (then `result,elem3,3` on the second iteration, and so on)
-- @return #?,... the result emitted by `fn` after the last iteration

---@private
function f:ireduce(fn,...)
  local r,i=tpack(...),1
  if r.n==0 then i,r=2,{self[1]} end
  for k=i,#self do tinsert(r,self[k]) tinsert(r,k) r=tpack(fn(tunpack(r))) end
  return tunpack(r)
end

---Reduces a map to a value (or tuple), using a function.
-- `fn` can simply return one of the two values passed (e.g. a custom "max" function) or calculate a wholly new
-- value from them (e.g. a custom "sum" function).
-- @function [parent=#coll] reduce
-- @param #coll self
-- @param #function fn a function that takes three or more parameters:
--   * the result(s) emitted from the previous iteration, or `initialValue`(s) for the first iteration
--   * an element value from this map, in arbitrary order
--   * the element key
-- @param initialValue (optional) the value(s) to pass to `fn` for the first iteration; if omitted, `fn` will
-- be passed `value1,value2,key2` (then `result,value3,key3` on the second iteration, and so on)
-- @return #?,... the result(s) emitted by `fn` after the last iteration

---@private
function f:reduce(fn,...)
  local r,k,v=tpack(...)
  if r.n==0 then k,r=next(self,k) r={r} end
  k,v=next(self,k)
  while k~=nil do tinsert(r,v) tinsert(r,k) r=tpack(fn(tunpack(r))) k,v=next(self,k) end
  return tunpack(r)
end

---Executes a predicate function across a list, in order, and returns the first element where that function returns true.
-- @function [parent=#coll] ifind
-- @param #coll self
-- @param #function fn a function that accepts two parameters, a list element and its index, and returns a boolean
-- @return #?,#number the first element of this list that caused `fn` to return `true`, and its index
-- @return #nil if not found

---@private
function f:ifind(fn) for k,v in ipairs(self) do if fn(v,k) then return v,k end end end

---Executes a predicate function across a list, in reverse order, and returns the first element where that function returns true.
-- @function [parent=#coll] ifindLast
-- @param #coll self
-- @param #function fn a function that accepts two parameters, a list element and its index, and returns a boolean
-- @return #?,#number the highest-index element of this list that caused `fn` to return `true`, and its index
-- @return #nil if not found

---@private
function f:ifindLast(fn) for i=#self,1,-1 do if fn(self[i],i) then return self[i],i end end end

---Executes a predicate function across a map, in arbitrary order, and returns the first element where that function returns true.
-- @function [parent=#coll] find
-- @param #coll self
-- @param #function fn a function that accepts two parameters, a map value and its index, and returns a boolean
-- @return #?,#number the first element of this map that caused `fn` to return `true`, and its key
-- @return #nil if not found

---@private
function f:find(fn) for k,v in pairs(self) do if fn(v,k) then return v,k end end end

-- hs.func:cycle() -> function()->value,key
-- Constructor
-- Creates a function that repeatedly iterates over a map, in arbitrary order
--
-- Parameters:
--  * None
--
-- Returns:
--  * a function that will return the next element (`value,key`) of this map every time it is called, cycling back
--    to the start after the last element
--
-- Notes:
--  * An example usage:
--     ```lua
--     f = hs.func.cycle({a=1, b=2, c=3})
--     t = {f(), f(), f(), f(), f(), f(), f()} -- {3, 2, 1, 3, 2, 1, 3, 'c'}
--     ```

---@private
function f.cycle(t)
  local k,v
  return function()
    k,v = next(t,k)
    if not k then k,v=next(t) end
    return v,k
  end
end

-- hs.func:icycle() -> function()->value,index
-- Constructor
-- Creates a function that repeatedly iterates over a list, in order
--
-- Parameters:
--  * None
--
-- Returns:
--  * a function that will return the next element (`value,index`) of this list every time it is called, cycling back
--    to the start after the last element
--
-- Notes:
--  * An example usage:
--     ```lua
--     f = hs.func.icycle({4, 5, 6})
--     t= {f(), f(), f(), f(), f(), f(), f()} -- {4, 5, 6, 4, 5, 6, 4}
--     ```

---@private
function f.icycle(t)
  local i = 0
  return function()
    i=i+1
    if i>#t then i=1 end
    return t[i],i
  end
end

---Checks if a predicate function is satisfied by every element of a collection.
-- @function [parent=#coll] every
-- @param #coll self
-- @param #function fn a function that accepts two parameters, a table value and its key, and returns a boolean
-- @return #boolean `true` if `fn` returns `true` for every element; `false` otherwise

---@private
function f:every(fn)
  for k,v in pairs(self) do if not fn(v,k) then return false end end
  return true
end

---Checks if a predicate function is satisfied by at least one element of a collection.
-- @function [parent=#coll] some
-- @param #coll self
-- @param #function fn a function that accepts two parameters, a table value and its key, and returns a boolean
-- @return #boolean `true` if `fn` returns `true` for at least one element; `false` otherwise

---@private
function f:some(fn) return f.find(self,fn)~=nil end

---Sorts a list.
-- This method is basically a wrapper for `table.sort`; the only difference is that a new table is returned
-- (in other words, the original list is left untouched).
-- @function [parent=#coll] sort
-- @param #coll self
-- @param #function fn a function that accepts two list elements, and returns `true` if the first should come
---    before the second in the sorted return list; if `nil`, the `<` (less than) operator is used
-- @param #boolean removeDuplicates (optional) if `true` the result list won't have any duplicate elements; the
-- `==` (equality) operator is used to determine duplicates
-- @return #coll.list a list with the same elements of this list, sorted according to `fn`

---@private
function f:sort(fn,removeDuplicates)
  local nt=removeDuplicates and f.toSet(self):toList() or copy(self)
  tsort(nt,fn~=nil and fn or f.defaultComparator)
  return nt
end

-- the following methods work on both maps and lists
local floor=math.floor
local function isListIndex(k)
  return type(k)=='number' and k>=1 and floor(k)==k -- not using 5.3 syntax (k//1==k, or math.type), as you never know
end

---Inserts an element into a collection.
-- @function [parent=#coll] insert
-- @param #coll self
-- @param element the element to insert
-- @param key (optional) the key for the element:
--   * if omitted, this is assumed to be a list, and `element` will be appended at the end
--   * if a positive integer, this is assumed to be a list, and `element` will be inserted in that position; subsequent
--     elements will be shifted up to make room
--   * otherwise, this method simply executes `self[key]=element`
-- @return #coll this collection, for method chaining

---@private
function f:insert(element,key)
  if key==nil then key=#self+1 end
  if isListIndex(key) then tinsert(self,key,element)
  else self[key]=element end
  return self
end

---Removes the element associated with a given key or index from this collection.
-- @function [parent=#coll] remove
-- @param #coll self
-- @param key the key for the element to remove:
--   * if a positive integer, this is assumed to be a list; the element in that position will be removed, and subsequent
--   elements will be shifted down to fill the hole
--   * otherwise, this method simply executes `self[key]=nil`
-- @return #coll this collection, for method chaining

---@private
function f:remove(key)
  if key==nil then return self end
  if isListIndex(key) then tremove(self,key)
  else self[key]=nil end
  return self
end

---Removes the highest-index given element from this list.
-- The list is traversed in reverse order.
-- @function [parent=#coll] iremove
-- @param #coll self
-- @param element the element to remove
-- @return #coll.list this list, for method chaining

---@private
function f:iremove(element)
  for i=#self,1,-1 do if self[i]==element then tremove(self,i) break end end
  return self
end

---Removes all occurrences of a given element from this collection.
-- @function [parent=#coll] removeElement
-- @param #coll self
-- @param element the element to remove
-- @return #coll this collection, for method chaining

---@private
function f:removeElement(element)
  local k=f.key(self,element)
  while k~=nil do
    f.remove(self,k)
    k=f.key(self,element)
  end
  return self
end


-- iterators

---Returns an iterator that returns `value,key` at every iteration, in arbitrary order.
-- @function [parent=#coll] values
-- @param #coll self
-- @return #function an iterator function meant for "for" loops: `for v,k in my_coll:values() do...`

---@private
function f:values()
  local k,v
  return function() k,v=next(self,k) return v,k end
end

---Returns an iterator that returns `key,value` at every iteration, in arbitrary order.
-- @function [parent=#coll] keys
-- @param #coll self
-- @return #function,#coll an iterator function and this collection, meant for "for" loops: `for k,v in my_coll:keys() do...`

---@private
function f:keys()return next,self end

---Alias for `:keys()`
-- @function [parent=#coll] pairs
f.pairs=f.keys

---Returns a list iterator that returns `key,value` at every iteration, in order.
-- @function [parent=#coll] ipairs
-- @param #coll self
-- @return #function,#coll an iterator function and this collection, meant for "for" loops: `for i,v in my_coll:ipairs() do...`

---@private
function f:ipairs() return ipairs(self) end

local function sortByValues(t,fn)
  fn=fn and function(a,b)return fn(a.v,b.v) end or function(a,b)return a.v<b.v end
  local r={}
  for k,v in pairs(t) do tinsert(r,{k=k,v=v}) end
  tsort(r,fn) return r
end

---Returns an iterator that returns `value,key` at every iteration, sorted by values.
-- @function [parent=#coll] byValues
-- @param #coll self
-- @param #function fn (optional) a comparator function to determine the sorting order
-- @return #function an iterator function meant for "for" loops: `for v,k in my_coll:byValues() do...`

---@private
function f:byValues(fn) hmchecks('table','?function')
  local i,r=0,sortByValues(self,fn)
  return function() i=i+1 return r[i].v,r[i].k end
end

---Returns an iterator that returns `key,value` at every iteration, sorted by values.
-- @function [parent=#coll] keysByValues
-- @param #coll self
-- @param #function fn (optional) a comparator function to determine the sorting order
-- @return #function an iterator function meant for "for" loops: `for k,v in my_coll:keysByValues() do...`

---@private
function f:keysByValues(fn) hmchecks('table','?function')
  local i,r=0,sortByValues(self,fn)
  return function() i=i+1 return r[i].k,r[i].v end
end

---Returns an iterator that returns `key,value` at every iteration, sorted by keys.
-- @function [parent=#coll] byKeys
-- @param #coll self
-- @param #function fn (optional) a comparator function to determine the sorting order
-- @return #function an iterator function meant for "for" loops: `for k,v in my_coll:byKeys() do...`

---@private
function f:byKeys(fn) hmchecks('table','?function')
  local i,kl=0,f.toList(self) tsort(kl,fn)
  return function()i=i+1 local k=kl[i] return k,self[k]end
end

---Returns an iterator that returns `value,key` at every iteration, sorted by keys.
-- @function [parent=#coll] valuesByKeys
-- @param #coll self
-- @param #function fn (optional) a comparator function to determine the sorting order
-- @return #function an iterator function meant for "for" loops: `for v,k in my_coll:valuesByKeys() do...`

---@private
function f:valuesByKeys(fn) hmchecks('table','?function')
  local i,kl=0,f.toList(self) tsort(kl,fn)
  return function()i=i+1 local k=kl[i] return self[k],k end
end

return setmetatable(f,{__call=function(_,t)return new(t)end})

