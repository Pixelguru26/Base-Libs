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

-- localization optimization
local sqrt = math.sqrt
local atan2 = math.atan2
local cos = math.cos
local sin = math.sin

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
    local l = t.length
    t.b.x = cos(v)*l
    t.b.y = sin(v)*l
  else
    return atan2(t.dy,t.dx)
  end
end
function _LINE.aliases.length(t,v)
  if v then
    local l = sqrt(t.dx*t.dx+t.dy*t.dy)
    local ratio = v/l
    t.b.x = t.a.x + (t.b.x-t.a.x)*ratio
    t.b.y = t.a.y + (t.b.y-t.a.y)*ratio
  else
    return sqrt(t.dx*t.dx+t.dy*t.dy)
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
function _LINE.isHoriz(self)
  return self.a.y == self.b.y
end
function _LINE.parallel(self,other)
  return self.m == other.m
end
function _LINE.intersectX(self,other)
  return (other.yInt-self.yInt)/(self.m-other.m)
end
function _LINE.intersect(self,other)
  -- AABB culling
  if self.x1<=other.x2 and self.x2>=other.x1 and self.y1<=other.y2 and self.y2>=other.y1 then
    -- easy checking of parallel lines
    if self.m == other.m then
      if self:solveY(other.a.x)==other.a.y then
        return true,"parallel"
      else
        return false,"parallel"
      end
    end
    -- A simplification with verticals
    if self:isVert() then
      local y = other:solveY(self.a.x)
      if y>=self.y1 and y<=self.y2 then
        return true,self.a.x,y,"self vertical, in range"
      else
        return false,"self vertical, out of range"
      end
    elseif other:isVert() then
      local y = self:solveY(other.a.x)
      if y>=other.y1 and y<=other.y2 then
        return true,other.a.x,y,"other vertical, in range"
      else
        return false,"other vertical, out of range"
      end
    end
    -- A simplification with horizontals
    if self:isHoriz() then
      local x = other:solveX(self.a.y)
      if x>=self.x1 and x<=self.x2 then
        return true,x,self.a.y,"self horizontal, in range"
      else
        return false,"self horizontal, out of range"
      end
    elseif other:isHoriz() then
      local x = self:solveX(other.a.y)
      if x>=other.x1 and x<=other.x2 then
        return true,x,other.a.y,"other horizontal, in range"
      else
        return false,"other horizontal, out of range"
      end
    end
    -- a more precise check
    local ix = self:intersectX(other)
    --print(self:solveY(ix),other:solveY(ix))
    if self:solveY(ix)==other:solveY(ix) and self:hasX(ix) and other:hasX(ix) then
      return true,ix,self:solveY(ix),"solved"
    else
      return false,"unsolved"
    end
  else
    return false,"AABB excluded"
  end
end
function _LINE.normal(self,dir,dist)
  dir = dir or 'r'
  dist = dist or 1
  local angle = atan2(self.dy,self.dx)
  if dir=='l' then
    angle = angle - math.pi/2
  else
    angle = angle + math.pi/2
  end
  local ax = self.mx
  local ay = self.my
  return _LINE(ax,ay,ax+cos(angle)*dist,ay+sin(angle)*dist)
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
  return _LINE(self.a.x,self.a.y,self.a.x-self.dy,self.a.y+self.dx)
end
function _LINE.perpB(self)
  return _LINE(self.b.x,self.b.y,self.b.x-self.dy,self.b.y+self.dx)
end
function _LINE.perpM(self)
  return _LINE(self.mx,self.my,self.mx-self.dy,self.my+self.dx)
end
function _LINE.unpack(self)
	return self.a.x,self.a.y,self.b.x,self.b.y
end

function _LINE.projVec(self,v,getVec)
  local temp = v - self.a
  local delta = Vec(self.dx,self.dy)
  local dist = temp..delta
  temp:del()
  local n = getVec and delta.n:del()
  delta:del()
  return dist,getVec and Vec(dist*n.x+self.a.x,dist*n.y+self.a.y)
end
function _LINE.projNormA(self,v,getVec,left)
  local temp = v - self.a
  local delta = left and Vec(self.dy,-self.dx) or Vec(-self.dy,self.dx)
  local dist = temp..delta
  temp:del()
  local n = getVec and delta.n:del()
  delta:del()
  return dist,getVec and Vec(dist*n.x+self.a.x,dist*n.y+self.a.y)
end
function _LINE.projNormB(self,v,getVec,left)
  local temp = v - self.b
  local delta = left and Vec(self.dy,-self.dx) or Vec(-self.dy,self.dx)
  local dist = temp..delta
  temp:del()
  local n = getVec and delta.n:del()
  delta:del()
  return dist,getVec and Vec(dist*n.x+self.b.x,dist*n.y+self.b.y)
end
function _LINE.projNormM(self,v,getVec,left)
  local temp = v - self.mid:del()
  local delta = left and Vec(self.dy,-self.dx) or Vec(-self.dy,self.dx)
  local dist = temp..delta
  temp:del()
  local n = getVec and delta.n:del()
  delta:del()
  return dist,getVec and Vec(dist*n.x+self.mx,dist*n.y+self.my)
end

function _LINE.solveDist(self,v)
  local length = self.length
  return Vec(v*self.dx/length+self.a.x,v*self.dy/length+self.a.y)
end
function _LINE.solveNormADist(self,v,left)
  local length = self.length
  return left and Vec(v*self.dy/length+self.a.x,v*(-self.dx/length)+self.a.y) or Vec(v*(-self.dy/length)+self.a.x,v*self.dx/length+self.a.y)
end
function _LINE.solveNormBDist(self,v,left)
  local length = self.length
  return left and Vec(v*self.dy/length+self.b.x,v*(-self.dx/length)+self.b.y) or Vec(v*(-self.dy/length)+self.b.x,v*self.dx/length+self.b.y)
end
function _LINE.solveNormMDist(self,v,left)
  local length = self.length
  return left and Vec(v*self.dy/length+self.mx,v*(-self.dx/length)+self.my) or Vec(v*(-self.dy/length)+self.mx,v*self.dx/length+self.my)
end

function _LINE.SATPoint(self,point,left)
  local dist = self:projNormA(v,false,left)
  return dist<=0, dist
end
function _LINE.SATPoints(self,points,left)
  local minimum = self:projNormA(points[1],false,left)
  local minI = 1
  for i = 2,#points do
    local v = points[i]
    local dist = self:projNormA(v,false,left)
    if dist < minimum then
      minimum = dist
      minI = i
    end
  end
  return minimum<=0, minI, minimum
end

function _LINE.fromRec(rec)
  local l,r,t,b = rec[1],rec[1]+rec[3],rec[2],rec[2]+rec[4]
  if rec.dir == "tl" then
    return _LINE(l,b,r,t),
      _LINE(r,t,r,b),
      _LINE(r,b,l,b)
  elseif rec.dir == "tr" then
    return _LINE(l,t,r,b),
      _LINE(r,b,l,b),
      _LINE(l,b,l,t)
  elseif rec.dir == "br" then
    return _LINE(l,t,r,t),
      _LINE(r,t,l,b),
      _LINE(l,b,l,t)
  elseif rec.dir == "bl" then
    return _LINE(l,t,r,t),
      _LINE(r,t,r,b),
      _LINE(r,b,l,t)
  else
    return _LINE(l,t,r,t), -- top
      _LINE(r,t,r,b), -- right
      _LINE(l,b,r,b), -- bottom
      _LINE(l,t,l,b) -- left
  end
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
function _LINE.__tostring(t)
  return '<'..t.a.x..','..t.a.y..'>,<'..t.b.x..','..t.b.y..'>'
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