local date,time = os.date,os.time
local min,max,tmove,tinsert=math.min,math.max,table.move,table.insert
local sformat,ssub,slower,srep,sfind=string.format,string.sub,string.lower,string.rep,string.find
local ipairs,type,select,rawget,rawset,print=ipairs,type,select,rawget,rawset,print
local function printf(...) return print(sformat(...)) end
local ERROR,WARNING,INFO,DEBUG,VERBOSE=1,2,3,4,5
local MAXLEVEL=VERBOSE
local LEVELS={nothing=0,error=ERROR,warning=WARNING,info=INFO,debug=DEBUG,verbose=VERBOSE}
local function toLogLevel(lvl)
  if type(lvl)=='string' then
    return LEVELS[slower(lvl)] or error('invalid log level',3)
  elseif type(lvl)=='number' then
    return max(0,min(MAXLEVEL,lvl))
  else error('loglevel must be a string or a number',3) end
end

local LEVELFMT={{'ERROR:',''},{'** Warning:',''},{'',''},{'','    '},{'','        '}}
local lasttime,lastid=0
local idlen,idf,idempty=20,'%20.20s:','                     '
local timeempty='        '

---Simple logger for debugging purposes.
-- @module hm.logger
-- @static
local logger=hm._core.protoModule('logger')

local instances=setmetatable({},{__mode='kv'})

---A string or number describing a log level.
-- Can be `'nothing'`, `'error'`, `'warning'`, `'info'`, `'debug'`, or `'verbose'`, or a corresponding number between 0 and 5.
-- @type loglevel
-- @extends #string


---Sets the log level for all logger instances (including objects' loggers)
--@function [parent=#hm.logger] setGlobalLogLevel
--@param #loglevel lvl
logger.setGlobalLogLevel=function(lvl)
  lvl=toLogLevel(lvl)
  for log in pairs(instances) do
    log.setLogLevel(lvl)
  end
end

---Sets the log level for all currently loaded modules.
-- This function only affects *module*-level loggers, object instances with their own loggers (e.g. windowfilters) won't be affected;
-- you can use `hs.logger.setGlobalLogLevel()` for those
-- @function [parent=#hm.logger] setModulesLogLevel
-- @param #loglevel lvl
logger.setModulesLogLevel=function(lvl)
  for ext,mod in pairs(package.loaded) do
    local prefix=string.sub(ext,1,3)
    if prefix=='hs.' or prefix=='hm.' and mod~=hs then
      if mod.setLogLevel then mod.setLogLevel(lvl) end
    end
  end
end

local history={}
local histIndex,histSize=0,0

---The number of log entries to keep in the history.
-- The starting value is 0 (history is disabled). To enable the log history, set this at the top of your userscript.
-- If you change history size (other than from 0) after creating any logger instances, things will likely break.
-- @field [parent=#hm.logger] #number historySize
-- @apichange function hm.logger.historySize([v]) -> field hm.logger.historySize
hm._core.property(logger,'historySize',
  function() return histSize end,
  function(v) assert(type(v)=='number','size must be a number') histSize=min(v,1000000) end)
--cannot deprecate the previous function as it has the same name

local function store(s)
  histIndex=histIndex+1
  if histIndex>histSize then histIndex=1 end
  history[histIndex]=s
end

---Returns the global log history.
-- Each log entry in the returned list is a table with the following fields:
--   * time - timestamp in seconds since the epoch
--   * level - a number between 1 (error) and 5 (verbose)
--   * id - a string containing the id of the logger instance that produced this entry
--   * message - a string containing the logged message
-- @function [parent=#hm.logger] history
-- @return a list of (at most `hs.logger.historySize`) log entries produced by all the logger instances, in chronological order
logger.history=function()
  local start=histIndex+1
  if not history[start] then return history end
  if start>histSize then start=1
  else tmove(history,1,start-1,histSize+1) end -- append
  tmove(history,start,histSize+start,1) --shift down
  tmove(history,histSize*2+1,histSize*2+start,histSize+1) --cleanup
  histIndex=histSize
  return history
end

logger.filterHistory=function(flt,lvl,case,entries)
  entries=entries or histSize
  local hist=logger.history()
  local filt={}
  if flt and not case then flt=slower(flt) end
  lvl=toLogLevel(lvl or 5)
  local n=0
  for i=#hist,1,-1 do
    local e=hist[i]
    if e.level<=lvl and (not flt or sfind(case and e.id or slower(e.id),flt,1,true) or sfind(case and e.mesage or slower(e.message),flt,1,true)) then
      tinsert(filt,1,e)
      n=n+1
      if n>=entries then break end
    end
  end
  return filt
end

---Prints the global log history to the console.
-- @function [parent=#hm.logger] printHistory
-- @param #string filter (optional) a string to filter the entries (by logger id or message) via `string.find` plain matching
-- @param #loglevel level (optional) the desired log level; if omitted, defaults to `verbose`
-- @param #boolean caseSensitive (optional) if true, filtering is case sensitive
-- @param #number entries (optional) the maximum number of entries to print; if omitted, all entries in the history will be printed
logger.printHistory=function(...)
  for _,e in ipairs(logger.filterHistory(...)) do
    printf('%s %s%s %s%s',date('%X',e.time),LEVELFMT[e.level][1],sformat(idf,e.id),LEVELFMT[e.level][2],e.message)
    --     printf('%s %s%s %s%s',date('%X',e.time),LEVELFMT[e.level][1],sformat(idf,e.id),LEVELFMT[e.level][2],e.message)
  end
end

-- logger
local lf = function(loglevel,lvl,id,fmt,...)
  if histSize<=0 and loglevel<lvl then if lvl==ERROR then return nil,sformat(fmt,...) else return end end
  local ct = time()
  local msg=sformat(fmt,...)
  if histSize>0 then store({time=ct,level=lvl,id=id,message=msg}) end
  if loglevel<lvl then return end
  id=sformat(idf,id)
  --   id=sformat(idf,id)
  local stime = timeempty
  if ct-lasttime>0 or lvl<3 then stime=date('%X') lasttime=ct end
  if id==lastid and lvl>3 then id=idempty else lastid=id end
  if lvl==ERROR then print'********' end
  printf('%s %s%s %s%s',stime,LEVELFMT[lvl][1],id,LEVELFMT[lvl][2],msg)
  if lvl==ERROR then print'********' return nil,msg end
end
local l = function(loglevel,lvl,id,...)
  if histSize>0 or loglevel>=lvl or lvl==ERROR then return lf(loglevel,lvl,id,srep('%s',select('#',...),' '),...) end
end

logger.idLength=function(len)
  if len==nil then return idlen end
  if type(len)~='number' or len<4 then error('len must be a number >=4',2)end
  len=min(len,40) idlen=len
  idf='%'..len..'.'..len..'s:'
  idempty=srep(' ',len+1)
end

logger.truncateID = "tail"
logger.truncateIDWithEllipsis = false

---Default log level for new logger instances.
-- The starting value is `'warning'`; set this (to e.g. `'info'`) at the top of your userscript to affect
-- all logger instances created without specifying a `loglevel` parameter
-- @field [parent=#hm.logger] #loglevel defaultLogLevel
logger.defaultLogLevel = 'warning'


---A logger instance.
--@type logger

---Creates a new logger instance.
-- The logger instance created by this method is not a regular object, but a plain table with "static" functions;
-- therefore, do *not* use the colon syntax for so-called "methods" in this module (as in `mylogger:setLogLevel(3)`);
-- you must instead use the regular dot syntax: `mylogger.setLogLevel(3)`
-- @function [parent=#hm.logger] new
-- @param #string id a string identifier for the instance (usually the module name)
-- @param #loglevel loglevel (optional) can be 'nothing', 'error', 'warning', 'info', 'debug', or 'verbose',
-- or a corresponding number between 0 and 5; uses `hs.logger.defaultLogLevel` if omitted
-- @return #logger the new logger instance
-- @usage local log = hs.logger.new('mymodule','debug')
-- @usage log.i('Initializing') -- will print "[mymodule] Initializing" to the console
function logger.new(id,loglevel)
  if type(id)~='string' then error('id must be a string',2) end
  --  id=sformat('%10s','['..sformat('%.8s',id)..']')
  local function setLogLevel(lvl)loglevel=toLogLevel(lvl)end
  setLogLevel(loglevel or logger.defaultLogLevel)
  local r = {
    setLogLevel = setLogLevel,
    getLogLevel = function()return loglevel end,
    e = function(...) return l(loglevel,ERROR,id,...) end,
    w = function(...) return l(loglevel,WARNING,id,...) end,
    i = function(...) return l(loglevel,INFO,id,...) end,
    d = function(...) return l(loglevel,DEBUG,id,...) end,
    v = function(...) return l(loglevel,VERBOSE,id,...) end,

    fe = function(fmt,...) return lf(loglevel,ERROR,id,fmt,...) end,
    fw = function(fmt,...) return lf(loglevel,WARNING,id,fmt,...) end,
    fi= function(fmt,...) return lf(loglevel,INFO,id,fmt,...) end,
    fd = function(fmt,...) return lf(loglevel,DEBUG,id,fmt,...) end,
    fv = function(fmt,...) return lf(loglevel,VERBOSE,id,fmt,...) end,
  }
  r.ef=r.fe r.wf=r.fw r.f=r.fi r.df=r.fd r.vf=r.fv --hs compatibility
  --  r.log=r.i r.logf=r.f
  instances[r]=true
  return setmetatable(r,{
    __index=function(t,k)
      return k=='level' and loglevel or rawget(t,k)
    end,
    __newindex=function(t,k,v)
      if k=='level' then return setLogLevel(v) else return rawset(t,k,v) end
    end
  })
end
return logger

---Sets the log level of the logger instance
-- @function [parent=#logger] setLogLevel
-- @param #loglevel loglevel can be 'nothing', 'error', 'warning', 'info', 'debug', or 'verbose'; or a corresponding number between 0 and 5

---Gets the log level of the logger instance
-- @function [parent=#logger] getLogLevel
-- @return #number The log level of this logger as a number between 0 ('nothing') and 5 ('verbose')

---The log level of the logger instance, as a number between 0 and 5
-- @field [parent=#logger] #number level

---Logs an error to the console
-- @function [parent=#logger] e
-- @param ... one or more message strings
-- @return #nil,#string nil and the error message
-- @apichange returns nil,error as per Lua informal standard; module functions can use the idiom `return log.e(...)` to fail

---Logs a formatted error to the console
-- @function [parent=#logger] fe
-- @param #string fmt formatting string as per `string.format`
-- @param ... one or more message strings
-- @return #nil,#string nil and the error message
-- @apichange logger.ef -> logger.fe
-- @apichange returns nil,error as per Lua informal standard; module functions can use the idiom `return log.fe(fmt,...)` to fail

---Logs a warning to the console
-- @function [parent=#logger] w
-- @param ... one or more message strings

---Logs a formatted warning to the console
-- @function [parent=#logger] fw
-- @param #string fmt formatting string as per `string.format`
-- @param ... one or more message strings
-- @apichange logger.wf -> logger.fw

---Logs info to the console
-- @function [parent=#logger] i
-- @param ... one or more message strings

---Logs formatted info to the console
-- @function [parent=#logger] fi
-- @param #string fmt formatting string as per `string.format`
-- @param ... one or more message strings
-- @apichange logger.f -> logger.fi

---Logs debug info to the console
-- @function [parent=#logger] d
-- @param ... one or more message strings

---Logs formatted debug info to the console
-- @function [parent=#logger] fd
-- @param #string fmt formatting string as per `string.format`
-- @param ... one or more message strings
-- @apichange logger.df -> logger.fd

---Logs verbose info to the console
-- @function [parent=#logger] v
-- @param ... one or more message strings

---Logs formatted verbose info to the console
-- @function [parent=#logger] fv
-- @param #string fmt formatting string as per `string.format`
-- @param ... one or more message strings
-- @apichange logger.vf -> logger.fv

