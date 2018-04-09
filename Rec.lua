local lib={name="Rec"}
local Vec=assert(_VECTOR or require("Vec")() or require("lib/Vec")() or require("libs/Vec")(), "Cannot find/use 'Vec.lua', this is a requirement for "..lib.name.." to function!")

local _RECTANGLE={0,0,0,0,type="rectangle",_CACHE={}}
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
	function _RECTANGLE.pos(v,iv)
		if iv then
			v.x=iv.x
			v.y=iv.y
		else
			return Vec(v.x,v.y)
		end
	end
	function _RECTANGLE.pos1(v,iv)
		if iv then
			v.x=iv.x
			v.y=iv.y
		end
		return Vec(v.x,v.y)
	end
	function _RECTANGLE.pos2(v,iv)
		if iv then
			v.r=iv.x
			v.y=iv.y
		end
		return Vec(v.r,v.y)
	end
	function _RECTANGLE.pos3(v,iv)
		if iv then
			v.x=iv.x
			v.b=iv.y
		end
		return Vec(v.x,v.b)
	end
	function _RECTANGLE.pos4(v,iv)
		if iv then
			v.r=iv.x
			v.b=iv.y
		end
		return Vec(v.r,v.b)
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
	-- end of properties
		for k,v in pairs(_RECTANGLE) do
			_RECTANGLE.data[k]=v
		end
	-- ==========================================
	_RECTANGLE.type="rectangle"
	function _RECTANGLE.intersect(v,iv)
		return(	v.r>=iv.l and
				v.l<=iv.r and
				v.t<=iv.b and
				v.b>=iv.t)
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
	function _RECTANGLE.relate(v,iv)
		-- ALL DISTANCES POSITIVE
		local dists={
			v.l-iv.r, -- distance to the left
			iv.l-v.r, -- distance to the right
			v.t-iv.b, -- distance up
			iv.t-v.b -- distance down
		}
		return dists
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
	v = v or table.remove(_CACHE,#_CACHE) or {}
	v[1] = x
	v[2] = y
	v[3] = w
	v[4] = h
	return setmetatable(v,_RECTANGLE)
end

function _RECTANGLE.del(v)
	table.insert(_CACHE,v)
	return v
end


setmetatable(_RECTANGLE,_RECTANGLE.meta)

local function ret(...)
	local args={...}
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