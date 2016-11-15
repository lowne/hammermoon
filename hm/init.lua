
local c=require'objc'
c.load'AppKit'
local tolua=c.tolua

local tinsert,sformat=table.insert,string.format

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

---@dev
inspect=function(t,inline,depth)
  if type(t)~='table' then return print(t)
  else return print(require'lib.inspect'(t,{depth=depth or (inline and 3 or 6),newline=inline and ' ' or '\n'})) end
end

package.path=package.path..';./lib/?.lua;./lib/?/init.lua'
package.cpath=package.cpath..';./lib/?.so'
require'checks'
require'compat53'
local type,floor,getmetatable=type,math.floor,getmetatable
checkers['uint']=function(v)return type(v)=='number' and v>0 and floor(v)==v end
checkers['false']=function(v)return v==false end
checkers['true']=function(v)return v==true end
checkers['positive']=function(v) return type(v)=='number' and v>0 end
checkers['positiveOrZero']=function(v) return type(v)=='number' and v>=0 end

--- Hammermoon main module
--@module hm
--@static
--@internalchange Using the 'checks' library for userscript argument checking.
--@internalchange Using the 'compat53' library, but syntax-level things (such as # not using __len) are still Lua 5.1

local log --hm.logger#logger
--local destroyers={}

--- Hammermoon's namespace, globally accessible from userscripts
hm={} --#hm


---Quits Hammermoon.
-- This function will make sure to properly close the Lua state, so that all the __gc metamethods will run.
--@function [parent=#hm] quit
function hm.quit()os.exit(1,1)end

---Returns the Hammermoon type of an object.
-- If `obj` is an Hammermoon @{<#module>}, @{<#module.class>}, or module object, this function will return its type name
-- instead of the generic `"table"`. In all other cases this function behaves like Lua's `type()`.
-- @param obj object to get the type of
-- @return #string the object type
--@function [parent=#hm] type
function hm.type(obj)
  local t=type(obj)
  if t=='table' then
    local mt=getmetatable(t)
    return mt.__type or 'table'
  else return t end
end

---@private
function hm._lua_setup()
  print'----- Hammermoon starting up -----'
  local newproxy,setmetatable,rawget,rawset=newproxy,setmetatable,rawget,rawset

  ---Debug options
  --@type hm.debug
  --@static
  --@dev
  --@apichange Doesn't exist in Hammerspoon

  ---Retain user objects internally (default `true`).
  -- User objects (timers, watchers, etc.) are retained internally by default, so
  -- userscripts needn't worry about their lifecycle.
  -- If falsy, they will get gc'ed unless the userscript keeps a global reference.
  -- @field [parent=#hm.debug] #boolean retainUserObjects
  -- @internalchange User objects are retained

  ---Cache uielement objects (default `true`).
  -- Uielement objects (including applications and windows) are cached internally for performance; this can be disabled.
  -- @field [parent=#hm.debug] #boolean cacheUIElements
  -- @internalchange Uielements are cached

  ---Disable type checks (default `false`).
  -- If set to `true`, type checks are disabled for slightly better performance.
  -- @field [parent=#hm.debug] #boolean disableTypeChecks
  -- @internalchange Centralized switch for type checking - Hammermoon modules should all use `hmcheck()`

  ---Disable assertions (default `false`).
  -- If set to `true`, assertions are disabled for slightly better performance.
  -- @field [parent=#hm.debug] #boolean disableAssertions
  -- @internalchange Centralized switch for assertion checking - Hammermoon modules should all use `hmassert()`

  local hmdebug={retainUserObjects=true,cacheUIElements=true,disableTypeChecks=false,disableAssertions=false}
  local rawchecks,rawassert,rawassertf=checks,assert,assertf

  ---@private
  hmcheck=checks
  ---@private
  hmassert=assert
  ---@private
  hmassertf=assertf
  ---@field [parent=#hm] #hm.debug debug
  hm.debug=setmetatable({},{__index=hmdebug,__newindex=function(t,k,v)
    v=not(not v)
    if rawget(hmdebug,k)==v then return end
    if k=='disableTypeChecks' then hmcheck=v and rawchecks or function()end
    elseif k=='disableAssertions' then hmassert=v and rawassert or function()end hmassertf=v and rawassertf or function()end
    elseif k=='retainUserObjects' then
    elseif k=='cacheUIElements' then
    else error('Invalid debug field '..k) end
    log.w('hm.debug:',k,'set to',v)
    hmdebug[k]=v
  end})

  local rawrequire=require
  require=function(modname)
    if modname:sub(1,3)=='hs.' then modname='hs_compat.'..modname:sub(4) end
    local mod=rawrequire(modname)
    if type(mod)=='table' then
      --      tinsert(destroyers,rawget(mod,'_hmdestroy'))
      local gc=rawget(mod,'__gc')
      if gc then
        assert(not rawget(mod,'__proxy'))
        local proxy=newproxy(true)
        getmetatable(proxy).__gc=function()mod.log.i('Unloading') return gc(mod) end
        rawset(mod,'__proxy',proxy)
      end
    end
    return mod
  end

  local function cacheValues(t) return setmetatable(t or {},{__mode='v'}) end
  local function cacheKeys(t) return setmetatable(t or {},{__mode='k'}) end
  local function retainValues() return hmdebug.retainUserObjects and {} or cacheValues() end
  local function retainKeys() return hmdebug.retainUserObjects and {} or cacheKeys() end

  local deprecationWarnings=cacheValues()
  local function warnDeprecation(f)
    if not f.allow then error(f.msg,3)
    elseif not deprecationWarnings[f.key] then log.w(f.msg) end
    deprecationWarnings[f.key]={} -- don't bother us for a bit
  end

  local properties,deprecated=cacheKeys(),cacheKeys()
  local module__index=function(t,k)
    local f=properties[t] and properties[t][k] if f then return f.get() end
    f=deprecated[t] and deprecated[t][k] if f then warnDeprecation(f) return f.values[t] end
    return nil
  end
  local function makeclass__index(cls)
    return function(self,k)
      local f=properties[cls] and properties[cls][k] if f then return f.get(self) end
      f=deprecated[cls] and deprecated[cls][k] if f then warnDeprecation(f) return f.values[self] end
      return cls[k]
    end
  end
  local module__newindex=function(t,k,v)
    local f=properties[t] and properties[t][k]
    if f then if f.set then f.set(v) else error(f.original..' is read only',2) end return end -- no tail call (for checks.lua)
    f=deprecated[t] and deprecated[t][k] if f then warnDeprecation(f) f.values[t]=v return end
    return rawset(t,k,v)
  end
  local function makeclass__newindex(cls)
    return function(self,k,v)
      local f=properties[cls] and properties[cls][k]
      if f then if f.set then f.set(self,v) else error(f.original..' is read only',2) end return end -- no tail call (for checks.lua)
      f=deprecated[cls] and deprecated[cls][k] if f then warnDeprecation(f) f.values[self]=v return end
      return rawset(self,k,v)
    end
  end

  ---Add a property to a module or class.
  -- This function will add to the module or class a user-facing field that uses custom getter and setter.
  -- @function [parent=#hm._core] property
  -- @param #module module @{<#module>} table or @{<#module.class>} table
  -- @param #string fieldname desired field name
  -- @param #function getter getter function
  -- @param #function setter setter function or `false` (to make the property read-only)
  -- @apichange Doesn't exist in Hammerspoon
  -- @internalchange Modules don't need to handle properties internally.

  local function getTableName(t) return getmetatable(t).__name end
  local function property(t,fieldname,getter,setter) checks('hm#module|hm#module.class|hs_compat#module','string','function','function|boolean')
    assert(rawget(t,fieldname)==nil,'property is shadowed by existing field')
    properties[t]=properties[t] or {}
    properties[t][fieldname]={get=getter,set=setter,original=getTableName(t)..'.'..fieldname}
    local capitalized=fieldname:sub(1,1):upper()..fieldname:sub(2)
    rawset(t,'get'..capitalized,getter)
    if setter then rawset(t,'set'..capitalized,setter) end
  end

  ---Deprecate a field or function of a module or class
  -- @function [parent=#hm._core] deprecate
  -- @param #module module @{<#module>} table or @{<#module.class>} table
  -- @param #string fieldname field or function name
  -- @param #string replacement the replacement field or function to direct users to
  -- @apichange Doesn't exist in Hammerspoon
  -- @internalchange Deprecation facility

  ---Disallow a field or function of a module or class (after deprecation)
  -- @function [parent=#hm._core] disallow
  -- @param #module module @{<#module>} table or @{<#module.class>} table
  -- @param #string fieldname field or function name
  -- @param #string replacement the replacement field or function to direct users to
  -- @apichange Doesn't exist in Hammerspoon
  -- @internalchange Deprecation facility

  local function deprecate(allow,t,fieldname,replacement) checks('boolean','hm#module|hm#module.class|hs_compat#module','string','?string')
    local isClass=hm.type(t)=='hm#module.class'
    local fld=assert(isClass or rawget(t,fieldname),'no such field: '..fieldname)
    local original=getTableName(t)..'.'..fieldname
    if type(fld)=='function' then original=original..'()' end
    local msgdeprecated=allow and ' is deprecated' or ' is no longer supported'
    local msgreplace=replacement and '; use '..replacement..' instead' or ''
    deprecated[t]=deprecated[t] or {}
    local values=cacheKeys(isClass and {} or {[t]=fld})
    deprecated[t][fieldname]={values=values,allow=allow,key=original,msg=original..msgdeprecated..msgreplace}
    rawset(t,fieldname,nil)
  end

  --  local function fancyTable(t) return setmetatable(t or {},fancymt) end

  ---Hammermoon core facilities for use by extensions.
  --@type hm._core
  --@field hm.logger#logger log Logger instance for Hammermoon's core
  --@static
  --@dev
  local core={rawrequire=require,
    property=property,deprecate=function(...)return deprecate(true,...)end,
    disallow=function(...)return deprecate(false,...) end,
    cacheValues=cacheValues,cacheKeys=cacheKeys,retainValues=retainValues,retainKeys=retainKeys}

  ---@private
  core.protoModule=function(name)return setmetatable({},{__type='hm#module',__name='hm.'..name}) end -- used only by logger

  ---@field [parent=#hm] #hm._core _core
  hm._core=core

  setmetatable(hm,{
    __index=function(t,k)
      print('-----       Loading extension: hm.'..k)
      local ok,res=xpcall(require,debug.traceback,'hm.'..k)
      if ok and res then rawset(t,k,res) return res
      else print(res) return nil end
    end,
    __newindex=function(t,k)error'Only Hammermoon extensions can go into table hm' end,
  })

  ---For compatibility with Hammerspoon userscripts
  hs=setmetatable({},{
    __index=function(t,k)
      print('-----       Loading compatibility wrapper for Hammerspoon extension: hs.'..k)
      local ok,res=xpcall(require,debug.traceback,'hs_compat.'..k)
      if ok and res then rawset(t,k,res) return res
      else print(res) return nil end
    end,
    __newindex=function(t,k)error'Not allowed' end,
  })


  hm.logger.defaultLogLevel=5
  log=hm.logger.new'core'
  log.d'Autoload extensions ready'
  core.log=log

  --  local function deprecate()

  ---Declare a new Hammermoon extension.
  --Use this function to create the table for your module.
  --If your module instantiates objects, you should pass `classmt` (even just an empty table),
  --and retrieve the metatable for your objects (and the constructor) via the `_class` field
  --of the returned module table. Note that the `__gc` metamethod, if present, *must* be already
  --in `classmt` (i.e. you cannot add it afterwards) for Hammermoon's allocation debugging to work.
  --@function [parent=#hm._core] module
  --@param #string name module name (without the `"hm."` prefix)
  --@param #table classmt initial metatable for the module's class (if any); can contain `__tostring`, `__eq`, `__gc`, etc
  --@return #module the "naked" table for the new module, ready to be filled with functions
  --@usage local mymodule=hm._core.module('mymodule',{})
  --@usage local myclass=mymodule._class
  --@usage function mymodule.myfunction(param) ... end
  --@usage function mymodule.construct(args) ... return myclass._new(...) end
  --@usage function myclass:mymethod() ... end
  --@usage ...
  --@usage return mymodule -- at the end of the file
  --@apichange Doesn't exist in Hammerspoon
  --@internalchange Allows allocation tracking, properties, deprecation; handled by core

  ---Type for Hammermoon extensions.
  --Hammermoon extensions (usually created via `hm._core.module()`) can be `require`d normally
  --(`local someext=require'hm.someext'`) or loaded directly via the the global `hm` namespace
  --(`hm.someext.somefn(...)`).
  --@type module
  --@field #module.class _class The class for the extension's objects
  --@field hm.logger#logger log The extension's module-level logger instance
  --@class

  ---Type for Hammermoon objects
  --@type module.class
  --@dev
  --@class

  ---Implement this function to perform any required cleanup when a module is unloaded
  --@function [parent=#module] __gc
  --@dev

  local function hmmodule(name,classmt,withLogger) --TODO object logger
    local mlog=hm.logger.new(name)
    local clsname='#'..name
    local cls=setmetatable({},{__tostring=function()return clsname end,__type='hm#module.class',__name='hm.'..name..'#'..name})
    if classmt then
      --      classNames[cls]='hm.'..name..'#'..name
      classmt.__type='hm.'..name..'#'..name
      classmt.__index=makeclass__index(cls)
      classmt.__newindex=makeclass__newindex(cls)
      local make=function(o) setmetatable(o,classmt) log.v('allocated:',o) return o end
      local gc=classmt.__gc
      local new=not gc and make or function(o)
        -- attach gc handler to our objects; if/when luajit gets the new gc that directly allows __gc in the metatable, this will be unnecessary
        assert(not rawget(o,'__proxy'))
        local proxy=newproxy(true)
        getmetatable(proxy).__gc=function()log.v('collected:',o) return gc(o) end
        rawset(o,'__proxy',proxy)
        return make(o)
      end
      ---Create a new instance.
      --Objects created by this function have their lifecycle tracked by Hammermoon's core.
      --@function [parent=#module.class] _new
      --@param #table t initial values for the new object
      --@return a new object instance
      --@dev
      cls._new=new
      cls._metatable=classmt
    end
    local m=setmetatable({log=mlog,_class=classmt and cls},
      {__type='hm#module',__name='hm.'..name,__index=module__index,__newindex=module__newindex})
    --    moduleNames[m]='hm.'..name
    --    properties[m]={} deprecated[m]={}
    return m
  end

  core.module=hmmodule
  ---@private
  core.hs_compat_module=function(name)
    return setmetatable({},{__type='hs_compat#module',__name='hs.'..name,__index=module__index,__newindex=module__newindex})
  end
  ---The shared `NSWorkspace` instance
  core.sharedWorkspace=c.NSWorkspace:sharedWorkspace() -- #cdata

  ---@type notificationCenter
  --@class

  log.d'Setting up workspace notification receiver'
  local ipairs=ipairs
  local function makeHMNC(nc)
    local callbacks={} --store in a closure for the block
    return {
      _nc=nc,_events={},_callbacks=callbacks,_observers={},
      _block=c.block(function(notif)
        local event,info=tolua(notif.name),notif.userInfo
        for _,cb in ipairs(callbacks[event]) do cb(event,info) end
      end,'v@'),
      ---@function [parent=#notificationCenter] register
      --@param #notificationCenter self
      --@param #string event
      --@param #function cb
      --@param #boolean priority
      --@dev
      --@internalchange Centralized callback registry for notification centers, to be used by extensions.

      register=function(self,event,cb,priority)
        assert(type(event)=='string')
        if not self._events[event] then
          log.d('Adding observer for notification',event)
          tinsert(self._observers,self._nc:addObserverForName_object_queue_usingBlock(event,nil,nil,self._block))
          self._events[event]=true
          self._callbacks[event]={}
        end
        log.v('Registering callback for notification',event)
        if priority then tinsert(self._callbacks[event],1,cb)
        else tinsert(self._callbacks[event],cb) end
      end
    }
  end
  ---The shared workspace's Notification Center.
  --@field [parent=#hm._core] #notificationCenter wsNotificationCenter
  core.wsNotificationCenter=makeHMNC(core.sharedWorkspace.notificationCenter)
  ---The default Notification Center.
  --@field [parent=#hm._core] #notificationCenter defaultNotificationCenter
  core.defaultNotificationCenter=makeHMNC(c.NSNotificationCenter:defaultCenter())

  ---`AXUIElementCreateSystemWide()` instance
  --@field [parent=#hm._core] #cdata systemWideAccessibility
  --@internalchange Instance to be used by extensions.

  setmetatable(core,{__index=function(t,k)
    if k=='systemWideAccessibility' then
      local axsw=c.AXUIElementCreateSystemWide()
      assert(axsw,'no systemwide accessibility object')
      rawset(t,k,axsw)
      return axsw
    else return nil end
  end})

  --[[
  -- preload ax modules
  local preload={'uielement','window','application'}
  for _,mod in ipairs(preload) do
    local r={}
    hm[mod]=r
    package.loaded['extensions.'..mod]=r
  end
--]]  

  local ok,user=pcall(require,'user')
  --  print(ok,user)
  if ok then return user() end
end

---@private
function hm._lua_destroy()
  log.i'Shutting down'
  --  for _,destroyer in ipairs(destroyers) do log.i'Shutting down'destroyer() end
  local core=hm._core
  for _,nc in ipairs{core.defaultNotificationCenter,core.wsNotificationCenter} do
    log.d'Removing observers for notifications'
    for _,obs in ipairs(nc._observers) do nc._nc:removeObserver(obs,nil) end
    nc._observers=nil
  end
  core.defaultNotificationCenter=nil core.wsNotificationCenter=nil
end

---@private
hm.__proxy=newproxy(true)
getmetatable(hm.__proxy).__gc=hm._lua_destroy

return hm
