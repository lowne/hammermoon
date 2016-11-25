sleep(0.5)
thisapp=hm.applications.activeApplication
--> thisapp = application: [pid:21168] luajit-bin 
test(thisapp.name=='luajit-bin') -- ok
test(thisapp.active) -- ok
print(thisapp.ownsMenuBar)
--> true 
--[[test(thisapp.ownsMenuBar==false) ]]

test(hm.applications.applicationForPID(100).name=='loginwindow') -- ok

finderbundle=hm.applications.defaultBundleForBundleID'com.apple.finder'
--> finderbundle = app bundle: Finder.app (in /System/Library/CoreServices) 
test(finderbundle.folder=='/System/Library/CoreServices') -- ok
test(finderbundle.name=='Finder.app') -- ok
print(finderbundle._nsbundle.loaded)
--> false 
test(finderbundle.application) -- ok
test(finderbundle.application.running) -- ok

Dash=hm.applications.runningApplications:toDictByField('name')['Dash']
--> Dash = application: [pid:21173] Dash 
test(not Dash.active) -- ok
Dash:activate()
--> application: [pid:21173] Dash 
sleep(0.2)
test(Dash.active) -- ok
test(hm.applications.activeApplication==Dash) -- ok
test(Dash.ownsMenuBar) -- ok
test(hm.applications.menuBarOwningApplication==Dash) -- ok

notesbundle=hm.applications.findBundle'Notes.app'
--> notesbundle = app bundle: Notes.app (in /Applications) 
test(notesbundle) -- ok
notesapp=notesbundle:launch()
--> notesapp = application: [pid:21175] Notes 
test(notesapp) -- ok
test(notesapp.running) -- ok
notesapp:quit()
--> application: [pid:21175] Notes 
sleep(0.5)
test(notesapp.running==false) -- ok

--> 16 total tests, 16 passed, 0 failed 
