local pathSep=require'fs.lfs'.separator
local pairs,sformat=pairs,string.format

local function extend(base,base2,t)
  local r={}
  for k,v in pairs(base) do r[k]=v end
  for k,v in pairs(base2) do r[k]=v end
  for k,v in pairs(t or {}) do r[k]=v end
  return r
end

local TEMPLATE_BASE={
  ['module']='$(title)>(globalfunctions)>(globalfields)>(types)>>(globalfunctions)>>(globalfields)>>(types)',

  ['function.link']='@{#($(plainparent)).$(name)}',
  ['field.link']='@{#($(plainparent)).$(name)}',
  ['type.link']='@{#($(name))}',

  ['type']='$(title)>>(functions)>>(fields)',

  ['fullname']='?(parent)$(invokator)$(name)',
  ['parent']='$(fullname)',
  ['plainparent']='?(parent.name)',

  ['function']='$(title)>>(parameters)>>(returns)?(long)$(usage)',

  ['parameters.index.pre']='',
  ['parameter.index']='$(name)',
  ['parameters.index.sep']=',',
  ['parameters.index.post']='',

  ['returns.index.pre']=' -> ',
  ['returntuple.index']='>(returntypes)',
  ['returntypes.index.pre']='',
  ['returntypes.index.sep']=',',
  ['returntypes.index.post']='',
  ['returns.index.sep']=' or ',
  ['returns.index.post']='',

  ['field']='$(title)?(long)$(usage)',

  ['type.static']=function(o)
    assert(o.type.ttag=='internaltype')
    return o.extra.static and '> Static table' or sformat('> Metatable for `<#%s>` objects',o.name)
  end,
  ['type.static']='',
  ['extra']='?(dev)?(apichange)',

  ['typelink']='@{$(module)#($(name))}',

}

local LINE='\n'
local BR='\n\n'
local TEMPLATE_MD=extend(TEMPLATE_BASE,{
  ['module.title']='$(header)@(extra)$(short)\n\n@(long)$(subheader)',
  ['module.header']='# Module $(fullname)\n\n',
  ['module.subheader']='## Overview\n\n',
  ['module.fullname']='`$(name)`',
  ['globalfunctions.index.pre']='| Global functions| |\n| :--- | :--- |\n',--function()return mdtableheader('Global functions')..'\n' end,
  ['globalfunctions.index.sep']=LINE,
  ['globalfunctions.index.post']=BR,
  ['globalfields.index.pre']='| Global fields | |\n| :--- | :--- |\n',--function()return mdtableheader('Global fields')..'\n' end,
  ['globalfields.index.sep']=LINE,
  ['globalfields.index.post']=BR,

  ['function.index']='$(htag) [`$(fullname)(>(parameters))`]($(link))>(returns) | $(short)',

  ['field.index']='$(htag) [`$(fullname)`]($(link)) : @@(type) | $(short)',

  ['types.index.pre']=LINE,
  ['types.index.sep']='',
  ['types.index.post']=BR,

  ['type.index']='| $(htag) [$(fullname)]($(link)) | $(short) |\n| :--- | :---\n>(functions)>(fields)\n\n',

  ['functions.index.pre']='',
  ['functions.index.sep']=LINE,
  ['functions.index.post']=LINE,
  ['fields.index.pre']='',
  ['fields.index.sep']=LINE,
  ['fields.index.post']=LINE,

  ['globalfunctions.pre']='\n\n-----------\n\n## Global functions\n\n',
  ['globalfunctions.sep']='',
  ['globalfunctions.post']=BR,

  ['globalfields.pre']='\n\n-----------\n\n## Global fields\n\n',
  ['globalfields.sep']='',
  ['globalfields.post']=BR,


  ['types.pre']='\n\n-----------\n\n',
  ['type']='$(title)>>(functions)>>(fields)',
  ['type.title']='## $(header)\n\n$(static)\n\n@(extra)$(short)\n\n?(long)',
  ['type.header']='$(htag) `$(fullname)`',
  ['type.fullname']=function(o)return sformat(o.extra.static and '%s' or '<#%s>',o.name) end,
  ['types.sep']='\n\n-----------\n\n',
  ['types.post']='\n\n-----------\n\n-----------\n\n',

  ['functions.pre']=LINE,
  ['function.title']='### $(header)\n\n@(extra)$(short)\n\n',
  ['long']='$()\n\n',
  ['function.header']='$(htag) `$(fullname)(>(parameters))`>(returns)',
  ['functions.sep']=LINE,
  ['functions.post']=LINE,

  ['parameters.pre']='**Parameters:**\n\n',
  ['parameter']='* `$(name)`: @@(type) $(short)',
  ['parameters.sep']=LINE,
  ['parameters.post']=BR,

  ['returns.pre']='**Returns:**\n\n',
  ['returntuple']='* >(returntypes) $(short)',
  ['returntypes.pre']='',
  ['returntypes.sep']=LINE,
  ['returntypes.post']=LINE,
  ['returns.sep']=LINE,
  ['returns.post']=BR,


  ['fields.pre']='',
  ['field.title']='### $(header)\n\@(extra)$(short)\n\n',
  ['field.header']='$(htag) `$(fullname)`: @@(type)',
  ['fields.sep']=LINE,
  ['fields.post']='',


  ['extra']='?(dev)?(apichange)',

  ['dev']='> **Internal/advanced use only** (e.g. for extension developers)\n\n',
  ['apichange']='> **API CHANGE**: $(short)\n\n',
  ['internalchange']='> INTERNAL CHANGE: $(short)\n\n',

  ['usage']=function(o) return o.extra.usage and sformat('**Usage**:\n\n```lua\n%s\n```',o.extra.usage.short) or '' end,

  ['notype']='`?`',
  ['notype.index']='`?`',
  ['varargtype']='`...`',
  ['varargtype.index']='`...`',
  ['niltype']='`nil`',
  ['niltype.index']='`nil`',
  ['primitivetype']='`<#$(name)>`',
  ['primitivetype.index']='`<#$(name)>`',

  ['internaltype']='[`<#$(name)>`]($(typelink))',
  ['internaltype.index']='[`<#$(name)>`]($(typelink))',
  ['staticinternaltype']='[`$(name)`]($(typelink))',
  ['staticinternaltype.index']='[`$(name)]($(typelink))',
  ['externaltype']='[`<$(module)#$(name)>`]($(typelink))',
  ['externaltype.index']='[`<$(module)#$(name)>`]($(typelink))',
  --  ['externaltypelink']='$(module).md$(typelink)',
  ['typelink']='@{$(module)#($(name))}',
  --  ['typelink']=function(o)return '#'..slugify('<#'..o.name..'>') end, --FIXME
  --  _['slugify']=function(o)local str=_[o.ttag..'.header'](o) return str:lower():gsub('%s','-'):gsub('[^%w%-_]','') end

  ---special fn to generate anchors for resolveLinks
  ['anchor']=function(s) assert(type(s)=='string') return s:lower():gsub('%s','-'):gsub('[^%w%-_]','') end,
  ----make filename
  ['filename']=function(dir,moduleName)
    if not moduleName then moduleName=dir dir=nil end
    if moduleName:sub(-3):lower()~='.md' then moduleName=moduleName..'.md' end
    if dir then moduleName=dir..pathSep..moduleName end
    return moduleName
  end,

  ['toc']='# Documentation\n\n>>(docfiles)',
  ['docfiles.pre']='| Module | |\n| :--- | :---|\n',
  ['docfile']='| [`$(name)`]($(link)) | $(short) |',
  ['docfiles.sep']=LINE,
  ['docfiles.post']=BR,
})

local TEMPLATE_CHANGES_BASE=extend(TEMPLATE_BASE,{
  ['module']='$(title)>>(globalfunctions)>>(globalfields)>>(types)', -- no index
  ['module.title']='$(header)@(extra)$(short)\n\n',
})

local TEMPLATE_APICHANGES_BASE=extend(TEMPLATE_CHANGES_BASE,{
  ['extra']='?(dev)?(apichange)',
})
local TEMPLATE_APICHANGES_MD=extend(TEMPLATE_MD,TEMPLATE_APICHANGES_BASE,{
  })
local TEMPLATE_INTERNALCHANGES_BASE=extend(TEMPLATE_CHANGES_BASE,{
  ['extra']='?(dev)?(apichange)?(internalchange)',
})
local TEMPLATE_INTERNALCHANGES_MD=extend(TEMPLATE_MD,TEMPLATE_INTERNALCHANGES_BASE,{
  })
return {
  all={md=TEMPLATE_MD,html=TEMPLATE_HTML},
  apichanges={md=TEMPLATE_APICHANGES_MD,html=TEMPLATE_APICHANGES_HTML},
  internalchanges={md=TEMPLATE_INTERNALCHANGES_MD,html=TEMPLATE_INTERNALCHANGES_HTML},
}

