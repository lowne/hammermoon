---Common types
-- @module hm.types
-- @static
-- @private

---@type hm.types
-- @field hm.types.coll#hm.types.coll coll
-- @field hm.types.geometry#hm.types.geometry geometry
-- @NOfield hm.types.color#hm.types.color color

local types=hm._core.module('hm.types',nil,{'coll','geometry','color'})

--checkers['hm.types#path']=nil
return types
