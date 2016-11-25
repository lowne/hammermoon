local c=require'objc'
c.load'Foundation'
local toobj=c.toobj
local ffi=require'ffi'

local NSURL=c.NSURL

local nsurl=hm._core.module('hm._os.nsurl')

function nsurl.fromPath(path) checkargs'string'
  return NSURL:fileUrlWithPath(toobj(path.stringByExpandingTildeInPath)).URLbyStandardizingPath
end
checkers['path:NSURL']=nsurl.fromPath
local error_out=ffi.new'int[1]'
checkers['existingPath:NSURL']=function(s)
  local url=nsurl.fromPath(s)
  if url:checkResourceIsReachableAndReturnError(error_out) then return url end
end

function nsurl.fromURL(url) checkargs'string' return NSURL:URLWithString(url) end

checkers['url:NSURL']=nsurl.fromURL
return nsurl
