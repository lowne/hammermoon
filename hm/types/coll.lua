-- 2016 Mark Lowne
--
-- This library is public domain.

---Some utilities for collections in Lua tables.
-- You can call the methods in this module as functions on "plain" tables, via the syntax
-- `new_table=coll.filter(coll.map(my_table, map_fn),filter_fn)`.
-- Alternatively, you can use the constructors and then call methods directly on the table, like this:
-- `new_table=coll.dict(my_table):map(map_fn):filter(filter_fn)`.
-- All tables or lists returned by coll methods, unless otherwise noted, will accept further coll methods.
--
-- The methods in this module can be used on these types of collections:
--   - *lists*: ordered collections (also known as linear arrays) where the (non-unique) elements are stored as *values* for sequential integer keys starting from 1
--   - *sets*: unordered sets where the (unique) elements are stored as *keys* whose value is the boolean `true` (or another constant)
--   - *dicts*: associative tables (also known as maps) where both keys and their values are arbitrary; they can have a list part as well
--   - *trees*, tables with multiple levels of nesting
-- @module hm.types.coll
-- @static

local getmetatable,setmetatable,rawequal=getmetatable,setmetatable,rawequal
local pairs,ipairs,next,select,type,hmtype=pairs,ipairs,select,next,type,hm.type
local tsort,tinsert,tremove,tconcat=table.sort,table.insert,table.remove,table.concat
local tunpack,tpack=table.unpack or unpack,table.pack or function(...) return {n=select('#',...),...} end
local tostring,sformat=tostring,string.format

---An ordered collection (also known as linear array) where the (non-unique) elements are stored as *values* for sequential integer keys starting from 1.
-- @type coll.list
-- @extends #coll.dict
-- @class

---An unordered set where the (unique) elements are stored as *keys* whose value is the boolean `true` (or another constant)
-- @type coll.set
-- @extends #coll.dict
-- @class

---An associative table (also known as dictionary) where both keys and their values are arbitrary; it can have a list part as well
-- @type coll.dict
-- @class


---@type hm.types.coll
local M={}

local mt_dict={__index=M,__call=function(self)return next,self end}
local mt_list={
  __index=M,
  __call=function(self)local i=0 return function()i=i+1 return self[i] end end,
  __tostring=function(self)return sformat('{%s}',self:tostring()) end,
}
local mt_set={__index=M,
  __call=function(self)return next,self end,
  __tostring=function(self)return sformat('set(%s)',self:toList():tostring()) end,
}

-- the following methods work on both maps and lists
local floor=math.floor
local function isListIndex(k)
  return type(k)=='number' and k>=1 and floor(k)==k -- not using 5.3 syntax (k//1==k, or math.type), as you never know
end
checkers['listIndex']=isListIndex
local function isList(t) return type(t)=='table' and M.everyk(t,isListIndex) end
checkers['list']=isList
checkers['list(_)']=function(v)if isList(v) then return ipairs(v) end end
checkers['value(_):list']=function(v) return ipairs{v} end
checkers['listOrValue(_)']=function(v) if not isList(v) then v={v} end return ipairs(v) end
local function isSet(t)
  if type(t)~='table' then return false end
  local val
  for k,v in pairs(t) do
    if val==nil then val=v
    elseif val~=v then return false end
  end
  return true
end
checkers['set']=isSet
checkers['set(_)']=function(v) if isSet(v) then return pairs(v) end end
checkers['value(_):set']=function(v) return next{[v]=true} end
checkers['setOrValue(_)']=function(v) if not isSet(v) then v={[v]=true} end return pairs(v) end

---Creates a dict object.
-- You can also use the shortcut `coll(table)`.
-- @function [parent=#hm.types.coll] dict
-- @param #table table (optional) if omitted a new empty table will be created
-- @return #coll.dict the table, that will now accept the @{<#coll.dict>} methods
function M.dict(table) checkargs'?table' return setmetatable(table or {},mt_dict) end
local dict=M.dict

---Creates a list object.
-- @function [parent=#hm.types.coll] list
-- @param #table table (optional) if omitted a new empty table will be created
-- @return #coll.list the table, that will now accept the @{<#coll.list>} methods
function M.list(table) checkargs'?table' return setmetatable(table or {},mt_list) end
local list=M.list

---Unpacks the elements in this list.
-- @function [parent=#coll.list] unpack
-- @param #coll.list self
-- @return ?,... all the elements in this list

---@private
function M:unpack() return tunpack(self) end

---Returns a string representation of this list.
-- @function [parent=#coll.list] tostring
-- @param #coll.list self
-- @param #string separator (optional) if omitted defaults to `","`
-- @return #string

---@private
function M:tostring(separator) return tconcat(self:map(tostring),separator or ', ') end

---Creates a set object.
-- @function [parent=#hm.types.coll] set
-- @param #table table (optional) if omitted a new empty table will be created
-- @return #coll.set the table, that will now accept the @{<#coll.set>} methods
function M.set(table) checkargs'?table' return setmetatable(table or {},mt_set) end
local set=M.set

---Shortcut for @{hm.types.coll.dict}
-- @callof #hm.types.coll
-- @param #table table
-- @return #coll.dict

---Creates a list of the values in this dict.
-- This method returns a list containing the all the *values* in this collection in arbitrary order.
-- @function [parent=#coll.dict] listValues
-- @param #coll.dict self
-- @return #coll.list

---@private
function M:listValues() checkargs'table'
  local nt=list() for _,v in pairs(self) do nt[#nt+1]=v end return nt
end

---Creates a list of the keys in this dict.
-- This method returns a list containing the all the *keys* in this collection in arbitrary order.
-- @function [parent=#coll.dict] listKeys
-- @param #coll.dict self
-- @return #coll.list

---@private
function M:listKeys() checkargs'table'
  local nt=list() for k in pairs(self) do nt[#nt+1]=k end return nt
end

---Removes holes in a list table.
-- @function [parent=#coll.list] compact
-- @param #coll.list self
-- @param #boolean inPlace
-- @return #coll.list the list with all the holes removed

---@private
function M:compact(self,inPlace)
  local keys=tsort(M.listKeys(self))
  local nt=list()
  for i in ipairs(keys) do nt[#nt+1]=self[i] end
  return inPlace and self:replace(nt) or nt
end

---Creates a list from a set.
-- Returns a list containing the all the *keys* in this set in arbitrary order.
-- @function [parent=#coll.set] toList
-- @param #coll.set self
-- @return #coll.list the resulting list

---@private
M.toList=M.listKeys

---Creates a set from a list.
-- Returns a set whose keys are all the (unique) elements from this list.
-- Any duplicates among the elements in this list will be discarded, as the keys in a Lua table are unique.
-- @function [parent=#coll.list] toSet
-- @param #coll.list self
-- @param value the constant value to assign to every key in the result table; if omitted, defaults to `true`
-- @return #coll.set the resulting set

---@private
function M:toSet(value) checkargs'table'
  if value==nil then value=true end
  local nt=set() for _,v in ipairs(self) do nt[v]=value end return nt
end

---Creates a dict with keys and values swapped.
-- Returns a dict where keys and values of this dict are swapped (i.e. an index table).
-- Any duplicates among the values in this dict will be discarded, as the keys in a Lua table are unique.
-- @function [parent=#coll.dict] toIndex
-- @param #coll.dict self
-- @return #coll.dict the resulting dict

---@private
function M:toIndex() checkargs'table'
  local nt=dict() for k,v in pairs(self) do nt[v]=k end return nt
end

---Executes a function across a list in order, and collects the results.
-- If this table has "holes", all elements after the first hole will be lost, as the table is iterated over with `ipairs`;
-- you can use `hs.func:dict()` if necessary.
-- @function [parent=#coll.list] imap
-- @param #coll.list self
-- @param #function fn a function that accepts two parameters, a list element and its index, and returns a value.
-- The values returned from this function will be collected, in order, into the result list; when `nil` is
-- returned the relevant element is discarded - the result list will *not* have "holes".
-- @return #coll.list a list containing the results of calling the function on every element in this list

---@private
function M:imap(fn) checkargs('table','callable')
  local nt=list() for k,v in ipairs(self) do nt[#nt+1]=fn(v,k) end return nt
end

---Collects a field from each element in this list.
-- @function [parent=#coll.list] imapToField
-- @param #coll.list self
-- @param #string fieldName
-- @return #coll.list a list containing `fieldName` for each of the elements in this list

---@private
function M:imapToField(fieldName) checkargs('table','string')
  local nt=list() for k,v in ipairs(self) do nt[#nt+1]=v[fieldName] end return nt
end

---Executes a function across a dict (in arbitrary order) and collects the results.
-- Notes:
-- * if `fn` doesn't return keys, the transformed values returned by it will be assigned to their respective original keys
-- * if `fn` *does* return keys, and they are not unique, the previous element with the same key will be overwritten;
--   keep in mind that the iteration order, and therefore which value will ultimately be associated to a
--   conflicted key, is arbitrary
-- * if `fn` returns `nil`, the respective key in the result dict will be absent
-- @function [parent=#coll.dict] map
-- @param #coll.dict self
-- @param #function fn a function that accepts two parameters, a dict value and its key, and returns
-- a new value for the element and, optionally, a new key. The key/value pair returned from
-- this function will be added to the result dict.
-- @return #coll.dict a dict containing the results of calling the function on every element in this dict

---@private
function M:map(fn) checkargs('table','callable')
  local nt=dict() for k,v in pairs(self) do local nv,nk=fn(v,k) nt[nk~=nil and nk or k]=nv end return nt
end

---Executes a function across a set (in arbitrary order) and collects the results.
-- Notes:
-- * the keys returned by `fn` may be not unique, but a set doesn't allow duplicates
-- @function [parent=#coll.set] mapk
-- @param #coll.set self
-- @param #function fn a function that a key and returns a new key, that will be added to the result set
-- @return #coll.set a set containing the results of calling the function on every key in this set

---@private
function M:mapk(fn) checkargs('table','callable')
  local nt=set() for k,v in pairs(self) do local nk=fn(k) if nk~=nil then nt[nk]=v end end return nt
end

---Executes a function across a dict (in arbitrary order) and collects the results.
-- @function [parent=#coll.dict] mapkv
-- @param #coll.dict self
-- @param #function fn a function that accepts two parameters, a dict key and its value, and returns
-- a new key and a new value. The key/value pair returned from this function will be added to the result dict.
-- @return #coll.dict a dict containing the results of calling the function on every element in this dict

---@private
function M:mapkv(fn) checkargs('table','callable')
  local nt=set() for k,v in pairs(self) do local nk,nv=fn(k,v) if nk~=nil then nt[nk]=nv end end return nt
end



---Executes a function with side effects across a list in order, discarding any results.
-- @function [parent=#coll.list] iforeach
-- @param #coll.list self
-- @param #function fn a function that accepts two parameters, a list element and its index

---@private
function M:iforeach(fn) checkargs('table','callable') for k,v in ipairs(self) do fn(v,k) end end

---Executes a function with side effects across a dict, in arbitrary order, discarding any results.
-- @function [parent=#coll.dict] foreach
-- @param #coll.dict self
-- @param #function fn a function that accepts two parameters, a dict value and its key

---@private
function M:foreach(fn) checkargs('table','callable') for k,v in pairs(self) do fn(v,k) end end

---Executes a function with side effects across a dict, in arbitrary order, discarding any results.
-- @function [parent=#coll.dict] foreachkv
-- @param #coll.dict self
-- @param #function fn a function that accepts two parameters, a dict key and its value

---@private
function M:foreachkv(fn) checkargs('table','callable') for k,v in pairs(self) do fn(k,v) end end

---Executes a function with side effects across a set, in arbitrary order, discarding any results.
-- @function [parent=#coll.set] foreachk
-- @param #coll.set self
-- @param #function fn a function that accepts a set key

---@private
function M:foreachk(fn) checkargs('table','callable') for k,v in pairs(self) do fn(k) end end

---Filters a list by running a predicate function on its elements in order.
-- @function [parent=#coll.list] ifilter
-- @param #coll.list self
-- @param #function fn a function that accepts two parameters, a list element and its index, and returns a boolean
-- value: `true` if the element should be kept, `false` if it should be discarded
-- @return #coll.list a list containing the elements for which `fn(element,index)` returns true

---@private
function M:ifilter(fn) checkargs('table','callable')
  local nt=list() for k,v in ipairs(self) do if fn(v,k) then nt[#nt+1]=v end end return nt
end

---Filters a list by an elements' field.
-- @function [parent=#coll.list] ifilterByField
-- @param #coll.list self
-- @param #string fieldName the elements' field to use for filtering
-- @param value if the element's `fieldName` doesn't have this value the element will be discarded
-- @return #coll.list a list containing the elements whose `fieldName` equals `value`

---@private
function M:ifilterByField(fieldName,value) checkargs('table','string')
  hmassert(self[1] and self[1][fieldName],'field '..fieldName..'not found in the list elements')
  return M.ifilter(self,function(el)return el[fieldName]==value end)
end

---Filters a dict by running a predicate function on its elements, in arbitrary order.
-- @function [parent=#coll.dict] filter
-- @param #coll.dict self
-- @param #function fn a function that accepts two parameters, a dict value and its key, and returns a boolean
-- value: `true` if the element should be kept, `false` if it should be discarded
-- @return #coll.dict a dict containing the elements for which `fn(value,key)` returns true

---@private
function M:filter(fn) checkargs('table','callable')
  local nt=dict() for k,v in pairs(self) do if fn(v,k) then nt[k]=v end end return nt
end

---Filters a dict by running a predicate function on its elements, in arbitrary order.
-- @function [parent=#coll.dict] filterkv
-- @param #coll.dict self
-- @param #function fn a function that accepts two parameters, a dict key and its value, and returns a boolean
-- value: `true` if the element should be kept, `false` if it should be discarded
-- @return #coll.dict a dict containing the elements for which `fn(value,key)` returns true

---@private
function M:filterkv(fn) checkargs('table','callable')
  local nt=dict() for k,v in pairs(self) do if fn(v,k) then nt[k]=v end end return nt
end

---Filters a set by running a predicate function on its elements, in arbitrary order.
-- @function [parent=#coll.set] filterk
-- @param #coll.set self
-- @param #function fn a function that accepts a key and returns a boolean
-- value: `true` if the key should be kept, `false` if it should be discarded
-- @return #coll.set a set containing the keys for which `fn(key)` returns true

---this module breaks apimodel.lua :/
-- @private
function M:filterk(fn) checkargs('table','callable')
  local nt=set() for k,v in pairs(self) do if fn(k) then nt[k]=v end end return nt
end

local function copy(t,l)
  if l<=0 then return t end
  local nt=setmetatable({},getmetatable(t))
  for k,v in pairs(t) do
    if type(v)=='table' then nt[k]=copy(v,l-1)
    else nt[k]=v end
  end
  return nt
end

---Returns a copy of the collection.
-- This function does *not* handle cycles; use the `maxDepth` parameter with care.
-- @function [parent=#coll.dict] copy
-- @param #coll.dict self
-- @param #number maxDepth (optional) on a tree, create a copy of every node until this nesting level is reached; if omitted, defaults
-- to 1; if 0, returns the input table (no copy will be performed)
-- @return #coll.dict a new collection containing the same data as this collection

---@private
function M:copy(self,maxDepth) checkargs('table','?positiveIntegerOrZero') return copy(self,maxDepth or 1) end

---Returns a copy of this list.
-- @function [parent=#coll.list] icopy
-- @param #coll.list self
-- @return #coll.list a new list containing the same elements as this collection

---@private
function M:icopy(self) checkargs'table'
  local nt=list() for k,v in ipairs(self) do nt[k]=v end return nt
end


local function contains(t,el,l)
  if l<=0 then return t==el and 0 or nil end
  for _,v in pairs(t) do
    if v==el then return l
    elseif type(v)=='table' then
      if contains(v,el,l-1) then return l-1 end
    end
  end
end

---Determines if a dict or tree contains a given object.
-- This function does *not* handle cycles; use the `maxDepth` parameter with care.
-- When maxDepth>1, the tree is traversed depth-first.
-- @function [parent=#coll.dict] contains
-- @param #coll.dict self
-- @param element a value or object to search the collection for
-- @param #number maxDepth (optional) on a tree, look for the element until this nesting level is reached; if omitted, defaults to 1
-- @return #number the nesting level where the element was found
-- @return #nil if not found

---@private
function M:contains(self,element,maxDepth) checkargs('table','!','?positiveInteger')
  maxDepth=maxDepth or 1
  local res=contains(self,element,maxDepth)
  return res and maxDepth-res+1 or nil
end

---Finds the key of a given element in a dict.
-- The table is traversed via `pairs` in arbitrary order; if `element` is associated to multiple keys
-- in the table, the first key found will be returned; subsequent calls to this method from the same
-- table *might* return a different key.
-- @function [parent=#coll.dict] key
-- @param #coll.dict self
-- @param element an object or value to search the table for
-- @return the first key in the dict (in arbitrary order) whose associated value is `element`; `nil` if the element is not found

---@private
function M:key(element) checkargs('table','!')
  for k,v in pairs(self) do if v==element then return k end end
end

---Finds the index of a given element in a list.
-- The table is traversed via `ipairs` in order; if `element` is associated to multiple indices
-- in the list, this funciton will always return the lowest one.
-- @function [parent=#coll.list] index
-- @param #coll.list self
-- @param element an object or value to search the list for
-- @return #number a positive integer, the index of the first occurence of `element` in the list; `nil` if the element is not found

---@private
function M:index(element) checkargs('table','!')
  for k,v in ipairs(self) do if v==element then return k end end
end

---Finds the index of a given element in a list.
-- The table is traversed in *reverse* order; if `element` is associated to multiple indices
-- in the list, this funciton will always return the highest one.
-- @function [parent=#coll.list] lastIndex
-- @param #coll.list self
-- @param element an object or value to search the list for
-- @return #number a positive integer, the index of the last occurence of `element` in the list; `nil` if the element is not found

---@private
function M:lastIndex(element) checkargs('table','!')
  for i=#self,1,-1 do if element==self[i] then return i end end
end

---Inserts an element to this list.
-- @function [parent=#coll.list] insert
-- @param #coll.list self
-- @param value the new element
-- @param #number index (optional) the index for the new element; if omitted, `value` is appended at the end of this list
-- @return #coll.list self

---@private
function M:insert(value,index) checkargs('table','?','?listIndex')
  if index then tinsert(self,index,value) else tinsert(self,value) end
  return self
end

---Appends an element at the end of this list.
-- @function [parent=#coll.list] append
-- @param #coll.list self
-- @param value the new element
-- @return #coll.list self

---@private
function M:append(value) checkargs('table') tinsert(self,value) return self end

---Concatenates two lists into one.
-- @function [parent=#coll.list] concat
-- @param #coll.list self
-- @param #coll.list otherList a list
-- @param #boolean inPlace (optional) if `true`, this list will be modified in-place, appending all the elements from `otherList`,
-- and returned; otherwise a new list will be created and returned
-- @return #coll.list a list with all the elements from this list followed by all the elements from `otherList`

---@private
function M:concat(otherList,inPlace) checkargs('table','table','?boolean')
  local nt=list(inPlace and self or {})
  if not inPlace then for _,v in ipairs(self) do nt[#nt+1]=v end end
  for _,v in ipairs(otherList) do nt[#nt+1]=v end
  return nt
end

---Merges elements from two dicts into one.
-- If `otherDict` has keys that are also present in this dict, the corresponding key/value pairs from this dict
-- will be *overwritten* in the result dict; *this is also true for the list parts of the tables*, if present.
-- @function [parent=#coll.dict] merge
-- @param #coll.dict self
-- @param #coll.dict otherDict a dict
-- @param #boolean inPlace (optional) if `true`, this dict will be modified in-place, merging all the elements from `otherDict`,
-- and returned; otherwise a new dict will be created and returned
-- @return #coll.dict a dict containing both the key/value pairs in this dict and those in `otherDict`

---Merges elements from two sets into one.
-- @function [parent=#coll.set] merge
-- @param #coll.set self
-- @param #coll.set otherSet a dict
-- @param #boolean inPlace (optional) if `true`, this set will be modified in-place
-- @return #coll.set a set containing both the keys in this set and those in `otherSet`

---@private
function M:merge(otherDict, inPlace) checkargs('table','table','?boolean')
  local nt=dict(inPlace and self or {})
  if not inPlace then for k,v in pairs(self) do nt[k]=v end end
  for k,v in pairs(otherDict) do nt[k]=v end
  return nt
end

---Executes, in order across a list, a function that returns lists, and concatenates all of those lists together.
-- @function [parent=#coll.list] imapcat
-- @param #coll.list self
-- @param #function fn a function that accepts two parameters, a list element and its index, and returns a list
-- @return #coll.list a list containing the concatenated results of calling `fn(element,index)` for every element in this list

---@private
function M:imapcat(fn) checkargs('table','callable')
  local nt=list()
  for k,v in ipairs(self) do M.concat(nt,fn(v,k),true) end
  return nt
end

---Executes, in arbitrary order across a dict, a function that returns dicts, and merges all of those dicts together.
-- Exercise caution if the tables returned by `fn` can contain the same keys: see the caveat in @{coll.dict.merge}.
-- @function [parent=#coll.dict] mapmerge
-- @param #coll.dict self
-- @param #function fn a function that accepts two parameters, a dict value and its key, and returns a dict
-- @return #coll.dict a dict containing the merged results of calling `fn(value,key)` for every element in this dict

---@private
function M:mapmerge(fn) checkargs('table','callable')
  local nt=dict()
  for k,v in pairs(self) do M.merge(nt,fn(v,k),true) end
  return nt
end

---Executes, in arbitrary order across a dict, a function that returns dicts, and merges all of those dicts together.
-- Exercise caution if the tables returned by `fn` can contain the same keys: see the caveat in @{coll.dict.merge}.
-- @function [parent=#coll.dict] mapmergekv
-- @param #coll.dict self
-- @param #function fn a function that accepts two parameters, a dict key and its value, and returns a dict
-- @return #coll.dict a dict containing the merged results of calling `fn(key,value)` for every element in this dict

---@private
function M:mapmergekv(fn) checkargs('table','callable')
  local nt=dict()
  for k,v in pairs(self) do M.merge(nt,fn(k,v),true) end
  return nt
end

---Reduces a list to a value (or tuple), using a function.
-- `fn` can simply return one of the two elements passed (e.g. a "max" function) or calculate a wholly new
-- value from them (e.g. a "sum" function).
-- @function [parent=#coll.list] ireduce
-- @param #coll.list self
-- @param #function fn A function that takes three or more parameters:
--   * the result(s) emitted from the previous iteration, or `initialValue`(s) for the first iteration
--   * an element from this list, iterating in order
--   * the element index
-- @param initialValue (optional) the value(s) to pass to `fn` for the first iteration; if omitted, `fn` will
-- be passed `elem1,elem2,2` (then `result,elem3,3` on the second iteration, and so on)
-- @return #?,... the result emitted by `fn` after the last iteration

---@private
function M:ireduce(fn,...) checkargs('table','callable')
  local r,i=tpack(...),1
  if r.n==0 then i,r=2,{self[1]} end
  for k=i,#self do tinsert(r,self[k]) tinsert(r,k) r=tpack(fn(tunpack(r))) end
  return tunpack(r)
end

---Reduces a dict to a value (or tuple), using a function.
-- `fn` can simply return one of the two values passed (e.g. a custom "max" function) or calculate a wholly new
-- value from them (e.g. a custom "sum" function).
-- @function [parent=#coll.dict] reduce
-- @param #coll.dict self
-- @param #function fn a function that takes three or more parameters:
--   * the result(s) emitted from the previous iteration, or `initialValue`(s) for the first iteration
--   * an element value from this dict, in arbitrary order
--   * the element key
-- @param initialValue (optional) the value(s) to pass to `fn` for the first iteration; if omitted, `fn` will
-- be passed `value1,value2,key2` (then `result,value3,key3` on the second iteration, and so on)
-- @return #?,... the result(s) emitted by `fn` after the last iteration

---@private
function M:reduce(fn,...) checkargs('table','callable')
  local r,k,v=tpack(...)
  if r.n==0 then k,r=next(self,k) r={r} end
  k,v=next(self,k)
  while k~=nil do tinsert(r,v) tinsert(r,k) r=tpack(fn(tunpack(r))) k,v=next(self,k) end
  return tunpack(r)
end

---Executes a predicate function across a list, in order, and returns the first element where that function returns true.
-- @function [parent=#coll.list] ifind
-- @param #coll.list self
-- @param #function fn a function that accepts two parameters, a list element and its index, and returns a boolean
-- @return #?,#number the first element of this list that caused `fn(value,index)` to return `true`, and its index
-- @return #nil if not found

---@private
function M:ifind(fn) checkargs('table','callable')
  for k,v in ipairs(self) do if fn(v,k) then return v,k end end
end

---Executes a predicate function across a list, in reverse order, and returns the first element where that function returns true.
-- @function [parent=#coll.list] ifindLast
-- @param #coll.list self
-- @param #function fn a function that accepts two parameters, a list element and its index, and returns a boolean
-- @return #?,#number the highest-index element of this list that caused `fn(value,index)` to return `true`, and its index
-- @return #nil if not found

---@private
function M:ifindLast(fn) checkargs('table','callable')
  for i=#self,1,-1 do if fn(self[i],i) then return self[i],i end end
end

---Executes a predicate function across a dict, in arbitrary order, and returns the first element where that function returns true.
-- @function [parent=#coll.dict] find
-- @param #coll.dict self
-- @param #function fn a function that accepts two parameters, a dict value and its index, and returns a boolean
-- @return #?,#? the first value of this dict that caused `fn(value,key)` to return `true`, and its key
-- @return #nil if not found

---@private
function M:find(fn) checkargs('table','callable')
  for k,v in pairs(self) do if fn(v,k) then return v,k end end
end

---Executes a predicate function across a dict, in arbitrary order, and returns the first element where that function returns true.
-- @function [parent=#coll.dict] findkv
-- @param #coll.dict self
-- @param #function fn a function that accepts two parameters, a dict key and its value, and returns a boolean
-- @return #?,#? the first key of this dict that caused `fn(key,value)` to return `true`, and its value
-- @return #nil if not found

---@private
function M:find(fn) checkargs('table','callable')
  for k,v in pairs(self) do if fn(k,v) then return k,v end end
end

---Executes a predicate function across a set and returns the first key where that function returns true.
-- @function [parent=#coll.set] findk
-- @param #coll.set self
-- @param #function fn a function that accepts a set key and returns a boolean
-- @return #? the first key of this set that caused `fn(key)` to return `true`
-- @return #nil if not found

---@private
function M:findk(fn) checkargs('table','callable')
  for k,v in pairs(self) do if fn(k) then return k end end
end

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
function M.cycle(t)
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
function M.icycle(t)
  local i = 0
  return function()
    i=i+1
    if i>#t then i=1 end
    return t[i],i
  end
end

---Checks if a predicate function is satisfied by every element of a dict.
-- @function [parent=#coll.dict] every
-- @param #coll.dict self
-- @param #function fn a function that accepts two parameters, a table value and its key, and returns a boolean
-- @return #boolean `true` if `fn(value,key)` returns `true` for every element; `false` otherwise

---@private
function M:every(fn) checkargs('table','callable')
  for k,v in pairs(self) do if not fn(v,k) then return false end end
  return true
end

---Checks if a predicate function is satisfied by every element of a dict.
-- @function [parent=#coll.dict] everykv
-- @param #coll.dict self
-- @param #function fn a function that accepts two parameters, a table key and its value, and returns a boolean
-- @return #boolean `true` if `fn(key,value)` returns `true` for every element; `false` otherwise

---@private
function M:everykv(fn) checkargs('table','callable')
  for k,v in pairs(self) do if not fn(k,v) then return false end end
  return true
end

---Checks if a predicate function is satisfied by every key of a set
-- @function [parent=#coll.set] everyk
-- @param #coll.set self
-- @param #function fn a function that accepts a set key and returns a boolean
-- @return #boolean `true` if `fn(key)` returns `true` for every element; `false` otherwise

---@private
function M:everyk(fn) checkargs('table','callable')
  for k,v in pairs(self) do if not fn(k) then return false end end
  return true
end

---Checks if a predicate function is satisfied by every element of a list.
-- @function [parent=#coll.list] ievery
-- @param #coll.list self
-- @param #function fn a function that accepts two parameters, a list value and its index, and returns a boolean
-- @return #boolean `true` if `fn(value,index)` returns `true` for every element; `false` otherwise

---@private
function M:ievery(fn) checkargs('table','callable')
  for k,v in ipairs(self) do if not fn(v,k) then return false end end
  return true
end

---Replace all the elements in this list with elements from another list
-- @function [parent=#coll.list] replace
-- @param #coll.list self
-- @param #coll.list otherList
-- @return #coll.list this list, with all elements replaced

---Replace all the key value pairs in this dict with key value pairs from another dict
-- @function [parent=#coll.dict] replace
-- @param #coll.dict self
-- @param #coll.dict otherDict
-- @return #coll.dict this dict

---@private
function M:replace(other) checkargs('table','table')
  for k,v in pairs(self) do self[k]=nil end
  for k,v in pairs(other) do self[k]=other end
  return self
end

---Removes duplicates from a list
-- @function [parent=#coll.list] dedupe
-- @param #coll.list self
-- @param #boolean inPlace (optional) if `true` modifies and returns this list
-- @return #coll.list a list without duplicate elements

---@private
function M:dedupe(inPlace) checkargs('table','?boolean')
  local nt=list(self):toSet():toList()
  return inPlace and self:replace(nt) or nt
end

---Returns a sorted copy of this list.
-- Unlike `table.sort`, this method can return a new list (in other words, the original list can be left untouched).
-- @function [parent=#coll.list] sort
-- @param #coll.list self
-- @param #function fn (optional) a function that accepts two list elements, and returns `true` if the first should come
---    before the second in the sorted return list; if `nil`, the `<` (less than) operator is used
-- @param #boolean inPlace (optional) if `true` modifies and returns this list
-- @return #coll.list a list with the same elements of this list, sorted according to `fn`

---@private
function M:sort(fn,inPlace) checkargs('table','?callable','?boolean')
  local nt=inPlace and list(self) or copy(self)
  tsort(nt,fn)
  return nt
end

---Returns a sorted copy of this list.
-- @function [parent=#coll.list] sortByField
-- @param #coll.list self
-- @param #string fieldName The elements' field to use as sorting key; the `<` (less than) operator is used as comparator
-- @param #boolean inPlace (optional) if `true` modifies and returns this list
-- @param #boolean reverse (optional) if `true`, the `>` operator is used instead
-- @return #coll.list a list with the same elements of this list, sorted by `fieldName`

---@private
function M:sortByField(fieldName,inPlace,reverse) checkargs('table','string','?boolean')
  hmassert(self[1] and self[1][fieldName],'field '..fieldName..'not found in the list elements')
  local nt=inPlace and list(self) or copy(self)
  tsort(nt,reverse and function(a,b) return b[fieldName]<a[fieldName] end or function(a,b) return a[fieldName]<b[fieldName] end)
  return nt
end

---Removes all occurrences of a given value from this dict.
-- @function [parent=#coll.dict] remove
-- @param #coll.dict self
-- @param value the value to remove
-- @return #coll.dict this dict with the given element removed

---@private
function M:remove(element) checkargs('table','!')
  for k,v in pairs(self) do if v==element then self[k]=nil end end
  return self
end

---Removes all occurrences of a given element from this list.
-- This method will not create holes in the list.
-- @function [parent=#coll.list] iremove
-- @param #coll.list self
-- @param element the element to remove
-- @return #coll.list this list with the given element removed

---@private
function M:iremove(element) checkargs('table','!')
  for i=#self,1,-1 do if self[i]==v then tremove(self,i) end end
  return self
end

-- iterators

---Returns an iterator that returns `value,key` at every iteration, in arbitrary order.
-- @function [parent=#coll.dict] values
-- @param #coll.dict self
-- @return #function an iterator function meant for "for" loops: `for v,k in my_coll:values() do...`

---@private
function M:values()
  local k,v
  return function() k,v=next(self,k) return v,k end
end

---Returns an iterator that returns `key,value` at every iteration, in arbitrary order.
-- @function [parent=#coll.dict] keys
-- @param #coll.dict self
-- @return #function,#coll.dict an iterator function and this collection, meant for "for" loops: `for k,v in my_coll:keys() do...`

---@private
function M:keys()return next,self end

---Alias for `:keys()`
-- @function [parent=#coll.dict] pairs
-- @param #coll.dict self
M.pairs=M.keys

---Returns a list iterator that returns `key,value` at every iteration, in order.
-- @function [parent=#coll.list] ipairs
-- @param #coll.list self
-- @return #function,#coll.list an iterator function and this list, meant for "for" loops: `for i,v in my_coll:ipairs() do...`

---@private
function M:ipairs() return ipairs(self) end

local function sortByValues(t,fn)
  if fn==true then fn=function(a,b)return b.v<a.v end
  elseif not fn then fn=function(a,b)return a.b<b.v end end
  --  fn=fn and function(a,b)return fn(a.v,b.v) end or function(a,b)return a.v<b.v end
  local r={}
  for k,v in pairs(t) do tinsert(r,{k=k,v=v}) end
  tsort(r,fn) return r
end

---Returns an iterator that returns `value,key` at every iteration, sorted by values.
-- @function [parent=#coll.dict] byValues
-- @param #coll.dict self
-- @param #function fn (optional) a comparator function to determine the sorting order;
-- if omitted, uses `<`; if `true`, uses `>`
-- @return #function an iterator function meant for "for" loops: `for v,k in my_coll:byValues() do...`

---Returns an iterator that returns `value,index` at every iteration, sorted by values.
-- @function [parent=#coll.list] byValues
-- @param #coll.list self
-- @param #function fn (optional) a comparator function to determine the sorting order;
-- if omitted, uses `<`; if `true`, uses `>`
-- @return #function an iterator function meant for "for" loops: `for v,i in my_coll:byValues() do...`

---@private
function M:byValues(fn) checkargs('table','?callable|true')
  local i,r=0,sortByValues(self,fn)
  return function() i=i+1 return r[i].v,r[i].k end
end

---Returns an iterator that returns `key,value` at every iteration, sorted by values.
-- @function [parent=#coll.dict] keysByValues
-- @param #coll.dict self
-- @param #function fn (optional) a comparator function to determine the sorting order;
-- if omitted, uses `<`; if `true`, uses `>`
-- @return #function an iterator function meant for "for" loops: `for k,v in my_coll:keysByValues() do...`

---Returns an iterator that returns `index,value` at every iteration, sorted by values.
-- @function [parent=#coll.list] keysByValues
-- @param #coll.list self
-- @param #function fn (optional) a comparator function to determine the sorting order;
-- if omitted, uses `<`; if `true`, uses `>`
-- @return #function an iterator function meant for "for" loops: `for i,v in my_coll:keysByValues() do...`

---@private
function M:keysByValues(fn) checkargs('table','?callable|true')
  local i,r=0,sortByValues(self,fn)
  return function() i=i+1 return r[i].k,r[i].v end
end

---Returns an iterator that returns `key,value` at every iteration, sorted by keys.
-- @function [parent=#coll.dict] byKeys
-- @param #coll.dict self
-- @param #function fn (optional) a comparator function to determine the sorting order;
-- if omitted, uses `<`; if `true`, uses `>`
-- @return #function an iterator function meant for "for" loops: `for k,v in my_coll:byKeys() do...`

---@private
function M:byKeys(fn) checkargs('table','?callable|true')
  local i,kl=0,M.toList(self) tsort(kl,fn)
  return function()i=i+1 local k=kl[i] return k,self[k]end
end

---Returns an iterator that returns `value,key` at every iteration, sorted by keys.
-- @function [parent=#coll.dict] valuesByKeys
-- @param #coll.dict self
-- @param #function fn (optional) a comparator function to determine the sorting order;
-- if omitted, uses `<`; if `true`, uses `>`
-- @return #function an iterator function meant for "for" loops: `for v,k in my_coll:valuesByKeys() do...`

---@private
function M:valuesByKeys(fn) checkargs('table','?callable|true')
  local i,kl=0,M.toList(self) tsort(kl,fn)
  return function()i=i+1 local k=kl[i] return self[k],k end
end

return setmetatable(M,{__call=function(_,t)return dict(t)end})

