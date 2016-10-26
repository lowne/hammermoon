return setmetatable({_hmdestroy=function()end},{__index=function(t,k)local v=require('bridge.'..k) rawset(t,k,v) return v end})
