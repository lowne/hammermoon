local function runtests()
  --  package.cpath=package.cpath..';./lib/?.so'
  local open,lines=io.open,io.lines
  local lfs=require'lfs'
  local inspect=require'lib.inspect'
  local getmetatable,setmetatable,tonumber,tostring,pairs,select,pcall,xpcall,rawset,loadstring,type,setfenv
    = getmetatable,setmetatable,tonumber,tostring,pairs,select,pcall,xpcall,rawset,loadstring,type,setfenv
  local unpack,tconcat,tremove=unpack,table.concat,table.remove
  local sformat,srep=string.format,string.rep

  local capn,capv={},{}
  --  local testGlobals=setmetatable({},{__index=_G})
  local baseSandbox=setmetatable({},{__index=_G})
  for i=1,10 do
    baseSandbox['pl'..i]=function(a)return inspect(a,{depth=i,newline=' ',indent=''})end
    baseSandbox['p'..i]=function(a)return inspect(a,{depth=i})end
    --    baseSandbox['pl'..i]=function(a)return inspect(a,true,i)end
    --    baseSandbox['p'..i]=function(a)return inspect(a,false,i)end
  end
  local log=hm.logger.new'tests'
  local require=hm._core.rawrequire
  baseSandbox.pl=baseSandbox.pl3 baseSandbox.p=baseSandbox.p3
  getmetatable(baseSandbox).__newindex=function()error'!'end
  local nullSandbox=setmetatable({print=function()end,require=function()end,test=function()end,terr=function()end},
    {__index=baseSandbox,__newindex=function(t,k,v)capn[#capn+1]=k capv[#capv+1]=v end})
  local trace=debug.traceback

  local function runfile(file)
    log.i('running',file)
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
      --      local fmt=srep('%s ',nArgs)
      --      output[#output+1]='--> '.. sformat(fmt,unpack(args))
      --      chunkLen=chunkLen+1
    end
    local inlineError=function(msg)
      msg=trace(msg)
      log.e(file,msg)
      for l in msg:gmatch('(.-)\n') do
        if l:sub(1,5)~='stack' then
          if l:find('[C]',1,true) then break end
          local pre,st,offs,post=l:match('(.-)%[string %"%_%_(%d+)%"%]%:(%d+)(%:.+)')
          inlinePrint(pre and (pre..file:sub(2)..':'..(tonumber(st)+tonumber(offs))..post) or l)
        end
      end
    end
    local total,passed,failed=0,0,0
    local inlineTest=function(pred)
      total=total+1
      local out=output[#output]:gsub('%s+%-%-.-$','')
      if type(pred)=='function' then pred=pred() end
      if not pred then log.e(file,' - test failed:',out) end
      passed=passed+(pred and 1 or 0)
      failed=failed+(pred and 0 or 1)
      output[#output]=out..(pred and ' -- ok' or ' -- FAILED')
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
      --      testGlobals[k]=v
      rawset(t,k,v)
    end
    fileSandbox=setmetatable({
      test=inlineTest,terr=inlineTestError,print=inlinePrint,rawprint=print,require=sandboxRequire},
    --    {__index=nullSandbox,--[[__newindex=_G--]]}) -- sandbox; don't escape globals (rest is running live anyway!)
    {__index=baseSandbox,__newindex=setGlobal}) -- sandbox; DO escape globals as required for whole-pad evalling
    nullSandbox.require=sandboxRequire
    getmetatable(nullSandbox).__index=fileSandbox
    local lastError
    for line in lines(file) do
      --      chunkLines=chunkLines+1
      --        line=line:gsub('%-%-%>.*','') -- remove generated output
      local lineprefix=line:sub(1,3)
      if lineprefix~='-->' and lineprefix~='--~' then
        --        line=line:gsub('%-%-%>.-\n','\n') --remove test results
        s=s..line..'\n'
        chunkLen=chunkLen+1
        -- remove all comments and newlines
        local evals=s:gsub('%-%-%[%[.-%-%-%]%]',''):gsub('%-%-.-\n','\n'):gsub('%s+',' ')
        local chunk,err
        if #evals:gsub('%s','')>0 then chunk,err=loadstring(s,'__'..chunkStart) end
        if chunk then --valid, proceed with eval
          -- if a test, assume failed
          --          local pres=evals:gsub('%s',''):sub(1,5)
          --          if pres=='test(' or pres=='terr(' then s=s:gsub('%s+%-%-.+$','')..' -- FAILED\n' end
          lastError=nil
          --            output[#output+1]='' output[#output+1]=s:sub(1,-2)
          output[#output+1]=s:sub(1,-2)
          --            chunkLen=chunkLen+1
          local retChunk,err=loadstring('return ('..evals..')')
          if retChunk then -- it's an expression, print the result
            log.v('  eval exp:',evals)
            local ok,res=pcall(setfenv(retChunk,nullSandbox))
            if ok and res~=nil then
              --              if type(res)~='string' then res=baseSandbox.pl1(res) end
              inlinePrint(tostring(res))
            end
          else
            log.v('  eval:   ',evals)
            local ok,res=pcall(setfenv(chunk,nullSandbox))
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
            capn,capv={},{}
          end
          --          local ok,res=xpcall(chunk,inlineError)
          xpcall(setfenv(chunk,fileSandbox),inlineError)
          s=''
          chunkStart=chunkStart+chunkLen chunkLen=0
        else lastError=err end
      end
    end
    if lastError then
      --      out=out..s
      output[#output+1]='' output[#output+1]=s:sub(1,-2)
      inlinePrint(lastError)
    end
    output[#output+1]=''
    inlinePrint(total,'total tests,',passed,'passed,',failed,'failed')
    log.i(total,'total tests,',passed,'passed,',failed,'failed')
    local f=open(file,'w')
    f:write(tconcat(output,'\n')..'\n') f:flush() f:close()
    for m in pairs(sandboxPackages) do package.loaded[m]=nil log.d('unloaded package',m) end
    return total,passed,failed
  end
  local files,total,passed,failed=0,0,0,0
  for file in lfs.dir'tests' do
    local path='tests/'..file
    if lfs.attributes(path).mode=='file' then
      files=files+1
      local t,p,f=runfile(path)
      total=total+t passed=passed+p failed=failed+f
    end
  end
  log.w(files,' files processed')
  log.w(total,'total tests,',passed,'passed,',failed,'failed')
  os.exit(1,1)
end
local cwd=debug.getinfo(1).source:match("@?(.*)/") or '.'
package.cpath=package.cpath..';'..cwd..'/lib/?.so'
require'lfs'.chdir(cwd)

require'hm'
require'hammermoon_app'(runtests)
