#!/usr/bin/env ./luajit
local cmd=arg[1]
if cmd~='run' and cmd~='clean' and cmd~='runall' and cmd~='pad' then
  print('arg needed: "run", "runall", "clean", "pad"')
  os.exit(1,1)
end

package.cpath="./?.so;./lib/?.so"
package.path="./?.lua;./?/init.lua;./lib/?.lua;./lib/?/init.lua"

local cwd=debug.getinfo(1).source:match("@?(.*)/") or '.'
package.cpath=package.cpath..';'..cwd..'/lib/?.so'

local lfs=require'lfs'
lfs.chdir(cwd)

local TESTSDIR='tests'
local TIMESTAMPS='tests/.timestamps'

require'hm'
require'hammermoon_app'(function()
  hm._core.log.level=4
  hm.logger.setGlobalLogLevel(4)
  hm.logger.defaultLogLevel=4

  local inspect=require'lib.inspect'
  local getmetatable,setmetatable,tonumber,tostring,pairs,select,pcall,xpcall,rawset,loadstring,type,setfenv
    = getmetatable,setmetatable,tonumber,tostring,pairs,select,pcall,xpcall,rawset,loadstring,type,setfenv
  local unpack,tconcat,tremove,tinsert=unpack,table.concat,table.remove,table.insert
  local sformat,srep,ipairs=string.format,string.rep,ipairs

  local capn,capv={},{}
  --  local testGlobals=setmetatable({},{__index=_G})
  local baseSandbox=setmetatable({},{__index=_G})
  for i=1,10 do
    baseSandbox['pl'..i]=function(a)return inspect(a,{depth=i,newline=' ',indent=''})end
    baseSandbox['p'..i]=function(a)return inspect(a,{depth=i})end
    --    baseSandbox['pl'..i]=function(a)return inspect(a,true,i)end
    --    baseSandbox['p'..i]=function(a)return inspect(a,false,i)end
  end
  local log=hm.logger.new('tests',5)
  local require=hm._core.rawrequire
  baseSandbox.pl=baseSandbox.pl3 baseSandbox.p=baseSandbox.p3
  getmetatable(baseSandbox).__newindex=function()error'!'end
  local nullSandbox=setmetatable({print=function()end,require=function()end,test=function()end,terr=function()end},
    {__index=baseSandbox,__newindex=function(t,k,v)capn[#capn+1]=k capv[#capv+1]=v end})
  local trace=debug.traceback
  local sleep
  local function cleanfile(lines)
  end
  local function runfile(lines)
    local path=lines.path
    log.i('running',path)
    local s,output='',{}
    local chunkStart,chunkLen=0,0
    local inlinePrint=function(...)
      local args={...}
      for i,a in pairs(args) do
        local na,nls=tostring(a):gsub('\n','\n--> ')
        args[i]=na chunkLen=chunkLen+nls
      end
      local nArgs=select('#',...)
      for i=1,nArgs do args[i]=args[i] or 'nil' end
      local s=sformat(srep('%s ',nArgs),unpack(args))
      local first=true
      repeat
        local i=121
        repeat
          i=i-1
          local c=s:sub(i,i)
        until c=='' or c==' ' or c==',' or i<80
        output[#output+1]=(first and '--> ' or '--~ ')..s:sub(1,i) chunkLen=chunkLen+1
        s=s:sub(i+1)
        first=nil
      until #s==0
    end
    local total,passed,failed=0,0,0
    local inlineError=function(msg)
      failed=failed+1
      msg=trace(msg)
      log.e(path,msg)
      for l in msg:gmatch('(.-)\n') do
        if l:sub(1,5)~='stack' then
          if l:find('[C]',1,true) then break end
          local pre,st,offs,post=l:match('(.-)%[string %"%_%_(%d+)%"%]%:(%d+)(%:.+)')
          inlinePrint(pre and (pre..path:sub(2)..':'..(tonumber(st)+tonumber(offs))..post) or l)
        end
      end
      output[#output+1]='--:'..'FAILED:'
    end
    local inlineTest=function(pred)
      total=total+1
      local out=output[#output]:gsub('%s+%-%-:.-$','')
      if type(pred)=='function' then pred=pred() end
      if not pred then log.e(path,' - test failed:',out) end
      passed=passed+(pred and 1 or 0)
      failed=failed+(pred and 0 or 1)
      output[#output]=out..(pred and ' --:ok:' or ' --:FAILED:')
      if output[#output-1]=='' then
        tremove(output,#output-1)
        chunkLen=chunkLen-1
      end
    end
    local fileSandbox
    local inlineTestError=function(f,err)
      return inlineTest(function()
        if type(f)=='string' then f=loadstring(f) end
        local ok,perr=pcall(setfenv(f,fileSandbox))
        --        local perr=not ok and perr:match('.-:%d+: ([^\n]-)%s*$')
        --        if err then print(#err,#perr) end
        --        print(err)print(perr)
        return ok==false and (err==nil or err==perr:match('.-:%d+: (.-)%s*$'))
      end)
    end
    local sandboxPackages={}
    local function sandboxRequire(m)
      local isLocal=package.loaded[m]==nil
      local r=require(m)
      if isLocal then
        sandboxPackages[m]=r
        log.d('loaded package',m)
      end
      return r
    end
    local function setGlobal(t,k,v)
      log.v('set global',k)
      capn[#capn+1]=k capv[#capv+1]=v
      --      testGlobals[k]=v
      rawset(t,k,v)
    end
    fileSandbox=setmetatable({
      test=inlineTest,terr=inlineTestError,sleep=sleep,print=inlinePrint,rawprint=print,require=sandboxRequire},
    --    {__index=nullSandbox,--[[__newindex=_G--]]}) -- sandbox; don't escape globals (rest is running live anyway!)
    {__index=baseSandbox,__newindex=setGlobal}) -- sandbox; DO escape globals as required for whole-pad evalling
    nullSandbox.require=sandboxRequire
    getmetatable(nullSandbox).__index=fileSandbox
    local lastError
    for _,line in ipairs(lines) do
      --      chunkLines=chunkLines+1
      --        line=line:gsub('%-%-%>.*','') -- remove generated output
      local lineprefix=line:sub(1,3)
      if lineprefix~='-->' and lineprefix~='--~' and lineprefix~='--:' then
        --        line=line:gsub('%-%-%>.-\n','\n') --remove test results
        s=s..line..'\n'
        chunkLen=chunkLen+1
        -- remove all comments and newlines
        local evals=s:gsub('%-%-%[%[.-%-%-%]%]',''):gsub('%-%-.-\n','\n'):gsub('%s+',' ')
        local chunk,err
        if #evals:gsub('%s','')==0 then
          output[#output+1]=s:sub(1,-2)
          s='' chunkStart=chunkStart+chunkLen chunkLen=0
        else
          chunk,err=loadstring(s,'__'..chunkStart)
          if not chunk then lastError=err else --valid, proceed with eval
            lastError=nil
            output[#output+1]=s:sub(1,-2)
            --            chunkLen=chunkLen+1
            local retChunk,err=loadstring('return ('..evals..')')
            if retChunk then -- it's an expression, print the result
              log.v('  eval exp:',evals)
              local ok,res=xpcall(setfenv(retChunk,fileSandbox),inlineError)
              if ok and res~=nil then
                --              if type(res)~='string' then res=baseSandbox.pl1(res) end
                inlinePrint(tostring(res))
              end
            else
              log.v('  eval:   ',evals)
              local ok,res=xpcall(setfenv(chunk,fileSandbox),inlineError)
              if ok then
                for i=1, #capn do
                  --                local s=tostring(capv[i])
                  --                if type(s)~='string' then s=nullSandbox.pl1(capv[i]) end
                  --                inlinePrint(capn[i]..' = '..nullSandbox.pl1(capv[i]))
                  inlinePrint(capn[i]..' = '..tostring(capv[i]))
                end
                --            if ok and capn then print(capn..': '..tostring(capv))
              else --TODO sethook, getlocal
                --              inlinePrint'?'
                inlinePrint(res)
              end
            end
            capn,capv={},{}
            s='' chunkStart=chunkStart+chunkLen chunkLen=0
          end
        end
      end
    end
    if lastError then
      --      out=out..s
      output[#output+1]='' output[#output+1]=s:sub(1,-2)
      inlinePrint(lastError)
    end
    inlinePrint(total,'total tests,',passed,'passed,',failed,'failed')
    log.i(total,'total tests,',passed,'passed,',failed,'failed')
    for m in pairs(sandboxPackages) do package.loaded[m]=nil log.d('unloaded package',m) end
    local f=io.open(path,'w')
    f:write(tconcat(output,'\n')..'\n') f:flush() f:close()
    return total,passed,failed
  end
  if cmd=='pad' then
    hm.timer.log.level=1
    local timestamp=0
    local path=arg[2] or 'scratchpad.lua'
    while true do
      repeat
        hm.timer.sleep(1)
        local pathmod=lfs.attributes(path,'modification')
      until pathmod>timestamp
      local lines={path=path}
      for line in io.lines(path) do lines[#lines+1]=line end
      runfile(lines)
      timestamp=os.time()
    end
    os.exit(1,1)
  end
  local total,passed,failed=0,0,0
  local timestamps={}
  --  if not lfs.attributes(TIMESTAMPS) then
  --    local f=io.open(TIMESTAMPS,'w') f:write'' f:close()
  --  end
  for line in io.lines(TIMESTAMPS) do
    local testfile,testtime=line:match('^([%l._/]+)%s*(%d+)%s*$')
    --    assert(testfile,testtime)
    timestamps[testfile]=tonumber(testtime)
    if cmd=="runall" or cmd=="clean" then timestamps[testfile]=0 end
  end
  local files={}
  for file in lfs.dir(TESTSDIR) do
    local path=TESTSDIR..'/'..file
    if lfs.attributes(path,'mode')=='file' and path:sub(-9)=='.test.lua' then
      local lines={}
      local mtime=lfs.attributes(path,'modification')
      timestamps[path]=timestamps[path] or 0
      if timestamps[path]<mtime then lines.path=path end
      --      files[#files+1]=path
      for line in io.lines(path) do
        local reqpath=line:match('^%-%-@file ([%l._/]+)')
        if reqpath then
          local mtime=lfs.attributes(reqpath,'modification')
          if mtime>timestamps[path] then lines.path=path end
        end
        lines[#lines+1]=line
      end
      if lines.path then files[#files+1]=lines end
    end
  end
  local nfiles=#files
  if cmd=="clean" then
    local f=io.open(TIMESTAMPS,'w') f:write'' f:close()
    for _,lines in ipairs(files) do
      local out={}
      for _,line in ipairs(lines) do
        local subbed
        line=line:gsub('%-%-[~>:].+$',function()subbed=true return '' end)
        if not subbed or #line>0 then out[#out+1]=line end
      end
      local f=io.open(lines.path,'w')
      f:write(tconcat(out,'\n')..'\n') f:flush() f:close()
    end
    os.exit(1,1)
  else
    local runnerCoro=coroutine.wrap(function()
      while files[1] do
        local t,p,f=runfile(files[1])
        timestamps[files[1].path]=f>0 and 0 or os.time()
        total=total+t passed=passed+p failed=failed+f
        tremove(files,1)
      end
      local f=io.open(TIMESTAMPS,'w')
      for testfile,timestamp in pairs(timestamps) do f:write(sformat('%s %d\n',testfile,timestamp)) end
      f:flush() f:close()
      log.w(nfiles,' files processed')
      log.w(total,'total tests,',passed,'passed,',failed,'failed')
      os.exit(1,1)
    end)
    local sleepTimer=hm.timer.new(runnerCoro)
    sleep=function(s)
      sleepTimer:runIn(s)
      coroutine.yield(true)
    end
    runnerCoro()
  end
end)

