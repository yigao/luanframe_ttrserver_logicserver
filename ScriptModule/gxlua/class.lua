function GetClassName(name)
	for k,v in pairs(_G) do
		if name==v then
			return k
		end 
	end
end
function CreateClass(name,basename)
	if _G[name] ~= nil then
		print("CreateClass被意外全局初始化,这里强制重置成类:"..name)
		return nil
	end
	_G[name] = {}
	local class = _G[name]
	if basename then
		local baseclass = _G[basename]
		if baseclass then
			for k,v in pairs(baseclass) do
				class[k] = v
			end
		else
			print("CreateClass error:" .. tostring(name) .. ":" .. tostring(basename))
		end
	end
	class.__classname = name
	function class:New(initclass)
		local new = initclass or {}
		setmetatable(new, { __index = self})
		return new
	end
	function class:SetClassName(cname)
		self.__classname = cname or self.__classname
	end
	return class
end