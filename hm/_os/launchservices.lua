---Launch Services interface
-- @module hm._os.launchservices
-- @static
-- @dev

local type,ipairs=type,ipairs
local sformat=string.format
--local ffi=require'ffi'
--local C=ffi.C
local c=require'objc' --lib.objc#objc
local bridge=c.bridge
local IN,OUT,OUT_R,UNUSED=bridge.IN,bridge.OUT,bridge.OUT_RETAINED,bridge.UNUSED
c.load'CoreServices.LaunchServices'


--[[
local OSStatusCodes={
  kLSAppInTrashErr              = -10660, --/* The app cannot be run when inside a Trash folder*/
  kLSExecutableIncorrectFormat  = -10661, --/* No compatible executable was found*/
  kLSAttributeNotFoundErr       = -10662, --/* An item attribute value could not be found with the specified name*/
  kLSAttributeNotSettableErr    = -10663, --/* The attribute is not settable*/
  kLSIncompatibleApplicationVersionErr = -10664, --/* The app is incompatible with the current OS*/
  kLSNoRosettaEnvironmentErr    = -10665, --/* The Rosetta environment was required not available*/
  kLSUnknownErr                 = -10810, --/* Unexpected internal error*/
  kLSNotAnApplicationErr        = -10811, --/* Item needs to be an application, but is not*/
  kLSNotInitializedErr          = -10812, --/* Not used in 10.2 and later*/
  kLSDataUnavailableErr         = -10813, --/* E.g. no kind string*/
  kLSApplicationNotFoundErr     = -10814, --/* E.g. no application claims the file*/
  kLSUnknownTypeErr             = -10815, --/* Don't know anything about the type of the item*/
  kLSDataTooOldErr              = -10816, --/* Not used in 10.3 and later*/
  kLSDataErr                    = -10817, --/* Not used in 10.4 and later*/
  kLSLaunchInProgressErr        = -10818, --/* E.g. launching an already launching application*/
  kLSNotRegisteredErr           = -10819, --/* Not used in 10.3 and later*/
  kLSAppDoesNotClaimTypeErr     = -10820, --/* One or more documents are of types (and/or one or more URLs are of schemes) not supported by the target application (sandboxed callers only)*/
  kLSAppDoesNotSupportSchemeWarning = -10821, --/* Not used in 10.2 and later*/
  kLSServerCommunicationErr     = -10822, --/* The server process (registration and recent items) is not available*/
  kLSCannotSetInfoErr           = -10823, --/* The extension visibility on this item cannot be changed*/
  kLSNoRegistrationInfoErr      = -10824, --/* The item contains no registration info*/
  kLSIncompatibleSystemVersionErr = -10825, --/* The app cannot run on the current OS version*/
  kLSNoLaunchPermissionErr      = -10826, --/* User doesn't have permission to launch the app (managed networks)*/
  kLSNoExecutableErr            = -10827, --/* The executable is missing*/
  kLSNoClassicEnvironmentErr    = -10828, --/* The Classic environment was required but is not available*/
  kLSMultipleSessionsNotSupportedErr = -10829, --/* The app cannot run simultaneously in two different sessions*/
}
--]]
local OSStatusMessages={
  [-10660] = "The app cannot be run when inside a Trash folder",
  [-10661] = "No compatible executable was found",
  [-10662] = "An item attribute value could not be found with the specified name",
  [-10663] = "The attribute is not settable",
  [-10664] = "The app is incompatible with the current OS",
  [-10665] = "The Rosetta environment was required not available",
  [-10810] = "Unexpected internal error",
  [-10811] = "Item needs to be an application, but is not",
  [-10813] = "E.g. no kind string",
  [-10814] = "E.g. no application claims the file",
  [-10815] = "Don't know anything about the type of the item",
  [-10818] = "E.g. launching an already launching application",
  [-10820] = "One or more documents are of types (and/or one or more URLs are of schemes) not supported by the target application (sandboxed callers only)",
  [-10822] = "The server process (registration and recent items) is not available",
  [-10823] = "The extension visibility on this item cannot be changed",
  [-10824] = "The item contains no registration info",
  [-10825] = "The app cannot run on the current OS version",
  [-10826] = "User doesn't have permission to launch the app (managed networks)",
  [-10827] = "The executable is missing",
  [-10828] = "The Classic environment was required but is not available",
  [-10829] = "The app cannot run simultaneously in two different sessions",
}
c.bridges['i:LSOSStatus']={get=function(code) return code~=0 and (OSStatusMessages[code] or c.bridges['i:OSStatus'].get(code)) or nil end}

local LSRolesMask={
  none                  = 0x00000001, --/* no claim is made about support for this type/scheme*/
  viewer                = 0x00000002, --/* claim to view items of this type*/
  editor                = 0x00000004, --/* claim to edit items of this type/scheme*/
  shell                 = 0x00000008, --/* claim to execute items of this type*/
  all                   = 0xFFFFFFFF --/* claim to do it all*/
}
c.bridges['I:LSRolesMask']={make=function(roles)
  if type(roles)=='string' then return LSRolesMask[roles] or LSRolesMask.none end
  local m=0 for _,role in ipairs(roles) do m=m+LSRolesMask[role] end return m==0 and LSRolesMask.none or m
end}



---@type hm._os.launchservices
-- @extends hm#module
local ls=hm._core.module'hm._os.launchservices'
local log=ls.log


local makePathSpec=bridge.struct('LSLaunchURLSpec',{appURL=IN'CFURLRef:path',launchFlags='LSLaunchFlags'})
local makeNSURLSpec=bridge.struct('LSLaunchURLSpec',{appURL=IN'CFURLRef:NSURL',launchFlags='LSLaunchFlags'})
local launchFlags=c.kLSLaunchDontSwitch+c.kLSLaunchNoParams--+c.kLSLaunchInhibitBGOnly
local openURLFromURLSpec=bridge.fn(OUT'i:LSOSStatus','LSOpenFromURLSpec','^{LSLaunchURLSpec=}',UNUSED'^CFURLRef')
---
-- @param #string path
-- @return #boolean `true` on success
-- @return #nil,#string on error
function ls.launchPath(path)
  local urlSpec=makePathSpec{appURL=path,launchFlags=launchFlags}
  local err=openURLFromURLSpec(urlSpec,nil)
  if err then return nil,sformat('launch %s: %s',path,err) else return true end
end
---
-- @param #cdata nsurl `NSURL`
-- @return #boolean `true` on success
-- @return #nil,#string on error
function ls.launch(nsurl)
  local urlSpec=makeNSURLSpec{appURL=nsurl,launchFlags=launchFlags}
  local err=openURLFromURLSpec(urlSpec,nil)
  if err then return nil,sformat('launch %s: %s',nsurl.absoluteString,err) else return true end
end


---List of `NSURL` cdata
-- @type NSURLList
-- @list #cdata

---@type pathList
-- @list <#string>

---
-- Private API
-- @function [parent=#hm._os.launchservices] allApplicationPaths
-- @return #pathList paths of apps
ls.allApplicationPaths=bridge.fn(nil,'_LSCopyAllApplicationURLs',OUT_R('CFArrayRef',OUT'CFURLRef:path'))
---
-- Private API
-- @function [parent=#hm._os.launchservices] allApplications
-- @return #NSURLList `NSURL`s of apps
ls.allApplications=bridge.fn(nil,'_LSCopyAllApplicationURLs',OUT_R('CFArrayRef',OUT'CFURLRef:NSURL'))

---
-- @param #string bundle ID
-- @return #pathList paths of apps
-- @return #nil,#string on error
ls.applicationPathsForBundleIdentifier=bridge.fn(
  OUT_R('CFArrayRef',OUT'CFURLRef:path'),'LSCopyApplicationURLsForBundleIdentifier',IN'CFStringRef',OUT_R'CFErrorRef')
---
-- @param #string bundle ID
-- @return #NSURLList `NSURL`s of apps
-- @return #nil,#string on error
ls.applicationsForBundleIdentifier=bridge.fn(
  OUT_R('CFArrayRef',OUT'CFURLRef:NSURL'),'LSCopyApplicationURLsForBundleIdentifier',IN'CFStringRef',OUT_R'CFErrorRef')

local applicationPathsForPath=bridge.fn(OUT_R('CFArrayRef',OUT'CFURLRef:path'),'LSCopyApplicationURLsForURL',IN'CFURLRef:path',IN'I:LSRolesMask')
local applicationsForPath=bridge.fn(OUT_R('CFArrayRef',OUT'CFURLRef:NSURL'),'LSCopyApplicationURLsForURL',IN'CFURLRef:path',IN'I:LSRolesMask')
local applicationsForNSURL=bridge.fn(OUT_R('CFArrayRef',OUT'CFURLRef:NSURL'),'LSCopyApplicationURLsForURL',IN'CFURLRef:NSURL',IN'I:LSRolesMask')
---
-- @param #string path path of file
-- @param #string role
-- @return #pathList paths of apps
-- @return #nil,#string if not found
function ls.applicationPathsForPath(path,role)
  local r=applicationPathsForPath(path,role) if r then return r else return nil,'No suitable app found' end
end
---
-- @param #string path path of file
-- @param #string role
-- @return #NSURLList `NSURL`s of apps
-- @return #nil,#string if not found
function ls.applicationsForPath(path,role)
  local r=applicationsForPath(path,role) if r then return r else return nil,'No suitable app found' end
end
---
-- @param #cdata nsurl `NSURL` of file
-- @param #string role
-- @return #NSURLList `NSURL`s of apps
-- @return #nil,#string if not found
function ls.applicationsForNSURL(nsurl,role)
  local r=applicationsForNSURL(nsurl,role) if r then return r else return nil,'No suitable app found' end
end

local applicationPathsForURL=bridge.fn(OUT_R('CFArrayRef',OUT'CFURLRef:NSURL'),'LSCopyApplicationURLsForURL',IN'CFURLRef',IN'I:LSRolesMask')
local applicationsForURL=bridge.fn(OUT_R('CFArrayRef',OUT'CFURLRef:path'),'LSCopyApplicationURLsForURL',IN'CFURLRef',IN'I:LSRolesMask')
---
-- @param #string url url
-- @return #pathList paths of apps
-- @return #nil,#string if not found
function ls.applicationPathsForURL(url)
  local r=applicationPathsForURL(url,'all') if r then return r else return nil,'No suitable app found' end
end
---
-- @param #string url url
-- @return #NSURLList `NSURL`s of apps
-- @return #nil,#string if not found
function ls.applicationsForURL(url)
  local r=applicationsForURL(url,'all') if r then return r else return nil,'No suitable app found' end
end

---
-- @param #string path of file
-- @param #string role
-- @return #string path of app
-- @return #nil,#string on error
ls.defaultApplicationPathForPath=bridge.fn(OUT'CFURLRef:path','LSCopyDefaultApplicationURLForURL',IN'CFURLRef:path',IN'I:LSRolesMask',OUT_R'CFErrorRef')
---
-- @param #string path of file
-- @param #string role
-- @return #cdata `NSURL` of app
-- @return #nil,#string on error
ls.defaultApplicationForPath=bridge.fn(OUT'CFURLRef:NSURL','LSCopyDefaultApplicationURLForURL',IN'CFURLRef:path',IN'I:LSRolesMask',OUT_R'CFErrorRef')
---
-- @param #cdata nsurl `NSURL` of file
-- @param #string role
-- @return #cdata `NSURL` of app
-- @return #nil,#string on error
ls.defaultApplicationForNSURL=bridge.fn(OUT'CFURLRef:NSURL','LSCopyDefaultApplicationURLForURL',IN'CFURLRef:NSURL',IN'I:LSRolesMask',OUT_R'CFErrorRef')

local defaultApplicationPathForURL=bridge.fn(OUT'CFURLRef:path','LSCopyDefaultApplicationURLForURL',IN'CFURLRef',IN'I:LSRolesMask',OUT_R'CFErrorRef')
local defaultApplicationForURL=bridge.fn(OUT'CFURLRef:NSURL','LSCopyDefaultApplicationURLForURL',IN'CFURLRef',IN'I:LSRolesMask',OUT_R'CFErrorRef')
---
-- @param #string url
-- @return #string path of app
-- @return #nil,#string on error
function ls.defaultApplicationPathForURL(url) return defaultApplicationPathForURL(url,'all') end
---
-- @param #string url
-- @return #cdata `NSURL` of app
-- @return #nil,#string on error
function ls.defaultApplicationForURL(url) return defaultApplicationForURL(url,'all') end

return ls
