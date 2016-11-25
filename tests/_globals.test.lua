test('should append ok to the right here') -- ok
-- ok
test(type(assertf)=='function') -- ok
terr("assertf(false,'%s','assertf')",'assertf') -- ok
test(type(errorf)=='function') -- ok
terr(function()errorf('%sf','error')end,'errorf') -- ok
test(type(checkargs)=='function') -- ok

fboolean=function(a) checkargs'boolean' return true end
--> fboolean = function: 0x02412470 
test(fboolean(false)) -- ok
test(fboolean(true)) -- ok
terr(fboolean) -- ok

fnumbernil=function(arg) checkargs'?number' return true end
--> fnumbernil = function: 0x02414310 
test(fnumbernil(33)) -- ok
test(fnumbernil) -- ok
terr(function()fnumbernil(false)end,"bad argument #1 ('arg') to 'fnumbernil' (nil or number expected, got boolean)") -- ok

fcallable=function(a) checkargs'callable' return a() end
--> fcallable = function: 0x024168e0 
test(fcallable(function()return true end)) -- ok
test(fcallable(setmetatable({},{__call=function()print'called!'return true end})))
--> called!  -- ok
-- ok
fconvert=function(arg) sanitizeargs'string|number:string|table:string' return type(arg)=='string' end
--> fconvert = function: 0x02418e60 
checkers['number:string']=function(n) return type(n)=='number' and tostring(n) end
checkers['table:string']=function(t) return type(t)=='table' and table.concat(t,',') end

test(fconvert('hi')) -- ok
test(fconvert(0)) -- ok
test(fconvert{1,2,3}) -- ok
terr('fconvert(true)',"bad argument #1 ('arg') to 'fconvert' (string or number or table expected, got boolean)") -- ok

fvalue=function(a) checkargs'value(string)' return true end
--> fvalue = function: 0x024175c0 
test(fvalue'ha') -- ok
terr('fvalue(15)') -- ok

require'hm.types.coll'
--> table: 0x0271b500 

flist=function(a) sanitizeargs'list(number)|value(number):list' return type(a)=='table' end
--> flist = function: 0x09f95e20 

test(flist{1,2,3}) -- ok
test(flist(-5)) -- ok
terr'flist"hum"' -- ok
test(flist{1,nil,'haha',3}) -- ok
terr'flist{1,"haha",3}' -- ok

flist2=function(a) sanitizeargs'listOrValue(number)' return type(a)=='table' end
--> flist2 = function: 0x09f9a068 

test(flist2{1,2,3}) -- ok
test(flist2(-5)) -- ok
terr'flist2"hum"' -- ok
test(flist2{1,nil,'haha',3}) -- ok
terr'flist2{1,"haha",3}' -- ok

--> 30 total tests, 30 passed, 0 failed 
