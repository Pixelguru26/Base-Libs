local function __call(t,...)
	for _,version in ipairs(t) do
		local execute = true
		local v
		for i=1,select('#',...) do
			v = (select(i,...))
			if type(v)~=version[2][i] then
				execute = false
				break;
			end
		end
		if execute then
			return version[1](...)
		end
	end
	return t.default(...)
end
local function add(t,...)
	local i,i1 = 1,select('#',...)
	local fn,args
	while i < i1 do
		i = i + 1
		fn = (select(i,...))
		args = (select(i+1,...))
		if type(args)=="table" then
			t.c = t.c + 1
			t[t.c] = {fn,args}
			i = i + 1
		else
			t.default = {fn,args}
		end
	end
end
local function def(...)
	local ret = {c=0,add=add}
	for i = 1,select('#',...),2 do
		ret.c = ret.c + 1
		ret[ret.c] = {(select(i,...)),(select(i+1,...))}
	end
	return setmetatable(ret,{__call = __call})
end

return def
