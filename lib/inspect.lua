-----------------------------------------------------
-- inspect.lua
-----------------------------------------------------
local type,setmetatable,getmetatable,rawset,rawget=type,setmetatable,getmetatable,rawset,rawget
local pairs,ipairs,pcall,tostring=pairs,ipairs,pcall,tostring
local tinsert,tsort,tconcat,srep,floor,huge=table.insert,table.sort,table.concat,string.rep,math.floor,math.huge
local a={_VERSION='inspect.lua 3.0.0',_URL='http://github.com/kikito/inspect.lua',
  _DESCRIPTION='human-readable representations of tables'}
a.KEY=setmetatable({},{__tostring=function()return'inspect.KEY'end})a.METATABLE=setmetatable(
  {},{__tostring=function()return'inspect.METATABLE'end})
local function b(c)if c:match('"')and not c:match("'")then
  return"'"..c.."'"end;return'"'..c:gsub('"','\\"')..'"'end
local d={["\a"]="\\a",["\b"]="\\b",["\f"]="\\f",["\n"]="\\n",["\r"]="\\r",["\t"]="\\t",["\v"]="\\v"}
local function e(f)return d[f]end;local function g(c)local h=c:gsub("\\","\\\\"):gsub("(%c)",e)return h end
local function i(c)return type(c)=='string'and c:match("^[_%a][_%a%d]*$")end
local function j(k,l)return type(k)=='number'and 1<=k and k<=l and floor(k)==k end
local m={['number']=1,['boolean']=2,['string']=3,['table']=4,['function']=5,['userdata']=6,['thread']=7}
local function n(o,p)local q,r=type(o),type(p)if q==r and(q=='string'or q=='number')then return o<p end
  local s,t=m[q],m[r]if s and t then return m[q]<m[r]elseif s then return true elseif t then return false end;return q<r end
local function u(v)local w,l={},#v;for k,x in pairs(v)do if not j(k,l)then tinsert(w,k)end end;tsort(w,n)return w end
local function y(v,z)local A=type(z)=='table'and rawget(z,'__tostring')local c,B;if type(A)=='function'then
  B,c=pcall(A,v)c=B and c or'error: '..tostring(c)end;if type(c)=='string'and#c>0 then return c end end
local C={__index=function(self,D)rawset(self,D,0)return 0 end}
local E={__index=function(self,D)local F=setmetatable({},{__mode="kv"})rawset(self,D,F)return F end}
local function G(v,H)H=H or setmetatable({},{__mode="k"})if type(v)=='table'then if not H[v]then H[v]=1;
  for k,I in pairs(v)do G(k,H)G(I,H)end;G(getmetatable(v),H)else H[v]=H[v]+1 end end;return H end
local J=function(K)local
  L,M={},#K;for N=1,M do L[N]=K[N]end;return L,M end;local function O(P,...)local w={...}local
  Q,M=J(P)for N=1,#w do Q[M+N]=w[N]end;return Q end;local function R(S,T,P)if T==nil then return nil
    end;local U=S(T,P)if type(U)=='table'then local V={}local W;for k,I in pairs(U)do
      W=R(S,k,O(P,k,a.KEY))if W~=nil then V[W]=R(S,I,O(P,W))end end;local
      z=R(S,getmetatable(U),O(P,a.METATABLE))setmetatable(V,z)U=V end;return U end;local X={}local
    Y={__index=X}function X:puts(...)local Z={...}local _=self.buffer;local M=#_;for N=1,#Z do
        M=M+1;_[M]=tostring(Z[N])end end;function
    X:down(a0)self.level=self.level+1;a0()self.level=self.level-1 end;function
    X:tabify()self:puts(self.newline,srep(self.indent,self.level))end;function
    X:alreadyVisited(I)return self.ids[type(I)][I]~=nil end;function X:getId(I)local a1=type(I)local
      a2=self.ids[a1][I]if not a2 then a2=self.maxIds[a1]+1;self.maxIds[a1]=a2;self.ids[a1][I]=a2
    end;return a2 end;function X:putKey(k)if i(k)then return
      self:puts(k)end;self:puts("[")self:putValue(k)self:puts("]")end;function X:putTable(v)if v==a.KEY or
      v==a.METATABLE then self:puts(tostring(v))elseif self:alreadyVisited(v)then self:puts('<table ',
        self:getId(v),'>')elseif self.level>=self.depth then self:puts('{...}')else if
        self.tableAppearances[v]>1 then self:puts('<',self:getId(v),'>')end;local a3=u(v)local l=#v;local
          z=getmetatable(v)local a4=y(v,z)self:puts('{')self:down(function()if a4 then self:puts(' [[',
          g(a4),']]')if l>=1 then self:tabify()end end;local a5=0;for N=1,l do if a5>0 then
            self:puts(',')end;self:puts(' ')self:putValue(v[N])a5=a5+1 end;for x,k in ipairs(a3)do if a5>0 then
            self:puts(',')end;self:tabify()self:putKey(k)self:puts(' = ')self:putValue(v[k])a5=a5+1 end;if
              self.includeMetatables and z then if a5>0 then self:puts(',')end;self:tabify()self:puts('<metatable> = ')
              self:putValue(z)end end)if#a3>0 or self.includeMetatables and z then self:tabify()elseif l>0 then
            self:puts(' ')end;self:puts('}')end end;function X:putValue(I)local a1=type(I)if a1=='string'then
        self:puts(b(g(I)))elseif a1=='number'or a1=='boolean'or a1=='nil'then self:puts(tostring(I))elseif
              a1=='table'then self:putTable(I)else self:puts('<',a1,' ',self:getId(I),'>')local
              a4=y(I,getmetatable(I))if a4 then self:puts(' -- ',g(a4))end end end;function a.inspect(a6,a7)a7=a7
              or{}local a8=a7.depth or huge;local a9=a7.newline or'\n'local aa=a7.indent or'  'local
                S=a7.process;local ab=a7.metatables;if S then a6=R(S,a6,{})end;local
                ac=setmetatable({depth=a8,buffer={},level=0,ids=setmetatable({},E),maxIds=setmetatable({},C),newline=a9,
                  indent=aa,tableAppearances=G(a6),includeMetatables=ab},Y)ac:putValue(a6)return
                  tconcat(ac.buffer)end;setmetatable(a,{__call=function(x,...)return a.inspect(...)end})
              return a
