------ OBJC -------
local c=require'objc'
local tolua,toobj,nptr=function(o) return o~=nil and c.tolua(o) or nil end,c.toobj,c.nptr
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


--local timers=hm._core.cacheValues()
local runningTimers={}
local timerCount=0
-- callbacks 1. receive arbitrary data as argument 2. can return false to stop the timer
local timerCallback=c.block(function(cftimer)
  local t=runningTimers[nptr(cftimer)]
  assert(t)
  --  if t._continue then return t._cb(t._data) end
  local ok,res=pcall(t._cb,t._data)
  if not ok then
    log.e(t,res)
    if not t._continue then t:stop() end
  elseif res==false then t:stop() end
  --  if res==false or (ok==false and not t._continue)
  --  if not ok then log.e(res) t:stop() end
end,'v@')



local function newTimer(delay,interval,cb,data,continueOnError)
  timerCount=timerCount+1
  local cftimer=c.CFRunLoopTimerCreateWithHandler(nil,CFAbsoluteTimeGetCurrent()+delay,interval,0,0,timerCallback)
  local o={_cftimer=cftimer,_ref=timerCount,_cb=cb,_data=data,_continue=continueOnError,_isRunning=false,_lastTrigger=0}
  --  timers[nptr(cftimer)]=o
  --TODO ffi.gc(nil)?
  return new(o)
end
function timer.new(interval,cb,data,continueOnError) return newTimer(interval,interval,cb,data,continueOnError) end

function timer.doAfter(delay,fn)
  return newTimer(delay,0,function()fn() return false end):start()
    --  return timer.new(delay,function(t)t:stop()return fn(t)end)
end

function tmr:start()
  if self._isRunning then return self end
  self._isRunning=true
  runningTimers[nptr(self._cftimer)]=self
  CFRunLoopAddTimer(currentRL,self._cftimer,c.kCFRunLoopDefaultMode)
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
