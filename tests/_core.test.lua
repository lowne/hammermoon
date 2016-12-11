--@file hm/init.lua
test(hm._core) 
test(type(hm._core.module)=='function') 
terr"hm._core.module'nonhmmodule'" 
terr"hm._core.module('hm.wrong','hello')" 
mod=hm._core.module('hm.testmodule',{testclass={__gc=function()end,__tostring=function()return'testobject'end}},{'testsubmodules'})
test(checkers['hm#module'](mod)) 
test(hm.type(mod)=='hm#module') 
test(mod._classes and mod._classes.testclass) 
test(hm.type(mod._classes.testclass)=='hm#module.class') 
obj=mod._classes.testclass._new{field='field'}
test(obj.field=='field') 
test(tostring(obj)=='testobject') 
test(type(hm._core.property)=='function') 
test(type(mod._property)=='function') 
mod._property('testprop',function()return 'value' end)
test(mod.testprop=='value') 
terr'mod.testprop=12' 
rwpropstorage=0
hm._core.property(mod,'rwprop',function()return rwpropstorage end,function(v)rwpropstorage=v end,'number')
test(mod.rwprop==0) 
mod.rwprop=-1
test(mod.rwprop==-1) 
test(rwpropstorage==-1) 
terr"mod.rwprop='nope'" 
test(type(hm._core.deprecate)=='function') 
--TODO
test(type(hm._core.declareEvents)=='function') 
test(type(mod._declareEvents)=='function') 
test(type(mod._emit)=='function') 
test(type(mod.handler)=='function') 
modhnd=mod.handler()
test(hm.type(modhnd)=='hm#handler') 
test(modhnd.active==false) 
test(type(modhnd.events)=='table') 
test(#modhnd.events==0) 
modhnd.active=true
test(modhnd.active==false) 
terr'modhnd.events="notdeclared"' 
test(modhnd:setEvents{'any'}==modhnd) 
test(modhnd._events.any) 
test(modhnd.events[1]=='any') 
mod._declareEvents('testevent')
modhnd.active=true
test(modhnd.active==false) 
hndfn=function(event,arg1,data) storeevent=event storearg1=arg1 storedata=data end
modhnd:start(nil,hndfn,'handler')
test(modhnd.active==true) 
terr'mod:_emit"wrongevent"' 
test(modhnd:start'testevent'==modhnd) 
mod._emit('testevent','arg1')
test(storeevent=='testevent' and storearg1=='arg1' and storedata==modhnd) 
mod._declareEvents'otherevent'
mod._emit('otherevent','dontchange')
test(storeevent=='testevent' and storearg1=='arg1' and storedata==modhnd) 
modhnd.events='any'
modhnd.data='somedata'
mod._emit('otherevent','willchange')
test(storeevent=='otherevent' and storearg1=='willchange' and storedata=='somedata') 
test(modhnd:stop()==modhnd) 
mod._emit('testevent','nothandled')
test(storeevent=='otherevent' and storearg1=='willchange' and storedata=='somedata') 
mod._declareEvents('newevent')
modhnd.active=true
mod._emit('newevent','shouldhandleany')
test(storeevent=='newevent' and storearg1=='shouldhandleany' and storedata=='somedata') 
terr'function mod.onHookEvent()end' 
mod._declareEvents{'hookEvent'}
function mod.onHookEvent(arg1) storearg1=arg1 hookcalled=true end
mod._emit('hookEvent','newarg1')
test(storearg1=='newarg1' and hookcalled) 
hookcalled=nil
test(not hookcalled) 
function mod.onAny(event,arg1,arg2) storeevent=event storearg1=arg1 storearg2=arg2 end
mod._emit('hookEvent','different','catchall')
--specific hook should still be called
test(hookcalled) 
--and catchall should be called after the specific hooks
test(storearg1=='different' and storearg2=='catchall') 
