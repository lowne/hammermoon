local newproxy,type,getmetatable,setmetatable,rawget,rawset=newproxy,type,getmetatable,setmetatable,rawget,rawset
local pairs,ipairs,next=pairs,ipairs,next
local tinsert,tsort,sformat=table.insert,table.sort,string.format



--package.path=package.path..';./lib/?.lua;./lib/?/init.lua'
--package.cpath=package.cpath..';./lib/?.so'



--checkers=checkers

--require'compat53'


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
    return mt and mt.__type or 'table'
  else return t end
end
require'hm._globals'
---@private
sanitizeargs=checkargs


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
    local ok,mod=xpcall(rawrequire,debug.traceback,modname)
    if ok and mod then
      loadedModules[modname]=true
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

  --  local submodules=cacheKeys()
  --  local properties,deprecated=cacheKeys(),cacheKeys()

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
    local function make_moduleSetter(setter,proptype,sanitize)
      if sanitize then return function(v) sanitizeargs(proptype) return setter(v) end
      else return function(v) checkargs(proptype) return setter(v) end end
    end
    local function make_objSetter(setter,cls,proptype,sanitize)
      if sanitize then return function(o,v) sanitizeargs(cls,proptype) setter(o,v) return o end
      else return function(o,v) checkargs(cls,proptype) setter(o,v) return o end end
    end
    checkargs('hm#module|hm#module.class|hs_compat#module','string','function','function|false|nil','?string','?boolean')
    assert(rawget(t,fieldname)==nil,'property is shadowed by existing field')
    local realsetter=setter
    if setter and type then
      realsetter=hm.type(t)=='hm#module.class' and make_objSetter(setter,tostring(t),type,sanitize)
        or make_moduleSetter(setter,type,sanitize)
    end
    t._properties[fieldname]={get=getter,set=realsetter,values=setter==nil and cacheKeys() or nil,original=getTableName(t)..'.'..fieldname}
    local capitalized=fieldname:sub(1,1):upper()..fieldname:sub(2)
    if not rawget(t,'get'..capitalized) then rawset(t,'get'..capitalized,getter) end
    if setter and not rawget(t,'set'..capitalized) then rawset(t,'set'..capitalized,realsetter) end
  end
  local function property_direct(t) return function(...) return property(t,...) end end

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
    local values=cacheKeys(isClass and {} or {[t]=fld})
    t._deprecated[fieldname]={values=values,allow=allow,key=original,msg=original..msgdeprecated..msgreplace}
    rawset(t,fieldname,nil)
  end

  ---Declare event names.
  -- Event names needn't be declared all at once; in fact a class/module A that uses class/module B is free to extend
  -- B with additional events (which will be emitted by A)
  -- @function [parent=#hm._core] declareEvents
  -- @param #module module @{<#module>} table or @{<#module.class>} table
  -- @param #eventList events event names

  local function declareEvents(t,eventList) checkargs('hm#module|hm#module.class','!listOrValue(string)')
    for _,event in ipairs(eventList) do
      event=event:lower()
      hmassertf(not t._events[event],'duplicate event declaration for %s: %s',t,event)
      hmassert(event~='any','cannot declare special event "any')
      t._events[event]=true
    end
  end

  local module__index=function(t,k)
    if type(k)~='string' then return nil end
    local f=rawget(t,'_properties')[k] if f then return f.get() end
    f=rawget(t,'_deprecated')[k] if f then warnDeprecation(f) return f.values[t] end
    f=rawget(t,'_submodules')[k] if f then f=hmrequire(f) rawset(t,k,f) return f end
  end
  local function make_class__index(cls)
    return function(self,k)
      if type(k)=='string' then
        local f=rawget(cls,'_properties')[k]
        if f then
          local values=f.values
          if values then --immutable property
            if values[self]~=nil then return values[self]
            else local v=f.get(self) values[self]=v return v end
          else return f.get(self) end
        end
        f=rawget(cls,'_deprecated')[cls] if f then warnDeprecation(f) return f.values[self] end
      end
      return cls[k]
    end
  end
  local module__newindex=function(t,k,v)
    if type(k)=='string' then
      local f=rawget(t,'_properties')[k]
      if f then if f.set then f.set(v) else error(f.original..' is read only',2) end return end -- no tail call (for checks.lua)
      if k:sub(1,2)=='on' then
        local event=k:lower():sub(3)
        local fn=v if event~='any' then fn=function(_,...) return v(...) end end --strip event arg on specific hook
        rawget(t,'handler')(fn,nil,event):start()
        return
      end
      f=rawget(t,'_deprecated')[k] if f then warnDeprecation(f) f.values[t]=v return end
    end
    return rawset(t,k,v)
  end
  local function make_class__newindex(cls)
    return function(self,k,v)
      if type(k)=='string' then
        local f=rawget(cls,'_properties')[k]
        if f then if f.set then f.set(self,v) else error(f.original..' is read only',2) end return end -- no tail call (for checks.lua)
        if k:sub(1,2)=='on' then
          local event=k:lower():sub(3)
          local fn=v if event~='any' then fn=function(_,...) return v(...) end end --strip event arg on specific hook
          rawget(cls,'handler')(self,fn,nil,event):start()
          return
        end
        f=rawget(cls,'_deprecated')[k] if f then warnDeprecation(f) f.values[self]=v return end
      end
      return rawset(self,k,v)
    end
  end

  local handlerProto={}
  do
    function handlerProto.getActive(self) return self._isActive end
    function handlerProto.setActive(self,v) if v then self:start() else self:stop() end return self end
    function handlerProto.getFn(self) return self._fn end
    function handlerProto.setFn(self,fn) self._fn=fn if fn==nil then self:stop() end return self end
    function handlerProto.getData(self) return self._data end
    local function setData(self,data) self._data=data=='handler' and self or data return self end
    handlerProto.setData=setData
    function handlerProto.getEvents(self)
      local eventList={}
      for k in pairs(self._events) do tinsert(eventList,k) end
      tsort(eventList) return eventList
    end
    local function setEvents(self,eventList)
      local events,validEvents={},self._parent._events
      for _,event in ipairs(eventList) do
        hmassertf(event=='any' or validEvents[event],'%s has no event %s',self._parent,event)
        events[event]=true
      end
      if events.any then events={any=true} end -- discard redundant events
      hmassert(next(events),'no events given')
      self._events=events
    end
    handlerProto.setEvents=function(self,eventList)
      local restart=self._isActive
      self:stop()
      setEvents(self,eventList)
      if restart then self:start() end
      return self
    end
    local handlerCount=0
    function handlerProto._newProto(parent,obj,fn,data,events)
      handlerCount=handlerCount+1
      local po={_object=obj,_parent=parent,_fn=fn,_ref=handlerCount,_isActive=false,_events={}}
      setData(po,data) if events then setEvents(po,events) end
      po._name=sformat('handler [#%d]',handlerCount)
      return po
    end
    --      function handlerProto._newModuleHandler(module,...) return new(module,nil,...) end
    --      handlerProto._newObjectHandler=new
    do
      local select=select
      local function vararg_append(last,n,first,...) if n==0 then return last else return first,vararg_append(last,n-1,...) end end
      local function emit(handlers,...)
        if handlers==nil then return end
        for _,handler in ipairs(handlers) do
          if handler._data~=nil then
            local ret=handler._fn(vararg_append(handler._data,select('#',...),...))
            if ret=='stop' then handler:stop() end
          else
            local ret=handler._fn(...)
            if ret=='stop' then handler:stop() end
          end
        end
      end
      local function handlerEmit(handlers,event,...)
        emit(handlers[event],event,...)
        return emit(handlers.any,event,...)
      end
      function handlerProto._moduleEmit(parent,event,...) checkargs('hm#module','string')
        event=event:lower()
        hmassertf(parent._events[event],'%s did not declare event %s',parent,event)
        return handlerEmit(parent._handlers,event,...)
      end
      function handlerProto._objectEmit(parent,obj,event,...) checkargs('hm#module.class','?','string')
        event=event:lower()
        hmassertf(parent._events[event],'%s did not declare event %s',parent,event)
        local handlers=parent._handlers[obj]
        return handlers and handlerEmit(handlers,event,...)
      end
  end
  do
    local tremove=table.remove
    local function removeHandler(self,handlers)
      if handlers==nil then return end
      for i,handler in ipairs(handlers) do
        if handler==self then tremove(handlers,i) return end
      end
    end
    function handlerProto._stop(self)
      if not self._isActive then return self end
      self.log.d('stopping',self)
      local handlers=self._parent._handlers
      if self._object then handlers=handlers[self._object] end
      for event in pairs(self._events) do
        removeHandler(self,handlers[event])
      end
      self._isActive=false return self
    end
  end
  do
    local tinsert=table.insert
    function handlerProto._start(self,eventList,fn,data) sanitizeargs('hm#handler','?!listOrValue(string)','?callable')
      --      self:stop()
      self.log.d(self._isActive and 'restarting' or 'starting',self)
      if not self._parent._isHandlersSetupDone then
        if self._parent._setupWatchers then self._parent._setupWatchers() end
        self._parent._isHandlersSetupDone=true
      end
      if eventList~=nil then self:stop() setEvents(self,eventList)
      elseif not next(self._events) then return log.e('handler has no events, cannot start: ',self) end
      if fn~=nil then self._fn=fn
      elseif not self._fn then return log.e('handler has no function, cannot start: ',self) end
      if data~=nil then setData(self,data) end
      local handlers=self._parent._handlers
      if self._object then
        handlers[self._object]=handlers[self._object] or {}
        handlers=handlers[self._object]
      end
      for event in pairs(self._events) do
        if handlers[event] then tinsert(handlers[event],self) else handlers[event]={self} end
      end
      self._isActive=true return self
    end
  end
  end

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
  -- @dev
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

  ---Emit a module-level event.
  -- @function [parent=#module] _emit
  -- @param #string event event name
  -- @param ... additional args to pass to event handlers

  ---Create a module-level handler.
  -- @function [parent=#module] handler
  -- @param #handlerFunction fn (optional)
  -- @param data (optional)
  -- @param #eventList events
  -- @return #hm.handler the new handler

  ---See @{hm._core.property()}
  -- @function [parent=#module] _property
  -- @param #string fieldname
  -- @param #function getter
  -- @param #function setter
  -- @param #string type
  -- @param #boolean sanitize
  -- @dev

  ---See @{hm._core.declareEvents()}
  -- @function [parent=#module] _declareEvents
  -- @param #eventList events event names
  -- @dev

  ---Implement this function to perform any required cleanup when a module is unloaded
  -- @function [parent=#module] __gc
  -- @dev

  ---Type for Hammermoon classes
  -- @type module.class
  -- @class
  -- @checker hm#module.class

  ---Create a new object.
  -- Objects created by this function have their lifecycle tracked by Hammermoon's core.
  -- @function [parent=#module.class] _new
  -- @param #table t initial values for the new object
  -- @param #string name (optional) if provided, the object will have its own logger instance with the given name
  -- @return #module.object a new object instance
  -- @dev

  ---See @{hm._core.property()}
  -- @function [parent=#module.class] _property
  -- @param #string fieldname
  -- @param #function getter
  -- @param #function setter
  -- @param #string type
  -- @param #boolean sanitize
  -- @dev

  ---See @{hm._core.declareEvents()}
  -- @function [parent=#module.class] _declareEvents
  -- @param #eventList events event names
  -- @dev

  ---Type for Hammermoon objects
  -- @type module.object
  -- @extends #module.class
  -- @field hm.logger#logger log the object logger (only if created with a name)
  -- @class

  ---Emit an object-level event.
  -- @function [parent=#module.class] _emit
  -- @param #module.class self
  -- @param #string event event name
  -- @param ... additional args to pass to event handlers

  ---Create an object-level handler.
  -- @function [parent=#module.class] handler
  -- @param #module.class self
  -- @param #handlerFunction fn (optional)
  -- @param data (optional)
  -- @param #eventList events
  -- @return #hm.handler the new handler

  ---Destroys all handlers associated with this object.
  -- @function [parent=#module.class] _destroyHandlers
  -- @param #module.class self

  ---@type module.classes
  -- @map <#string,#module.class>
  -- @dev



  ---@private
  hm.protoModule=function(name)return setmetatable({},{__type='hm#module',__name='hm.'..name}) end -- used only by logger
  require'hm.logger'.defaultLogLevel=5
  local newLogger=require'hm.logger'.new
  log=newLogger'core'
  local handlerClass
  local function make_directFunction(fn,t) return function(...) return fn(t,...) end end
  --  local function make_eventsSet()return setmetatable({},{__index={_setupHandlers=true,_destroyHandlers=true}}) end
  local function hmmodule(name,classes,submoduleNames) checkargs('string','?table','?listOrValue(string)')
    assertf(name:sub(1,3)=='hm.','invalid module name %s',name)
    log.i('Loading module',name)
    local m=setmetatable({log=newLogger(name),
      _events={},_handlers={},_properties={},_deprecated={},_submodules={}},
    {__type='hm#module',__name=name,__tostring=function()return 'module: '..name end,
      __index=module__index,__newindex=module__newindex})
    rawset(m,'_property',make_directFunction(property,m))
    rawset(m,'_declareEvents',make_directFunction(declareEvents,m))
    if classes then
      for className,objmt in pairs(classes) do
        local fullname=name..'#'..className
        if fullname=='hm.core#handler' then fullname='hm#handler' end
        checkers[fullname]=fullname
        --        log.d('added type',fullname)
        local cls=setmetatable({log=m.log,_properties=cacheKeys(),_deprecated={}},
          {__tostring=function()return fullname end,__type='hm#module.class',__name=fullname})
        rawset(cls,'_property',make_directFunction(property,cls))

        objmt.__type=fullname
        objmt.__index=make_class__index(cls)
        objmt.__newindex=make_class__newindex(cls)
        local make=function(o,name) --hmcheck('table','?string')
          setmetatable(o,objmt) o.log=name and newLogger(name) if name then o._name=name end
          log.v('allocated:',o) return o
        end
        local gc=objmt.__gc
        local new=not gc and make or function(o,name)
          -- attach gc handler to our objects; if/when luajit gets the new gc that directly allows __gc in the metatable, this will be unnecessary
          hmassert(not rawget(o,'__proxy'))
          local proxy=newproxy(true)
          getmetatable(proxy).__gc=function()log.v('collecting:',o) return gc(o) end
          rawset(o,'__proxy',proxy)
          return make(o,name)
        end
        rawset(cls,'_new',new)
        if fullname~='hm#handler' then
          rawset(cls,'_declareEvents',make_directFunction(declareEvents,cls))
          rawset(cls,'_events',{}) rawset(cls,'_handlers',cacheKeys())
          cls._isHandlersSetupDone=false --FIXME
          local oemit=handlerProto._objectEmit
          rawset(cls,'_emit',make_directFunction(handlerProto._objectEmit,cls))
          local nh=handlerClass._new
          local nph=handlerProto._newProto
          rawset(cls,'handler',function(self,fn,data,events) sanitizeargs(fullname,'?callable','?','?!listOrValue(string)')
            return nh(nph(cls,self,fn,data,events))
          end)
          rawset(cls,'_destroyHandlers',function (self)
            local handlers=cls._handlers[self]
            if handlers then for handler in pairs(handlers) do handler:destroy() end end
            cls._handlers[self]=nil
          end)
        end
        classes[className]=cls
        --        m['_class_'..className]=cls
      end
      rawset(m,'_classes',classes)
    end
    for _,sub in ipairs(submoduleNames or {}) do m._submodules[sub]=name..'.'..sub end
    local proxy=newproxy(true)
    getmetatable(proxy).__gc=function()
      log.i('Unloading module:',name) --FIXME
      if m._isHandlersSetupDone and m._destroyWatchers then m._destroyWatchers(m) end
      local gc=m.__gc
      return gc and gc(m)
    end
    rawset(m,'__proxy',proxy)
    if name~='hm.core' then
      rawset(m,'_emit',make_directFunction(handlerProto._moduleEmit,m))
      do
        local nph=handlerProto._newProto
        local nh=handlerClass._new
        rawset(m,'handler',function(fn,data,events,name) sanitizeargs('?callable','?','?!listOrValue(string)','?string')
          return nh(nph(m,nil,fn,data,events),name)
        end)
      end
      m._isHandlersSetupDone=false --FIXME
    end
    return m
  end
  checkers['hm#module']='hm#module'
  checkers['hm#module.class']='hm#module.class'


  ---Hammermoon core facilities for use by modules.
  -- @type hm._core
  -- @field hm.logger#logger log Logger instance for Hammermoon's core
  -- @static
  -- @dev


  local core=hmmodule('hm.core',{['handler']={__gc=function(self)end,__tostring=function(self)
    if self._isActive then return sformat('%s (active on %s)',self._name,self._parent)
    else return sformat('%s (inactive)',self._name) end
  end}}) --#module
  do
    handlerClass=core._classes.handler
    ---Type for Hammermoon handler objects
    -- @type hm.handler
    -- @class
    -- @checker hm#hm.handler
    local handler=handlerClass
    for k,v in pairs(handlerProto) do
      if k:sub(1,1)~='_' then handler[k]=v end
    end
    ---Whether the handler is currently active.
    -- Setting this to `false` or `nil` stops the handler; `true` starts the handler.
    -- @field [parent=#hm.handler] #boolean active
    -- @property
    handler._property('active',handler.getActive,handler.setActive,'boolean')
    ---Generic handler function.
    -- The full signature can be found on each module's documentation.
    -- @function [parent=#hm.handler] handlerFunction
    -- @param #string eventName the event being handled
    -- @param ... additional arguments sent by the emitter; the last argument is the `data` passed to `.handler()`
    -- @return #string if "stop", the handler automatically becomes inactive
    -- @prototype

    ---The handler's function.
    -- Setting this to `nil` stops the handler. Otherwise, if the handler is active,
    -- all subsequent events will be handled by the new function.
    -- @field [parent=#hm.handler] #handlerFunction fn
    -- @property
    handler._property('fn',handler.getFn,handler.setFn,'?callable')

    ---The handler's arbitrary data.
    -- This will be passed to the @{#handlerFunction} as the last argument.
    -- The special value `"handler"` will pass the handler object itself.
    -- @field [parent=#hm.handler] data
    -- @property
    handler._property('data',handler.getData,handler.setData,'?')
    ---@type eventList
    -- @list <#string>

    ---The events handled by this handler.
    -- @field [parent=#hm.handler] #eventList events
    -- @property
    handler._property('events',handler.getEvents,handler.setEvents,'!listOrValue(string)',true)

    ---Starts the handler.
    -- @function [parent=#hm.handler] start
    -- @param #hm.handler self
    -- @param #eventList events (optional)
    -- @param #handlerFunction fn (optional)
    -- @param data (optional)
    -- @return #hm.handler self
    handler.start=handlerProto._start

    ---Stops the handler.
    -- @function [parent=#hm.handler] stop
    -- @param #hm.handler self
    -- @return #hm.handler self
    handler.stop=handlerProto._stop

    ---Destroys the handler.
    -- @function [parent=#hm.handler] destroy
    -- @param #hm.handler self
    -- @return #hm.handler self
    function handler:destroy()
      self:stop()
      self._object=nil self._events=nil self._fn=nil self._data=nil
      self._parent=nil
    end

  end

  core.rawrequire=rawrequire
  core.property=property
  core.declareEvents=declareEvents
  core.deprecate=function(...)return deprecate(true,...)end
  core.disallow=function(...)return deprecate(false,...) end
  core.cacheValues=cacheValues core.cacheKeys=cacheKeys--,retainValues=retainValues,retainKeys=retainKeys}

  --  local core={rawrequire=rawrequire,
  --    property=property,deprecate=function(...)return deprecate(true,...)end,
  --    disallow=function(...)return deprecate(false,...) end,
  --    cacheValues=cacheValues,cacheKeys=cacheKeys,retainValues=retainValues,retainKeys=retainKeys}


  ---@field [parent=#hm] #hm._core _core
  hm._core=core

  setmetatable(hm,{
    __index=function(t,k)
      rawset(t,k,hmrequire('hm.'..k))
      return rawget(t,k)
    end,
    __newindex=function(t,k)error'Only Hammermoon modules can go into table hm' end,
  })

  --  hm.logger.defaultLogLevel=2
  --  log=hm.logger.new'core'
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

