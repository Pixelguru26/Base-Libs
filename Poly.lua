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
			x = iv
		end
	end
	if v then
		t[i].x = v
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
			y = iv
		end
	end
	if v then
		t[i].y = v
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
			x = iv
		end
	end
	if v then
		t[i].x = v
	else
		return x
	end
end
function _POLY.aliases.y2(t,v)
	local i,y = 1,t[1].y
	for ii,iv in ipairs(t) do
		if iv.y >= y then
			i = ii
			y = iv
		end
	end
	if v then
		t[i].y = v
	else
		return y
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
end]]--

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
		return t[(k-1)%t.c+1]
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
			POLY.aliases[k](t,v)
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
