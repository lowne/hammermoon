---Additions to the global namespace
-- @module hm._globals
-- @static

local sformat=string.format

---@function [parent=#global] errorf
--@param #string fmt
--@param ...
errorf=function(fmt,...)error(sformat(fmt,...),2)end

---@function [parent=#global] assertf
--@param v
--@param #string fmt
--@param ...
assertf=function(v,fmt,...)if not v then error(sformat(fmt,...),2) else return v end end

---@function [parent=#global] printf
--@param #string fmt
--@param ...
printf=function(fmt,...)return print(sformat(fmt,...)) end

---@function [parent=#global] inspect
--@param #table t
--@param #boolean inline
--@param #number depth
---@dev
inspect=function(t,inline,depth)
  if type(t)~='table' then return print(t)
  else return print(require'lib.inspect'(t,{depth=depth or (inline and 3 or 6),newline=inline and ' ' or '\n'})) end
end

---`assert`.
-- Modules should use this (instead of `assert`), as it can be disabled via `hm.debug`
-- @param v
-- @param #string msg
--@dev
hmassert=assert
---`assertf`.
-- Modules should use this (instead of `assertf`), as it can be disabled via `hm.debug`
-- @param v
-- @param #string fmt
-- @param ...
--@dev
hmassertf=assertf


------------------------
-- typechecking library
-- Built on top of checks.lua, adding:
--   - meaningful error message for __newindex (cannot use tail call, though)
--   - support for stuctured types ("list(string|number)")
--   - checkers can also sanitize args ("list(string)|string:list" converts "str" to {"str"})

local type,getmetatable,ipairs,rawget,rawset,rawequal=type,getmetatable,ipairs,rawget,rawset,rawequal
local getlocal,setlocal,getinfo=debug.getlocal,debug.setlocal,debug.getinfo

local check_one
---TODO doc structype(itemtype)
-- @type checkersDict
-- @map <#string,#function>

---Assign functions to this dict for custom type checkers.
-- @field [parent=#global] #checkersDict checkers
checkers = setmetatable({},{
  __index=function(t,k)
    local metatype,subtypes,sanitizedtype=k:match('(%w+)(%b()):?(.*)')
    if metatype then
      metatype=metatype..'(_)'
      if #sanitizedtype>0 then metatype=metatype..':'..sanitizedtype end
      subtypes=subtypes:sub(2,-2)
      local sub={}
      for subtype in subtypes:gmatch('[^,]+') do sub[#sub+1]=subtype end
      local f
      if sub[3] then error'nyi'
      elseif sub[2] then
        local keytype,valuetype=sub[1],sub[2]
        f=function(struct)
          local newstruct,changed={}
          local iter,checkstruct,startidx=check_one(metatype,struct)
          if not iter then return false
          elseif iter==true then return true end
          hmassertf(type(iter)=='function','checker for structured type %s must return an iterator fn,t,idx',metatype)
          if not rawequal(checkstruct,struct) then changed=true newstruct=checkstruct end
          for key,value in iter,checkstruct,startidx do
            local newkey=check_one(keytype,key)
            if not newkey then return false
            elseif newkey==true then newkey=key
            elseif not rawequal(newkey,key) then rawset(newstruct,key,nil) changed=true end
            local newvalue=check_one(valuetype,value)
            if not newvalue then return false
            elseif newvalue==true then
            elseif not rawequal(newvalue,value) then rawset(newstruct,newkey,newvalue) changed=true end
          end
          return changed and newstruct or true
        end
      elseif sub[1] then
        local valuetype=sub[1]
        f=function(struct)
          local newstruct,changed={}
          local iter,checkstruct,startidx=check_one(metatype,struct)
          if not iter then return false
          elseif iter==true then return true end
          hmassertf(type(iter)=='function','checker for structured type %s must return an iterator fn,t,idx',metatype)
          if not rawequal(checkstruct,struct) then changed=true newstruct=checkstruct end
          for key,value in iter,checkstruct,startidx do
            local newvalue=check_one(valuetype,value)
            if not newvalue then return false
            elseif newvalue==true then
            elseif not rawequal(newvalue,value) then rawset(newstruct,key,newvalue) changed=true end
          end
          return changed and newstruct or true
        end
      else error('no subtypes found in '..k) end
      t[k]=f
      return f
    end
  end,
  __newindex=function(t,k,v)
    assert(type(k)=='string','checkers need a string key')
    local f
    if type(v)=='string' then
      f=function(val)
        if type(val)==v then return true end
        local mt=getmetatable(val)
        return mt and mt.__type==v
      end
    elseif type(v)=='table' then
      local objtype=assert(v.__type,'The provided table has no __type field')
      f=function(val)
        local mt=getmetatable(val)
        return mt and mt.__type==objtype
      end
    else f=v end
    assert(type(f)=='function','invalid checker')
    printf('[added checker %s]',k)
    rawset(t,k,f)
  end
})

local checkers=checkers
check_one=function(expected,val) return hmassertf(checkers[expected],'no checker for type %s',expected)(val) end
local function check_many(name, expected, val)
  if expected=='?' then return true
  elseif expected=='!' then return (val~=nil)
  elseif type(expected)=='function' then return expected(val)
  elseif type(expected)~='string' then
    error 'strings or checkers expected by checkargs()'
  elseif val==nil and expected:sub(1,1) == '?' then return true end
  local newval,err
  for one in expected:gmatch "[^|?]+" do
    newval,err=hmassertf(checkers[one],'no checker for type %s',one)(val)
    --    newval,err=check_one(one,val)
    if newval then return newval end
  end
  return nil,err
end

function checkargs(...)
  for i, arg in ipairs{...} do
    local name, val = getlocal(2, i)
    local newval,err = check_many(name, arg, val)
    if not newval then
      local fmt = "bad argument #%d to '%s' (%s expected, got %s)"
      local fname = getinfo(2, 'n').name
      if getinfo(3, 'n').name=='__newindex' then
        local k,v=getlocal(3,2) fname=v
        fmt = "[%d] bad value for '%s' (%s expected, got %s)"
      end
      local types={}
      if arg:sub(1,1)=='?' then types[1]='nil' end
      for type in arg:gmatch'[^|?]+' do types[#types+1]=type:match'[^:]+':gsub('value%((.-)%)','%1') end
      types=table.concat(types,' or ')
      error(string.format(fmt, i, fname or "?", types, type(val))..'\n'..(err or ''), 3)
    elseif newval~=true then setlocal(2,i,newval)
    end
  end
end

for _,type in ipairs{'string','number','boolean','table','function'} do checkers[type]=type end

local floor=math.floor
checkers['uint']=function(v)return type(v)=='number' and v>0 and floor(v)==v end
checkers['int']=function(v)return type(v)=='number' and floor(v)==v end
checkers['integer']=checkers.int
checkers['positiveInteger']=function(v)return type(v)=='number' and v>0 and floor(v)==v end
checkers['positiveIntegerOrZero']=function(v)return type(v)=='number' and v>=0 and floor(v)==v end
checkers['positiveNumber']=function(v) return type(v)=='number' and v>0 end
checkers['positiveNumberOrZero']=function(v) return type(v)=='number' and v>=0 end
checkers['false']=function(v)return v==false end
checkers['true']=function(v)return v==true end
local function isCallable(v) return type(v)=='function' or (type(v)=='table' and getmetatable(v) and getmetatable(v).__call and true) end
checkers['callable']=isCallable

-- this is pretty pointless, but this template is used by e.g. 'value(sometype):list'
checkers['value(_)']=function(v)return function(item,idx) if idx then return false,item end end,v,true end

