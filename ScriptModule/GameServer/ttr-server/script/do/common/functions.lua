

--[[
实际上，除了 C++ 回调 Lua 函数之外，在其他所有需要回调的地方都可以使用 handler()。

@param mixed obj Lua 对象
@param function method 对象方法

@return function

]]--

function handler(obj, method)
	if (nil == obj or nil == method) then
		logError("handler param == nil");
		return nil;
	end
    return function(...)
        return method(obj, ...)
    end
end

function checktable(value)
    if type(value) ~= "table" then value = {} end
    return value
end

-- 单例模式
function singleton(classname, super)
    local cls = {}
    if super then
        for k,v in pairs(super) do cls[k] = v end
        cls.super = super
    else
        cls.ctor = function() end
    end

    cls.__cname = classname
    cls.__index = cls

    local Instance = setmetatable({class = cls}, cls)
    function cls.Instance()
        return Instance
    end
    return cls
end

-- 分割字符串
function SplitStr(str, reps)
	local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

-- 检查表中是否存在
function IsInTable(value, tbl)
	if nil == tbl then return false; end
	for k,v in pairs(tbl) do
		if v == value then
			return true;
		end
	end
	return false;
end

function ReverseTable(tab)  
    local tmp = {}  
    for i = 1, #tab do  
        local key = #tab  
        tmp[i] = table.remove(tab)  
    end  
  
    return tmp  
end

