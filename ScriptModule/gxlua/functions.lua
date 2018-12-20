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

function shuffle(tbl)
    
    local tbl_count = #tbl;
    for i=1,tbl_count do
        local ridx  = math.random(1, tbl_count);
        if i~=ridx then
            local temp  = tbl[i];
            tbl[i]      = tbl[ridx];
            tbl[ridx]   = temp;
        end
    end
end

-- start --

--------------------------------
-- 从表格中删除指定值，返回删除的值的个数
-- @function [parent=#table] removebyvalue
-- @param table array 表格
-- @param mixed value 要删除的值
-- @param boolean removeall 是否删除所有相同的值
-- @return integer#integer 

--[[--

从表格中删除指定值，返回删除的值的个数

~~~ lua

local array = {"a", "b", "c", "c"}
nlinfo(table.removebyvalue(array, "c", true)) -- 输出 2

~~~

]]

-- end --
function table.removebyvalue(array, value, removeall)
    local c, i, max = 0, 1, #array
    while i <= max do
        if array[i] == value then
            table.remove(array, i)
            c = c + 1
            i = i - 1
            max = max - 1
            if not removeall then break end
        end
        i = i + 1
    end
    return c
end

function get_data_by_sec(sec)
    sec = sec < 0 and 0 or sec
    local data =
    {
        day = math.floor(sec / 3600 / 24),
        hour = math.floor(sec / 3600) % 24,
        min = math.floor(sec % 3600 / 60),
        sec = sec % 60,
    }
    return data
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

function urlEncode(s)  
     s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)  
    return string.gsub(s, " ", "+")  
end  
  
function urlDecode(s)  
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)  
    return s  
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


-- 位标识符操作  Start
function GetBit( curr, enum_val )
    return (curr & (1<<enum_val)) > 0;
end

function SetBit( curr, enum_val )
    return curr | (1<<enum_val)
end

function ClearBit( curr, enum_val )
    if (curr & (1<<enum_val)) > 0 then
        curr = curr ~ (1<<enum_val);
    end
    return curr;
end

function SetBits( curr, enum_tb )
    for _,v in ipairs(enum_tb) do
        curr = curr | (1<<v);
    end
    return curr
end

function ClearBits( curr, enum_tb )
    for _,enum_val in ipairs(enum_tb) do
        if (curr & (1<<enum_val)) > 0 then
            curr = curr ~ (1<<enum_val);
        end
    end
    return curr;
end

-- 位标识符操作  End

function DumpMemorySnapshot()
    collectgarbage("collect")
    MemoryRefInfo.m_cMethods.DumpMemorySnapshot("./", "All", -1)
end

function DumpMemorySnapshotComparedFile( file_1, file_2 )
    MemoryRefInfo.m_cMethods.DumpMemorySnapshotComparedFile("./", "Compared", -1, file_1, file_2)
end

