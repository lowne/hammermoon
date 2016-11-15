local deprecate=hm._core.deprecate
local hstimer=hm._core.hs_compat_module('timer')
local timer=hm.timer
local setmetatable,type=setmetatable,type

--------------- fns ------------------
function hstimer.seconds(n) return timer.toSeconds(n) end
deprecate(hstimer,'seconds','hm.timer.toSeconds()')
function hstimer.minutes(n) return 60 * n end
deprecate(hstimer,'minutes')
function hstimer.hours(n)   return 60 * 60 * n end
deprecate(hstimer,'hours')
function hstimer.days(n)    return 60 * 60 * 24 * n end
deprecate(hstimer,'days')
function hstimer.weeks(n)   return 60 * 60 * 24 * 7 * n end
deprecate(hstimer,'weeks')
function hstimer.secondsSinceEpoch() return timer.absoluteTime()+978307200 end
deprecate(hstimer,'secondsSinceEpoch','hm.timer.absoluteTime()')

local mt={__index=hstimer}
function hstimer.new(interval,fn,continueOnError)
  return setmetatable({_hmtimer=timer.new(fn),_continueOnError=continueOnError,_interval=interval},mt)
end
deprecate(hstimer,'new','hm.timer.new():runEvery()')

function hstimer.doAfter(sec,fn) local self=hstimer.new(nil,fn) self._hmtimer:runIn(sec) return self end
deprecate(hstimer,'doAfter','hm.timer.new():runIn()')

function hstimer.doEvery(interval,fn) return hstimer.new(interval,fn):start() end
deprecate(hstimer,'doEvery','hm.timer.new():runEvery()')

function hstimer.doAt(time,repeatInterval,fn,continueOnError)
  if type(repeatInterval)=='function' then continueOnError=fn fn=repeatInterval repeatInterval=nil end
  repeatInterval=repeatInterval or '1d'
  local self=hstimer.new(repeatInterval,fn,continueOnError)
  self._hmtimer:runEvery(repeatInterval,time,continueOnError)
  return self
end
deprecate(hstimer,'doAt','hm.timer.new():runEvery()')

function hstimer.doUntil(pred,fn,checkInterval)
  local self=hstimer.new(nil,fn)
  self._hmtimer:runWhile(function()return not pred()end,checkInterval or 1)
  return self
end
deprecate(hstimer,'doUntil','hm.timer.new():runWhile()')
function hstimer.doWhile(pred,fn,checkInterval)
  local self=hstimer.new(nil,fn)
  self._hmtimer:runWhile(function()return pred()end,checkInterval or 1)
  return self
end
deprecate(hstimer,'doWhile','hm.timer.new():runWhile()')
function hstimer.waitUntil(pred,fn,checkInterval)
  local self=hstimer.new(nil,fn)
  self._hmtimer:runAfter(function()return not pred()end,checkInterval or 1)
  return self
end
deprecate(hstimer,'waitUntil','hm.timer.new():runAfter()')
function hstimer.waitWhile(pred,fn,checkInterval)
  local self=hstimer.new(nil,fn)
  self._hmtimer:runAfter(function()return pred()end,checkInterval or 1)
  return self
end
deprecate(hstimer,'waitWhile','hm.timer.new():runAfter()')

----------------- methods ---------------
function hstimer:start()
  if self._hmtimer._isRunning or not self._interval then return self end
  self._hmtimer:runEvery(self._interval,self._interval,self._continueOnError) return self
end
deprecate(hstimer,'start','hm.timer.new():runEvery()')

function hstimer:stop() self._hmtimer:destroy() return self end
deprecate(hstimer,'stop','hm.timer.new():cancel()')

function hstimer:running()  return self._hmtimer.scheduled end
deprecate(hstimer,'running','<#hm.timer>.scheduled')

function hstimer:nextTrigger() return self._hmtimer.nextRun end
deprecate(hstimer,'nextTrigger','<#hm.timer>.nextRun')

function hstimer:setNextTrigger(v) self._hmtimer.nextRun=v end
deprecate(hstimer,'setNextTrigger','<#hm.timer>.nextRun=value')

-------------------- delayed ------------------------
local hsdelayed=hm._core.hs_compat_module('timer.delayed')
local dmt={__index=hsdelayed}

function hsdelayed.new(delay,fn) return setmetatable({_hmtimer=timer.new(fn),_delay=delay},dmt) end
deprecate(hsdelayed,'new','hm.timer.new()')

function hsdelayed:start(delay) self._hmtimer:runIn(delay or self._delay) return self end
deprecate(hsdelayed,'start','hm.timer.new():runIn()')

function hsdelayed:stop() self._hmtimer:cancel() return self end
deprecate(hsdelayed,'stop','<#hm.timer>:cancel()')

function hsdelayed:setDelay(delay) self._delay=delay return self:start() end
deprecate(hsdelayed,'setDelay')

function hsdelayed:running() return self._hmtimer.running end
function hsdelayed:nextTrigger() return self._hmtimer.nextRun end

return hstimer
