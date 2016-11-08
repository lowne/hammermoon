---@module docbuilder

---@type docbuilder

assert(_VERSION == "Lua 5.1",'Lua 5.1 is required')
local lddextractor = require 'lddextractor'
local fs=require'fs.lfs'


function _DEBUG(t,d)
  local p=t.parent t.parent=nil
  print(require'inspect'(t,{depth=d or 3}))
  t.parent=p
end
local pairs,ipairs,next=pairs,ipairs,next
local tinsert,tremove,tsort,tconcat,sformat=table.insert,table.remove,table.sort,table.concat,string.format

local function readFile(filePath)
  print('Reading file '..filePath)
  local file=assert(io.open(filePath,'r'))
  local data=file:read('*all')
  file:close()
  return data
end

local function makeModel(filePath,noHeuristics)
  return assert(lddextractor.generateapimodule(filePath,readFile(filePath),noHeuristics))
end
local function makeCommentFile(filePath)
  return assert(lddextractor.generatecommentfile(filePath,readFile(filePath)))
end

local function makeAPI(filePaths,destPath)
  for _,filePath in ipairs(filePaths) do
    local module=makeModel(filePath)
    assert(module.name,'No module name for '..filePath)
    local comments=makeCommentFile(filePath)
    local pathOut=destPath..fs.separator..module.name..'.lua'
    assert(fs.fill(pathOut,comments))
    print('Generated file ',pathOut)
  end
end

local function has(t) return t and next(t) end
local function makeFilter(filtertbl) return function(o) return filtertbl[o.tag](o) end end
local defaultFilterTag=setmetatable({
  --   file=function(o)return o.name and (has(o.types) or has(o.fields)) and o end,
  },
  {__index=function()
    return function(o)
      --      local hasInfo=o.name and (#o.short>0 or #o.long>0 or has(o.types) or has(o.fns) or has(o.fields) or has(o.params) or has(o.returns))
      return o.name and not o.extra.private and o
    end
  end})


local defaultFilter=makeFilter(defaultFilterTag)
local function makeMetadataTagFilter(metadataTag)
  return makeFilter(setmetatable({},{__index=function()return function(o)
    if not defaultFilter(o) then return
    elseif o.extra[metadataTag] then return o
    elseif o.parent and o.parent.extra[metadataTag] then return o end
    for _,children in ipairs{'globalfunctions','globalfields','types','functions','fields'} do
      if o[children] and o[children][1] then return o end
    end
    --    return defaultFilter(o) and o.extra[metadataTag] and o
  end end}))
end

local currentModuleName
local function traverse(o,flt,i,parent)
  local function strip(s) return s and s:gsub('^%s+',''):gsub('%s+$','') or nil end
  local function sortedpairs(t)
    local keys,i={},0 for k in pairs(t) do tinsert(keys,k) end tsort(keys)
    return function() i=i+1 local k=keys[i] return k,t[k] end
  end
  local function getExtra(o)
    local extra={ttag='extra'}
    for tag,data in pairs(o.metadata or {}) do
      local desc={} for _,d in ipairs(data) do tinsert(desc,d.description) end
      extra[tag]={ttag=tag,short=strip(tconcat(desc,'\n'))}
    end
    return extra
  end
  local function copyAttrs(o)
    return {name=o.name,ttag=o.ttag,long=strip(o.description) or '',short=strip(o.shortdescription) or '',extra=getExtra(o)}
  end

  local function getItemTTag(o)
    assert(o.tag=='item','getItemTypeTag on '..o.tag)
    if not o.type and not o:resolvetype() then return 'field' end
    local typeTag=o.type.tag
    if typeTag=='primitivetyperef' then return 'field'
    elseif typeTag=='externaltyperef' then return 'field'
    elseif typeTag=='internaltyperef' or typeTag=='inlinetyperef' then
      local typeDef=o:resolvetype()
      if typeDef then if typeDef.tag=='functiontypedef' then return 'function' elseif typeDef.tag=='recordtypedef' then return 'field' end end
      --    local typename=o.type.typename
      --    if typename:sub(1,2)=='__' and typename:match('__%d+$') then return 'function' else return 'field' end --educated guess
    elseif typeTag=='exprtyperef' then
      if o.type.expression.definition then return getItemTTag(o.type.expression.definition)
      else return nil end
    end
    print('Cannot determine type for:') _DEBUG(o,4) print('resolvetype():',o:resolvetype() or 'nil') error'unknown type'
  end
  local function setItemTTag(t) t.ttag=getItemTTag(t) return t.ttag end
  local function _getItemType(t,typeref)
    --TODO for singlefile, all refs must be absolute (so, module must be included for internaltyperef)
    if not t then return 'notype','' end
    local tag=t.tag
    if tag=='primitivetyperef' then
      if t.typename=='nil' then return 'niltype','nil'
      else return 'primitivetype',t.typename end
    elseif tag=='internaltyperef' then
      if t.typename=='cdata' then return 'primitivetype','cdata'
      elseif typeref and typeref.metadata and typeref.metadata.static then return 'staticinternaltype',t.typename
      else return 'internaltype',t.typename end
    elseif tag=='externaltyperef' then return 'externaltype',t.typename,t.modulename
    elseif tag=='exprtyperef' then return _getItemType(t.expression.definition.type)
    else _DEBUG(t) error('cannot deal with type tag:'..tag) end
  end
  local function getItemType(t,typeref)
    if not t then return {ttag='notype',name=''} end
    local tag,name,module=_getItemType(t,typeref)
    return {ttag=tag,name=name,module=module or currentModuleName}
  end
  local PRIMITIVE_TYPES={['nil']=true,boolean=true,number=true,string=true,table=true,['function']=true,cdata=true,userdata=true}
  local function getTypeFromString(s)
    local module,name=s:match('([%w._]*)#([%w._]+)')
    if #module==0 then module=nil end
    local ttag='internaltype'
    if PRIMITIVE_TYPES[name] then ttag='primitivetype'
    elseif module then ttag='externaltype' end
    return {ttag=ttag,name=name,module=module or currentModuleName}
  end

  local tags={
    ['file']=function(o,flt,i)
      local t=copyAttrs(o) t.types={ttag='types'} t.globalfields={ttag='globalfields'} t.globalfunctions={ttag='globalfunctions'} t.ttag='module'
      currentModuleName=t.name
      t.anchors={} -- save all anchors here, so later we can link back to them
      t.addtypeanchor=function(o)
        assert(o.ttag=='type')
        t.anchors[sformat('%s#(%s)',t.name,o.name)]=o
      end
      t.addanchor=function(o)
        assert(o.ttag=='field' or o.ttag=='function')
        assert(o.parent.ttag=='type')
        t.anchors[sformat('%s#(%s).%s',t.name,o.parent.name,o.name)]=o
      end
      for k,v in sortedpairs(o.globalvars) do
        if setItemTTag(v) then
          local f=traverse(v,flt,i+1)
          if f then
            tinsert(v.ttag=='function' and t.globalfunctions or t.globalfields,f)
            print('Found global '..f.name)
            t.anchors[sformat('%s#().%s',t.name,f.name)]=f
          end
        end
      end
      local moduleType
      local moduleTypeRef=o:moduletyperef()
      if moduleTypeRef and moduleTypeRef.tag=='internaltyperef' then
        local moduleTypeDef=o.types[moduleTypeRef.typename]
        if moduleTypeDef and moduleTypeDef.tag=='recordtypedef' then
          moduleType=moduleTypeDef moduleType.ttag='type'
          local module=traverse(moduleType,flt,i+1,t)
          if module then module.extra=t.extra module.htag='Module' end
          tinsert(t.types,module)
        end
      end
      for k,v in sortedpairs(o.types) do if v~=moduleType then
        assert(v.tag=='functiontypedef' or v.tag=='recordtypedef',v.name..' found inside types: '..v.tag)
        if v.tag=='recordtypedef' then v.ttag='type' tinsert(t.types,traverse(v,flt,i+1,t)) end
      end end
      t.addanchor=nil t.addtypeanchor=nil
      return flt(t) or nil
    end,
    ['type']=function(o,flt,i,parent)
      if o.name=='cdata' then return end
      local t=copyAttrs(o) t.functions={ttag='functions'} t.fields={ttag='fields'}
      t.addanchor=parent.addanchor
      t.htag=t.extra.static and 'Table' or 'Type'
      t.type={ttag='internaltype',name=t.name,module=currentModuleName}
      --TODO extends,map,list
      for k,v in sortedpairs(o.fields) do
        if setItemTTag(v) then tinsert(v.ttag=='function' and t.functions or t.fields,traverse(v,flt,i+1,t)) end
      end
      --metadata: extends.description (the exact string as in source)
      -- also list, map - same thing, the full string in .description
      parent.addtypeanchor(t)
      t.addanchor=nil
      return flt(t) or nil
    end,
    ['function']=function(o,flt,i,parent)
      local typeDef=o:resolvetype() or {}
      local t=copyAttrs(typeDef) t.ttag='function' t.name=o.name t.parent=parent t.extra=getExtra(o)
      t.parameters={ttag='parameters'} t.returns={ttag='returns'}
      for _,mparam in ipairs(typeDef.params or {}) do
        local param=copyAttrs(mparam) param.type=getItemType(mparam.type) param.ttag='parameter' param.short=param.long param.long=nil
        tinsert(t.parameters,param)
      end
      for _,ret in ipairs(typeDef.returns or {}) do
        local returntuple={ttag='returntuple',returntypes={ttag='returntypes'},short=strip(ret.description)}
        -- handle declared vararg returns (--@return #sometype,... desc)
        local j,i,k=0
        while j do i,j=ret.description:find('[%w%._]*#[%w%._]+,',j+1) k=j or k end
        if k then k,j=ret.description:find('[^%s]',k+1) end
        if k and ret.description:sub(k,k+2)=='...' then
          returntuple.short=strip(ret.description:sub(k+3))
          for n in ret.description:gmatch('([%w%._]*#[%w%._]+),') do
            local typeref=getTypeFromString(n)
            tinsert(returntuple.returntypes,typeref)
          end
          tinsert(returntuple.returntypes,{ttag='varargtype',name='...'})
        else
          for _,rtype in ipairs(ret.types) do
            local typeref=getItemType(rtype)
            tinsert(returntuple.returntypes,typeref)
          end
        end
        if not returntuple.returntypes[1] then returntuple.returntypes[1]=getItemType() end
        tinsert(t.returns,returntuple)
      end
      t.htag='Function'
      t.invokator=parent and '.' or ''
      if parent then
        if t.parameters[1] and t.parameters[1].name=='self' then t.invokator=':' t.htag='Method' tremove(t.parameters,1) end
        parent.addanchor(t)
      else t.htag='Global function'
      end
      return flt(t) or nil
    end,
    ['field']=function(o,flt,i,parent)
      local t=copyAttrs(o) t.type=getItemType(o.type,o:resolvetype()) t.parent=parent t.invokator=parent and '.' or ''
      t.htag=parent and 'Field' or 'Global field' if t.extra.const then t.htag='Constant' end
      if parent then parent.addanchor(t) end
      return flt(t) or nil
    end,
    item=function() error'no more!' end,
    functiontypedef=function() error'no more!' end,
    recordtypedef=function() error'no more!' end,
  }
  print(string.rep('  ',i)..'Traversing: '..(o.name or '??'))
  return tags[o.ttag or o.tag](o,flt,i,parent) or nil
end


local function template(model,templ)
  local _=setmetatable(templ,{__index=function(t,k)return function(o)_DEBUG (o)error('tag not implemented: '..k) return o end end})

  local function _list(o,post)
    if not o[1] then return '' end
    --    _DEBUG(o)
    local r={}
    for j,itm in ipairs(o) do tinsert(r,_[itm.ttag..post](itm)) end
    return _[o.ttag..post..'.pre']{}..tconcat(r,_[o.ttag..post..'.sep'](o)).._[o.ttag..post..'.post']{}
  end
  local function list(o) return _list(o,'') end
  local function listindex(o) return _list(o,'.index') end
  local rawget,type=rawget,type
  --- mini template engine.
  -- "$()": return itself (must be a string)
  -- "$(sel)": return string field or call selector on object,
  -- "$(field.subfield)": return string subfield
  -- "@(sel)": call selector on same-name object field
  -- "?(sel)": call selector on optional same-name object field
  -- "?(field.subfield)": return optional string subfield
  -- "@@(field)": call field's ttag
  -- "@?(field)": call an optional field's ttag
  -- ">>(field)": list with field's ttag
  -- ">(field)": list with field's ttag..'.index'
  local function sub(s) return function(o) return
    (s:gsub('>>%b()',function(tag)return list(o[tag:sub(4,-2)]) end)
      :gsub('>%b()',function(tag)return listindex(o[tag:sub(3,-2)]) end)
      :gsub('%$%b()',function(tag)
        tag=tag:sub(3,-2)
        if tag=='' then assert(type(o)=='string','$() called on non-string') return o
        elseif type(o[tag])=='string' then return o[tag] end
        local fld,sub=tag:match('(%w+)%.(%w+)')
        if fld then
          assert(o[fld] and o[fld][sub] and type(o[fld][sub]=='string'),'missing or non-string subfield '..tag)
          return o[fld][sub]
        end
        local f=rawget(_,o.ttag..'.'..tag) or rawget(_,tag)
        return assert(f,'missing selector:'..o.ttag..'.'..tag)(o)
      end)
      :gsub('@@%b()',function(tag)
        tag=tag:sub(4,-2) assert(o[tag],o.name..' has no field '..tag)
        local f=rawget(_,o[tag].ttag)
        return assert(f,'missing selector:'..(o[tag].ttag or 'missing ttag'))(o[tag])
      end)
      :gsub('@%?%b()',function(tag)
        tag=tag:sub(4,-2) if not o[tag] then return '' end
        local f=rawget(_,o[tag].ttag)
        return assert(f,'missing selector:'..(o[tag].ttag or 'missing ttag'))(o[tag])
      end)
      :gsub('@%b()',function(tag)
        tag=tag:sub(3,-2) assert(o[tag],o.name..' has no field '..tag)
        local f=rawget(_,o.ttag..'.'..tag) or rawget(_,tag)
        return assert(f,'missing selector:'..o.ttag..'.'..tag)(o[tag])
      end)
      :gsub('%?%b()',function(tag)
        tag=tag:sub(3,-2)
        local fld,sub=tag:match('(%w+)%.(%w+)')
        if fld then return o[fld] and o[fld][sub] or '' end
        if not o[tag] then return '' end
        local f=rawget(_,o.ttag..'.'..tag) or rawget(_,tag)
        return assert(f,'missing selector:'..o.ttag..'.'..tag)(o[tag])
      end))
  end end
  for k,v in pairs(_) do if type(v)=='string' then _[k]=sub(v) end end
  return _[model.ttag](model)
end
local function resolveLinks(moduleName,s,anchors,templ)
  -- fill in missing module name for internal links
  return s:gsub('@{%s*(#[%w_()%.]-)%s*}', function(l)return '@{'..moduleName..l..'}' end)
    -- find the actual links
    :gsub('@{%s*(.-)%s*}', function(l)
      local o=assert(anchors[l],'cannot resolve link: '..l)
      local destModule=assert(l:match('^(.-)#'),'missing module in link: '..l)
      local header=assert(templ[o.ttag..'.header'],'missing .header for '..o.ttag)(o)
      header=header:gsub('(%b[])%b()','%1')
      local anchor='#'..templ.anchor(header)
      if destModule~=moduleName then anchor=templ.filename(destModule)..anchor end
      print('Link '..l..' resolved to '..anchor)
      return anchor
    end)
end



---Build docs.
-- Args table:
-- - format: 'html', 'md' or 'api'
-- - what: 'all', 'dev', 'apichanges', 'internalchanges'
-- - heuristics: include undocumented fields/functions (unless @private)
-- - dir: relative path to output directory
-- - file: relative path to single output file collating all the docs
-- - toc: name for the ToC file, if omitted, default will be used
-- [1], [2], etc.: source folders
-- Only one of 'dir' and 'file' can be passed.
-- @callof #docbuilder
-- @param #table args {format=...,what=...,dir/file=...,dir1,dir2,...}
local function makeDocs(args)
  assert(type(args)=='table' and #args>0,'No directory or files provided')
  args.format=args.format or 'hmtl'
  args.what=args.what or 'all'
  assert(not (args.dir and args.file),'Only one of dir= or file= allowed')
  assert(not args.tocfile or not args.file,'Cannot have a ToC for single file output')
  args.dir=args.dir or 'docs'
  local function hasValue(t,v)for _,u in ipairs(t) do if v==u then return true end end end
  local validFormats={'html','md','api'}
  local validWhats={'all','dev','internalchanges','apichanges'}
  assert(hasValue(validFormats,args.format),'Invalid format; can be: '..tconcat(validFormats,', '))
  assert(hasValue(validWhats,args.what),'Invalid what; can be: '..tconcat(validWhats,', '))
  assert(args.format~='api' or args.what=='all','format="api" requires what="all"')
  local ok,missing=fs.checkdirectory(args)
  assert(ok,'Files or directories missing: '..tconcat(missing or {},', '))
  local filePaths=assert(fs.filelist(args))
  if args.format=='api' then return makeAPI(filePaths,args.dir) end
  --  local extension='.'..args.format
  local filter=defaultFilter
  if args.what~='all' then
    local t={internalchanges='internalchange',apichanges='apichange',dev='dev'}
    filter=makeMetadataTagFilter(t[args.what])
  end
  local modules,anchors,docs={},{},{ttag='docfiles'}
  for _,filePath in ipairs(filePaths) do
    local metamodel=makeModel(filePath,not args.heuristics)
    if metamodel.name then
      if args.modeldir then
        local dest=args.modeldir..fs.separator..metamodel.name..'.metamodel'
        fs.fill(dest,require'inspect'(metamodel,{depth=12}))
        print('Saved '..dest)
      end
      local model=traverse(metamodel,filter,1)
      if model then
        for s,a in pairs(model.anchors) do anchors[s]=a end model.anchors=nil -- store all anchors
        if args.modeldir then
          local dest=args.modeldir..fs.separator..metamodel.name..'.model'
          fs.fill(dest,require'inspect'(model,{depth=10}))
          print('Saved '..dest)
        end
        tinsert(modules,model)
      end
    else print('Skipped, no module name') end
  end
  local templ=require'doctemplates'[args.what][args.format]
  --  local templ=args.format=='md' and TEMPLATE_MD or error'not implemented'
  if not args.file then args.tocfile=templ.filename(args.dir,args.tocfile or (args.format=='md' and 'README.md' or 'index.html')) end
  for _,module in ipairs(modules) do
    print('Applying template for '..module.name)
    local body=template(module,templ)
    print('Resolving links for '..module.name)
    body=resolveLinks(args.file and 'N/A' or module.name,body,anchors,templ)
    tinsert(docs,args.file and body or {body=body,name=module.name,link=templ.filename(module.name),short=module.short,ttag='docfile'})
  end
  if args.file then
    assert(fs.fill(templ.filename(args.file),tconcat(docs,'\n\n')))
    print('Saved '..args.file)
  else
    for _,doc in ipairs(docs) do
      local filename=templ.filename(args.dir,doc.name)
      assert(fs.fill(filename,doc.body))
      print('Saved '..filename)
    end
    if args.tocfile then
      print('Generating ToC')
      assert(fs.fill(args.tocfile,template({ttag='toc',docfiles=docs},templ)))
      print('Saved '..args.tocfile)
    end
  end
end

return setmetatable({makeDocs=makeDocs},{__call=function(_,...)return makeDocs(...)end})
