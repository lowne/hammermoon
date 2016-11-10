return setmetatable({},{__index=function(t,k)local v=require('bridge.'..k) rawset(t,k,v) return v end})
