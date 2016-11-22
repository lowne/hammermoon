local pathSep=require'fs.lfs'.separator
local pairs,sformat=pairs,string.format

local function extend(base,base2,t)
  local r=setmetatable({},
    {__index=function(t,k)return function(o)
      error((o.type and o.type.ttag or '?')..' '..(o and o.name or '?')..': tag not implemented: '..k)
    end end})
  for k,v in pairs(base) do r[k]=v end
  for k,v in pairs(base2 or {}) do r[k]=v end
  for k,v in pairs(t or {}) do r[k]=v end
  for k,v in pairs(r) do
    if type(v)=='string' and v:sub(1,5)=='COPY:' then r[k]=r[v:sub(6)] end
  end
  return r
end

local TEMPLATE_BASE=extend{
  ['module']='$(title)>(globalfunctions)>(globalfields)>(types)>(prototypes)>>(globalfunctions)>>(globalfields)>>(types)>>(prototypes)',

  ['function.link']='@[#($(plainparent)).$(name)]',
  ['field.link']='@[#($(plainparent)).$(name)]',
  ['type.link']='@[#($(name))]',

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

  ['extra']='?(dev)?(apichange)',

  ['typelink']='@[$(module)#($(name))]',
}

local LINE='\n'
local BR='\n\n'
local HR='\n\n------------------\n\n'

local TEMPLATE_MD_INDEX_TABLES=extend{
  ['globalfunctions.index.pre']='| Global functions| |\n| :--- | :--- |\n',--function()return mdtableheader('Global functions')..'\n' end,
  ['globalfunctions.index.sep']=LINE,
  ['globalfunctions.index.post']=BR,
  ['globalfields.index.pre']='| Global fields | |\n| :--- | :--- |\n',--function()return mdtableheader('Global fields')..'\n' end,
  ['globalfields.index.sep']=LINE,
  ['globalfields.index.post']=BR,

  ['prototypes.index.pre']='| Function prototypes | |\n| :--- | :--- |\n',
  ['prototypes.index.sep']=LINE,
  ['prototypes.index.post']=BR,

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
}
local TEMPLATE_MD_INDEX_LISTS=extend{
  ['globalfunctions.index.pre']='* Global functions:\n',
  ['globalfunctions.index.sep']=LINE,
  ['globalfunctions.index.post']=BR,
  ['globalfields.index.pre']='* Global fields:\n',
  ['globalfields.index.sep']=LINE,
  ['globalfields.index.post']=BR,

  ['prototypes.index.pre']='* Function prototypes:\n',
  ['prototypes.index.sep']=LINE,
  ['prototypes.index.post']=BR,

  ['function.index']='  * [`$(name)(>(parameters))`]($(link))>(returns) - @(htag)',

  ['field.index']='  * [`$(name)`]($(link)) : @@(type) - @(htag)',

  ['types.index.pre']=LINE,
  ['types.index.sep']='',
  ['types.index.post']=BR,

  ['type.index']='* $(htag) [`$(name)`]($(link))\n>(functions)>(fields)\n\n',

  ['htag']=function(o)return o:lower()end,
  ['functions.index.pre']='',
  ['functions.index.sep']=LINE,
  ['functions.index.post']=LINE,
  ['fields.index.pre']='',
  ['fields.index.sep']=LINE,
  ['fields.index.post']=LINE,
}
local TEMPLATE_MD=extend(TEMPLATE_BASE,TEMPLATE_MD_INDEX_LISTS,{
  ['module.title']='$(header)@(extra)$(short)\n\n@(long)$(subheader)',
  ['module.header']='# Module $(fullname)\n\n',
  ['module.subheader']='## Overview\n\n',
  ['module.fullname']='`$(name)`',


  ['globalfunctions.pre']=HR..'## Global functions\n\n',
  ['globalfunctions.sep']='',
  ['globalfunctions.post']=BR,

  ['globalfields.pre']=HR..'## Global fields\n\n',
  ['globalfields.sep']='',
  ['globalfields.post']=BR,

  ['prototypes.pre']=HR,
  ['prototypes.sep']=BR,
  ['prototypes.post']=LINE,

  ['types.pre']=HR,
  ['type']='$(title)>>(functions)>>(fields)',
  ['type.title']='@(headersize) $(header)\n\n@?(extends)@(extra)$(short)\n\n?(long)$(usage)',
  ['headersize']=function(o)return string.rep('#',o) end,
  --  ['type.headersize']=function(o)return o.extra.class and '##' or '###' end,
  ['type.header']='$(htag) `$(name)`',
  ['extends']='> extends @@(type)\n\n',
  ['type.fullname']=function(o)return sformat(o.extra.static and '%s' or '<#%s>',o.name) end,
  ['type.headername']=function(o)return sformat(o.extra.static and '%s' or '#%s',o.name) end,
  ['types.sep']=HR,
  ['types.post']=LINE,

  ['functions.pre']=LINE,
  ['function.title']='### $(header)\n\n@(extra)$(short)\n\n',
  ['long']='$()\n\n',
  ['function.header']='$(htag) `$(fullname)(>(parameters))`>(returns)',
  ['functions.sep']=LINE,
  ['functions.post']=LINE,

  --  ['parameters.pre']='**Parameters:**\n\n',
  ['parameters.pre']='',
  --  ['parameter']='* @@(type) `$(name)`: $(short)',
  ['parameter']='* `$(name)`: @@(type) $(short)',
  ['parameters.sep']=LINE,
  ['parameters.post']=BR,

  --  ['returns.pre']='**Returns:**\n\n',
  ['returns.pre']=BR,
  --  ['returntuple']='* >(returntypes) $(short)',
  ['returntuple']='* Returns >(returntypes): $(short)@?(selftype)',
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

  ['usage']=function(o) return o.extra.usage and sformat('**Usage**:\n\n```lua\n%s\n```\n',o.extra.usage.short) or '' end,

  ['notype']='_`<?>`_',
  ['notype.index']='_`<?>`_',
  ['varargtype']='_`...`_',
  ['varargtype.index']='_`...`_',
  ['niltype']='_`nil`_',
  ['niltype.index']='_`nil`_',
  ['primitivetype']='_`<#$(name)>`_',
  ['primitivetype.index']='_`<#$(name)>`_',

  ['internaltype']='[_`<#$(name)>`_]($(typelink))',
  ['internaltype.index']='[_`<#$(name)>`_]($(typelink))',

  --  ['selftype']='',
  ['selftype.index']='`self`', --only for function returns

  ['staticinternaltype']='[_`$(name)`_]($(typelink))',
  ['staticinternaltype.index']='[_`$(name)`_]($(typelink))',
  --  ['listtype']='`{`[`<#$(valuetype.name)>`](@{$(valuetype.module)#($(valuetype.name))})`, ...}`',
  ['listtype']='`{`@@(valuetype)`, ...}`',
  ['listtype.index']='`{`@@(valuetype)`, ...}`',
  ['maptype']='`{ [`@@(keytype)`] =`@@(valuetype)`, ...}`',
  ['maptype.index']='`{ [`@@(keytype)`] =`@@(valuetype)`, ...}`',
  ['externaltype']='[_`<$(module)#$(name)>`_]($(typelink))',
  ['externaltype.index']='[_`<$(module)#$(name)>`_]($(typelink))',
  ['moduletype']='[_`$(module)`_]($(typelink))',
  ['moduletype.index']='[_`$(module)`_]($(typelink))',

  ---special fn to generate anchors for user links (i.e. @{...}) by resolveLinks
  ['userlink']=function(text,anchor) return sformat('[`%s`](%s)',text,anchor) end,
  ['userlinktype']=function(text,anchor) return sformat('[_`%s`_](%s)',text,anchor) end,
  ---special fn to generate anchors from a header string for resolveLinks
  ['anchor']=function(s)
    assert(type(s)=='string')
    s=s:gsub('(%b[])%b()','%1') -- get the text part of the header
    return s:lower():gsub('%s','-'):gsub('[^%w%-]','') -- slugify according to github md headers
  end,
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
  ['module']='$(title)>>(globalfunctions)>>(globalfields)>>(types)>>(prototypes)', -- no index
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
  apichange={md=TEMPLATE_APICHANGES_MD,html=TEMPLATE_APICHANGES_HTML},
  internalchange={md=TEMPLATE_INTERNALCHANGES_MD,html=TEMPLATE_INTERNALCHANGES_HTML},
}

