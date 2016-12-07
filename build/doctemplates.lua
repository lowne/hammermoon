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
  ['assets']=function()return{} end,
  ['file']='$(body)',
  ['module']='$(title)$>(globalfunctions)$>(globalfields)$>(types)$>(prototypes)$>>(globalfunctions)$>>(globalfields)$>>(types)$>>(prototypes)',
  ['module.fullname']='$(name)',
  ['module.link']='@[$(name)#()]',

  ['function.link']='@[#($(plainparent)).$(name)]',
  ['field.link']='@[#($(plainparent)).$(name)]',
  ['type.link']='@[#($(name))]',

  ['type']='$(title)$>>(fields)$>>(functions)',

  ['fullname']='?(parent)$(invokator)$(name)',
  ['parent']='$(fullname)',
  ['plainparent']='?(parent.name)',

  ['function']='$(title)$>>(parameters)$>>(returns)?(long)$(usage)',

  ['parameters.index.pre']='',
  ['parameter.index']='$(name)',
  ['parameters.index.sep']=',',
  ['parameters.index.post']='',

  ['returns.index.pre']=' -> ',
  ['returntuple.index']='$>(returntypes)',
  ['returntypes.index.pre']='',
  ['returntypes.index.sep']=',',
  ['returntypes.index.post']='',
  ['returns.index.sep']=' or ',
  ['returns.index.post']='',

  ['field']='$(title)?(long)$(usage)',

  ['extra']='?(dev)?(apichange)',

  ['typelink']='@[$(module)#($(name))]',
}

local MD_LINE='\n'
local MD_BR='\n\n'
local MD_HR='\n\n------------------\n\n'

local TEMPLATE_MD_INDEX_TABLES=extend{
  ['globalfunctions.index.pre']='| Global functions| |\n| :--- | :--- |\n',--function()return mdtableheader('Global functions')..'\n' end,
  ['globalfunctions.index.sep']=MD_LINE,
  ['globalfunctions.index.post']=MD_BR,
  ['globalfields.index.pre']='| Global fields | |\n| :--- | :--- |\n',--function()return mdtableheader('Global fields')..'\n' end,
  ['globalfields.index.sep']=MD_LINE,
  ['globalfields.index.post']=MD_BR,

  ['prototypes.index.pre']='| Function prototypes | |\n| :--- | :--- |\n',
  ['prototypes.index.sep']=MD_LINE,
  ['prototypes.index.post']=MD_BR,

  ['function.index']='$(htag) [`$(fullname)($>(parameters))`]($(link))$>(returns) | $(short)',

  ['field.index']='$(htag) [`$(fullname)`]($(link)) : @@(type) | $(short)',

  ['types.index.pre']=MD_LINE,
  ['types.index.sep']='',
  ['types.index.post']=MD_BR,

  ['type.index']='| $(htag) [$(fullname)]($(link)) | $(short) |\n| :--- | :---\n$>(functions)$>(fields)\n\n',

  ['functions.index.pre']='',
  ['functions.index.sep']=MD_LINE,
  ['functions.index.post']=MD_LINE,
  ['fields.index.pre']='',
  ['fields.index.sep']=MD_LINE,
  ['fields.index.post']=MD_LINE,
}
local TEMPLATE_MD_INDEX_LISTS=extend{
  ['globalfunctions.index.pre']='* Global functions\n',
  ['globalfunctions.index.sep']=MD_LINE,
  ['globalfunctions.index.post']=MD_BR,
  ['globalfields.index.pre']='* Global fields\n',
  ['globalfields.index.sep']=MD_LINE,
  ['globalfields.index.post']=MD_BR,

  ['prototypes.index.pre']='* Function prototypes\n',
  ['prototypes.index.sep']=MD_LINE,
  ['prototypes.index.post']=MD_BR,

  ['function.index']='  * [`$(name)($>(parameters))`]($(link))$>(returns) - @(htag)',

  ['field.index']='  * [`$(name)`]($(link)) : @@(type) - @(htag)',

  ['types.index.pre']=MD_LINE,
  ['types.index.sep']='',
  ['types.index.post']=MD_BR,

  ['type.index']='* $(htag) [`$(name)`]($(link))\n$>(fields)$>(functions)\n\n',

  ['htag']=function(o)return o:lower()end,
  ['functions.index.pre']='',
  ['functions.index.sep']=MD_LINE,
  ['functions.index.post']=MD_LINE,
  ['fields.index.pre']='',
  ['fields.index.sep']=MD_LINE,
  ['fields.index.post']=MD_LINE,
}
local TEMPLATE_MD=extend(TEMPLATE_BASE,TEMPLATE_MD_INDEX_LISTS,{
  ['module.title']='# $(header)\n\n@(extra)$(short)\n\n@(long)$(subheader)',
  ['module.header']='Module `$(name)`',
  ['module.anchor']='Module `$(name)`',
  ['module.subheader']='## Overview\n\n',
  --  ['module.fullname']='`$(name)`',


  ['globalfunctions.pre']=MD_HR..'## Global functions\n\n',
  ['globalfunctions.sep']='',
  ['globalfunctions.post']=MD_BR,

  ['globalfields.pre']=MD_HR..'## Global fields\n\n',
  ['globalfields.sep']='',
  ['globalfields.post']=MD_BR,

  ['prototypes.pre']=MD_HR,
  ['prototypes.sep']=MD_BR,
  ['prototypes.post']=MD_LINE,

  ['types.pre']=MD_HR,
  --  ['type']='$(title)$>$>(fields)$>>(functions)',
  ['type.title']='@(headersize) $(header)\n\n@?(extends)@(extra)$(short)\n\n?(long)$(usage)',
  ['headersize']=function(o)return string.rep('#',o) end,
  --  ['type.headersize']=function(o)return o.extra.class and '##' or '###' end,
  ['type.header']='$(htag) `$(name)`',
  ['type.anchor']='$(htag) `$(name)`',
  ['extends']='> Extends @@(type)\n\n',
  ['type.fullname']=function(o)return sformat(o.extra.static and '%s' or '<#%s>',o.name) end,
  ['type.headername']=function(o)return sformat(o.extra.static and '%s' or '#%s',o.name) end,
  ['types.sep']=MD_HR,
  ['types.post']=MD_LINE,

  ['functions.pre']=MD_LINE,
  ['function.title']='### $(header)\n\n@(extra)$(short)\n\n',
  ['long']='$()\n\n',
  ['function.header']='$(htag) `$(fullname)($>(parameters))`$>(returns)',
  ['function.anchor']='$(htag) `$(fullname)($>(parameters))`$>(returns)',
  ['functions.sep']=MD_LINE,
  ['functions.post']=MD_LINE,

  --  ['parameters.pre']='**Parameters:**\n\n',
  ['parameters.pre']='',
  --  ['parameter']='* @@(type) `$(name)`: $(short)',
  ['parameter']='* `$(name)`: @@(type) $(short)',
  ['parameters.sep']=MD_LINE,
  ['parameters.post']=MD_BR,

  --  ['returns.pre']='**Returns:**\n\n',
  ['returns.pre']=MD_BR,
  --  ['returntuple']='* >(returntypes) $(short)',
  ['returntuple']='* Returns $>(returntypes): $(short)@?(selftype)',
  ['returntypes.pre']='',
  ['returntypes.sep']=MD_LINE,
  ['returntypes.post']=MD_LINE,
  ['returns.sep']=MD_LINE,
  ['returns.post']=MD_BR,


  ['fields.pre']='',
  ['field.title']='### $(header)\n\@(extra)$(short)\n\n',
  ['field.header']='$(htag) `$(fullname)`: @@(type)',
  ['field.anchor']='$(htag) `$(fullname)`: @@(type)',
  ['fields.sep']=MD_LINE,
  ['fields.post']='',


  ['extra']='?(dev)?(checker)?(apichange)?(internalchange)',

  ['checker']='> Defines type checker `$(short)`\n\n',
  ['dev']='> **Internal/advanced use only**\n\n',
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

  ---special fn to generate hrefs for user links (i.e. @{...}) by resolveLinks
  ['userlink']=function(text,anchor) return sformat('[`%s`](%s)',text,anchor) end,
  ['userlinktype']=function(text,anchor) return sformat('[_`%s`_](%s)',text,anchor) end,
  ---special fn to generate hrefs from an anchor for resolveLinks
  ['href']=function(s)
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

  ['toc']='# Documentation\n\n$>>(docfiles)',
  ['docfiles.pre']='| Module | |\n| :--- | :---|\n',
  ['docfile']='| [`$(name)`]($(link)) | $(short) |',
  ['docfiles.sep']=MD_LINE,
  ['docfiles.post']=MD_BR,
})
local LINE='<br>'
local HR='<br>'
local MARKDOWN=function(s)
  return s:gsub('`([^`]+)`','<code>%1</code>')
    :gsub('\n%s*%*%s+([^\n]+)','<li>%1</li>')
    :gsub('[*_][*_](.-)[*_][*_]','<strong>%1</strong>')
    :gsub('[*_](.-)[*_]','<em>%1</em>')

end
local TEMPLATE_HTML=extend(TEMPLATE_BASE,{
  --  ['assets']=function()return {'rainbow.css','rainbow.js','docs.css'} end,
  ['file']=[[
<html>
<title>$(name) - Hammermoon documentation</title>
<meta charset="UTF-8">
<link href="docs.css" rel="stylesheet" type="text/css">
<link href="rainbow.css" rel="stylesheet" type="text/css">
<body>
$(body)
<script src="rainbow.js"></script>
</body>
</html>
]],
  ['entrytype']=function(o)
    local t=o.htag:lower()
    local types={type='Type',tabl='Record',clas='Class',read='Property',prop='Property',fiel='Field',glob='Global',func='Function',meth='Method',modu='Module'}
    return types[o.htag:lower():sub(1,4)] or error('wrong htag: '..t)
  end,
  ['dashanchor']='<a name="//apple_ref/cpp/$(entrytype)/$(fullname)" class="dashAnchor"></a>',
  ['module.title']='$(dashanchor)<h1 id="$(anchor)">Module <code>$(name)</code></h1>@(extra)?(short)?(long)$(subheader)',
  ['module.anchor']=function(o)return (o.parent and o.parent.name..'-' or '')..o.name end,
  ['module.subheader']='<h2>Overview</h2>',
  --  ['module.fullname']='<code>$(name)</code>',


  ['globalfunctions.index.pre']='<dl><dt>Global functions</dt>',
  ['globalfunctions.index.sep']='',
  ['globalfunctions.index.post']='</dl>',
  ['globalfields.index.pre']='<dl><dt>Global fields</dt>',
  ['globalfields.index.sep']='',
  ['globalfields.index.post']='</dl>',

  ['prototypes.index.pre']='<dl><dt>Function prototypes</dt>',
  ['prototypes.index.sep']='',
  ['prototypes.index.post']='</dl>',

  ['function.index']='<dd><a href=$(link)><code>$(name)($>(parameters))</code></a>$>(returns) - @(htag)</dd>',
  ['returns.index.pre']=' &ndash;&rsaquo; ',

  ['field.index']='<dd><a href=$(link)><code>$(name)</code></a> : @@(type) - @(htag)</dd>',

  ['types.index.pre']='<dl>',
  ['types.index.sep']='</dl><dl>',
  ['types.index.post']='</dl>',

  ['type.index']='<dt>$(htag) <a href=$(link)><code>$(name)</code></a></dt>$>(fields)$>(functions)',

  ['htag']=function(o)return o:lower()end,
  ['functions.index.pre']='',
  ['functions.index.sep']='',
  ['functions.index.post']='',
  ['fields.index.pre']='',
  ['fields.index.sep']='',
  ['fields.index.post']='',

  ['globalfunctions.pre']=HR..'<h2>Global functions</h2>',
  ['globalfunctions.sep']='',
  ['globalfunctions.post']=LINE,

  ['globalfields.pre']=HR..'<h2>Global fields</h2>',
  ['globalfields.sep']='',
  ['globalfields.post']=LINE,

  ['prototypes.pre']=HR,
  ['prototypes.sep']=LINE,
  ['prototypes.post']=LINE,

  ['types.pre']=HR,
  --  ['type']='$(title)$>>(fields)$>>(functions)',
  ['type.title']='$(dashanchor)<@(headersize) id="$(anchor)">$(htag) <code>$(name)</code></@(headersize)>@?(extends)@(extra)?(short)?(long)$(usage)',
  ['headersize']=function(o)return 'h'..o end,
  --  ['type.headersize']=function(o)return o.extra.class and '##' or '###' end,
  ['type.anchor']=function(o)return (o.parent and o.parent.name..'-' or '')..o.name end,
  ['extends']='<blockquote>Extends @@(type)</blockquote>',
  ['type.fullname']=function(o)return sformat(o.extra.static and '%s' or '&lt;#%s&gt;',o.name) end,
  ['type.headername']=function(o)return sformat(o.extra.static and '%s' or '#%s',o.name) end,
  ['types.sep']=HR,
  ['types.post']=LINE,

  ['functions.pre']='',
  ['function.title']='$(dashanchor)<h3 id="$(anchor)">$(htag) <code>$(fullname)($>(parameters))</code>$>(returns)</h3>@(extra)?(short)',
  ['short']=function(o)return '<span class=short>'..MARKDOWN(o)..'</p>' end,
  ['long']=function(o)return '<p class=long>'..MARKDOWN(o)..'</p>' end,
  ['function.anchor']=function(o)return (o.parent and o.parent.name..'-' or '')..o.name end,
  ['functions.sep']='',
  ['functions.post']='',

  --  ['parameters.pre']='**Parameters:**\n\n',
  ['parameters.pre']='<ul>',
  --  ['parameter']='* @@(type) `$(name)`: $(short)',
  ['parameter']='<li> <code>$(name)</code>: @@(type) ?(short)</li>',
  ['parameters.sep']='',
  ['parameters.post']='</ul>',

  --  ['returns.pre']='**Returns:**\n\n',
  ['returns.pre']='<ul>',
  --  ['returntuple']='* >(returntypes) $(short)',
  ['returntuple']='<li>Returns $>(returntypes): ?(short)@?(selftype)</li>',
  ['returntypes.pre']='',
  ['returntypes.sep']=LINE,
  ['returntypes.post']=LINE,
  ['returns.sep']='',
  ['returns.post']='</ul>',


  ['fields.pre']='',
  ['field.title']='$(dashanchor)<h3 id="$(anchor)">$(htag) <code>$(fullname)</code>: @@(type)</h3>@(extra)?(short)',
  ['field.anchor']=function(o)return (o.parent and o.parent.name..'-' or '')..o.name end,
  ['fields.sep']='',
  ['fields.post']='',


  ['extra']='?(dev)?(checker)?(apichange)?(internalchange)',

  ['checker']='<blockquote>Defines type checker <code>$(short)</code></blockquote>',
  ['dev']='<blockquote><strong>Internal/advanced use only</strong></blockquote>',
  ['apichange']='<blockquote><strong>API CHANGE:</strong> ?(short)</blockquote>',
  ['internalchange']='<blockquote>INTERNAL CHANGE: ?(short)</blockquote>',

  ['usage']=function(o) return o.extra.usage and
    sformat('<strong>Usage:</strong><br><pre><code class="language-lua">%s</code></pre>',o.extra.usage.short) or '' end,

  ['notype']='<em><code>&lt;?&gt;</code></em>',
  ['notype.index']='<em><code>&lt;?&gt;</code></em>',
  ['varargtype']='<em></code>...</code></em>',
  ['varargtype.index']='<em></code>...</code></em>',
  ['niltype']='<em><code>nil</code></em>',
  ['niltype.index']='<em><code>nil</code></em>',
  ['primitivetype']='<em><code>&lt;#$(name)&gt;</code></em>',
  ['primitivetype.index']='<em><code>&lt;#$(name)&gt;</code></em>',

  ['internaltype']='<a href=$(typelink)><em><code>&lt;#$(name)&gt;</code></em></a>',
  ['internaltype.index']='<a href=$(typelink)><em><code>&lt;#$(name)&gt;</code></em></a>',

  --  ['selftype']='',
  ['selftype.index']='<code>self</code>', --only for function returns

  ['staticinternaltype']='<a href=$(typelink)><em><code>&lt;#$(name)&gt;</code></em></a>',
  ['staticinternaltype.index']='<a href=$(typelink)><em><code>&lt;#$(name)&gt;</code></em></a>',
  --  ['listtype']='`{`[`<#$(valuetype.name)>`](@{$(valuetype.module)#($(valuetype.name))})`, ...}`',
  ['listtype']='<code>{</code>@@(valuetype)<code>, ...}</code>',
  ['listtype.index']='<code>{</code>@@(valuetype)<code>, ...}</code>',
  ['maptype']='<code>{ [</code>@@(keytype)<code>] = </code>@@(valuetype)<code>, ...}</code>',
  ['maptype.index']='<code>{ [</code>@@(keytype)<code>] = </code>@@(valuetype)<code>, ...}</code>',
  ['externaltype']='<a href=$(typelink)><em><code>&lt;$(module)#$(name)&gt;</code></em></a>',
  ['externaltype.index']='<a href=$(typelink)><em><code>&lt;$(module)#$(name)&gt;</code></em></a>',
  ['moduletype']='<a href=$(typelink)><em><code>$(module)</em></code></a>',
  ['moduletype.index']='<a href=$(typelink)><em><code>$(module)</em></code></a>',

  ---special fn to generate hrefs for user links (i.e. @{...}) by resolveLinks
  ['userlink']=function(text,href) return sformat('<a href="%s"><code>%s</code></a>',href,text) end,
  ['userlinktype']=function(text,href) return sformat('<a href="%s"><em><code>%s</code></em></a>',href,text) end,
  ---special fn to generate hrefs from an anchor for resolveLinks
  ['href']=function(s)return s end,
  ----make filename
  ['filename']=function(dir,moduleName)
    if not moduleName then moduleName=dir dir=nil end
    if moduleName:sub(-5):lower()~='.html' then moduleName=moduleName..'.html' end
    if dir then moduleName=dir..pathSep..moduleName end
    return moduleName
  end,

  ['toc']='<h1> Hammermoon documentation</h1> $>>(docfiles)',
  ['docfiles.pre']='<dl>',
  ['docfile']='<dt><a href=$(link)><code>$(name)</code></a></dt><dd>?(short)</dd>',
  ['docfiles.sep']='',
  ['docfiles.post']='</dl>',
})

local function DOCSET(name,type,path)
  return sformat('INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (%s,%s,%s)',name,type,path)
end
local TEMPLATE_DOCSET=extend(TEMPLATE_HTML,{
  --  ['assets']=function()return{'fulldocs/html/*'}end,
  ['file']='CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);\nCREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);\n$(body)',
  ['module']='$(title)$>(globalfunctions)$>(globalfields)$>(types)$>(prototypes)',
  ['globalfunctions.index.pre']='',
  ['globalfunctions.index.sep']='',
  ['globalfunctions.index.post']='',
  ['globalfields.index.pre']='',
  ['globalfields.index.sep']='',
  ['globalfields.index.post']='',
  ['prototypes.index.pre']='',
  ['prototypes.index.sep']='',
  ['prototypes.index.post']='',
  ['types.index.pre']='',
  ['types.index.sep']='',
  ['types.index.post']='',

  ['module.title']='INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("$(name)","Module","$(link)");\n',
  ['function.index']='INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("$(fullname)","$(entrytype)","$(link)");\n',
  ['field.index']='INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("$(fullname)","$(entrytype)","$(link)");\n',
  ['type.index']='INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("$(fullname)","$(entrytype)","$(link)");\n$>(fields)$>(functions)',
  ['type.fullname']=function(o)return sformat(o.extra.static and '%s' or '<#%s>',o.name) end,

  ['anchor']=function(o)return (o.parent and o.parent.name..'-' or '')..o.name end,
})

local TEMPLATE_USERDOCS_MD=extend(TEMPLATE_MD,{
  ['extra']=''
})
local TEMPLATE_USERDOCS_HTML=extend(TEMPLATE_HTML,{
  ['extra']=''
})

local TEMPLATE_USERDOCS_DOCSET=extend(TEMPLATE_DOCSET,{
  --  ['assets']=function()return{'docs/html/*'}end,
  ['extra']=''
})

local TEMPLATE_CHANGES_BASE=extend(TEMPLATE_BASE,{
  ['module']='$(title)$>>(globalfunctions)$>>(globalfields)$>>(types)$>>(prototypes)', -- no index
  ['module.title']='$(header)@(extra)$(short)\n\n',
})

local TEMPLATE_APICHANGES_BASE=extend(TEMPLATE_CHANGES_BASE,{
  ['extra']='?(dev)?(apichange)',
})
local TEMPLATE_APICHANGES_MD=extend(TEMPLATE_MD,TEMPLATE_APICHANGES_BASE,{
  })
local TEMPLATE_APICHANGES_HTML=extend(TEMPLATE_HTML,TEMPLATE_APICHANGES_BASE,{
  })
local TEMPLATE_INTERNALCHANGES_BASE=extend(TEMPLATE_CHANGES_BASE,{
  ['extra']='?(dev)?(apichange)?(internalchange)',
})
local TEMPLATE_INTERNALCHANGES_MD=extend(TEMPLATE_MD,TEMPLATE_INTERNALCHANGES_BASE,{
  })
local TEMPLATE_INTERNALCHANGES_HTML=extend(TEMPLATE_HTML,TEMPLATE_INTERNALCHANGES_BASE,{
  })
return {
  all={md=TEMPLATE_MD,html=TEMPLATE_HTML,docset=TEMPLATE_DOCSET},
  ['-dev']={md=TEMPLATE_USERDOCS_MD,html=TEMPLATE_USERDOCS_HTML,docset=TEMPLATE_USERDOCS_DOCSET},
  --  ['-docset']={docset=TEMPLATE_DOCSET},
  apichange={md=TEMPLATE_APICHANGES_MD,html=TEMPLATE_APICHANGES_HTML},
  internalchange={md=TEMPLATE_INTERNALCHANGES_MD,html=TEMPLATE_INTERNALCHANGES_HTML},
}

