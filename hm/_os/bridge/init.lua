return setmetatable({},{__index=function(t,k)local v=require('hm._os.bridge.'..k) rawset(t,k,v) return v end})
