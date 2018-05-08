local lib={name="Rec"}

local function safeRequire(...)
	for i,v in ipairs({...}) do
		local success,val = pcall(function () return require(v) end)
		if success then return val end
	end
end

local Vec=assert(_VECTOR or safeRequire("Vec","lib/Vec","libs/Vec"), "Cannot find/use 'Vec.lua', this is a requirement for "..lib.name.." to function!")
if type(Vec)=="function" then Vec = Vec() end
local Line = _LINE or safeRequire("Line","lib/Line","libs/Line")

local _RECTANGLE={0,0,0,0,type="rectangle",_CACHE={C=0}}
local _CACHE = _RECTANGLE._CACHE

_RECTANGLE.x=1
_RECTANGLE.X=1
_RECTANGLE.left=1
_RECTANGLE.Left=1
_RECTANGLE.LEFT=1
_RECTANGLE.y=2
_RECTANGLE.Y=2
_RECTANGLE.top=2
_RECTANGLE.Top=2
_RECTANGLE.TOP=2
_RECTANGLE.w=3
_RECTANGLE.W=3
_RECTANGLE.width=3
_RECTANGLE.Width=3
_RECTANGLE.WIDTH=3
_RECTANGLE.h=4
_RECTANGLE.H=4
_RECTANGLE.height=4
_RECTANGLE.Height=4
_RECTANGLE.HEIGHT=4

_RECTANGLE.meta={}
_RECTANGLE.data={}

-- util
	local function min(a,b)
		return a<b and a or b
	end
	local function max(a,b)
		return a>b and a or b
	end
-- horiz
	function _RECTANGLE.l(v,iv)
		if iv then
			v.x=iv
		end
		return v.x
	end
	_RECTANGLE.L=_RECTANGLE.l
	function _RECTANGLE.r(v,iv)
		if iv then
			v.x=iv-v.w
		end
		return v.x+v.w
	end
	_RECTANGLE.R=_RECTANGLE.r
-- vert
	function _RECTANGLE.t(v,iv)
		if iv then
			v.y=iv.y
		end
		return v.y
	end
	_RECTANGLE.T=_RECTANGLE.t
	function _RECTANGLE.b(v,iv)
		if iv then
			v.y=iv-v.h
		end
		return v.y+v.h
	end
	_RECTANGLE.B=_RECTANGLE.b
-- mid
	function _RECTANGLE.mx(v,iv)
		if iv then
			v.x=iv-v.w/2
		end
		return v.x+v.w/2
	end
	_RECTANGLE.MX=_RECTANGLE.mx
	function _RECTANGLE.my(v,iv)
		if iv then
			v.y=iv-v.h/2
		end
		return v.y+v.h/2
	end
	_RECTANGLE.MY=_RECTANGLE.my
-- corners
	-- top left
	function _RECTANGLE.pos(v,iv)
		if iv then
			v.x=iv.x
			if v.dir=="tl" then
				v.b=iv.y
			else
				v.y=iv.y
			end
		else
			if v.dir=="tl" then
				return Vec(v.x,v.b)
			else
				return Vec(v.x,v.y)
			end
		end
	end
	_RECTANGLE.pos1 = _RECTANGLE.pos
	-- top right
	function _RECTANGLE.pos2(v,iv)
		if iv then
			v.r = iv.r
			if v.dir=="tr" then
				v.b=iv.y
			else
				v.y=iv.y
			end
		else
			if v.dir=="tr" then
				return Vec(v.r,v.b)
			else
				return Vec(v.r,v.y)
			end
		end
	end
	-- bottom right
	function _RECTANGLE.pos3(v,iv)
		if iv then
			v.r=iv.x
			if v.dir=="br" then
				v.y=iv.y
			else
				v.b=iv.y
			end
		else
			if v.dir=="br" then
				return Vec(v.r,v.y)
			else
				return Vec(v.r,v.b)
			end
		end
	end
	-- bottom left
	function _RECTANGLE.pos4(v,iv)
		if iv then
			v.x = iv.x
			if v.dir=="bl" then
				v.y=iv.y
			else
				v.b=iv.y
			end
		else
			if v.dir=="bl" then
				return Vec(v.x,v.y)
			else
				return Vec(v.x,v.b)
			end
		end
	end
	function _RECTANGLE.pos5(v,iv)
		if iv then
			v.mx=iv.x
			v.my=iv.y
		end
		return Vec(v.mx,v.my)
	end

-- other??
	function _RECTANGLE.dims(v,iv)
		if iv then
			v.w=iv.x
			v.h=iv.y
		end
		return Vec(v.w,v.h)
	end

	function _RECTANGLE.slope(v)
		if _LINE then
			if v.dir then
				if v.dir == "tl" then
					return _LINE(v[1],v[2]+v[4],v[1]+v[3],v[2])
				elseif v.dir == "tr" then
					return _LINE(v[1],v[2],v[1]+v[3],v[2]+v[4])
				elseif v.dir == "br" then
					return _LINE(v[1]+v[3],v[2],v[1],v[2]+v[4])
				elseif v.dir == "bl" then
					return _LINE(v[2]+v[4],v[1],v[2],v[1]+v[3])
				end
			end
		else
			error("Line.lua not found or added, it is a requirement for slope()!")
		end
	end
	-- end of properties
		for k,v in pairs(_RECTANGLE) do
			_RECTANGLE.data[k]=v
		end
	-- ==========================================
	_RECTANGLE.type="rectangle"
	function _RECTANGLE.sPos(v,i)
		i = (i-1)%3+1
		if v.dir=="tl" then
			if i==1 then return Vec(v.x,v.b)
			elseif i==2 then return Vec(v.r,v.y)
			elseif i==3 then return Vec(v.r,v.b)
			end
		elseif v.dir=="tr" then
			if i==1 then return Vec(v.x,v.y)
			elseif i==2 then return Vec(v.r,v.b)
			elseif i==3 then return Vec(v.x,v.b)
			end
		elseif v.dir=="br" then
			if i==1 then return Vec(v.x,v.y)
			elseif i==2 then return Vec(v.r,v.y)
			elseif i==3 then return Vec(v.x,v.b)
			end
		elseif v.dir=="bl" then
			if i==1 then return Vec(v.x,v.y)
			elseif i==2 then return Vec(v.r,v.y)
			elseif i==3 then return Vec(v.r,v.b)
			end
		end
	end
	function _RECTANGLE.sPosList(v)
		return {v:sPos(1),v:sPos(2),v:sPos(3)}
	end
	function _RECTANGLE.corner(v,i)
		i = (i-1)%4+1
		if i==1 then return Vec(v.x,v.y)
		elseif i==2 then return Vec(v.r,v.y)
		elseif i==3 then return Vec(v.r,v.b)
		elseif i==4 then return Vec(v.x,v.b)
		end
	end
	function _RECTANGLE.aPos(v,i)
		i = (i-1)%(v.dir and 3 or 4)+1
		if v.dir=="tl" then
			if i==1 then return Vec(v.x,v.b)
			elseif i==2 then return Vec(v.r,v.y)
			elseif i==3 then return Vec(v.r,v.b)
			end
		elseif v.dir=="tr" then
			if i==1 then return Vec(v.x,v.y)
			elseif i==2 then return Vec(v.r,v.b)
			elseif i==3 then return Vec(v.x,v.b)
			end
		elseif v.dir=="br" then
			if i==1 then return Vec(v.x,v.y)
			elseif i==2 then return Vec(v.r,v.y)
			elseif i==3 then return Vec(v.x,v.b)
			end
		elseif v.dir=="bl" then
			if i==1 then return Vec(v.x,v.y)
			elseif i==2 then return Vec(v.r,v.y)
			elseif i==3 then return Vec(v.r,v.b)
			end
		else
			if i==1 then return Vec(v.x,v.y)
			elseif i==2 then return Vec(v.r,v.y)
			elseif i==3 then return Vec(v.r,v.b)
			elseif i==4 then return Vec(v.x,v.b)
			end
		end
	end
	function _RECTANGLE.corners(v)
		return {Vec(v.x,v.y),Vec(v.r,v.y),Vec(v.r,v.b),Vec(v.x,v.b)}
	end
	function _RECTANGLE.intersect(v,iv)
		return(	v.r>=iv.l and
				v.l<=iv.r and
				v.t<=iv.b and
				v.b>=iv.t)
	end
	function _RECTANGLE.relate(v,iv)
		-- ALL DISTANCES POSITIVE
		return v.l-iv.r, -- distance to the left
			iv.l-v.r, -- distance to the right
			v.t-iv.b, -- distance up
			iv.t-v.b -- distance down
	end
	function _RECTANGLE.fullIntersect(v,iv)
		return v:intersect(iv),v:relate(iv)
	end
	function _RECTANGLE.intersection(v,iv)
		local x = max(v.x,iv.x)
		local y = max(v.y,iv.y)
		local w = v.r < iv.r and v.r-x or iv.r-x
		local h = v.b < iv.b and v.b-y or iv.b-y
		return _RECTANGLE(x,y,w,h)
	end
	function _RECTANGLE.expelDir(v,iv)
		local l1,r1,u1,d1 = unpack(v:relate(iv))
		l = math.abs(l1)
		r = math.abs(r1)
		u = math.abs(u1)
		d = math.abs(d1)
		if l<r and l<u and l<d then
			return 1,l1,r1,u1,d1
		elseif r<l and r<u and r<d then
			return 2,l1,r1,u1,d1
		elseif u<l and u<r and u<d then
			return 3,l1,r1,u1,d1
		elseif d<l and d<r and d<u then
			return 4,l1,r1,u1,d1
		end
	end
	function _RECTANGLE.SATIntersect(self,other)
		local within = true
		for i = 1,self.dir and 3 or 4 do
			local v = Line.fromRecI(self,i)
			local within1 = v:SATPointsRec(other)
			within = within and within1
			v:del()
		end
		for i = 1,other.dir and 3 or 4 do
			local v = Line.fromRecI(other,i)
			local within1 = v:SATPointsRec(self)
			within = within and within1
		end
		return within
	end
	function _RECTANGLE.SATNearest(self,other,getDelta,getImpact)
		local within = true
		local nearestSide,nearestPoint,nearest = 1,1,-math.huge
		local point,impact
		local within1,minI,minimum,v
		local typeA = true
		-- check other rectangle's points (this rec's perspective)
		-- accurately determines nearest point and side
		-- partially determines boolean
		-- if this defines nearest, we have an intersection type A - dynamic corner into static side.
		-- this means our impact is the dynamic corner, and the delta is a projection of the corner
		-- onto the static side.
		for i=1,other.dir and 3 or 4 do
			v = Line.fromRecI(other,i)
			within1,minI,minimum = v:SATPointsRec(self,true)
			within = within and within1
			if minimum > nearest then
				nearestSide = i
				nearestPoint = minI
				nearest = minimum
				typeA = true
			end
			v:del()
		end
		-- check this rectangle's points (other rec's perspective)
		-- finishes determining boolean
		-- if this defines nearest, we have a type B - static corner into dynamic side.
		-- this means our impact is the static corner, and the delta is a projection of the corner
		-- onto the dynamic side.
		for i=1,self.dir and 3 or 4 do
			v = Line.fromRecI(self,i)
			within1,minI,minimum = v:SATPointsRec(other,true)
			within = within and within1
			if minimum > nearest then
				nearestSide = i
				nearestPoint = minI
				nearest = minimum
				typeA = false
			end
			v:del()
		end
		if within and typeA then
			if getDelta then
				local nearCorner = self:aPos(nearestPoint)
				local _,point = Line.fromRecI(other,nearestSide):del():projVec(nearCorner,true)
				delta = point-nearCorner
				nearCorner:del()
			end
			if getImpact then
				impact = self:aPos(nearestPoint)
			end
		elseif within then
			if getDelta then
				local nearCorner = other:aPos(nearestPoint)
				local _,point = Line.fromRecI(self,nearestSide):del():projVec(nearCorner,true)
				delta = nearCorner-point
				nearCorner:del()
			end
			if getImpact then
				impact = other:aPos(nearestPoint)
			end
		end
		return within,
			typeA,
			nearestSide,
			nearestPoint,
			nearest,
			(getDelta and delta) or (getImpact and impact),
			(getImpact and getDelta and impact)
	end
	function _RECTANGLE.SATExpel(self,other,getDelta)
		if self:intersect(other) then
			local within,typeA,nearestSideI,nearestPointI,nearestDist,delta = self:SATNearest(other,true)
			if within then
				self.x = self.x + delta.x
				self.y = self.y + delta.y
				if getDelta then
					return delta
				else
					delta:del()
				end
			end
		end
	end
	function _RECTANGLE.expel(v,iv)
		if v:intersect(iv) then
			local dir,l,r,u,d = v:expelDir(iv)
			if dir==1 then
				v.x = v.x - l
				return Vec(-1,0)
			elseif dir==2 then
				v.x = v.x + r
				return Vec(1,0)
			elseif dir==3 then
				v.y = v.y - u
				return Vec(0,-1)
			elseif dir==4 then
				v.y = v.y + d
				return Vec(0,1)
			end
		end
	end
	function _RECTANGLE.fit(v,iv,copy)
		if copy then
			local r = v:copy()
			r.x = math.min(math.max(r.x,iv.x),iv.r-r.w)
			r.y = math.min(math.max(r.y,iv.y),iv.b-r.h)
			return r
		else
			v.x = math.min(math.max(v.x,iv.x),iv.r-v.w)
			v.y = math.min(math.max(v.y,iv.y),iv.b-v.h)
			return v
		end
	end
	function _RECTANGLE.copy(v,dx,dy,dw,dh,mod)
		if mod then
			for k,v in pairs(v) do
				mod[k] = v
			end
		end
		dx=dx or 0
		dy=dy or 0
		dw=dw or 0
		dh=dh or 0
		return _RECTANGLE(v.x+dx,v.y+dy,v.w+dw,v.h+dh,mod)
	end
	function _RECTANGLE.multiply(v,val)
		return _RECTANGLE(v.x*val,v.y*val,v.w*val,v.h*val)
	end

	local function iter(self,other)
		if other.r<self.r then
			other.x = other.x + other.w
		elseif other.b<self.b then
			other.x = other._ITERSTARTX
			other.y = other.y + other.h
		else
			return nil
		end
		return other,other
	end
	function _RECTANGLE.iter(self,other)
		other._ITERSTARTX = other.x
		other.x = other.x - other.w
		return iter,self,other
	end

	function _RECTANGLE.regressB(self,vec)
		return _VECTOR(math.floor((vec.x-self.x)/self.w)+1,math.floor((vec.y-self.y)/self.h)+1)
	end
	function _RECTANGLE.regress(self,area,vec)
		local v = self:regressB(vec)
		return v.x+v.y*math.floor(area.w/self.w)
	end
	function _RECTANGLE.unpack(self)
		return self[1],self[2],self[3],self[4]
	end

function _RECTANGLE.loadLine(_LINE)
	Line = _LINE or _G.LINE
end

function _RECTANGLE.__index(t,k)
	if type(_RECTANGLE[k])=='function' and _RECTANGLE.data[k] then
		return _RECTANGLE[k](t)
	elseif _RECTANGLE[k] and _RECTANGLE.data[k] then
		return t[_RECTANGLE[k]]
	elseif _RECTANGLE[k] then
		return _RECTANGLE[k]
	else
		return nil
	end
end

function _RECTANGLE.__newindex(t,k,v)
	if type(_RECTANGLE[k])=='function' and _RECTANGLE.data[k] then
		_RECTANGLE[k](t,v)
	elseif _RECTANGLE[k] and _RECTANGLE.data[k] then
		t[_RECTANGLE[k]]=v
	else
		rawset(t,k,v)
	end
end

function _RECTANGLE.__tostring(v)
	local ret={'[',tostring(v.pos1),',',tostring(v.dims),']'}
	return table.concat(ret)
end
function _RECTANGLE.__eq(a,b)
	return a.pos1==b.pos1 and a.pos4==b.pos4
end

function _RECTANGLE.meta.__call(t,x,y,w,h,v)
	--print(t,x,y,w,h,v)
	local v = v or nil
	if not v and _CACHE.C>0 then
		v=table.remove(_CACHE,_CACHE.C)
		v.dir = nil
		_CACHE.C = _CACHE.C-1
	elseif not v then
		v = {}
	end
	v[1] = x
	v[2] = y
	v[3] = w
	v[4] = h
	return setmetatable(v,_RECTANGLE)
end

function _RECTANGLE.del(v)
	_CACHE.C = _CACHE.C + 1
	_CACHE[_CACHE.C] = v
	return v
end

setmetatable(_RECTANGLE,_RECTANGLE.meta)

local function ret(...)
	local args={...}
	_G._RECTANGLE = _RECTANGLE
	for i,v in ipairs(args) do
		if type(v)=='string' then
			_G[v]=_RECTANGLE
		else
			v=_RECTANGLE
		end
	end
	return _RECTANGLE
end
return ret

--[[
--A bit of code for a modified json lib, stored here for future potential.

json.encoders.rectangle = function(val,op)
  return "{\"type\":\"rectangle\",\"x\":"..val.x..",\"y\":"..val.y..",\"w\":"..val.w..",\"h\":"..val.h.."}"
end
json.decoders.rectangle = function(val)
  local x,y,w,h = val.x,val.y,val.w,val.h
  val.x,val.y,val.w,val.h = nil,nil,nil,nil
  return (Rec(x,y,w,h,val))
end
]]--