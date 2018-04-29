local function __call(t,...)
	local args = {...}
	for _,version in ipairs(t) do
		local execute = true
		for i,v in ipairs(args) do
			if type(v)~=version[2][i] then
				execute = false
				break;
			end
		end
		if execute then
			version[1](...)
		end
	end
end
local function add(t,fn,args)
	t.c = t.c + 1
	t[t.c] = {fn,args}
end
local function def(...)
	local args = {...}
	local ret = {c=0,add=add}
	for i = 1,#args,2 do
		ret.c = ret.c + 1
		ret[ret.c] = {args[i],args[i+1]}
	end
	return setmetatable(ret,{__call = __call})
end

return def