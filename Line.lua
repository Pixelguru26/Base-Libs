local lib={name="Line"}
local function safeRequire(...)
  for i,v in ipairs({...}) do
    local success,val = pcall(function () return require(v) end)
    if success then return val end
  end
end

local Vec=assert(_VECTOR or safeRequire("Vec","lib/Vec","libs/Vec"), "Cannot find/use 'Vec.lua', this is a requirement for "..lib.name.." to function!")
if type(Vec)=="function" then Vec = Vec() end

local _LINE = {Vec(0,0),Vec(0,0),_CACHE={C=0}}
local _CACHE = _LINE._CACHE
_LINE.aliases = {}
_LINE.meta = {}

-- ========================================== Utils

local function min(a,b)
	return a<=b and a or b
end
local function max(a,b)
	return a>=b and a or b
end
local function lerp(v,a,b)
	return a+v*(b-a)
end

-- ========================================== v.Aliases

_LINE.aliases.a=1
_LINE.aliases.A=1
_LINE.aliases.b=2
_LINE.aliases.B=2
-- top left x
function _LINE.aliases.x(t,v)
	if v then
		if v.a.x <= v.b.x then
      t.a.x = v
    else
      t.b.x = v
    end
	else
		return min(t.a.x,t.b.x)
	end
end
_LINE.aliases.x1 = _LINE.aliases.x
-- top left y
function _LINE.aliases.y(t,v)
	if v then
		if v.a.y <= v.b.y then
      t.a.y = v
    else
      t.b.y = v
    end
	else
		return min(t.a.y,t.b.y)
	end
end
_LINE.aliases.y1 = _LINE.aliases.y

-- v.bottom right x
function _LINE.aliases.x2(t,v)
	if v then
    if v.a.x >= v.b.x then
      t.a.x = v
    else
      t.b.x = v
    end
	else
		return max(t.a.x,t.b.x)
	end
end
-- v.bottom right y
function _LINE.aliases.y2(t,v)
	if v then
    if v.a.y >= v.b.y then
      t.a.y = v
    else
      t.b.y = v
    end
	else
		return max(t.a.y,t.b.y)
	end
end

-- leftmost point
function _LINE.aliases.l(t,v)
  if v then
    if t.a.x<=t.b.x then
      t.a = v
    else
      t.b = v
    end
  else
    if t.a.x<=t.b.x then
      return t.a
    else
      return t.b
    end
  end
end
-- rightmost point
function _LINE.aliases.r(t,v)
  if v then
    if t.a.x>=t.b.x then
      t.a = v
    else
      t.b = v
    end
  else
    if t.a.x>=t.b.x then
      return t.a
    else
      return t.b
    end
  end
end

-- topmost point
function _LINE.aliases.u(t,v)
  if v then
    if v.a.y<=b.y then
      t.a = v
    else
      t.b = v
    end
  else
    if t.a.y<=t.b.y then
      return t.a
    else
      return t.b
    end
  end
end
-- bottommost point
function _LINE.aliases.d(t,v)
  if v then
    if v.a.y>=b.y then
      t.a = v
    else
      t.b = v
    end
  else
    if t.a.y>=t.b.y then
      return t.a
    else
      return t.b
    end
  end
end

-- delta x / horizontal length
function _LINE.aliases.dx(t,v)
	if v then
		t.b.x = t.a.x+v
	else
		return t.b.x-t.a.x
	end
end
_LINE.aliases.w = _LINE.aliases.dx
-- delta y / vertical length
function _LINE.aliases.dy(t,v)
	if v then
		t.b.y = t.a.y+v
	else
		return t.b.y-t.a.y
	end
end
_LINE.aliases.h = _LINE.aliases.dy
-- standard form slope
function _LINE.aliases.slope(t,v)
	return t.dy/t.dx
end
_LINE.aliases.m = _LINE.aliases.slope
-- y intercept of the line
function _LINE.aliases.yInt(t,v)
  if v then
    local dy = v-t:solveY(0)
    t.a.y = t.a.y + dy
    t.b.y = t.b.y + dy
  else
    return t:solveY(0)
  end
end
--_LINE.aliases.b = _LINE.aliases.yInt
-- middle point of line
function _LINE.aliases.mx(t,v)
  if v then
    local dx = v-(t.a.x + t.b.x)/2
    t.a.x = t.a.x + dx
    t.b.x = t.b.x + dx
  else
    return (t.a.x + t.b.x)/2
  end
end
function _LINE.aliases.my(t,v)
  if v then
    local dy = v-(t.a.y + t.b.y)/2
    t.a.y = t.a.y + dy
    t.b.y = t.b.y + dy
  else
    return (t.a.y + t.b.y)/2
  end
end
function _LINE.aliases.mid(t,v)
  if v then
    t.mx = v.x
    t.my = v.y
  else
    return Vec(t.mx,t.my)
  end
end
-- crazy shit like angles
function _LINE.aliases.angle(t,v)
  if v then
    
  else
    return math.atan2(t.dy,t.dx)
  end
end
function _LINE.aliases.length(t,v)
  if v then
    local l = math.sqrt(t.dx*t.dx+t.dy*t.dy)
    local ratio = v/l
    t.b.x = t.a.x + (t.b.x-t.a.x)*ratio
    t.b.y = t.a.y + (t.b.y-t.a.y)*ratio
  else
    return math.sqrt(t.dx*t.dx+t.dy*t.dy)
  end
end
-- ========================================== Methods

function _LINE.solveY(self,x)
	return lerp((x-self.x)/(self.dx),self.l.y,self.r.y)
end
function _LINE.solveX(self,y)
	return lerp((y-self.y)/(self.dy),self.u.x,self.d.x)
end
function _LINE.hasX(self,x)
  return x>=self.x and x<=self.x2
end
function _LINE.hasY(self,y)
  return y>=self.y and y<=self.y2
end
function _LINE.hasPoint(self,x,y)
  return self:hasX(x) and (self:solveX(x)==y or (self:isVert() and self:hasY(y)))
end
function _LINE.isVert(self)
  return self.a.x == self.b.x
end
function _LINE.parallel(self,other)
  return self.m == other.m
end
function _LINE.intersectX(self,other)
  return (other.yInt-self.yInt)/(self.m-other.m)
end
function _LINE.intersect(self,other)
  -- AABB culling
  if self.x<=other.x1 and self.x1>=other.x and self.y<=other.y1 and self.y1>=other.y then
    -- easy checking of parallel lines
    if self.m == other.m then
      if self:solveY(other.a.x)==other.a.y then
        return true
      else
        return false
      end
    end
    -- if either one is vertical, then they must be intersecting according to AABB.
    if self:isVert() then
      return true,self.a.x,other:solveY(self.a.x)
    elseif other:isVert() then
      return true,other.a.x,self:solveY(other.a.x)
    end
    -- a more precise check
    local ix = self:intersectX(other)
    --print(self:solveY(ix),other:solveY(ix))
    if self:solveY(ix)==other:solveY(ix) and self:hasX(ix) and other:hasX(ix) then
      return true,ix,self:solveY(ix)
    else
      return false
    end
  else
    return false
  end
end
function _LINE.normal(self,dir,dist)
  dir = dir or 'r'
  dist = dist or 1
  local angle = math.atan2(self.dy,self.dx)
  if dir=='l' then
    angle = angle - math.pi/2
  else
    angle = angle + math.pi/2
  end
  local ax = self.mx
  local ay = self.my
  return _LINE(ax,ay,ax+math.cos(angle)*dist,ay+math.sin(angle)*dist)
end
function _LINE.mir(self,x,y)
  if type(x)~="table" then
    local m,b = self.m,self.yInt
    local d = (x+m*(y-b))/(1+m*m)
    return 2*d-x,2*d*m-y+2*b
  else
    local x,y,m,b = v.x,v.y,self.m,self.yInt
    local d = (x+m*(y-b))/(1+m*m)
    return Vec(2*d-x,2*d*m-y+2*b)
  end
end
function _LINE.perpA(self)
  return _LINE(self.a.x,self.a.y,self.a.x+self.dy,self.a.y-self.dx)
end
function _LINE.perpB(self)
  return _LINE(self.b.x,self.b.y,self.b.x+self.dy,self.b.y-self.dx)
end
function _LINE.perpM(self)
  return _LINE(self.mx,self.my,self.mx+self.dy,self.my-self.dx)
end
function _LINE.unpack(self)
	return self.a.x,self.a.y,self.b.x,self.b.y
end

function _LINE.del(self)
	table.insert(_CACHE,self)
	_CACHE.C = _CACHE.C + 1
	return self
end

-- ========================================== Mechanics

function _LINE.__index(t,k)
	if _LINE.aliases[k] then
		if type(_LINE.aliases[k])~="function" then
			return t[_LINE.aliases[k]]
		else
			return _LINE.aliases[k](t)
		end
	else
		return _LINE[k]
	end
end
function _LINE.__newindex(t,k,v)
  if _LINE.aliases[k] then
    if type(_LINE.aliases[k])~="function" then
      t[_LINE.aliases[k]] = v
    else
      _LINE.aliases[k](t,v)
    end
  else
    rawset(t,k,v)
  end
end

function _LINE.meta.__call(t,x0,y0,x1,y1)
	local v
	if _CACHE.C>0 then
		v=table.remove(_CACHE,_CACHE.C)
		_CACHE.C = _CACHE.C-1
	else
		v = {}
	end
  if type(x0)~="table" then
    v[1] = Vec(x0,y0)
    v[2] = Vec(x1,y1)
  else
    v[1] = x0
    v[2] = y0
  end
	return setmetatable(v,_LINE)
end

setmetatable(_LINE,_LINE.meta)

local function ret(...)
	local args={...}
  _G._LINE = _LINE
	for i,v in ipairs(args) do
		if type(v)=='string' then
			_G[v]=_LINE
		else
			v=_LINE
		end
	end
	return _LINE
end
return ret