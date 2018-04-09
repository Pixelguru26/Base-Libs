local _VECTOR={0,0,funcs={},type="vector",_CACHE={C=0}}
local _CACHE = _VECTOR._CACHE
_VECTOR.x=1
_VECTOR.X=1
_VECTOR.y=2
_VECTOR.Y=2
_VECTOR.w=1
_VECTOR.W=1
_VECTOR.h=2
_VECTOR.H=2

_VECTOR.meta={}

function _VECTOR.__index(t,k)
	if type(_VECTOR[k])=='function' then
		return _VECTOR[k](t)
	elseif v~=1 and v~=2 and _VECTOR[k] then
		return t[_VECTOR[k]] or _VECTOR[k]
	elseif _VECTOR.funcs[k] then
		return _VECTOR.funcs[k]
	else
		return nil
	end
end

function _VECTOR.__newindex(t,k,v)
	if type(_VECTOR[k])=='function' then
		return _VECTOR[k](t,v)
	elseif k~=1 and k~=2 and _VECTOR[k] then
		t[_VECTOR[k]]=v
	elseif _VECTOR.funcs[k] then
		rawset(_VECTOR.funcs[k](t),v)
	else
		rawset(t,k,v)
	end
end

-- maths
	function _VECTOR.__add(a,b)
	    if type(a)=='table' and type(b)=='table' then
	        return _VECTOR(a.x+b.x,a.y+b.y)
	    elseif type(a)=='table' then
	        return _VECTOR(a.x+b,a.y+b)
	    elseif type(b)=='table' then
	        return _VECTOR(b.x+a,b.y+a)
	    end
	end
	function _VECTOR.__sub(a,b)
	    if type(a)=='table' and type(b)=='table' then
	        return _VECTOR(a.x-b.x,a.y-b.y)
	    elseif type(a)=='table' then
	        return _VECTOR(a.x-b,a.y-b)
	    elseif type(b)=='table' then
	        return _VECTOR(b.x-a,b.y-a)
	    end
	end
	function _VECTOR.__mul(a,b)
	    if type(a)=='table' and type(b)=='table' then
	        return _VECTOR(a.x*b.x,a.y*b.y)
	    elseif type(a)=='table' then
	        return _VECTOR(a.x*b,a.y*b)
	    elseif type(b)=='table' then
	        return _VECTOR(b.x*a,b.y*a)
	    end
	end
	function _VECTOR.__div(a,b)
	    if type(a)=='table' and type(b)=='table' then
	        return _VECTOR(a.x/b.x,a.y/b.y)
	    elseif type(a)=='table' then
	        return _VECTOR(a.x/b,a.y/b)
	    elseif type(b)=='table' then
	        return _VECTOR(b.x/a,b.y/a)
	    end
	end
	function _VECTOR.__mod(a,b)
	    if type(a)=='table' and type(b)=='table' then
	        return _VECTOR(a.x%b.x,a.y%b.y)
	    elseif type(a)=='table' then
	        return _VECTOR(a.x%b,a.y%b)
	    elseif type(b)=='table' then
	        return _VECTOR(b.x%a,b.y%a)
	    end
	end
	function _VECTOR.__pow(a,b)
	    if type(a)=='table' and type(b)=='table' then
	        return _VECTOR(a.x^b.x,a.y^b.y)
	    elseif type(a)=='table' then
	        return _VECTOR(a.x^b,a.y^b)
	    elseif type(b)=='table' then
	        return _VECTOR(b.x^a,b.y^a)
	    end
	end
	function _VECTOR.__concat(a,b) -- DOT PRODUCT
	    if type(a)=='table' and type(b)=='table' then
	    	local al = a.l
	    	return(a.x/a.l*b.x+a.y/a.l*b.y)
	    end
	end

-- general
	function _VECTOR.__tostring(v)
	    local r={'<',v.x,',',v.y,'>'}
	    return table.concat(r)
	end

	function _VECTOR.__eq(a,b)
		if type(a)=="number" then
			return a==b.x and a==b.y
		elseif type(b)=="number" then
			return a.x==b and a.y==b
		end
		return a.x==b.x and a.y==b.y
	end
	function _VECTOR.__lt(a,b)
		if type(a)=="number" then
			return a < b.x and a < b.y
		elseif type(b)=="number" then
			return a.x < b and a.y < b
		end
		return a.x < b.x and a.y < b.y
	end
	function _VECTOR.__le(a,b)
		if type(a)=="number" then
			return a<=b.x and a<=b.y
		elseif type(b)=="number" then
			return a.x<=b and a.y<=b
		end
		return a.x<=b.x and a.y<=b.y
	end

	-- Vector angle
	function _VECTOR.a(t)
		return math.atan2(t.y,t.x)
	end
	_VECTOR.A=_VECTOR.a

	-- Vector magnitude - length
	function _VECTOR.l(t)
		local a = t.a
		if a>7*math.pi/4 or a<math.pi/4 or a>3*math.pi/4 and a<5*math.pi/4 then
			return t.x/math.cos(a)
		else
			return t.y/math.sin(a)
		end
	end
	_VECTOR.L=_VECTOR.l

	-- Vector unit - converts vector to unit length
	function _VECTOR.n(t)
		local l=t.l
		return _VECTOR(t.x/l,t.y/l)
	end
	_VECTOR.N=_VECTOR.n

	function _VECTOR.max(t)
		return math.max(t.x,t.y)
	end
	_VECTOR.MAX=_VECTOR.max
	_VECTOR.Max=_VECTOR.max

	function _VECTOR.min(t)
		return math.min(t.x,t.y)
	end
	_VECTOR.MIN=_VECTOR.min
	_VECTOR.Min=_VECTOR.min

	function _VECTOR.r(v)
		return _VECTOR(v.y,v.x)
	end
	_VECTOR.rev=_VECTOR.r
	_VECTOR.reverse=_VECTOR.r
	_VECTOR.R=_VECTOR.r
	_VECTOR.Rev=_VECTOR.r
	_VECTOR.Reverse=_VECTOR.r
	_VECTOR.REV=_VECTOR.r
	_VECTOR.REVERSE=_VECTOR.r

	function _VECTOR.abs(v)
		return _VECTOR(math.abs(v.x),math.abs(v.y))
	end
	_VECTOR.Abs=_VECTOR.abs
	_VECTOR.ABS=_VECTOR.abs
	_VECTOR.absolute=_VECTOR.abs
	_VECTOR.Absolute=_VECTOR.abs
	_VECTOR.ABSOLUTE=_VECTOR.abs

	function _VECTOR.funcs.dist(self,other)
		return (self-other).l
	end

	function _VECTOR.funcs.copy(self,a,b)
		a=a or 0
		b=b or 0
		if type(a)=="table" then
			return _VECTOR(self.x+a.x,self.y+a.y)
		else
			return _VECTOR(self.x+a,self.y+b)
		end
	end


function _VECTOR.meta.__call(t,x,y)
	local v
	if _CACHE.C>0 then
		v=table.remove(_CACHE,_CACHE.C)
		_CACHE.C = _CACHE.C-1
	else
		v = {}
	end
	v[1] = x
	v[2] = y
	return setmetatable(v,_VECTOR)
end

setmetatable(_VECTOR,_VECTOR.meta)

_VECTOR.Origin=_VECTOR(0,0)
_VECTOR.origin=_VECTOR.Origin
_VECTOR.o=_VECTOR.Origin
_VECTOR.O=_VECTOR.Origin

_VECTOR.zero=_VECTOR(0,0)
_VECTOR.Zero=_VECTOR.zero
_VECTOR.ZERO=_VECTOR.zero

function _VECTOR.funcs.isWithinRec(self,rect)
	return type(rect)=="table" and rect.type=="rectangle" and self >= rect.pos1 and self <= rect.pos4
end

function _VECTOR.funcs.limit(self,min,max)
	return Vec(
		self.x < min.x and min.x or (self.x > max.x and max.x or self.x),
		self.y < min.y and min.y or (self.y > max.y and max.y or self.y)
		)
end

function _VECTOR.funcs.del(self)
	table.insert(_CACHE,self)
	_CACHE.C = _CACHE.C+1
	return self
end

function _VECTOR.funcs.inc(self,other)
	self[1] = self[1] + other[1]
	self[2] = self[2] + other[2]
	return self
end
function _VECTOR.funcs.dec(self,other)
	self[1] = self[1] - other[1]
	self[2] = self[2] - other[2]
	return self
end
function _VECTOR.funcs.mul(self,other)
	self[1] = self[1] * other[1]
	self[2] = self[2] * other[2]
	return self
end
function _VECTOR.funcs.div(self,other)
	self[1] = self[1] / other[1]
	self[2] = self[2] / other[2]
	return self
end
function _VECTOR.funcs.set(self,other)
	self[1] = other[1]
	self[2] = other[2]
	return self
end
function _VECTOR.funcs.mod(self,other)
	self[1] = self[1] % other[1]
	self[2] = self[2] % other[2]
	return self
end

function dist(x1,y1,x2,y2)
	if type(x1)=="table" then -- vec mode
		return dist(x1.x,x1.y,y1.x,y1.y)
	else
		return math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1))
	end
end

local function ret(...)
	local args={...}
	for i,v in ipairs(args) do
		if type(v)=='string' then
			_G[v]=_VECTOR
		else
			v=_VECTOR
		end
	end
	return _VECTOR
end
return ret