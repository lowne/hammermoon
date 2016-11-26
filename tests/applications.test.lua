--@file hm/applications.lua
--@file hm/_os/uielements.lua
--@file tests/applications.test.lua


sleep(0.5)
thisapp=hm.applications.activeApplication
test(thisapp.name=='luajit')  
test(thisapp.active)  
print(thisapp.ownsMenuBar)
--[[test(thisapp.ownsMenuBar==false) ]]
test(hm.applications.applicationForPID(100).name=='loginwindow')  

finderbundle=hm.applications.defaultBundleForBundleID'com.apple.finder'
test(finderbundle.folder=='/System/Library/CoreServices')  
test(finderbundle.name=='Finder.app')  
print(finderbundle._nsbundle.loaded)
test(finderbundle.application)  
test(finderbundle.application.running)  

Dash=hm.applications.runningApplications:toDictByField('name')['Dash']
test(not Dash.active)  
Dash:activate()
sleep(0.2)
test(Dash.active)  
test(hm.applications.activeApplication==Dash)  
test(Dash.ownsMenuBar)  
test(hm.applications.menuBarOwningApplication==Dash)  

notesbundle=hm.applications.findBundle'Notes.app'
test(notesbundle)  
notesapp=notesbundle:launch()
test(notesapp)  
test(notesapp.running)  
notesapp:quit()
sleep(0.5)
test(notesapp.running==false)  
