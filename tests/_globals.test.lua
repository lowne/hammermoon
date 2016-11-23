test('should append ok to the right here') -- ok
-- ok
test(type(assertf)=='function') -- ok
terr("assertf(false,'%s','assertf')",'assertf') -- ok
test(type(errorf)=='function') -- ok
terr(function()errorf('%sf','error')end,'errorf') -- ok
test(type(checkargs)=='function') -- ok

fboolean=function(a) checkargs'boolean' return true end
--> fboolean = <function 1> 
test(fboolean(false)) -- ok
test(fboolean(true)) -- ok
terr(fboolean) -- ok

fnumbernil=function(a) checkargs'?number' return true end
--> fnumbernil = <function 1> 
test(fnumbernil(33)) -- ok
test(fnumbernil) -- ok
terr(function()fnumbernil(false)end,"bad argument #1 to 'fnumbernil' (nil or number expected, got boolean)") -- ok

fcallable=function(a) checkargs'callable' return a() end
--> fcallable = <function 1> 
test(fcallable(function()return true end)) -- ok
test(fcallable(setmetatable({},{__call=function()print'called!'return true end})))
--> called!  -- ok
-- ok
fconvert=function(a) sanitizeargs'string|number:string|table:string' return type(a)=='string' end
--> fconvert = <function 1> 
checkers['number:string']=function(n) return type(n)=='number' and tostring(n) end
checkers['table:string']=function(t) return type(t)=='table' and table.concat(t,',') end

test(fconvert('hi')) -- ok
test(fconvert(0)) -- ok
test(fconvert{1,2,3}) -- ok
terr('fconvert(true)',"bad argument #1 to 'fconvert' (string or number or table expected, got boolean)") -- ok

fvalue=function(a) checkargs'value(string)' return true end
--> fvalue = <function 1> 
test(fvalue'ha') -- ok
terr('fvalue(15)') -- ok

require'hm.types.coll'
--> { append = <function 1>, byKeys = <function 2>, byValues = <function 3>, compact = <function 4>, concat = <function 5>, contains = <function 6>, copy = <function 7>, cycle = <function 8>, dedupe = <function 9>, dict = <function 10>, every = <function 11>, everyk = <function 12>, everykv = <function 13>, filter = <function 14>, filterk = <function 15>, filterkv = <function 16>, find = <function 17>, findk = <function 18>, foreach = <function 19>, foreachk = <function 20>, foreachkv = <function 21>, icopy = <function 22>, icycle = <function 23>, ievery = <function 24>, ifilter = <function 25>, ifilterByField = <function 26>, ifind = <function 27>, ifindLast = <function 28>, iforeach = <function 29>, imap = <function 30>, imapcat = <function 31>, index = <function 32>, insert = <function 33>, ipairs = <function 34>, ireduce = <function 35>, iremove = <function 36>, key = <function 37>, keys = <function 38>, keysByValues = <function 39>, lastIndex = <function 40>, list = <function 41>, listKeys = <function 42>, listValues = <function 43>, map = <function 44>, mapk = <function 45>, mapkv = <function 46>, mapmerge = <function 47>, mapmergekv = <function 48>, merge = <function 49>, pairs = <function 38>, reduce = <function 50>, remove = <function 51>, replace = <function 52>, set = <function 53>, sort = <function 54>, sortByField = <function 55>, toIndex = <function 56>, toList = <function 42>, toSet = <function 57>, tostring = <function 58>, unpack = <function 59>, values = <function 60>, valuesByKeys = <function 61> } 

flist=function(a) sanitizeargs'list(number)|value(number):list' return type(a)=='table' end
--> flist = <function 1> 

test(flist{1,2,3}) -- ok
test(flist(-5)) -- ok
terr'flist"hum"' -- ok
test(flist{1,nil,'haha',3}) -- ok
terr'flist{1,"haha",3}' -- ok

--> 25 total tests, 25 passed, 0 failed 
