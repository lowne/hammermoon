
local c=require'objc'
c.load'AppKit'
local tolua=c.tolua

local tinsert,sformat=table.insert,string.format

---@function [parent=#global] errorf
--@param #string fmt
--@param ...
errorf=function(fmt,...)error(sformat(fmt,...))end

---@function [parent=#global] assertf
--@param #string fmt
--@param ...
assertf=function(v,fmt,...)if not v then errorf(fmt,...) end end

---@function [parent=#global] printf
--@param #string fmt
--@param ...
printf=function(fmt,...)return print(sformat(fmt,...)) end

--package.path=package.path..';./lib/?.lua;./lib/?/init.lua'
--require'compat53'

--- Hammermoon main module
--@module hm
--@static

local log --hm.logger#logger
local destroyers={}

--- Hammermoon's namespace, globally accessible from userscripts
hm={} --#hm

---For compatibility with Hammerspoon userscripts
hs=hm

---@private
function hm._lua_setup()
  print'----- Hammermoon starting up -----'
  local newproxy,getmetatable,setmetatable,rawget,rawset,type=newproxy,getmetatable,setmetatable,rawget,rawset,type

  ---Debug options
  --@type hm.debug
  --@field #boolean retain_user_objects if false, user objects (timers, watchers, etc.) will get gc'ed unless the userscript keeps a global reference
  --@field #boolean cache_uielements if false, uielement objects (including applications and windows) are not cached
  --@static
  --@dev
  --@apichange doesn't exist in Hammerspoon
  local hmdebug={
    retain_user_objects=true,
    cache_uielements=true,
  }
  ---@field [parent=#hm] #hm.debug debug
  hm.debug=hmdebug

  local rawrequire=require
  require=function(modname)
    local pfx=modname:sub(1,3)
    if pfx=='hs.' then modname='hm.'..modname:sub(4) end
    local mod=rawrequire(modname)
    if type(mod)=='table' then tinsert(destroyers,rawget(mod,'_hmdestroy')) end
    return mod
  end

  local function cacheValues(t) return setmetatable(t or {},{__mode='v'}) end
  local function cacheKeys(t) return setmetatable(t or {},{__mode='k'}) end
  local function retainValues() return hmdebug.retain_user_objects and {} or cacheValues() end
  local function retainKeys() return hmdebug.retain_user_objects and {} or cacheKeys() end

  local moduleNames=cacheKeys()
  local properties={}
  local deprecationWarnings=cacheValues()
  local deprecatedFields={}

  local function warnDeprecation(f)
    if not f.allow then error(f.msg)
    elseif not deprecationWarnings[f.key] then
      deprecationWarnings[f.key]={} -- don't bother us for a bit
      log.w(f.msg)
    end
  end
  local fancymt={
    __index=function(t,k)
      if properties[t][k] then return properties[t][k].get()
      elseif deprecatedFields[t] and deprecatedFields[t][k] then
        local f=deprecatedFields[t][k]
        warnDeprecation(f)
        return f.value
      else return nil end
    end,
    __newindex=function(t,k,v)
      if properties[t] and properties[t][k] then properties[t][k].set(v)
      elseif deprecatedFields[t] and deprecatedFields[t][k] then
        local f=deprecatedFields[t][k]
        warnDeprecation(f)
        f.value=v
      else rawset(t,k,v) end
    end,
  }
  ---Add a user-facing field to a module with a custom getter and setter
  -- @function [parent=#hm._core] property
  -- @param #module module
  -- @param #string fieldname
  -- @param #function getter
  -- @param #function setter

  local function property(t,fieldname,getter,setter)
    assert(getmetatable(t)==fancymt,'table was not created by hm._core.module()')
    assert(type(getter)=='function' and type(setter)=='function','invalid getter or setter')
    assert(rawget(t,fieldname)==nil,'property is shadowed by existing field')
    properties[t]=properties[t] or {}
    properties[t][fieldname]={get=getter,set=setter}
  end
  local function deprecate(allow,t,fieldname,replacement)
    assert(getmetatable(t)==fancymt,'table was not created by hm._core.module()')
    local fld=rawget(t,fieldname)
    if not fld then error(rawget(properties[t][fieldname])and 'NYI: deprecate property' or 'no such field:'..fieldname) end
    local key=sformat('%s.%s',moduleNames[t],fieldname)
    if type(fld)=='function' then
      local f={key=key,allow=allow,msg=sformat('%s() is deprecated. Use %s instead',key,replacement)}
      rawset(t,fieldname,function(...)
        warnDeprecation(f)
        return fld(...)
      end)
    else
      deprecatedFields[t]=deprecatedFields[t] or {}
      deprecatedFields[t][fieldname]={value=fld,key=key,allow=allow,msg=sformat('%s is deprecated. Use %s instead',key,replacement)}
      rawset(t,fieldname,nil)
    end
  end

  local function fancyTable(t) return setmetatable(t or {},fancymt) end


  ---Hammermoon core facilities for use by extensions.
  --@type hm._core
  --@field hm.logger#logger log Logger instance for Hammermoon's core
  --@static
  --@dev

  ---Deprecate a field or function of a module
  -- @function [parent=#hm._core] deprecate
  -- @param #module module
  -- @param #string fieldname
  -- @param #string replacement The replacement field or function to direct users to

  ---Disallow a field or function of a module (after deprecation)
  -- @function [parent=#hm._core] disallow
  -- @param #module module
  -- @param #string fieldname
  -- @param #string replacement The replacement field or function to direct users to

  local core={rawrequire=require,protoModule=fancyTable, -- used only by logger
    property=property,deprecate=function(...)return deprecate(true,...)end,
    disallow=function(...)return deprecate(false,...) end,
    cacheValues=cacheValues,cacheKeys=cacheKeys,retainValues=retainValues,retainKeys=retainKeys}

  ---@field [parent=#hm] #hm._core _core
  hm._core=core

  setmetatable(hm,
    {__index=function(t,k)
      print('-----       Loading extension: '..k)
      local ok,res=xpcall(require,debug.traceback,'hm.'..k)
      if ok and res then rawset(t,k,res) return res
      else print(res) return nil end
    end,
    __newindex=function(t,k)error'Only Hammermoon extensions can go into table hm' end,
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
  --of the returned module table. Note that the `__gc` operator, if present, *must* be already
  --in `classmt` (i.e. you cannot add it afterwards) for Hammermoon's allocation debugging to work.
  --@function [parent=#hm._core] module
  --@param #string name module name (without the '`hm.` prefix)
  --@param #table classmt initial metatable for the module's class (if any); can contain `__tostring`, `__eq`, `__gc`, etc
  --@return #module the "naked" table for the new module, ready to be filled with functions
  --@usage local mymodule=hm._core.module('mymodule',{})
  --@usage local myclass=mymodule._class
  --@usage function mymodule.myfunction(param) ... end
  --@usage function mymodule.construct(args) ... return myclass._new(...) end
  --@usage function myclass:mymethod() ... end
  --@usage ...
  --@usage return mymodule -- at the end of the file

  ---Type for Hammermoon extensions.
  --Hammermoon extensions (usually created via `hm._core.module()`) can be `require`d normally
  --(`local someext=require'hm.someext'`) or loaded directly via the the global `hm` namespace
  --(`hm.someext.somefn(...)`).
  --@type module
  --@field #module.class _class The class for the extension's objects
  --@field hm.logger#logger log The extension's module-level logger instance

  ---Type for Hammermoon objects
  --@type module.class
  --@dev



  local function hmmodule(name,classmt)
    local mlog=hm.logger.new(name)
    local clsname='<'..name..'>'
    local cls=setmetatable({},{__tostring=function()return clsname end})
    if classmt then
      classmt.__index=cls
      local make=function(o) setmetatable(o,classmt) log.v('allocated:',o) return o end
      local gc=classmt.__gc
      local new=not gc and make or function(o)
        -- attach gc handler to our objects; if/when luajit gets the new gc that directly allows __gc in the metatable, this will be unnecessary
        assert(not o.__proxy)
        local proxy=newproxy(true)
        getmetatable(proxy).__gc=function()log.v('collected:',o) return gc(o) end
        o.__proxy=proxy
        return make(o)
      end
      ---Create a new instance.
      --Objects created by this function have their lifecycle tracked by Hammermoon's core.
      --@function [parent=#module.class] _new
      --@param #table t initial values for the new object
      --@return a new object instance
      --@dev
      cls._new=new
    end
    local m=fancyTable{log=mlog,_class=cls}
    moduleNames[m]=name
    return m
  end

  core.module=hmmodule
  core.sharedWorkspace=c.NSWorkspace:sharedWorkspace()

  ---@type notificationCenter

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
  --[[
  local ipairs=ipairs
  local workspaceObserverBlock=c.block(function(notif)
    local event,info=c.tolua(notif.name),notif.userInfo
    for _,cb in ipairs(workspaceObserverCallbacks[event]) do cb(event,info) end
  end,'v@')
  core.wsNCObservers={}
  function core.registerWorkspaceObserver(event,cb,priority)
    if not workspaceObservedEvents[event] then
      log.d('Adding observer for workspace notification',event)
      tinsert(core.workspaceObservers,core.wsNotificationCenter:addObserverForName_object_queue_usingBlock(event,nil,nil,workspaceObserverBlock))
      workspaceObservedEvents[event]=true
      workspaceObserverCallbacks[event]={}
    end
    log.v('Registering callback for workspace notification',event)
    if priority then tinsert(workspaceObserverCallbacks[event],1,cb)
    else tinsert(workspaceObserverCallbacks[event],cb) end
  end
  --]]

  ---`AXUIElementCreateSystemWide()` instance
  --@field [parent=#hm._core] #cdata systemWideAccessibility

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
  print(ok,user)
  if ok then return user() end
end

---@private
function hm._lua_destroy()
  for _,destroyer in ipairs(destroyers) do destroyer() end
  --  for ext in pairs(package.loaded) do if ext._hmdestroy then ext._hmdestroy() end end
  local core=hm._core
  log.d'Removing observers for notifications'
  for _,nc in ipairs{core.defaultNotificationCenter,core.wsNotificationCenter} do
    for _,obs in ipairs(nc._observers) do nc._nc:removeObserver(obs,nil) end
  end
  --  for _,obs in ipairs(core.wsNCObservers) do core.wsNotificationCenter:removeObserver(obs,nil) end
end

return hm
