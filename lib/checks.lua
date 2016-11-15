--------------------------------------------------------------------------------
-- Copyright (c) 2006-2013 Fabien Fleutot and others.
--
-- All rights reserved.
--
-- This program and the accompanying materials are made available
-- under the terms of the Eclipse Public License v1.0 which
-- accompanies this distribution, and is available at
-- http://www.eclipse.org/legal/epl-v10.html
--
-- This program and the accompanying materials are also made available
-- under the terms of the MIT public license which accompanies this
-- distribution, and is available at http://www.lua.org/license.html
--
-- Contributors:
--     Fabien Fleutot - API and implementation
--     Mark Lowne - meaningful error message for __newindex (cannot use tail call, though)
--------------------------------------------------------------------------------

-- Alternative implementation of checks() in Lua. Slower than
-- the C counterpart, but no compilation/porting concerns.

checkers = { }
local type,getmetatable,checkers,ipairs=type,getmetatable,checkers,ipairs
local getlocal,getinfo=debug.getlocal,debug.getinfo

local function check_one(expected, val)
  if type(val)==expected then return true end
  local mt = getmetatable(val)
  if mt and mt.__type==expected then return true end
  local f = checkers[expected]
  if f and f(val) then return true end
  return false
end

local function check_many(name, expected, val)
  if expected=='?' then return true
  elseif expected=='!' then return (val~=nil)
  elseif type(expected) ~= 'string' then
    error 'strings expected by checks()'
  elseif val==nil and expected :sub(1,1) == '?' then return true end
  for one in expected :gmatch "[^|?]+" do
    if check_one(one, val) then return true end
  end
  return false
end

function checks(...)
  for i, arg in ipairs{...} do
    local name, val = getlocal(2, i)
    local success = check_many(name, arg, val)
    if not success then
      local fmt = "bad argument #%d to '%s' (%s expected, got %s)"
      local fname = getinfo(2, 'n').name
      if getinfo(3, 'n').name=='__newindex' then
        local k,v=getlocal(3,2) fname=v
        fmt = "[%d] bad value for '%s' (%s expected, got %s)"
      end
      local types={}
      if arg:sub(1,1)=='?' then types[1]='nil' end
      for type in arg:gmatch'[^|?]+' do types[#types+1]=type end
      types=table.concat(types,' or ')
      local msg = string.format(fmt, i, fname or "?", types, type(val))
      error(msg, 3)
    end
  end
end

return checks
