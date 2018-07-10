--[[
-- TODO:
> decomposition
> SAT poly
> addition
> subtraction
> Minkowski math
> line intersection
> cutting/scissors
> expulsion
> scaling
]]--

-- ==========================================
local lib={name="Poly"}
local reqLocations = {"","lib/","libs/","Lib/","Libs/","Base-Libs/","BLibs/","BaseLibs/","base-libs/","blibs/","baselibs/"}
for i = 6,#reqLocations do
	for j=2,6 do
		table.insert(reqLocations,reqLocations[j].."/"..reqLocations[i])
	end
end
local function safeRequire(...)
	local v,success,val
	for i=1,select('#',...) do
		v = (select(i,...))
		for ii,iv in ipairs(reqLocations) do
			success,val = pcall(function () return require(iv..v) end)
			if success then return val end
		end
	end
end

local Vec=assert(_VECTOR or safeRequire("Vec"), "Cannot find/use 'Vec.lua', this is a requirement for "..lib.name.." to function!")
if type(Vec)=="function" then Vec = Vec() end
local Line=assert(_VECTOR or safeRequire("Line"), "Cannot find/use 'Line.lua', this is a requirement for "..lib.name.." to function!")
if type(Line)=="function" then Line = Line() end

local _POLY = {c=0,_CACHE={C=0},type="polygon"}
local _CACHE = _POLY._CACHE
_POLY.aliases = {}
_POLY.meta = {}

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

-- ========================================== Aliases

function _POLY.aliases.x(t,v)
	local i,x = 1,t[1].x
	for ii,iv in ipairs(t) do
		if iv.x <= x then
			i = ii
			x = iv.x
		end
	end
	if v then
		for ii,iv in ipairs(t) do
			iv.x = iv.x - x + v
		end
	else
		return x
	end
end
_POLY.aliases.x1 = _POLY.aliases.x
function _POLY.aliases.y(t,v)
	local i,y = 1,t[1].y
	for ii,iv in ipairs(t) do
		if iv.y <= y then
			i = ii
			y = iv.y
		end
	end
	if v then
		for ii,iv in ipairs(t) do
			iv.y = iv.y - y + v
		end
	else
		return y
	end
end
_POLY.aliases.y1 = _POLY.aliases.y
function _POLY.aliases.x2(t,v)
	local i,x = 1,t[1].x
	for ii,iv in ipairs(t) do
		if iv.x >= x then
			i = ii
			x = iv.x
		end
	end
	if v then
		for ii,iv in ipairs(t) do
			iv.x = iv.x - x + v
		end
	else
		return x
	end
end
function _POLY.aliases.y2(t,v)
	local i,y = 1,t[1].y
	for ii,iv in ipairs(t) do
		if iv.y >= y then
			i = ii
			y = iv.y
		end
	end
	if v then
		for ii,iv in ipairs(t) do
			iv.y = iv.y - y + v
		end
	else
		return y
	end
end

function _POLY.aliases.mx(t,v)
	if v then
		local mx = 0
		for i,iv in ipairs(t) do
			mx = mx + iv.x
		end
		mx = mx / t.c
		local dx = v - mx
		for i,iv in ipairs(t) do
			iv.x = iv.x + dx
		end
	else
		local r = 0
		for i,v in ipairs(t) do
			r = r + v.x
		end
		return r/t.c
	end
end
function _POLY.aliases.my(t,v)
	if v then
		local my = 0
		for i,iv in ipairs(t) do
			my = my + iv.y
		end
		my = my / t.c
		local dy = v - my
		for i,iv in ipairs(t) do
			iv.y = iv.y + dy
		end
	else
		local r = 0
		for i,v in ipairs(t) do
			r = r + v.y
		end
		return r/t.c
	end
end
function _POLY.aliases.mid(t,v)
	if v then
		local dx, dy = v.x - m.x, v.y - m.y
		for i,iv in ipairs(t) do
			iv.x, iv.y = iv.x + dx, iv.y + dy
		end
	else
		local r = Vec(0,0)
		for i,v in ipairs(t) do
			r:add(v)
		end
		return r/t.c
	end
end

-- ========================================== Methods

--[[function _POLY.order(self)
	local unsorted = true
	local v
	local tau = 2*math.pi
	while unsorted do
		unsorted = false
		for i=2,self.c,1 do
			mv = self[i-1]
			v = self[i]
			iv = self[i+1]
			-- if next segment's angle is NOT greater than previous...
			if atan2(iv.y-v.y,iv.x-v.x)%tau < atan2(v.y-mv.y,v.x-mv.x)%tau then
				self[i],self[i+1] = self[i+1],self[i]
				unsorted = true
			end
		end
	end
	return self
end
]]--

function _POLY.SATPoint(self,a)
	local v1,px,py,l,dp
	local minI,minDist = 1, math.huge
	for i,v in ipairs(self) do
		v1 = self[i+1]
		px,py = v1.y-v.y, -v1.x+v.x -- left normal
		l = sqrt( px * px + py * py )
		dp = ( a.x * px / l + a.y * py / l )
		if dp < minDist then
			minI = i
			minDist = dp
		end
	end
	return minDist <= 0, minI, minDist
end

local function deltaDP(a,b,v)
	local vx,vy,dx,dy = v.x-a.x, v.y-a.y, b.x-a.x, b.y-a.y
	local l = sqrt(dx*dx+dy*dy)
	return (vx*dx/l+vy*dy/l)
end

local function project(a,b,v)
	local vx,vy, dx,dy = v.x-a.x,v.y-a.y, b.x-a.x,b.y-a.y
	local l = sqrt(dx*dx+dy*dy)
	local dp = (vx*dx/l+vy*dy/l)
	return dp*dx/l,dp*dy/l
end

local function debugLine(v1,v2,x2,y2)
	local r,g,b,a = love.graphics.getColor()
	love.graphics.setColor(1,0,0,1)
	if type(v1)=="table" then
		love.graphics.line(v1.x,v1.y,v2.x,v2.y)
	else
		love.graphics.line(v1,v2,x2,y2)
	end
	love.graphics.setColor(r,g,b,a)
end
local function debugPoint(x,y)
	local r,g,b,a = love.graphics.getColor()
	love.graphics.setColor(1,0,0,1)
	if type(x)=="table" then
		love.graphics.circle("fill",x.x,x.y,3)
	else
		love.graphics.circle("fill",x,y,3)
	end
	love.graphics.setColor(r,g,b,a)
end
function _POLY.SATNearest(self,other,getDelta,getImpact)
	if self.c == 0 then
		return false
	end
	if other.c == 0 then
		return false
	end
	if self.c == 1 then
		return other:SATPoint(self[1])
	end
	if other.c == 1 then
		return self:SATPoint(other[1])
	end
	local v1,px,py,l,dp
	local minSide, minPoint, minDist = 1, 1, -math.huge
	local typeA = false
	local within = true
	local within1, delta, impact
	-- type A
	for i,v in ipairs(other) do
		v1 = other[i+1]
		within1 = false
		px,py = v1.y-v.y, -v1.x+v.x -- left normal
		l = sqrt( px * px + py * py )
		for ii,iv in ipairs(self) do
			dp = ( (iv.x - v.x) * px / l + (iv.y - v.y) * py / l )
			if dp <= 0 then
				if dp > minDist then
					minSide = i
					minPoint = ii
					minDist = dp
					typeA = true
				end
				within1 = true
			end
		end
		within = within and within1
	end
	--[[for i,v in ipairs(self) do
		for ii,iv in ipairs(other) do
			v1 = other[ii+1]
			px = v1.y - iv.y
			py = iv.x - v1.x
			dp = ( () )
		end
	end]]--
	-- type B
	for i,v in ipairs(self) do
		v1 = self[i+1]
		within1 = false
		px,py = v1.y-v.y, -v1.x+v.x -- left normal
		l = sqrt( px * px + py * py )
		for ii,iv in ipairs(other) do
			dp = ( (iv.x - v.x) * px / l + (iv.y - v.y) * py / l )
			if dp <= 0 then
				if dp > minDist then
					minSide = i
					minPoint = ii
					minDist = dp
					typeA = false
				end
				within1 = true
			end
		end
		within = within and within1
	end
	if within and typeA then
		if getDelta then
			debugLine(other[minSide],other[minSide+1])
			debugPoint(self[minPoint])
			local point = Vec(project(other[minSide],other[minSide+1],self[minPoint])):add(other[minSide])
			debugPoint(point)
			delta = point:del() - self[minPoint]
			debugLine(self[minPoint],self[minPoint]+delta)
			if getImpact then
				impact = point
			else
				--point:del()
			end
		end
		if getImpact then
			impact = self[nearestPoint]
		end
	elseif within then
		if getDelta then
			debugLine(self[minSide],self[minSide+1])
			debugPoint(other[minPoint])
			local point = Vec(project(self[minSide],self[minSide+1],other[minPoint])):add(self[minSide])
			debugPoint(point)
			delta = other[minPoint] - point:del()
			debugLine(other[minPoint],other[minPoint]+delta)
			if getImpact then
				impact = point
			else
				--point:del()
			end
		end
		if getImpact then
			impact = other[nearestPoint]
		end
	end
	return within,
		typeA,
		minSide,
		minPoint,
		minDist,
		(getDelta and delta) or (getImpact and impact),
		(getImpact and getDelta and impact)
end

function _POLY.SATPoly(self,other)

end

function _POLY.rot(self,a) -- oki
	local pivot = self.mid
	local dx,dy
	local sinA,cosA = sin(a),cos(a)
	for i,v in ipairs(self) do
		dx,dy = v.x - pivot.x, v.y - pivot.y
		v.x = pivot.x + ( dx * cosA - dy * sinA )
		v.y = pivot.y + ( dx * sinA + dy * cosA )
	end
	pivot:del()
end

function _POLY.add(self,...)
	local iv,iv1
	local i = 0
	while i < select('#',...) do
		i = i + 1
		iv = (select(i,...))
		if type(iv)=="table" and iv.type=="vector" then
			self.c = self.c + 1
			self[self.c] = iv
		elseif type(iv)=="table" and iv.type=="line" then
			if iv.a == self[self.c] then
				self.c = self.c + 1
				self[self.c] = iv.b
			else
				self.c = self.c + 2
				self[self.c-1] = iv.a
				self[self.c] = iv.b
			end
		else
			iv1 = (select(i+1,...))
			if type(iv)=="number" and type(iv1)=="number" then
				self.c = self.c+1
				self[self.c] = Vec(iv,iv1)
				i = i + 1
			end
		end
	end
end

function _POLY.rem(self,i)
	self.c = self.c - 1
    return table.remove(self, i)
end

function _POLY.fromRec(rec)
  local l,r,t,b = rec[1],rec[1]+rec[3],rec[2],rec[2]+rec[4]
  if rec.dir == "tl" then
    return _POLY(l,b,r,t,r,b)
  elseif rec.dir == "tr" then
    return _POLY(l,t,r,b,l,b)
  elseif rec.dir == "br" then
    return _POLY(l,t,r,t,l,b)
  elseif rec.dir == "bl" then
    return _POLY(l,t,r,t,r,b)
  else
    return _POLY(l,t,r,t,r,b,r,b)
  end
end

function _POLY.del(self)
	table.insert(_CACHE,self)
	_CACHE.C = _CACHE.C + 1
	return self
end

-- ========================================== Mechanics

function _POLY.__index(t,k)
	if type(k)=="number" then
		return rawget(t,(k-1)%t.c+1)
	elseif _POLY.aliases[k] then
		if type(_POLY.aliases[k])~="function" then
			return t[_POLY.aliases[k]]
		else
			return _POLY.aliases[k](t)
		end
	else
		return _POLY[k]
	end
end
function _POLY.__newindex(t,k,v)
	if type(k)=="number" then
		rawset(t,(k-1)%t.c+1,v)
	elseif _POLY.aliases[k] then
		if type(_POLY.aliases[k])~="function" then
			t[_POLY.aliases[k]] = v
		else
			_POLY.aliases[k](t,v)
		end
	else
		rawset(t,k,v)
	end
end
function _POLY.__tostring(t)
	local ret = {"["}
	for i,v in ipairs(t) do
		table.insert(ret,tostring(v))
	end
	table.insert(ret,"]")
	return table.concat(ret,',')
end

function _POLY.meta.__call(t,...)
	local v
	if _CACHE.C>0 then
		v=table.remove(_CACHE,_CACHE.C)
		_CACHE.C = _CACHE.C-1
		for i = v.c, 1, -1 do
			table.remove(v,i)
		end
	else
		v = {}
	end
	v.c = 0
	local iv,iv1
	local i = 0
	while i < select('#',...) do
		i = i + 1
		iv = (select(i,...))
		if type(iv)=="table" and iv.type=="vector" then
			v.c = v.c + 1
			v[v.c] = iv
		elseif type(iv)=="table" and iv.type=="line" then
			if iv.a == v[v.c] then
				v.c = v.c + 1
				v[v.c] = iv.b
			else
				v.c = v.c + 2
				v[v.c-1] = iv.a
				v[v.c] = iv.b
			end
		else
			iv1 = (select(i+1,...))
			if type(iv)=="number" and type(iv1)=="number" then
				v.c = v.c+1
				v[v.c] = Vec(iv,iv1)
				i = i + 1
			end
		end
	end
	return setmetatable(v,_POLY)
end

setmetatable(_POLY,_POLY.meta)

local function ret(...)
	local args={...}
  _G._POLY = _POLY
	for i,v in ipairs(args) do
		if type(v)=='string' then
			_G[v]=_POLY
		else
			v=_POLY
		end
	end
	return _POLY
end
return ret
