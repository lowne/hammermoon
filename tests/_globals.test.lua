--@file hm/init.lua
--@file hm/_globals.lua
--@file hm/types/coll.lua
test('should append ok to the right here') 
test(type(assertf)=='function') 
terr("assertf(false,'%s','assertf')",'assertf') 
test(type(errorf)=='function') 
terr(function()errorf('%sf','error')end,'errorf') 
test(type(checkargs)=='function') 
test(type(sanitizeargs)=='function') 

fboolean=function(a) checkargs'boolean' return true end
test(fboolean(false)) 
test(fboolean(true)) 
terr(fboolean) 

fnumbernil=function(arg) checkargs'?number' return true end
test(fnumbernil(33)) 
test(fnumbernil) 
terr(function()fnumbernil(false)end,"bad argument #1 ('arg') to 'fnumbernil' (nil or number expected, got boolean)") 

fcallable=function(a) checkargs'callable' return a() end
test(fcallable(function()return true end)) 
test(fcallable(setmetatable({},{__call=function()print'called!'return true end})))

fconvert=function(arg) sanitizeargs'string|number:string|table:string' return type(arg)=='string' end
checkers['number:string']=function(n) return type(n)=='number' and tostring(n) end
checkers['table:string']=function(t) return type(t)=='table' and table.concat(t,',') end
test(fconvert('hi')) 
test(fconvert(0)) 
test(fconvert{1,2,3}) 
terr('fconvert(true)',"bad argument #1 ('arg') to 'fconvert' (string or number or table expected, got boolean)") 

fvalue=function(a) checkargs'value(string)' return true end
test(fvalue'ha') 
terr('fvalue(15)') 

require'hm.types.coll'

flist=function(a) sanitizeargs'list(number)|value(number):list' return type(a)=='table' end
test(flist{1,2,3}) 
test(flist(-5)) 
terr'flist"hum"' 
test(flist{1,nil,'haha',3}) 
terr'flist{1,"haha",3}' 

flist2=function(a) sanitizeargs'listOrValue(number)' return type(a)=='table' end
test(flist2{1,2,3}) 
test(flist2(-5)) 
terr'flist2"hum"' 
test(flist2{1,nil,'haha',3}) 
terr'flist2{1,"haha",3}' 

print(checkers['!listOrValue(string)']())
print(checkers['!listOrValue(string)']{})

flist3=function(a) sanitizeargs'!listOrValue(string)' return type(a)=='table' end
test(flist3{'hah','hoh'}) 
test(flist3'huh') 
terr'flist3(44)' 
terr'flist3()' 
terr'flist3{}' 
terr'flist3{false}' 
terr'flist3{"true",true}' 
