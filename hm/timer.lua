---Schedule asynchronous execution of functions in the future.
-- @module hm.timer
-- @static
-- @apichange Fully overhauled module; all timers are of the 'delayed' sort for maximum flexibility.
-- @internalchange Don't bother with NSTimer intermediates, we abstract directly from CFRunLoopTimer

------ OBJC -------
local c=require'objc'
local tolua,toobj,nptr=c.tolua,c.toobj,c.nptr
c.load'CoreFoundation'
c.load'Foundation'

-- these wants (3rd arg) a CFString, but kCFRunLoopDefaultMode is defined as const CFString - hence the 'r' in the patch
c.addfunction('CFRunLoopAddTimer',{retval='v','^{__CFRunLoop=}','^{__CFRunLoopTimer=}','r^{__CFString=}'})
c.addfunction('CFRunLoopRemoveTimer',{retval='v','^{__CFRunLoop=}','^{__CFRunLoopTimer=}','r^{__CFString=}'})
--c.addfunction('CFRunLoopRunInMode',{retval='i','@"NSString"','d','B'})

local currentRL=c.CFRunLoopGetCurrent()
local CFAbsoluteTimeGetCurrent=c.CFAbsoluteTimeGetCurrent
local CFRunLoopAddTimer,CFRunLoopRemoveTimer=c.CFRunLoopAddTimer,c.CFRunLoopRemoveTimer
local kCFRunLoopDefaultMode=c.kCFRunLoopDefaultMode
local CFRunLoopTimerGetNextFireDate,CFRunLoopTimerSetNextFireDate=c.CFRunLoopTimerGetNextFireDate,c.CFRunLoopTimerSetNextFireDate
local type,ipairs,pairs,tonumber,pcall=type,ipairs,pairs,tonumber,pcall
local tostring,sformat,floor=tostring,string.format,math.floor
local date=os.date


local DISTANT_FUTURE=315360000 -- 10 years (roughly)
local NOT_SCHEDULED_INTERVAL_THRESHOLD=283824000 -- 9 years
local HIGH_FREQUENCY_THRESHOLD=1 -- (seconds) inclusive
--local PREDICATE_CHECK_DEFAULT_INTERVAL=1 -- bad idea

local nextTrigger -- fw decl
local function nextTriggerToString(self)
  local delta=nextTrigger(self)
  if not delta then return 'not scheduled' end
  local h,m,s=floor(delta/3600),floor(delta/60)%60,delta<10 and sformat('%.2f',delta%60) or floor(delta%60)
  h,m=h>0 and tostring(h)..'h ' or '',m>0 and tostring(m)..'m ' or ''
  return sformat('%s in %s%s%ss',self._isPredicate and 'check predicate' or 'scheduled to execute',h,m,s)
end
local function timeOfDayToString(time) time=time%86400
  return sformat('%02d:%02d:%02d',floor(time/3600),floor(time/60)%60,floor(time/60))
end
---@type hm.timer
-- @extends hm#module
local timer=hm._core.module('timer',{
  __tostring=function(self) return sformat('timer: [#%d] (%s)',self._ref,nextTriggerToString(self)) end,
  __gc=function(self)return self:cancel()end,
})
local log=timer.log


local INTERVAL_PATTERNS={'??d??h---','-??h??m--','--??m??s-','??d----','-??h---','--??m--','---??s-','----????ms'}
local LOCALTIME_PATTERNS={'-??:??--','-????--','-??:??:??-'}
do for _,patt in ipairs{INTERVAL_PATTERNS,LOCALTIME_PATTERNS} do for i,s in ipairs(patt) do
  patt[i]='^%s*'..(s:gsub('%?[dhms]','%0%%s*'):gsub('m%%s%*s','ms')
    :gsub('%?%?%?%?ms','(%%d%%d?%%d?%%d?)ms')
    :gsub('%?%?%?%?','(%%d?%%d)(%%d%%d)')
    :gsub('%?%?','(%%d%%d?)')
    :gsub('%-','()'))..'%s*$'
end end end
local function parseTimeString(time,patterns)
  if type(time)=='string' then
    time=time:lower()
    local d,h,m,s,ms
    for _,pattern in ipairs(patterns) do d,h,m,s,ms=time:match(pattern) if d then break end end
    if not d then return nil end--error('invalid time string '..time,3) end
    if type(d)=='number' then d=0 end --remove "missing" captures
    if type(h)=='number' then h=0 end
    if type(m)=='number' then m=0 end
    if type(s)=='number' then s=0 end
    if type(ms)=='number' then ms=0 end
    d=tonumber(d) h=tonumber(h) m=tonumber(m) s=tonumber(s) ms=tonumber(ms)
    if h>=24 or m>=60 or s>=60 then return nil end--error('invalid time string '..time,3) end
    time=d*86400+h*3600+m*60+s+(ms/1000)
  end
  if type(time)~='number' or time<0 then return nil end--error('invalid time',3) end
  return time
end
local function parseInterval(s)return parseTimeString(s,INTERVAL_PATTERNS)end
local function parseLocalTime(s)return parseTimeString(s,LOCALTIME_PATTERNS)end
---A string describing a time of day.
-- The following are valid formats: `"HH:MM:SS"`, `"HH:MM"` or `"HHMM"` - they represent a time of day in hours, minutes, seconds (24-hour clock)
-- You can also use a plain number (in seconds after midnight) wherever this type is expected.
--
-- Examples: `"8:00:00"` or `"800"` or `28800` (in seconds).
-- @type timeOfDayString
-- @extends #string
checkers['hm.timer#timeOfDayString']=function(s) return parseLocalTime(s) and true or false end

---A string describing a time interval.
-- The following are valid formats: `"DDdHHh"`, `"HHhMMm"`, `"MMmSSs"`, `"DDd"`, `"HHh"`, `"MMm"`, `"SSs"`, `"NNNNms"` - they represent
-- an interval in days, hours, minutes, seconds and/or milliseconds.
-- You can also use a plain number (in seconds) wherever this type is expected.
--
-- Examples: `"1m30s"` or `90` (in seconds); `"1500ms"` or `1.5`.
-- @type intervalString
-- @extends #string
checkers['hm.timer#intervalString']=function(s) return parseInterval(s) and true or false end


---Returns the number of seconds since midnight local time.
-- @function [parent=#hm.timer] localTime
-- @return #number number of seconds, with millisecond precision or better
-- @internalchange high precision
function timer.localTime() local tnow=date('*t') return tnow.sec+tnow.min*60+tnow.hour*3600+CFAbsoluteTimeGetCurrent()%1 end

---Returns the number of seconds since an arbitrary point in the distant past.
-- This function should only be used for measuring time intervals. The starting point is Jan 1 2001 00:00:00 GMT, so *not* the UNIX epoch.
-- @function [parent=#hm.timer] absoluteTime
-- @return #number number of seconds, with millisecond precision or better
function timer.absoluteTime() return CFAbsoluteTimeGetCurrent() end

---Converts to number of seconds
-- @function [parent=#hm.timer] toSeconds
-- @param #string timeString a @{<#timeOfDayString>} or @{<#intervalString>}
-- @return #number number of seconds in the interval (if @{<#intervalString>}) or after midnight (if @{<#timeOfDayString>})
function timer.toSeconds(timeString) hmcheck'hm.timer#intervalString|hm.timer#timeOfDayString'
  return parseInterval(timeString) or parseLocalTime(timeString)
end

local currentThread=c.NSThread:currentThread()
---Halts all processing for a given interval.
-- **WARNING**: this function will stop *all* processing by Hammermoon.
-- For anything other than very short intervals, use @{hm.timer.new()} with a callback instead.
-- @function [parent=#hm.timer] sleep
-- @param #number s interval in seconds
function timer.sleep(s) hmcheck'positive'
  if s>=0.1 then log.w('hm.timer.sleep() stops *all* processing by Hammermoon! For longer intervals, use hm.timer.new() with a callback instead.') end
  return currentThread:sleepForTimeInterval(s)
end

---Type for timer objects.
-- A timer holds an execution unit that can be scheduled for running later in time in various ways via its `:run...()` methods.
-- After being scheduled a timer can be unscheduled (thus prevented from running) via its [`:cancel()`](@[hm.timer#(timer).cancel]) method.
-- @type timer
-- @extends hm#module.class
-- @class
local tmr=timer._class
local new=tmr._new

local runningTimers=hm._core.retainValues()
local timerCount=0

---Creates a new timer.
-- @param #timerFunction fn a function to be executed later
-- @param data (optional) arbitrary data that will be passed to `fn`; if the special string `"elapsed"`, `fn` will be passed the time in seconds since the previous execution (or creation)
-- @return #timer a new timer object
-- @apichange All `hs.timer` constructors are covered by the new `:run...()` methods
function timer.new(fn,data) hmcheck'function'
  timerCount=timerCount+1
  local o=new{_ref=timerCount,_runcb=fn,_timercb=fn,_data=data,isRunning=false,_lastTrigger=CFAbsoluteTimeGetCurrent(),_elapsed=data=='elapsed' or nil}
  log.d('Created',o) return o
end

---A function that will be executed by a timer.
-- @function [parent=#hm.timer] timerFunction
-- @param #timer timer the timer that scheduled execution of this function
-- @param data `data` passed to `timer.new()` or, if `data` was `"elapsed"`, elapsed time in seconds since last execution
-- @prototype
-- @apichange Timer callbacks can receive the timer itself and arbitrary data (or the elapsed time) as arguments.


local function start(self,nextTrigger)
  CFRunLoopTimerSetNextFireDate(self._timer,nextTrigger)
  if self._isRunning then log.v('Rescheduled',self) return end
  self._isRunning=true
  log.v('Scheduled',self)
  runningTimers[nptr(self._timer)]=self
  CFRunLoopAddTimer(currentRL,self._timer,kCFRunLoopDefaultMode)
end

local function stop(self)
  if not self._isRunning or not self._timer then return end
  self._isRunning=false
  log.d('Unscheduled',self)
  runningTimers[nptr(self._timer)]=nil
  CFRunLoopRemoveTimer(currentRL,self._timer,kCFRunLoopDefaultMode)
end

local function run(self)
  local now=CFAbsoluteTimeGetCurrent()
  if self._interval==0 then stop(self) -- one-off
  elseif self._interval then start(self,now+self._interval) end --reschedule
  log.v('Executing',self)
  local ok,res=pcall(self._runcb,self,self._elapsed and now-self._lastTrigger or self._data)
  self._lastTrigger=now
  if not ok then
    if not self._continueOnError then stop(self) error(res) end
    return log.e(self,'Error on run:',res)
  else return res end
end

local function getTimer(cftimer) return runningTimers[nptr(cftimer)] or error'timer callback with unscheduled timer!' end
--local timerCallback=c.block(function(cftimer) return getTimer(cftimer):_timercb() end,'v@')
local timerCallback=function(cftimer,_) return getTimer(cftimer):_timercb() end
local function makeTimer(self,interval,timercb)
  local highFreq=interval>0 and interval<=HIGH_FREQUENCY_THRESHOLD or nil
  if self._timer and highFreq~=self._highFrequency then
    stop(self) self._timer=nil -- have the wrong sort of timer, throw away the old one
  end
  if not self._timer then
    self._timer=c.CFRunLoopTimerCreate(nil,0,highFreq and interval or DISTANT_FUTURE,0,0,timerCallback,nil)
    self._highFrequency=highFreq
  end
  self._interval=not highFreq and interval or nil
  self._timercb=timercb or run
  self._isPredicate=timercb and true or nil
end


---Executes the timer now.
-- @function [parent=#timer] run
-- @param #timer self
function tmr:run() hmcheck'hm.timer#timer' run(self) end --just for kicks

---Unschedule a timer.
-- The timer's @{<#timerFunction>} will not be executed again until you call one of its `:run...()` methods.
-- @function [parent=#timer] cancel
-- @param #timer self
-- @apichange Timers can be rescheduled freely without needing to create new ones (unlike with `hs.timer:stop()`)
function tmr:cancel() hmcheck'hm.timer#timer' stop(self) end

--TODO?
--function ftr:pause()
--  if not self._isRunning or not self._timer then return end
--  CFRunLoopTimerSetNextFireDate(self._timer,DISTANT_FUTURE)
--end

--function tmr:destroy() hmcheck'hm.timer#timer' stop(self) timers[self]=nil self._isDestroyed=true end

---`true` if the timer is scheduled for execution.
-- Setting this to `false` or `nil` unschedules the timer.
-- @field [parent=#timer] #boolean scheduled
-- @property
-- @apichange `<#hs.timer>:running()`, with some differences.
hm._core.property(tmr,'scheduled',
  function(self)return self._isRunning or false end,
  function(self,v)hmcheck('?','?false') stop(self)
  end)

nextTrigger=function(self) hmcheck'hm.timer#timer'
  if not self._timer or not self._isRunning then return nil end
  local delta=CFRunLoopTimerGetNextFireDate(self._timer)-CFAbsoluteTimeGetCurrent()
  return delta<NOT_SCHEDULED_INTERVAL_THRESHOLD and delta or nil
end
local function setNextTrigger(self,delay) hmcheck('hm.timer#timer','?false|hm.timer#intervalString')
  if not delay then return stop(self) end
  if not self._timer then makeTimer(self,0) end
  return start(self,CFAbsoluteTimeGetCurrent()+parseInterval(delay))
end
---The timer's scheduled next execution time, in seconds from now.
-- If this value is `nil`, the timer is currently unscheduled.
-- You cannot set this value to a negative number; setting it to `0` triggers timer execution right away;
-- setting it to `nil` unschedules the timer.
-- @field [parent=#timer] #number nextRun
-- @property
-- @apichange `<#hs.timer>:nextTrigger()`, with some differences.
hm._core.property(tmr,'nextRun',nextTrigger,setNextTrigger)
---The timer's last execution time, in seconds since.
-- If the timer has never been executed, this value is the time since creation.
-- @field [parent=#timer] #number elapsed
-- @readonlyproperty
-- @apichange Was `<#hs.timer>:nextTrigger()` when negative, but only if the timer was not running.
hm._core.property(tmr,'elapsed',function(self)return CFAbsoluteTimeGetCurrent()-self._lastTrigger end,false)

--[[
---Schedules execution of the timer at a given time of day.
--
-- @function [parent=#timer] runAt
-- @param #timer self
-- @param #timeOfDayString time
function tmr:runAt(time) hmcheck('hm.timer#timer','hm.timer#timeOfDayString')
  time=parseLocalTime(time)
  local now=timer.localTime()
  if time<=now then time=time+86400 end
  log.i(self,'will run at',timeOfDayToString(time))
  makeTimer(self,0) return start(self,time)
end
--]] --unless these are persisted, HM can't be Reminders.app so this is pointless 

---Schedules execution of the timer after a given delay.
-- Every time you call this method the "execution countdown" is restarted - i.e. any previous schedule (created
-- with any of the `:run...()` methods) is overwritten. This can be useful
-- to coalesce processing of unpredictable asynchronous events into a single
-- callback; for example, if you have an event stream that happens in "bursts" of dozens of events at once,
-- use an appropriate `delay` to wait for things to settle down, and then your callback will run just once.
-- @function [parent=#timer] runIn
-- @param #timer self
-- @param #intervalString delay
-- @usage
-- local coalesceTimer=hm.timer.new(doSomethingExpensiveOnlyOnce)
-- local function burstyEventCallback(...)
--   coalesceTimer:runIn(2.5) -- wait 2.5 seconds after the last event in the burst
-- end
-- @apichange This replaces non-repeating timers (`hs.timer.new()` and `hs.timer.doAfter()`) as well as `hs.timer.delayed`s
-- @internalchange These timers technically "repeat" into the distant future, so they can be reused at will, but are
--                 transparently added to and removed from the run loop as needed
function tmr:runIn(delay) hmcheck('hm.timer#timer','hm.timer#intervalString')
  delay=parseInterval(delay)
  if delay>=60 then
    local time=timer.localTime()+delay
    log.i(self,'will run at',timeOfDayToString(time))
  end
  makeTimer(self,0) return start(self,delay+CFAbsoluteTimeGetCurrent())
end

---Schedules repeated execution of the timer.
-- If `delayOrStartTime` is a @{<#timeOfDayString>}, the timer will be scheduled to execute for the first time at the earliest occurrence
-- given the `repeatInterval`, e.g.:
--
--   * If it's 17:00, `myTimer:runEvery("6h","0:00")` will set the timer 1 hour from now (at 18:00)
--   * If it's 19:00, `myTimer:runEvery("6h","0:00")` will set the timer 5 hour from now (at 0:00 tomorrow)
--   * If it's 21:00, `myTimer:runEvery("6h","20:00")` will set the timer 5 hours from now (at 2:00 tomorrow)
--
-- @param #timer self
-- @param #intervalString repeatInterval
-- @param delayOrStartTime (optional) the timer will start executing: if omitted or `nil`, right away; if an @{<#intervalString>} or a number (in seconds),
--        after the given delay; if a @{<#timeOfDayString>}, at the earliest occurrence for given time
-- @param #boolean continueOnError (optional) if `true`, the timer will keep repeating (and executing) even if its @{<#timerFunction>} causes an error
-- @usage
-- -- run a job every day at 8, regardless of when Hammermoon was (re)started:
-- hm.timer.new(doThisEveryMorning,myData):runEvery("1d","8:00")
--
-- -- run a job every hour on the hour from 8:00 to 20:00:
-- for h=8,20 do hm.timer.new(runJob):runEvery("1d",h..":00") end
--
-- -- start doing something every second in 5 seconds:
-- local myTimer=hm.timer.new(mustDoThisVeryOften)
-- myTimer:runEvery(1,5)
-- -- and later (maybe in some event callback), stop:
-- myTimer:cancel()
-- @apichange This replaces all repeating timers, whether created via `hs.timer.new()`, `hs.timer.doEvery()`, or `hs.timer.doAt()`
-- @internalchange High frequency timers (less than 1s repeat interval) are like `hs.timer`s, i.e. the repeat schedule is managed
--                 internally by the `CFRunLoopTimer` for performance. Other timers behave like `hs.timer.delayed`s,
--                 i.e. they are rescheduled "manually" after every trigger.
function tmr:runEvery(repeatInterval,delayOrStartTime,continueOnError)
  hmcheck('hm.timer#timer','hm.timer#intervalString','?hm.timer.intervalString|hm.timer#timeOfDayString','?boolean')
  ---@private
  self._continueOnError=continueOnError
  repeatInterval=parseInterval(repeatInterval)
  local delay
  if not delayOrStartTime then delay=CFAbsoluteTimeGetCurrent()+0.01 --was nil
  else delay=parseInterval(delayOrStartTime) --was interval
    if not delay then --was time of day
      delay=parseLocalTime(delayOrStartTime)
      local now=timer.localTime()
      while delay<now do delay=delay+repeatInterval end
  end
  end
  makeTimer(self,repeatInterval) return start(self,delay)
end

---A predicate function that controls conditional execution of a timer.
-- @function [parent=#hm.timer] predicateFunction
-- @param data `data` passed to `timer.new()` or, if `data` was `"elapsed"`, elapsed time in seconds since last execution
-- @return #boolean the return value will determine wheter to run, repeat, skip or cancel altogether the timer's execution, depending on what method was used
-- @prototype
-- @apichange Predicate functions can receive arbitrary data (or the elapsed time) as argument.

local function makePredicateCallback(predicateFn,runWith,stopWith) hmcheck('function','boolean','?boolean')
  return function(self)
    local ok,res=pcall(predicateFn,self._elapsed and CFAbsoluteTimeGetCurrent()-self._lastTrigger or self._data)
    if not ok then
      if not self._continueOnError then stop(self) end
      return log.e(self,'Error on predicate check:',res)
    else
      if not runWith==not res then run(self) end --cast to bool
      if stopWith==not(not res) then stop(self) end --cast to bool (stopWith can be nil)
    end
  end
end
local function startPredicate(self,predicateCallback,checkInterval,continueOnError)
  self._continueOnError=continueOnError
  makeTimer(self,parseInterval(checkInterval),predicateCallback)
  return start(self,0.01+CFAbsoluteTimeGetCurrent())
end
---Schedules repeated execution of the timer while a given predicate remains true.
-- The given `predicateFn` will start being checked right away. While it returns `true`, the timer will
-- execute; as soon as it returns `false` the timer will be canceled.
-- @function [parent=#timer] runWhile
-- @param #timer self
-- @param #predicateFunction predicateFn A predicate function that determines whether to contine executing the timer
-- @param #intervalString checkInterval interval between predicate checks (and timer executions)
-- @param #boolean continueOnError (optional) if `true`, the timer will keep repeating (and executing) even if
--        its @{<#timerFunction>} or `predicateFn` cause an error
-- @apichange Replaces `hs.timer.doWhile()` and `hs.timer.doUntil()`
function tmr:runWhile(predicateFn,...) hmcheck('function','hm.timer#intervalString','?boolean')
  return startPredicate(self,makePredicateCallback(predicateFn,true,false),...)
end
---Schedules execution of the timer after a given predicate becomes false.
-- The given `predicateFn` will start being checked right away. As soon as it returns `false`, the timer will
-- execute (once).
-- @function [parent=#timer] runAfter
-- @param #timer self
-- @param #predicateFunction predicateFn A predicate function that determines whether to contine waiting before executing the timer
-- @param #intervalString checkInterval interval between predicate checks
-- @param #boolean continueOnError (optional) if `true`, `predicateFn` will keep being checked even if it causes an error
-- @apichange Replaces `hs.timer.waitWhile()` and `hs.timer.waitUntil()`
function tmr:runAfter(predicateFn,...) hmcheck('function','hm.timer#intervalString','?boolean')
  return startPredicate(self,makePredicateCallback(predicateFn,false,false),...)
end
---Schedules execution of the timer every time a given predicate is true.
-- The given `predicateFn` will start being checked right away. Every time it returns `true`, the timer will
-- execute.
-- @function [parent=#timer] runWhen
-- @param #timer self
-- @param #predicateFunction predicateFn A predicate function that determines whether to execute the timer
-- @param #intervalString checkInterval interval between predicate checks (and potential timer executions)
-- @param #boolean continueOnError (optional) if `true`, `predicateFn` will keep being checked even if it - or the
--        timer's @{<#timerFunction>} - causes an error
-- @apichange Not (directly) available in HS, but of dubious utility anyway.
function tmr:runWhen(predicateFn,...) hmcheck('function','hm.timer#intervalString','?boolean')
  return startPredicate(self,makePredicateCallback(predicateFn,true,nil),...)
end


---@private
function timer.__gc()
  for _,tmr in pairs(runningTimers) do stop(tmr) end
  runningTimers={}
end
return timer

