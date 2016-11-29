local newproxy,type,getmetatable,setmetatable,rawget,rawset=newproxy,type,getmetatable,setmetatable,rawget,rawset
local pairs,ipairs=pairs,ipairs
local tinsert,sformat=table.insert,string.format



--package.path=package.path..';./lib/?.lua;./lib/?/init.lua'
--package.cpath=package.cpath..';./lib/?.so'



--checkers=checkers

--require'compat53'
require'hm._globals'

---@private
sanitizeargs=checkargs

--- Hammermoon main module
-- @module hm
-- @static
-- @internalchange Using the 'checks' library for userscript argument checking.
-- @internalchange Using the 'compat53' library, but syntax-level things (such as # not using __len) are still Lua 5.1

--- Hammermoon's namespace, globally accessible from userscripts
hm={} --#hm

local log --hm.logger#logger

---@field [parent=#hm] hm._os#hm._os _os
-- @private

---@field [parent=#hm] hm.types#hm.types types
-- @private

---@field [parent=#hm] hm.timer#hm.timer timer
-- @private

---Quits Hammermoon.
-- This function will make sure to properly close the Lua state, so that all the __gc metamethods will run.
--@function [parent=#hm] quit
function hm.quit()os.exit(1,1)end

---Returns the Hammermoon type of an object.
-- If `obj` is an Hammermoon @{<#module>}, @{<#module.class>}, or @{<#module.object>}, this function will return its type name
-- instead of the generic `"table"`. In all other cases this function behaves like Lua's `type()`.
-- @param obj object to get the type of
-- @return #string the object type
--@function [parent=#hm] type
function hm.type(obj)
  local t=type(obj)
  if t=='table' then
    local mt=getmetatable(obj)
    return mt.__type or 'table'
  else return t end
end


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

local function make_hmdebug()
  local rawcheckargs,rawassert,rawassertf=checkargs,assert,assertf
  return setmetatable({},{__index=hmdebug,__newindex=function(t,k,v)
    v=not(not v) --toboolean
    if rawget(hmdebug,k)==v then return end
    if k=='disableTypeChecks' then checkargs=v and rawcheckargs or function()end
    elseif k=='disableAssertions' then
      hmassert=v and rawassert or function(v)return v end
      hmassertf=v and rawassertf or function(v)return v end
    elseif k=='retainUserObjects' then
    elseif k=='cacheUIElements' then
    else error('Invalid debug field '..k) end
    log.w('hm.debug:',k,'set to',v)
    hmdebug[k]=v
  end})
end


local loadedModules={}
local userGlobals=setmetatable({},{__mode='k'})
---@private
function hm._lua_setup()
  print'[Hammermoon starting up]'

  ---@field [parent=#hm] #hm.debug debug
  hm.debug=make_hmdebug()

  local rawrequire=require
  local function hmrequire(modname)
    --    if not loadedModules[modname] then print('[Loading module: '..modname..']') end
    local ok,mod=xpcall(rawrequire,debug.traceback,modname)
    if ok and mod then
      loadedModules[modname]=true
      if type(mod)=='table' then
        local gc=rawget(mod,'__gc')
        if gc and not rawget(mod,'__proxy') then
          assert(not rawget(mod,'__proxy'))
          local proxy=newproxy(true)
          getmetatable(proxy).__gc=function()log.i('Unloading module:',modname) return gc(mod) end
          rawset(mod,'__proxy',proxy)
        end
      end
      return mod
    else error(mod) end
  end

  require=function(modname)
    if modname:sub(1,3)=='hm.' then return hmrequire(modname)
    elseif modname:sub(1,3)=='hs.' then return hmrequire('hs_compat.'..modname:sub(4))
    else return rawrequire(modname) end
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

  --[[
  local function makeLazyCaller(cls,obj)
    return setmetatable({},{
      __index=function(lazyCaller,methodName)
        local m=cls[methodName]
        assert(isCallable(m),'No such method: '..methodName)
        local caller=function(a,b,c,d,e,f,g) return function() return m(obj,a,b,c,d,e,f,g) end end
        local f=setmetatable({},{
          __index=function(_,k)
            if k=='call' then
            end
          end,
          __call=caller,
        })
        rawset(lazyCaller,methodName,f) return f
      end,
    })
  end
--]]
  local properties,deprecated=cacheKeys(),cacheKeys()
  local submodules={}
  local module__index=function(t,k)
    local f=properties[t] and properties[t][k] if f then return f.get() end
    f=deprecated[t] and deprecated[t][k] if f then warnDeprecation(f) return f.values[t] end
    f=submodules[t] and submodules[t][k] if f then f=hmrequire(f) rawset(t,k,f) return f end
    return nil
  end
  local function makeclass__index(cls)
    return function(self,k)
      local f=properties[cls] and properties[cls][k]
      if f then
        local values=f.values
        if values then --immutable property
          if values[self]~=nil then return values[self]
          else local v=f.get(self) values[self]=v return v end
        else return f.get(self) end
      end
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
  -- @param #function setter setter function; if `false` the property is read-only; if `nil` the property is
  --        immutable and will be cached after the first query.
  -- @param #string type field type (for writable fields)
  -- @param #boolean sanitize if `true`, use `sanitizeargs` instead of `checkargs`
  -- @apichange Doesn't exist in Hammerspoon; this also allows fields in modules and objects to be trivially type-checked.
  -- @internalchange Modules don't need to handle properties internally.

  local function getTableName(t) return getmetatable(t).__name end
  local function property(t,fieldname,getter,setter,type,sanitize)
    checkargs('hm#module|hm#module.class|hs_compat#module','string','function','function|false|nil','?string','?boolean')
    assert(rawget(t,fieldname)==nil,'property is shadowed by existing field')
    properties[t]=properties[t] or {}
    local realsetter=setter
    if setter and type then
      if hm.type(t)=='hm#module.class' then
        local clsname=tostring(t)
        realsetter=function(o,v) (sanitize and sanitizeargs or checkargs)(clsname,type) setter(o,v) return o end
      else realsetter=function(v,b) (sanitize and sanitizeargs or checkargs)(type)return setter(v) end end
    end
    properties[t][fieldname]={get=getter,set=realsetter,values=setter==nil and cacheKeys() or nil,original=getTableName(t)..'.'..fieldname}
    local capitalized=fieldname:sub(1,1):upper()..fieldname:sub(2)
    if not rawget(t,'get'..capitalized) then rawset(t,'get'..capitalized,getter) end
    if setter and not rawget(t,'set'..capitalized) then rawset(t,'set'..capitalized,realsetter) end
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

  local function deprecate(allow,t,fieldname,replacement) checkargs('boolean','hm#module|hm#module.class|hs_compat#module','string','?string')
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

  ---Hammermoon core facilities for use by extensions.
  --@type hm._core
  --@field hm.logger#logger log Logger instance for Hammermoon's core
  --@static
  --@dev
  local core={rawrequire=rawrequire,
    property=property,deprecate=function(...)return deprecate(true,...)end,
    disallow=function(...)return deprecate(false,...) end,
    cacheValues=cacheValues,cacheKeys=cacheKeys,retainValues=retainValues,retainKeys=retainKeys}

  ---@private
  core.protoModule=function(name)return setmetatable({},{__type='hm#module',__name='hm.'..name}) end -- used only by logger

  ---@field [parent=#hm] #hm._core _core
  hm._core=core

  setmetatable(hm,{
    __index=function(t,k)
      rawset(t,k,hmrequire('hm.'..k))
      return rawget(t,k)
    end,
    __newindex=function(t,k)error'Only Hammermoon modules can go into table hm' end,
  })

  checkers['hm#module']='hm#module'
  checkers['hm#module.class']='hm#module.class'
  hm.logger.defaultLogLevel=2
  log=hm.logger.new'core'
  log.d'Autoload extensions ready'
  core.log=log

  ---For compatibility with Hammerspoon userscripts
  hs=setmetatable({},{
    __index=function(t,k)
      rawset(t,k,hmrequire('hs_compat.'..k))
      return rawget(t,k)
    end,
    __newindex=function(t,k)error'Not allowed' end,
  })

  ---Declare a new Hammermoon module.
  -- Use this function to create the table for your module.
  -- If your module instantiates objects, you should pass `classes` (the values can just be empty tables),
  -- and retrieve the metatable for your objects (and the constructor) via the `_classes[<CLASSNAME>]` field
  -- of the returned module table. Note that the `__gc` metamethod of a class, if used, must be *already*
  -- in the class table passed to this function (i.e. you cannot add it afterwards) for Hammermoon's allocation debugging to work.
  -- @function [parent=#hm._core] module
  -- @param #string name module name (without the `"hm."` prefix)
  -- @param #table classes a map with the initial metatables (as values) for the module's classes (whose names are the map's keys),
  -- if any; the metatables can can contain `__tostring`, `__eq`, `__gc`, etc. This table, suitably instrumented, will be
  -- available in the resuling module's `_classes` field
  -- @param #table submodules a plain list of submodule names, if any, that will be automatically required as the respective
  -- fields in this module are accessed
  -- @return #module the "naked" table for the new module, ready to be filled with functions
  -- @usage local mymodule=hm._core.module('mymodule',{myclass={}})
  -- @usage local myclass=mymodule._classes.myclass
  -- @usage function mymodule.myfunction(param) ... end
  -- @usage function mymodule.construct(args) ... return myclass._new(...) end
  -- @usage function myclass:mymethod() ... end
  -- @usage ...
  -- @usage return mymodule -- at the end of the file
  -- @apichange Doesn't exist in Hammerspoon
  -- @internalchange Allows allocation tracking, properties, deprecation; handled by core

  ---Type for Hammermoon modules.
  -- Hammermoon modules (usually created via `hm._core.module()`) can be `require`d normally
  -- (`local somemod=require'hm.somemod'`) or loaded directly via the the global `hm` namespace
  -- (`hm.somemod.somefn(...)`).
  -- @type module
  -- @field #module.classes _classes The classes (i.e., object metatables) declared by this module
  -- @field hm.logger#logger log The extension's module-level logger instance
  -- @class
  -- @checker hm#module

  ---Implement this function to perform any required cleanup when a module is unloaded
  -- @function [parent=#module] __gc
  -- @dev

  ---Type for Hammermoon object classes
  -- @type module.class
  -- @dev
  -- @class
  -- @checker hm#module.class

  ---@type module.classes
  -- @map <#string,#module.class>

  ---Type for Hammermoon objects
  -- @type module.object
  -- @field hm.logger#logger log the object logger (only if created with a name)
  -- @dev
  -- @class


  local newLogger=hm.logger.new
  local function hmmodule(name,classes,submoduleNames) checkargs('string','?table','?listOrValue(string)')
    assert(name:sub(1,3)=='hm.')
    log.i('Loading module',name)
    local m=setmetatable({log=newLogger(name)},
      {__type='hm#module',__name=name,__tostring=function()return 'module: '..name end,
        __index=module__index,__newindex=module__newindex})
    if classes then
      for className,objmt in pairs(classes) do
        local fullname=name..'#'..className
        checkers[fullname]=fullname
        --        log.d('added type',fullname)
        local cls=setmetatable({},{__tostring=function()return fullname end,__type='hm#module.class',__name=fullname})
        objmt.__type=fullname
        objmt.__index=makeclass__index(cls)
        objmt.__newindex=makeclass__newindex(cls)
        local make=function(o,name) --hmcheck('table','?string')
          setmetatable(o,objmt) o.log=name and newLogger(name) if name then o._name=name end
          log.v('allocated:',o) return o
        end
        local gc=objmt.__gc
        local new=not gc and make or function(o,name)
          -- attach gc handler to our objects; if/when luajit gets the new gc that directly allows __gc in the metatable, this will be unnecessary
          assert(not rawget(o,'__proxy'))
          local proxy=newproxy(true)
          getmetatable(proxy).__gc=function()log.v('collecting:',o) return gc(o) end
          rawset(o,'__proxy',proxy)
          return make(o,name)
        end
        ---Create a new instance.
        --Objects created by this function have their lifecycle tracked by Hammermoon's core.
        --@function [parent=#module.class] _new
        --@param #table t initial values for the new object
        --@param #string name (optional) if provided, the object will have its own logger instance with the given name
        --@return #module.object a new object instance
        --@dev
        cls._new=new
        --        cls._metatable=classmt
        classes[className]=cls
        --        m['_class_'..className]=cls
      end
      m._classes=classes
    end
    submodules[m]={}
    for _,sub in ipairs(submoduleNames or {}) do submodules[m][sub]=name..'.'..sub end
    return m
  end

  core.module=hmmodule

  ---@private
  core.hs_compat_module=function(name)
    return setmetatable({},{__type='hs_compat#module',__name='hs.'..name,__index=module__index,__newindex=module__newindex})
  end
  checkers['hs_compat#module']='hs_compat#module'

  require'hm.types.coll'

  setmetatable(_G,{__newindex=function(t,k,v) userGlobals[k]=true rawset(t,k,v) end}) --capture globals for cleanup
  --  require'user'
  --  local ok,err=xpcall(require,debug.traceback,'user')
  --  if not ok then print('\n\n[USERSCRIPT ERROR] ----------- \n'..err..'\n-------------------------------\n\n') hm.quit() end

end
---This is necessary for clean teardown when using certain OS features - apparently these must be invalidated/released/etc
-- before the NSApp is killed. Alternatively, os.exit(1,1) will clean up the Lua state nicely, but it is unknown
-- if this has any ill effect on the still-quitting NSApp.
-- @private
function hm._lua_destroy()
  for k in pairs(userGlobals) do rawset(_G,k,nil) end
  for k in pairs(loadedModules) do rawset(package.loaded,k,nil) end
  rawset(_G,'hm',nil)
  collectgarbage'collect'collectgarbage'collect'
end

---@private
hm.__proxy=newproxy(true)
getmetatable(hm.__proxy).__gc=function()
  print'[Hammermoon shutting down]'
end

