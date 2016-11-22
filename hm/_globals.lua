---Additions to the global namespace
-- @module hm._globals
-- @static

---@function [parent=#global] errorf
--@param #string fmt
--@param ...
errorf=function(fmt,...)error(sformat(fmt,...))end

---@function [parent=#global] assertf
--@param v
--@param #string fmt
--@param ...
assertf=function(v,fmt,...)if not v then errorf(fmt,...) end end

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
--   - checkers can also sanitize args (e.g. when passing a single string in place of a list of strings)
--   - support for stuctured types ("list(string|number)")

local type,getmetatable,ipairs,rawget,rawset=type,getmetatable,ipairs,rawget,rawset
local getlocal,setlocal,getinfo=debug.getlocal,debug.setlocal,debug.getinfo

local check_one
---TODO doc structype(itemtype)
-- @type checkersDict
-- @map <#string,#function>

---Assign functions to this dict for custom type checkers.
-- @field [parent=#global] #checkersDict checkers
checkers = setmetatable({},{
  __index=function(t,k)
    local metatype,subtypes=k:match('(%w+)(%b())')
    if metatype then
      --      local metachecker=assert(rawget(t,metatype),'No such metatype checker: '..metatype)
      --      local itername='iter('..metatype..')'
      --      local metaiter=assert(rawget(t,itername),'iterator '..itername..' not found for metatype '..metatype)
      subtypes=subtypes:sub(2,-2)
      local sub={}
      for subtype in subtypes:gmatch('[^,]+') do sub[#sub+1]=subtype end
      local keytype,valuetype
      if sub[3] then error'nyi'
        --        f=function(v)
        --          if not check_one(metatype,v) then return false end
        --          for el in metaiter(v) do
        --            for i,subtype in ipairs(sub) do
        --              if not check_one(subtype,el[i]) then return false end
        --            end
        --          end
        --        end
      elseif sub[2] then keytype,valuetype=sub[1],sub[2]
      elseif sub[1] then valuetype=sub[1]
      else error('no subtypes found in '..k) end

      local f=function(struct)
        local newstruct,changed={}
        local checkstruct=check_one(metatype,struct)
        if not checkstruct then return false
        elseif checkstruct~=true then changed=true newstruct=checkstruct end
        --        elseif checkstruct==true then checkstruct=struct end
        for key,value in ipairs(changed and newstruct or struct) do
          local newkey=key
          if keytype then
            newkey=check_one(keytype,key)
            if not newkey then return false
            elseif newkey==true then newkey=key end
          end
          local newvalue=check_one(valuetype,value)
          if not newvalue then return false
          elseif newvalue==true then newvalue=value end
          rawset(newstruct,key,nil) rawset(newstruct,newkey,newvalue)
          if newvalue~=value or newkey~=key then changed=true  end
        end
        return changed and newstruct or true
      end
      t[k]=f
      --      rawset(t,k,f)
      return f
    end
  end,
})


local checkers=checkers
check_one=function(expected, val)
  local f = checkers[expected]
  if f then return f(val) end
  if type(val)==expected then return true end
  local mt = getmetatable(val)
  if mt and mt.__type==expected then return true end
  return false
end

local function check_many(name, expected, val)
  if expected=='?' then return true
  elseif expected=='!' then return (val~=nil)
  elseif type(expected)=='function' then return expected(val)
  elseif type(expected)~='string' then
    error 'strings or checkers expected by checks()'
  elseif val==nil and expected:sub(1,1) == '?' then return true end
  local newval,err
  for one in expected:gmatch "[^|?]+" do
    newval,err=check_one(one,val)
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
      for type in arg:gmatch'[^|?]+' do types[#types+1]=type end
      types=table.concat(types,' or ')
      error(string.format(fmt, i, fname or "?", types, type(val))..'\n'..(err or ''), 3)
    elseif newval~=true then setlocal(2,i,newval)
    end
  end
end

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

getmetatable(checkers).__newindex=function(t,k,v)
  hm._core.log.d('added type',k)
  rawset(t,k,v)
end
--checkers['list']=function(v)
--  if type(v)~='table' then return false end
--  for k,v in pairs(v) do if type(k)~='number' or floor(k)~=k then return false end end
--  return true
--end
--checkers['stringList']=function(v) if type(v)~='table' then return false end for _,s in ipairs(v) do if type(s)~='string' then return false end end return true end
--checkers['stringOrStringList']=function(v)
--  if type(v)=='string' then return {v}
--  elseif type(v)~='table' then return false end
--  for _,s in ipairs(v) do if type(s)~='string' then return false end end return true
--end
