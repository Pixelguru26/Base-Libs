local type,rawget,rawset,setmetatable,getmetatable = type,rawget,rawset,setmetatable,getmetatable

local function construct(type,...)
	local v
	local _CACHE = type._CACHE
	if _CACHE.C > 0 then
		v = _CACHE[_CACHE.C]
		_CACHE.C = _CACHE.C - 1
		_CACHE[_CACHE.C] = nil
		if type.__gc then
			setmetatable(v,nil)
			type.__gc(v)
		end
	else
		v = {}
	end
	type._CONSTRUCTOR(v,...)
	return setmetatable(v,type)
end

local function index(t,k)
	local _type = getmetatable(t)
	if type(k)=="number" then
		if t._MAX then
			if t._MIN then
				return t[(k-t._MIN)%t._MAX+t._MIN]
			else
				return t[(k-1)%t._MAX+1]
			end
		else
			return _type[k]
		end
	elseif _type.aliases[k] then
		if type(_type.aliases[k]) == "function" then
			return _type.aliases[k](t)
		else
			return t[_type.aliases[k]]
		end
	else
		return _type[k]
	end
end

local function newindex(t,k,v)
	local _type = getmetatable(t)
	if type(k)=="number" then
		if t._MAX then
			if t._MIN then
				rawset(t,(k-t._MIN)%t._MAX+t._MIN,v)
			else
				rawset(t,(k-1)%t._MAX+1,v)
			end
		else
			rawset(_type,k,v)
		end
	elseif _type.aliases[k] then
		if type(_type.aliases[k]) == "function" then
			rawset(t,_type.aliases[k],v)
		else
			_type.aliases[k](t,v)
		end
	else
		rawset(t,k,v)
	end
end

local function del(t)
	local _type = getmetatable(t)
	t._CACHE.C = t._CACHE.C + 1
	t._CACHE[t._CACHE.C] = t
	return t
end

-- struct constructor function.
local function struct(typename,constructor)
	local v = {
		type = typename,
		del = del,
		_META = {
			__call = construct
		},
		_CACHE = {
			C = 0
		},
		_CONSTRUCTOR = constructor,
		__index = index,
		__newindex = newindex,

		aliases = {},
		funcs = {}
	}
	return setmetatable(v,v._META)
end

return struct
