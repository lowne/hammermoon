---
-- @module hm._os.eventtap
-- @static

---@type hm._os.eventtap
-- @extends hm#module
local tap=hm._core.module('_os.eventtap',{})
local log=tap.log

---@type event
-- @extends hm#module.object
local evt,new=tap._class,tap._class._new

