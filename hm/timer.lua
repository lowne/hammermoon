------ OBJC -------
local c=require'objc'
local tolua,toobj,nptr=c.tolua,c.toobj,c.nptr
c.load'CoreFoundation'
c.load'Foundation'

-- these wants (3rd arg) a CFString, but kCFRunLoopDefaultMode is defined as const CFString - hence the 'r' in the patch
c.addfunction('CFRunLoopAddTimer',{retval='v','^{__CFRunLoop=}','^{__CFRunLoopTimer=}','r^{__CFString=}'})
c.addfunction('CFRunLoopRemoveTimer',{retval='v','^{__CFRunLoop=}','^{__CFRunLoopTimer=}','r^{__CFString=}'})

c.addfunction('CFRunLoopRunInMode',{retval='i','@"NSString"','d','B'})
local currentRL=c.CFRunLoopGetCurrent()
local CFAbsoluteTimeGetCurrent=c.CFAbsoluteTimeGetCurrent
local CFRunLoopAddTimer,CFRunLoopRemoveTimer=c.CFRunLoopAddTimer,c.CFRunLoopRemoveTimer
local kCFRunLoopDefaultMode=c.kCFRunLoopDefaultMode
local CFRunLoopTimerGetNextFireDate,CFRunLoopTimerSetNextFireDate=c.CFRunLoopTimerGetNextFireDate,c.CFRunLoopTimerSetNextFireDate
local pairs,pcall=pairs,pcall
local sformat=string.format




local timer=hm._core.module('timer',{
  __tostring=function(self) return sformat('hm.timer: [#%d] (%s)',self._ref,
    self._isRunning and sformat('next trigger in %.3fs',self:nextTrigger()) or 'not running') end,
  __gc=function(self)end, --TODO
})
local tmr,new,log=timer._class,timer._class._new,timer.log

-- callbacks 1. receive arbitrary data or elapsed time as argument 2. can return false to stop the timer

local runningTimers,timerCount={},0

--[[
local timerCallback=c.block(function(cftimer)
  local t=runningTimers[nptr(cftimer)] or error'timer callback with unscheduled timer!' 
  local now=CFAbsoluteTimeGetCurrent()
  local data=t._elapsed and now-t._lastTrigger or t._data  
  local ok,res=pcall(t._cb,t._data)
  if not ok then
    log.e(t,res)
    if not t._continue then t:stop() end
  elseif res==false then t:stop() end
  t._lastTrigger=now
  if not t._repeats then t:stop() t._repeats=nil end
end,'v@')

local function newTimer(delay,interval,cb,data,continueOnError)
  timerCount=timerCount+1
  local repeats,elapsed,now=interval>0,data=='elapsed',CFAbsoluteTimeGetCurrent()
  local cftimer=c.CFRunLoopTimerCreateWithHandler(nil,now+delay,interval,0,0,timerCallback)
  local o={_cftimer=cftimer,_ref=timerCount,_cb=cb,_continue=continueOnError,_isRunning=false,_repeats=repeats,_elapsed=elapsed,
    _data=data,_lastTrigger=now}
  --  timers[nptr(cftimer)]=o
  --TODO ffi.gc(nil)?
  if o._data==nil then o._data=o end
  return new(o)
end
--]]

local REPEATS,ELAPSED,CONTINUE=1,2,4
local function getTimer(cftimer) return runningTimers[nptr(cftimer)] or error'timer callback with unscheduled timer!' end
local function runCallback(t,data)
  --  local t=runningTimers[nptr(cftimer)] or error'timer callback with unscheduled timer!'
  local ok,res=pcall(t._cb,data or t._data)
  if not ok then log.e(t,res) return nil else return res end
end
local callbacks={
  [0]=function(t) runCallback(t) t:stop() t._repeats=nil end,
  [ELAPSED]=function(t)
    local now=CFAbsoluteTimeGetCurrent()
    runCallback(t,now-t._lastTrigger) t:stop() t.repeats=nil
    t._lastTrigger=now
  end,
  [REPEATS]=function(t) if not runCallback(t) then t:stop() end end,
  [REPEATS+CONTINUE]=function(t) if runCallback(t)==false then t:stop() end end,
  [REPEATS+ELAPSED]=function(t)
    local now=CFAbsoluteTimeGetCurrent()
    if not runCallback(t,now-t._lastTrigger) then t:stop() end
    t._lastTrigger=now
  end,
  [REPEATS+CONTINUE+ELAPSED]=function(t)
    local now=CFAbsoluteTimeGetCurrent()
    if runCallback(t,now-t._lastTrigger)==false then t:stop() end
    t._lastTrigger=now
  end,
}

for i,fn in pairs(callbacks) do
  callbacks[i]=c.block(function(cftimer) return fn(getTimer(cftimer)) end,'v@')
end
callbacks[CONTINUE]=callbacks[0] callbacks[CONTINUE+ELAPSED]=callbacks[ELAPSED]

local function newTimer(delay,interval,cb,data,continueOnError)
  local repeats,elapsed,continue=interval>0 and REPEATS or 0,data=='elapsed' and ELAPSED or 0,continueOnError and CONTINUE or 0
  local now=CFAbsoluteTimeGetCurrent()
  local cftimer=c.CFRunLoopTimerCreateWithHandler(nil,now+delay,interval,0,0,callbacks[repeats+elapsed+continue])
  local o={_cftimer=cftimer,_ref=timerCount,_cb=cb,_isRunning=false,_data=data,_repeats=interval>0,_lastTrigger=now}
  if o._data==nil then o._data=o end
  --TODO ffi.gc(nil)?
  return new(o)
end

function timer.new(interval,cb,data,continueOnError) return newTimer(interval,interval,cb,data,continueOnError) end

function timer.doAfter(delay,fn,data)
  --  return newTimer(delay,0,function()fn() return false end):start()
  return newTimer(delay,0,fn,data):start()--function()fn() return false end):start()
    --  return timer.new(delay,function(t)t:stop()return fn(t)end)
end

function tmr:start()
  if self._repeats==nil then log.e(self,'cannot be started again')
    --  if self._invalidated then log.e(self,'cannot be started again')
  elseif not self._isRunning then
    self._isRunning=true
    runningTimers[nptr(self._cftimer)]=self
    --    self._lastTrigger=self._lastTrigger and CFAbsoluteTimeGetCurrent() -- nope
    CFRunLoopAddTimer(currentRL,self._cftimer,c.kCFRunLoopDefaultMode)
  end
  return self
end
function tmr:stop()
  if not self._isRunning then return self end
  self._isRunning=false
  runningTimers[nptr(self._cftimer)]=nil
  CFRunLoopRemoveTimer(currentRL,self._cftimer,kCFRunLoopDefaultMode)
  return self
end

function tmr:running() return self._isRunning end
function tmr:nextTrigger()
  return CFRunLoopTimerGetNextFireDate(self._cftimer)-CFAbsoluteTimeGetCurrent()
end
function tmr:setNextTrigger(seconds)
  CFRunLoopTimerSetNextFireDate(self._cftimer,CFAbsoluteTimeGetCurrent()+seconds)
  return self
end

timer.absoluteTime=CFAbsoluteTimeGetCurrent
local currentThread=c.NSThread:currentThread()
function timer.usleep(us) return currentThread:sleepForTimeInterval(us/1000000) end
function timer._hmdestroy()
  for _,tmr in pairs(runningTimers) do tmr:stop() end
end
return timer
