
local type,tonumber=type,tonumber
local sformat=string.format

local function fromHex(s) return tonumber('0x'..s)/256 end
local function isValue(v) return type(v)=='number' and v>=0 and v<=1 end
local function getColor(t)
  if type(t)=='string' then
    if #t==3 then
      local r,g,b=t:sub(1,1),t:sub(2,2),t:sub(3,3)
      t={fromHex(r..r),fromHex(g..g),fromHex(b..b)}
    elseif #t==6 then
      local r,g,b=t:sub(1,2),t:sub(3,4),t:sub(5,6)
      t={fromHex(r),fromHex(g),fromHex(b)}
    else return end
  end
  if type(t)~='table' then return end
  if t.red then t={t.red,t.green,t.blue} end
  return isValue(t[1]) and isValue(t[2]) and isValue(t[3])
end
checkers['color']=getColor
checkers['hm.types.color#color']=getColor

