---@module docbuilder

---@type docbuilder
local M={verbose=nil}
local rawprint=print
local function print(...)return M.verbose and rawprint(...)end
assert(_VERSION == "Lua 5.1",'Lua 5.1 is required')
local lddextractor = require 'lddextractor'
local fs=require'fs.lfs'

function _DEBUG(t,d)
  local p=t.parent t.parent=nil
  local s=require'inspect'(t,{depth=d or 3})
  t.parent=p return s
end
function _PDEBUG(t,d) print(_DEBUG(t,d)) end
local pairs,ipairs,next=pairs,ipairs,next
local tinsert,tremove,tsort,tconcat,sformat=table.insert,table.remove,table.sort,table.concat,string.format

local function readFile(filePath)
  local file=assert(io.open(filePath,'r'))
  local data=file:read('*all')
  file:close()
  return data
end


---Model generated by lddextractor
--@type metamodel

---Generate metamodel with lddextractor
--@return #metamodel
function M.makeMetamodel(filePath,noHeuristics)
  return assert(lddextractor.generateapimodule(filePath,readFile(filePath),noHeuristics))
end

---Return only the ldoc comments in a source file
--@return #string
function M.extractComments(filePath)
  return assert(lddextractor.generatecommentfile(filePath,readFile(filePath)))
end

function M.makeAPI(filePaths,destPath)
  for _,filePath in ipairs(filePaths) do
    local module=M.makeMetamodel(filePath)
    assert(module.name,'No module name for '..filePath)
    local comments=M.extractComments(filePath)
    local pathOut=destPath..fs.separator..module.name..'.lua'
    assert(fs.fill(pathOut,comments))
    print('Generated file ',pathOut)
  end
end

--local function has(t) return t and next(t) end
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
function M.makeMetadataTagFilter(metadataTag)
  if metadataTag=='all' then return defaultFilter end
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


---Filter a model to only keep interesting items
--@param #module module
--@param filter
--@return #module the filtered model
function M.filter(module,filter)
  local function copy(t) return {name=t.name,ttag=t.ttag,htag=t.htag,type=t.type,extra=t.extra,short=t.short,long=t.long} end
  local function flt(s,d,fieldname)
    d[fieldname]=copy(s[fieldname])
    for _,f in ipairs(s[fieldname]) do tinsert(d[fieldname],filter(f) or nil) end
  end
  local r=copy(module) r.types=copy(module.types)
  flt(module,r,'globalfunctions')
  flt(module,r,'globalfields')
  for _,t in ipairs(module.types) do
    local dt=copy(t)
    flt(t,dt,'functions')
    flt(t,dt,'fields')
    tinsert(r.types,filter(dt) or nil)
  end
  return filter(r) or nil
end

---@type anchors
--@map <#string,#typeditem>

---Generate a module's model ready for templating, and a dictionary of anchors for all parsed items to be used later by resolveLinks
--@param #metamodel metamodel
--@return #module,#anchors
function M.makeModel(metamodel)
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


  ---@type item
  --@field #string name
  --@field #string ttag
  --@field #string htag
  --@field #table metamodel

  ---@type typeditem
  --@extends #item
  --@field #itemtype type

  ---@type module
  --@extends #item
  --@field #typelist types
  --@field #fieldlist globalfields
  --@field #fnlist globalfunctions

  ---@type typelist
  --@list <#type>

  ---@type type
  --@extends #item
  --@field #fieldlist fields
  --@field #functionlist functions

  ---@type fieldlist
  --@list <#field>

  ---@type field
  --@extends #typeditem

  ---@type fnlist
  --@list <#function>

  ---@type fn
  --@extends #item
  --@field #parameterlist parameters
  --@field #returntuplelist returns

  ---@type parameterlist
  --@list <#parameter>

  ---@type parameter
  --@extends #typeditem

  ---@type returntuplelist
  --@list <#returntuple>

  ---@type returntuple
  --@list <#returntype>

  ---@type returntype
  --@extends #typeditem

  ---notype, niltype, primitivetype, internaltype, staticinternaltype, listtype, maptype, externaltype
  --@type typettag
  --@extends #string

  ---@type itemtype
  --@field #typettag ttag
  --@field #string name
  --@field #string module (optional) module name for externaltype
  --@field #table typedef link to metamodel typedef (if available)

  local module=copyAttrs(metamodel) --#module
  local typedefs,anchors={},{}

  local PRIMITIVE_TYPES={['nil']=true,boolean=true,number=true,string=true,table=true,['function']=true,cdata=true,userdata=true}
  ---@return #itemtype
  local function getTypeFromString(s)
    local mod,name=s:match('([%w._]*)#([%w._]+)')
    if #mod==0 then mod=nil end
    local ttag='internaltype'
    if PRIMITIVE_TYPES[name] then ttag='primitivetype'
    elseif mod then ttag='externaltype' end
    return {ttag=ttag,name=name,module=mod or module.name}
  end

  ---@return #itemtype
  local function getItemType(o)
    if not o or not o.type then return {ttag='notype',name=''} end
    local typetag,typename,typedef=o.type.tag,o.type.typename,o.resolvetype and o:resolvetype()
    if typetag=='primitivetyperef' then
      if typename=='nil' then return {ttag='niltype',name='nil'}
      else return {ttag='primitivetype',name=typename} end
    elseif typetag=='externaltyperef' then return {ttag='externaltype',name=typename,module=o.type.modulename}
    elseif typetag=='exprtyperef' then return getItemType(o.type.expression.definition)
    elseif typetag=='inlinetyperef' then
      assert(typedef,'inlinetyperef without typedef: '.._DEBUG(o))
      if typedef.tag=='functiontypedef' then return {ttag='functiontype',name=typedef.name,module=module.name}--,typedef=typedef}
      else error('inlinetyperef not a function '.._DEBUG(o)) end
    elseif typetag=='internaltyperef' then
      if typename=='cdata' then return {ttag='primitivetype',name='cdata'}
      elseif typedefs[typename] then return typedefs[typename].type
      else
        assert(typedef and typedef.tag=='functiontypedef')
        return {ttag='functiontype',name=typedef.name,module=module.name}--,typedef=typedef}
      end
    else _DEBUG(o) error('cannot deal with type tag:'..typetag) end
  end

  ---@return #type
  local function newType(o)
    if o.name=='cdata' then return end --ffi primitive type (not known to apimodelbuilder)
    print('  Adding type '..o.name)
    local t=copyAttrs(o) --#type
    t.ttag='type' t.metamodel=o t.htag=t.extra.static and 'Table' or 'Type'
    t.functions={ttag='functions'} t.fields={ttag='fields'}
    t.type={ttag='internaltype',name=t.name,module=module.name}--,typedef=o}
    typedefs[t.name]=t
    if t.extra.list then
      local valuename=assert(t.extra.list.short:match('^<#(.-)>'),'no basetype for '..t.name)
      local valuetype=getTypeFromString('#'..valuename)
      --      if valuetype.ttag=='internaltype' then valuetype.typedef=assert(typedefs[valuename].metamodel,'no typedef for '..valuename) end
      t.type.ttag='listtype' t.type.valuetype=valuetype
      return
    elseif t.extra.map then
      local keyname,valuename=t.extra.map.short:match('^<#(.-),%s*#(.-)>')
      assert(keyname and valuename,'no keytype or valuetype for '..t.name)
      local keytype,valuetype=getTypeFromString('#'..keyname),getTypeFromString('#'..valuename)
      --      if keytype.ttag=='internaltype' then keytype.typedef=assert(typedefs[keyname],'no typedef for keytype '..keyname) end
      --      if valuetype.ttag=='internaltype' then valuetype.typedef=assert(typedefs[valuename].metamodel,'no typedef for valuetype '..valuename) end
      t.type.ttag='maptype' t.type.keytype=keytype t.type.valuetype=valuetype
      return
    elseif t.extra.static then t.type.ttag='staticinternaltype' end
    tinsert(module.types,t) anchors[sformat('%s#(%s)',module.name,t.name)]=t
    return t
  end

  ---@return #fn
  local function newFunction(o,parent)
    local itemtype=getItemType(o)
    local typedef=o:resolvetype() or {} --itemtype.typedef
    local t=copyAttrs(typedef) --#fn
    t.ttag='function' t.name=o.name t.parent=parent t.extra=getExtra(o) --t.type=itemtype
    t.parameters={ttag='parameters'} t.returns={ttag='returns'}
    for _,mparam in ipairs(typedef.params or {}) do
      local param=copyAttrs(mparam) param.type=getItemType(mparam) param.ttag='parameter' param.short=param.long param.long=nil
      tinsert(t.parameters,param)
    end
    for _,ret in ipairs(typedef.returns or {}) do
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
          local typeref=getItemType({type=rtype})
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
    else t.htag='Global function' end
    anchors[sformat('%s#(%s).%s',module.name,parent and parent.name or '',t.name)]=t
    return t
  end

  ---@return #field
  local function newField(o,parent)
    local t=copyAttrs(o) --#type
    t.type=getItemType(o) t.parent=parent t.ttag='field'
    t.invokator=parent and '.' or ''
    t.htag=parent and 'Field' or 'Global field' if t.extra.const then t.htag='Constant' end
    anchors[sformat('%s#(%s).%s',module.name,parent and parent.name or '',t.name)]=t
    return t
  end

  ---traverse metamodel
  module.ttag='module' module.htag='Module'
  module.types={ttag='types'} module.globalfields={ttag='globalfields'} module.globalfunctions={ttag='globalfunctions'}

  local moduleTypeRef=assert(metamodel:moduletyperef(),'no module typeref!') assert(moduleTypeRef.tag=='internaltyperef')
  local moduleTypeDef=assert(metamodel.types[moduleTypeRef.typename],'no module type!') assert(moduleTypeDef.tag=='recordtypedef')
  --- add module's type
  local moduleType=newType(moduleTypeDef) moduleType.htag='Module'
  --- gather types
  for k,v in sortedpairs(metamodel.types) do if v~=moduleTypeDef then
    assert(v.tag=='functiontypedef' or v.tag=='recordtypedef',v.name..' found inside types: '..v.tag)
    if v.tag=='recordtypedef' then newType(v) end
  end end
  --- add globals
  for k,item in sortedpairs(metamodel.globalvars) do
    print('  Adding global '..item.name)
    local itemtype=getItemType(item) --#itemtype
    if itemtype.ttag=='functiontype' then tinsert(module.globalfunctions,newFunction(item))
    else tinsert(module.globalfields,newField(item)) end
  end
  --- add types
  for _,v in ipairs(module.types) do
    local type=v --#type
    print('  Traversing type '..type.name)
    for k,item in sortedpairs(type.metamodel.fields) do
      print('    Adding field '..item.name)
      local itemtype=getItemType(item) --#itemtype
      if itemtype.ttag=='functiontype' then tinsert(type.functions,newFunction(item,type))
      else tinsert(type.fields,newField(item,type)) end
    end
    type.metamodel=nil --cleanup
  end

  return module,anchors--filter(module) or nil,anchors
end

---Generate doc contents for an item's model (module, type, field, function, ...)  by applying a template
--@param #item item
--@param #table templ the template to use
--@return #string
function M.template(item,templ)
  --  local _=setmetatable(templ,{__index=function(t,k)return function(o)_DEBUG (o)error('tag not implemented: '..k) return o end end})
  local _=templ
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
    (s:gsub('>>%b()',function(tag) return list(o[tag:sub(4,-2)]) end)
      :gsub('>%b()',function(tag) return listindex(o[tag:sub(3,-2)]) end)
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
      :gsub('!%b()',function(tag)
        tag=tag:sub(3,-2)
        if tag=='' then assert(type(o)=='string','$() called on non-string') print(o)return o
        elseif type(o[tag])=='string' then print(o[tag])return o[tag] end
        local fld,sub=tag:match('(%w+)%.(%w+)')
        if fld then
          assert(o[fld] and o[fld][sub] and type(o[fld][sub]=='string'),'missing or non-string subfield '..tag)
          print(o[fld][sub]) return o[fld][sub]
        end
        print(tag) return ''
          --        local f=rawget(_,o.ttag..'.'..tag) or rawget(_,tag)
          --        local r=assert(f,'missing selector:'..o.ttag..'.'..tag)(o)
          --        print(r) return r
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
  return _[item.ttag](item)
end

local resolved={}
---Resolve `@{...}` links (in the original comments, or added by the template)
--@param #string modulename
--@param #string doc
--@param #anchors anchors
--@param #table templ the template that was passed to `template()`
function M.resolveLinks(moduleName,doc,anchors,templ)
  -- fill in missing module name for internal links
  return doc:gsub('@{%s*(#[%w_()%.]-)%s*}', function(l)return '@{'..moduleName..l..'}' end)
    -- find the actual links
    :gsub('@{%s*(.-)%s*}', function(l)
      local o=assert(anchors[l],'cannot resolve link: '..l)
      local destModule=assert(l:match('^(.-)#'),'missing module in link: '..l)
      local header=assert(templ[o.ttag..'.header'],'missing .header for '..o.ttag)(o)
      header=header:gsub('(%b[])%b()','%1')
      local anchor='#'..templ.anchor(header)
      if destModule~=moduleName then anchor=templ.filename(destModule)..anchor end
      if not resolved[l] then print('Link '..l..' resolved to '..anchor) resolved[l]=true end
      return anchor
    end)
end

return M