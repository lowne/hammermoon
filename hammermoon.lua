local c=require'objc'
c.load'Foundation'
c.load'ApplicationServices.HIServices'
c.addfunction('AXIsProcessTrustedWithOptions', {retval='B','@"NSDict"'})
if not c.AXIsProcessTrustedWithOptions(c.toobj{AXTrustedCheckOptionPrompt=1}) then
  print'Please enable accessibility!'
  os.exit()
end

package.path=package.path..';hammermoon/?.lua;hammermoon/?/init.lua;' --./extensions/?.lua;./extensions/?/init.lua'

local tinsert,sformat=table.insert,string.format
local log
local destroyers={}
local function luaSetup()
  print'----- Hammermoon starting up -----'
  local rawerror=error
  ---globals
  errorf=function(fmt,...)error(sformat(fmt,...))end
  assertf=function(v,fmt,...)if not v then errorf(fmt,...) end end
  printf=function(fmt,...)return print(sformat(fmt,...)) end
  ---debug options
  local hmdebug={
    retain_user_objects=true,
    cache_uielements=true,
  }
  --  error=function(str)print(debug.traceback('ERROR: '..str,2))os.exit()end
  local rawrequire=require
  require=function(modname)
    local pfx=modname:sub(1,3)
    if pfx=='hs.' or pfx=='hm.' then modname='extensions.'..modname:sub(4) end
    local mod=rawrequire(modname)
    if type(mod)=='table' then tinsert(destroyers,rawget(mod,'_hmdestroy')) end
    return mod
  end
  hm=setmetatable({
    --    _newWatcher=newWatcher,
    },{__index=function(t,k)
      print('-----       Loading extension: '..k)
      local ok,res=xpcall(require,debug.traceback,'extensions.'..k)
      if ok and res then rawset(t,k,res) return res
      else print(res) return nil end
    end})
  hs=hm
  hm.logger.defaultLogLevel=5
  log=hm.logger.new'core'
  log.d'Autoload extensions ready'
  local newproxy,getmetatable,setmetatable=newproxy,getmetatable,setmetatable
  local function hmstaticmodule(name)
  end
  --  local classes={}
  local function hmmodule(name,classmt)
    local log=hm.logger.new(name)
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
      cls._new=new
    end
    return {log=log,_class=cls}
  end
  local function cacheValues(t) return setmetatable(t or {},{__mode='v'}) end
  local function cacheKeys(t) return setmetatable(t or {},{__mode='k'}) end
  local function retainValues() return hmdebug.retain_user_objects and {} or cacheValues() end
  local function retainKeys() return hmdebug.retain_user_objects and {} or cacheKeys() end
  local core={rawrequire=require,log=log,module=hmmodule,
    cacheValues=cacheValues,cacheKeys=cacheKeys,retainValues=retainValues,retainKeys=retainKeys,
  --    class=function(name) return setmetatable({},{__tostring=function()return name end}) end, -- class table for objects
  --    object=hmobject,
  }
  core.sharedWorkspace=c.NSWorkspace:sharedWorkspace()
  core.notificationCenter=core.sharedWorkspace.notificationCenter

  local workspaceObservedEvents={}
  local workspaceObserverCallbacks={}
  log.d'Setting up workspace notification receiver'
  local workspaceObserverBlock=c.block(function(notif)
    local event,info=c.tolua(notif.name),notif.userInfo
    for _,cb in ipairs(workspaceObserverCallbacks[event]) do cb(event,info) end
  end,'v@')
  core.workspaceObservers={}
  function core.registerWorkspaceObserver(event,cb,priority)
    if not workspaceObservedEvents[event] then
      log.d('Adding observer for workspace notification',event)
      tinsert(core.workspaceObservers,core.notificationCenter:addObserverForName_object_queue_usingBlock(event,nil,nil,workspaceObserverBlock))
      workspaceObservedEvents[event]=true
      workspaceObserverCallbacks[event]={}
    end
    log.v('Registering callback for workspace notification',event)
    if priority then tinsert(workspaceObserverCallbacks[event],1,cb)
    else tinsert(workspaceObserverCallbacks[event],cb) end
  end
  setmetatable(core,{__index=function(t,k)
    if k=='systemWideAccessibility' then
      local axsw=c.AXUIElementCreateSystemWide()
      assert(axsw,'no systemwide accessibility object')
      rawset(t,k,axsw)
      return axsw
    else return nil end
  end})
  hm._core=core
  --[[
  -- preload ax modules
  local preload={'uielement','window','application'}
  for _,mod in ipairs(preload) do
    local r={}
    hm[mod]=r
    package.loaded['extensions.'..mod]=r
  end
--]]  

  --  local ok,user=pcall(require'user')
  --  if ok then return user() end
  require'user'()
end

local function luaDestroy()
  for _,destroyer in ipairs(destroyers) do destroyer() end
  --  for ext in pairs(package.loaded) do if ext._hmdestroy then ext._hmdestroy() end end
  local core=hm._core
  log.d'Removing observers for workspace notifications'
  for _,obs in ipairs(core.workspaceObservers) do core.notificationCenter:removeObserver(obs,nil) end
end
c.load'AppKit'
luaSetup()
luaDestroy()
--require'app'(luaSetup,luaDestroy)

