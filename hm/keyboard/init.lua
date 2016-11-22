---Create and manage keyboard shortcuts.
-- @module hm.keyboard
-- @static

---------- OBJC ----------
local c=require'objc'
local tolua,toobj,nptr=c.tolua,c.toobj,c.nptr
c.load'Carbon.HIToolbox'
--local EVENTS=require'bridge.hitoolbox_events'

local next,pairs,ipairs=next,pairs,ipairs
local sformat,tinsert=string.format,table.insert
local bor,band=bit.bor,bit.band
local now=require'hm.timer'.absoluteTime
local coll=require'hm.types.coll'
local keyEvent=require'hm._os.events'.key

local activeContexts,enabledContexts={},{}

---@type hm.keyboard
-- @extends hm#module
local keyboard=hm._core.module('keyboard',{context={
  __tostring=function(self)return sformat('hotkey context: [%s] (%s)',self._name,
    activeContexts[self] and 'active' or (enabledContexts[self] and 'inactive' or 'disabled')) end,
  __gc=function(self)assert(not activeContexts[self])end,
},hotkey={
  __tostring=function(self)return sformat('hotkey: %s',self._msg)end,
  __gc=function(self)assert(not self._ctx._activeHotkeys[self])end,
}})
local log=keyboard.log

keyboard.keys=require'hm.keyboard.keys'
keyboard.symbols=require'hm.keyboard.symbols'
for k,v in pairs(keyboard.symbols) do keyboard.keys[v]=assert(keyboard.keys[k]) end
keyboard.symbols['hyper']='✧'
local keyCodes=keyboard.keys
local keySymbols=keyboard.symbols

---Type for hotkey objects
-- @type hotkey
-- @extends hm#module.object
-- @class
local hk=keyboard._classes.hotkey

---@field [parent=#hotkey] #context _ctx
--@private

---Type for context objects
-- @type context
-- @extends hm#module.object
-- @class
local ctx=keyboard._classes.context

---@type hotkeySet
--@map <#hotkey,#boolean>
--@private

---@field [parent=#context] #hotkeySet _activeHotkeys
--@private

---@field [parent=#context] #hotkeySet _enabledHotkeys
--@private
local retainedContexts=hm._core.retainKeys()

---@type hotkeys
--@map <#string,hm.types.coll#coll.list>
--@private
local hotkeys={}

---
-- @return #context
function keyboard.newContext(name,windowfilter)
  local o=ctx._new({_enabledHotkeys={},_activeHotkeys={}},name)
  if windowfilter then retainedContexts[o]=true end
  return o
end



local keyNames=coll.filter(keyCodes,function(v,k)return type(k)=='string'end)
local HYPER_FLAG={}
keyNames['hyper']=HYPER_FLAG
keyNames['✧']=HYPER_FLAG
local keyOrder=getmetatable(keyboard.keys).order
function ctx:newHotkey(keys,message)
  keys=keys:lower()
  local prevSeparator
  local codes,concurrent,trigger={},{}
  local d,again=1,true
  while again and d<#keys+1 do
    again=nil
    --    print('looking in',keys:sub(d))
    for name,code in pairs(keyNames) do
      local s,e=keys:find(name,d,true)
      if s==d then
        --        print('found',name)
        if e==#keys then --last one
          if prevSeparator=='+' then concurrent[code]=true
          else trigger=code end
          d=#keys+1 again=true
          break
        else
          local next=keys:sub(e+1,e+1)
          --          print(next)
          if next=='+' or next=='-' or next==' ' then
            if next=='+' then
              assert(code~=HYPER_FLAG,'invalid format')
              concurrent[code]=true
              prevSeparator=next
            else
              assert(prevSeparator~='+','invalid format')
              codes[code]=true
            end
            prevSeparator=next
            d=e+2 again=true
            break
          end
        end
      end
    end
    assert(again,'invalid format')
  end
  assert(d>#keys,'invalid format?')
  if codes[HYPER_FLAG] then
    codes[HYPER_FLAG]=nil codes[keyCodes.cmd]=true codes[keyCodes.alt]=true codes[keyCodes.ctrl]=true codes[keyCodes.shift]=true
  end
  local idx=''
  for _,code in ipairs(keyOrder) do
    if codes[code] then idx=idx..(keySymbols[keyCodes[code]] or keyCodes[code]..'-') end
  end
  if next(concurrent) then
    idx=idx..'['
    for _,code in ipairs(keyOrder) do
      if concurrent[code] then idx=idx..(keySymbols[keyCodes[code]] or keyCodes[code])..'+' end
    end
    idx=idx:sub(1,-2)..']'
  else
    for _,code in ipairs(keyOrder) do
      if trigger==code then idx=idx..(keySymbols[keyCodes[code]] or keyCodes[code]) end
    end
  end
  if not hotkeys[idx] then hotkeys[idx]=coll() end
  local msg=idx..(message and ': '..message or '')
  print(msg)
  local o=hk._new{_idx=idx,_msg=msg,_codes=codes,_trigger=trigger,_concurrent=next(concurrent) and concurrent,
    _ctx=self,_isEnabled=false,_isActive=false}
  return o
end

local keycodesTree={}
local currentBranch=keycodesTree
local function rebuildTree()
  keycodesTree={}
  local function copybut(t,notk)local r={} for k,v in pairs(t) do if k~=notk then r[k]=v end end return r end
  local function add(tree,codes,trigger,concurrent,leaf)
    if not next(codes) then
      if concurrent then
        for code in pairs(concurrent) do
          add(tree,copybut(concurrent,code),code,nil,leaf)
        end
      elseif trigger then tree[trigger]=leaf return end
    else
      for code in pairs(codes) do
        tree[code]=tree[code] or {}
        add(tree[code],copybut(codes,code),trigger,concurrent,leaf)
      end
    end
  end
  for ctx in pairs(activeContexts) do
    for hk in pairs(ctx._activeHotkeys) do
      add(keycodesTree,hk._codes,hk._trigger,hk._concurrent,hk)
    end
  end
  currentBranch=keycodesTree
end

local function hkActivate(self,batch,force)
  if not force and self._isActive then return end
  local hks=hotkeys[self._idx]
  if hks[#hks]==self then return end --already at the top of the stack
  self._isActive=true self._ctx._activeHotkeys[self]=true
  hks:iremove(self)
  if #hks>0 then log.i(hks[#hks],'disabled (shadowed)') end
  hks:insert(self)
  log.i(self,'enabled')
  if not batch then return rebuildTree() end
end
function hk:enable()
  self._isEnabled=true self._ctx._enabledHotkeys[self]=true
  hkActivate(self) return self
end
local function hkDeactivate(self,batch)
  if not self.active then return end
  self._isActive=false self._ctx._activeHotkeys[self]=nil
  local hks=hotkeys[self._idx]
  local action=hks[#hks]==self --was top dog
  hks:iremove(self)
  log.i(self,'disabled')
  if action then
    if #hks>0 then log.i(hks[#hks],'reenabled (was shadowed)') end
    if not batch then return rebuildTree() end
  end
end
function hk:disable(self)
  self._isEnabled=false self._ctx._enabledHotkeys[self]=nil
  hkDeactivate(self) return self
end

function hk:onPress(fn) self.pressed=fn return self end

function ctx:enable()
  if activeContexts[self] then return end
  activeContexts[self]=true
  for hk in pairs(self._enabledHotkeys) do hkActivate(hk,true) end
  return rebuildTree()
end

function ctx:disable()
  if not activeContexts[self] then return end
  activeContexts[self]=nil
  for hk in pairs(self._activeHotkeys) do hkDeactivate(hk,true) end
  return rebuildTree()
end

function ctx:bind(keys,fn)
  return self:newHotkey(keys):enable():onPress(fn)
end

local CONCURRENT_KEYPRESSES_THRESHOLD=0.015
local keyStates,OOB_FLAG,WAITRELEASE_FLAG={},{},{}
local pendingKeys={}

--local function emitOnePending(tmr)
--  local code=pendingKeys[1]
--  if code then
--    print('emitting',keyCodes[code.down or code.up],code.down and 'down' or 'up')
--    keyEvent(code.down or code.up,code.down):post()
--  else tmr:cancel() end
--  table.remove(pendingKeys,1)
--end
--local pendingTimer=require'hm.timer'.new(emitOnePending)

--local function emitPending() if not pendingTimer.scheduled then return pendingTimer:runEvery(0.05,0.05) end end
local function emitPending()
  for _,code in ipairs(pendingKeys) do
    log.v('[ >>]',code.down and '[PRS]' or '[REL]',keyCodes[code.down or code.up])
    keyEvent(code.down or code.up,code.down):post()
  end
  pendingKeys={}
end
local max=math.max
local function keyPressed(code)
  log.v('[PRS]',keyCodes[code])
  if currentBranch.waitRelease then return true end --eat everything
  currentBranch=currentBranch[code]
  if not currentBranch then
    log.v('-----OOB')
    emitPending()
    currentBranch=OOB_FLAG
    log.v('[ > ] [PRS]',keyCodes[code])
    return
  end
  tinsert(pendingKeys,{down=code})
  if currentBranch._concurrent then
    print'concurrent!'
    local last,delta=keyStates[code],0
    for ccode in pairs(currentBranch._concurrent) do
      print('a code is',ccode,last,keyStates[ccode])
      delta=max(delta,last-assert(keyStates[ccode]))
    end
    print(delta)
    if delta>CONCURRENT_KEYPRESSES_THRESHOLD then
      log.v('-----too slow, OOB')
      emitPending()
      currentBranch=OOB_FLAG
      return true
    else
      if currentBranch.pressed then
        currentBranch.pressed()
      end
      pendingKeys={}
      currentBranch={waitRelease=code,released=currentBranch.released,_trigger=code}
      log.v('-----waitRelease')
      return true
    end
  end
  if currentBranch.pressed then
    currentBranch.pressed()
    pendingKeys={}
    if not currentBranch.interstitial then
      currentBranch={waitRelease=code,released=currentBranch.released,_trigger=code}
      log.v('-----waitRelease')
    end
  end
  return true
end

local function keyReleased(code)
  log.v('[REL]',keyCodes[code])
  local willEat
  if currentBranch.waitRelease then
    if currentBranch.waitRelease~=code then return true
    else willEat=true end
  end
  if currentBranch.released and currentBranch._trigger==code then
    pendingKeys={}
    currentBranch.released()
    willEat=true
  elseif currentBranch~=OOB_FLAG and not currentBranch.waitRelease then
    tinsert(pendingKeys,{up=code})
    willEat=true
  end
  currentBranch=keycodesTree --restart from root now
  for k,v in pairs(keyStates) do
    currentBranch=currentBranch[k] or OOB_FLAG
  end
  if currentBranch==OOB_FLAG or currentBranch==keycodesTree then
    emitPending()
  end
  if not willEat then
    log.v('[ > ] [REL]',keyCodes[code])
  end
  if currentBranch==OOB_FLAG then log.v('-----OOB')
  elseif currentBranch==keycodesTree then log.v('READY') end
  return willEat
end
local function keyRepeated(code)
  if currentBranch==OOB_FLAG then return
  elseif currentBranch.repeated then currentBranch.repeated() return true
  else tinsert(pendingKeys,{down=code}) return true end
end

local callback={
  keyDown=function(ev)
    local code=ev:getKeyCode()
    if keyStates[code] then return keyRepeated(code)
    else keyStates[code]=now() return keyPressed(code) end
  end,
  keyUp=function(ev)
    local code=ev:getKeyCode()
    keyStates[code]=nil return keyReleased(code)
  end,
  flagsChanged=function(ev)
    for key,state in pairs(ev:getMods()) do
      local code=keyCodes[key]
      if not state~=not keyStates[code] then
        if state then keyStates[code]=now() return keyPressed(code)
        else keyStates[code]=nil return keyReleased(code) end
      end
    end
  end,
}
local taps={}
for _,evType in ipairs{'keyDown','keyUp','flagsChanged'} do taps[evType]=hm._os.events.eventtap({evType},callback[evType]):start() end

keyboard.globalContext=keyboard.newContext('global')
keyboard.globalContext:enable()
function keyboard.bind(keys,fn)
  return keyboard.globalContext:bind(keys,fn)
end

return keyboard
