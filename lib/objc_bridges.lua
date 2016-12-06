local type,next,pairs,ipairs=type,next,pairs,ipairs
local rawget,rawset,getmetatable,setmetatable=rawget,rawset,getmetatable,setmetatable
local tostring,tonumber=tostring,tonumber

local ffi=require'ffi'
local C,cast,gc=ffi.C,ffi.cast,ffi.gc

local objc=require'objc'
objc.load'CoreFoundation'
objc.addfunction('CFRetain',{'^v'})
objc.addfunction('CFRelease',{'^v'})
objc.addfunction('CFGetRetainCount',{retval='i','^v'})
objc.addfunction('CFShow',{'^v'})
local log=objc.log
local logtopics=objc.debug.logtopics
local NULL=ffi.NULL --luaffi compat?
local id_ct = ffi.typeof'id'

local logCFRelease=not logtopics.refcount and C.CFRelease or function(cf)
  local n=C.CFGetRetainCount(cf)
  log('refcount','%s: CFRelease() (%d -> %d)',cf,n,n-1)
  return C.CFRelease(cf)
end
local NSRelease=objc.methodcallerraw(objc.NSObject,'release')
local NSRetain=objc.methodcallerraw(objc.NSObject,'retain')
local NSCopy=objc.methodcallerraw(objc.NSObject,'copy')
local bridge_mt={__index=logtopics.refcount and function(t,k)
  assert(k=='get_retained')
  local get=t.get
  rawset(t,k,function(cf,s1,s2)local ret=get(cf,s1,s2) if ret~=NULL then logCFRelease(cf) end return ret end)
  return(rawget(t,k))
end or function(t,k)
  assert(k=='get_retained')
  local get=t.get
  rawset(t,k,function(cf,s1,s2)local ret=get(cf,s1,s2) if ret~=NULL then C.CFRelease(cf) end return ret end)
  return(rawget(t,k))
end}

local bridge_mt_id={__index=function(t,k)
  assert(k=='get_retained')
  local get=t.get
  rawset(t,k,function(id,s1,s2)local ret=get(id,s1,s2) if ret~=NULL then NSRelease(id) end return ret end)
  return(rawget(t,k))
end}

local bridges_mt={__newindex=function(t,k,v)
  assert(type(v)=='table')
  if not getmetatable(v) then
    if v.get then
      local get=v.get
      rawset(v,'get',function(obj,...) if obj==NULL then return nil else return get(obj,...) end end)
    end
    if v.make then
      local make=v.make
      rawset(v,'make',function(val,...) if val==nil then return NULL else return make(val,...) end end)
    end
    setmetatable(v,k:sub(1,1)=='@' and bridge_mt_id or bridge_mt)
  end
  log('bridging','added bridge: %s',k)
  rawset(t,k,v)
end}
local function make_bridge_table(t)return setmetatable(t,bridges_mt) end
local bridges=make_bridge_table{struct1=make_bridge_table{},struct2=make_bridge_table{},tollfree={}}

local loggc=function(cf)
  local n=C.CFGetRetainCount(cf)
  log('refcount','%s: (%d -> %d)',cf,n-1,n)
  return gc(cf,logCFRelease)
end or function(cf) return gc(cf,C.CFRelease) end

local cf_cts={}
local function tollfree_bridge(cftype,nstype)
  assert(objc.debug.bridged_cftypes[cftype],cftype..' is not tollfree bridged')
  cf_cts[cftype]=cf_cts[cftype] or ffi.typeof(cftype)
  local cf_ct=cf_cts[cftype]
  local cf_to_ns=logtopics.refcount and function(cf)
    --original cf should still get CFReleased on gc; :copy() will increase the retain count
    local obj=cast(id_ct,cf)
    local n=C.CFGetRetainCount(cf)
    log('refcount','%s: tollfree CF->NS (%d)',cf,n)
    return NSCopy(obj) -- call :copy() so objc.lua can track refcount internally
  end or function(cf)
    local obj=cast(id_ct,cf)
    return NSCopy(obj)
  end

  local ns_to_cf=logtopics.refcount and function(id)
    local cf=loggc(cast(cf_ct,id))
    local n=C.CFGetRetainCount(cf)
    log('refcount','%s: tollfree NS->CF (%d)',cf,n)
    C.CFRetain(cf) -- will release on gc
    return cf
  end or function(id)
    local cf=gc(cast(cf_ct,id),C.CFRelease)
    C.CFRetain(cf)
    return cf
  end

  bridges[cftype..':'..nstype]={
    --    get_retained=function(cf) local ns=cf_to_ns(cf) CFRelease(cf) return ns end,
    get=cf_to_ns,
    make=ns_to_cf,
  }
  bridges['@"'..nstype..'":'..cftype]={
    --    get_retained=function(ns) local cf=ns_to_cf(ns) NSRelease(ns) return cf end,
    get=ns_to_cf,
    make=cf_to_ns,
  }
  bridges.tollfree[cftype]=ns_to_cf
  bridges.tollfree[nstype]=cf_to_ns
end



-- CFString ----------------
local kCFStringEncodingUTF8=objc.kCFStringEncodingUTF8
local STRING_MAXLEN=8192
local string_out=ffi.new('char[?]',STRING_MAXLEN)
local ctostring=ffi.string
objc.cdef'CFStringGetCString'
--bridgesupport mistakenly has char* instead of const char* for 2nd arg >:{
objc.addfunction('CFStringCreateWithCString',{retval='^{__CFString=}','^{__CFAllocator=}','r*','I'},false)
local function getCFString(cf)
  --  if cf==NULL then return nil end
  C.CFStringGetCString(cf,string_out,STRING_MAXLEN,kCFStringEncodingUTF8)
  return ctostring(string_out)
end
local function makeCFString(v) return loggc(C.CFStringCreateWithCString(nil,v,kCFStringEncodingUTF8)) end
bridges['CFStringRef']={
  get=getCFString,
  --  get_retained=function(cf)
  --    if cf==NULL then return nil end
  --    C.CFStringGetCString(cf,string_out,STRBUFFER_LEN,kCFStringEncodingUTF8)
  --    logCFRelease(cf)
  --    return ctostring(string_out)
  --  end,
  make=makeCFString,
}
bridges['@"NSString"']={
  get=objc.methodcallerraw(objc.NSString,'UTF8String'),
  make=objc.classmethodcaller(objc.NSString,'stringWithUTF8String')
}
tollfree_bridge('CFStringRef','NSString')


-- CFArray ----------------
objc.cdef'CFArrayGetCount'
objc.cdef'CFArrayGetValueAtIndex'
bridges['CFArrayRef']={
  get=function(cf)
    local r,l={},tonumber(C.CFArrayGetCount(cf))
    for i=0,tonumber(l)-1 do r[#r+1]=C.CFArrayGetValueAtIndex(cf,i) end
    return r
  end,
  make=function(v)
  end,
}
bridges.struct1['CFArrayRef']={
  get=function(cf,sub)
    local r,l={},tonumber(C.CFArrayGetCount(cf))
    for i=0,tonumber(l)-1 do r[#r+1]=sub(C.CFArrayGetValueAtIndex(cf,i)) end
    return r
  end,
  make=function(v,sub)
  end,
}
objc.cdef'CFDictionaryGetCount' objc.cdef'CFDictionaryGetKeysAndValues' objc.cdef'CFDictionaryGetValue'
local DICTIONARY_MAXLEN=8192
--local keys_out=ffi.new('id[?]',DICTIONARY_MAXLEN)
--local values_out=ffi.new('id[?]',DICTIONARY_MAXLEN)
local keys_out=ffi.new('void*[?]',DICTIONARY_MAXLEN)
local values_out=ffi.new('void*[?]',DICTIONARY_MAXLEN)
bridges['CFDictionaryRef']={
  get=function(cf)
    local r,l={},tonumber(C.CFDictionaryGetCount(cf))
    assert(l<DICTIONARY_MAXLEN)
    C.CFDictionaryGetKeysAndValues(cf,keys_out,values_out)
    for i=0,l-1 do r[keys_out[i]]=values_out[i] end
    return r
  end
}

bridges.struct1['CFDictionaryRef']={
  get=function(cf,subk)
    local r,l={},tonumber(C.CFDictionaryGetCount(cf))
    assert(l<DICTIONARY_MAXLEN)
    C.CFDictionaryGetKeysAndValues(cf,keys_out,values_out)
    for i=0,l-1 do r[subk(keys_out[i])]=values_out[i] end
    return r
  end
}
bridges.struct2['CFDictionaryRef']={
  get=function(cf,subk,fieldTypes)
    local r,l={},tonumber(C.CFDictionaryGetCount(cf))
    assert(l<DICTIONARY_MAXLEN)
    C.CFDictionaryGetKeysAndValues(cf,keys_out,values_out)
    for i=0,l-1 do
      local k=subk(keys_out[i])
      r[k]=fieldTypes[k](values_out[i])
    end
    return r
  end
}
bridges.struct2['CFDictionaryRef:lazytable']={
  get=function(cf,subk,fieldTypes)
    return setmetatable({},{__index=function(t,k)
      --      print(C.CFDictionaryGetValue(cf,cast('void*',subk(k))))
      --FIXME the s1 argument needs to be 'IN' so subk==make; issues with expected void*
      return fieldTypes[k](C.CFDictionaryGetValue(cf,subk(k)))
    end})
  end
}

-- CFURL ------------------
objc.cdef'CFURLGetString'
bridges['CFURLRef']={
  get=function(cf) return getCFString(C.CFURLGetString(cf)) end,
  make=function(v) end, --TODO
}
objc.cdef'CFURLGetFileSystemRepresentation' objc.cdef'CFURLCreateWithFileSystemPath'
bridges['CFURLRef:path']={
  get=function(cf)
    C.CFURLGetFileSystemRepresentation(cf,true,string_out,STRING_MAXLEN)
    return ctostring(string_out)
  end,
  make=function(v)
    return loggc(C.CFURLCreateWithFileSystemPath(nil,makeCFString(v),0,false))
  end,
}
tollfree_bridge('CFURLRef','NSURL')

-- CFError ----------------
objc.cdef'CFErrorGetCode' objc.cdef'CFErrorGetDomain' objc.cdef'CFErrorCopyDescription'
--force const cfstring for domain
objc.addfunction('CFErrorCreate',{retval='^{__CFError=}','^{__CFAllocator=}','r^{__CFString=}','l','^{__CFDictionary='},false)

local function getCFErrorDescription(cf) return getCFString(C.CFErrorCopyDescription(cf)) end
bridges['CFErrorRef']={
  get=getCFErrorDescription,
}
local function makeCFError(domain,code) return loggc(C.CFErrorCreate(nil,domain,code,nil)) end
--bridges['i:OSStatus']={
--  get=function(i) if i==0 then return nil else return getCFErrorDescription(makeCFError(objc.kCFErrorDomainOSStatus,i)) end end,
--  make=function(v) return makeCFError(objc.kCFErrorDomainOSStatus,v) end,
--}
bridges['i:OSStatus']={
  get=function(i)
    if i==0 then return nil else
      objc.load'CoreServices.CarbonCore'
      ffi.cdef[[const char * GetMacOSStatusCommentString(int32_t err);]]
      return ctostring(C.GetMacOSStatusCommentString(i))
    end
  end,
--  make=function(v) return makeCFError(objc.kCFErrorDomainOSStatus,v) end,
}
bridges['CFErrorRef:table']={
  get=function(cf)
    local r={} --TODO infodict
    r.code=tonumber(C.CFErrorGetCode(cf))
    r.domain=getCFString(C.CFErrorGetDomain(cf))
    return r
  end,
  make=function(v) return makeCFError(v.domain,v.code) end,
}
tollfree_bridge('CFErrorRef','NSError')
return bridges
