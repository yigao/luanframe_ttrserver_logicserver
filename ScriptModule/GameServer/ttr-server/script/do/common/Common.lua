common = {}

--获得距离今天24点剩余秒数
function common.GetTodayZeroLeftTime()
    local nowTime = os.time()
    local timetable = os.date("*t", nowTime)
    return 24*3600 - timetable.hour * 3600 - timetable.min * 60 - timetable.sec
end

-- 删除table表中符合conditionFunc的数据
-- @param tb 要删除数据的table
-- @param data 符合要删除的数据
function common.removeTableData(tb, data)
    -- body
    if tb ~= nil and next(tb) ~= nil then
        -- todo
        for i = #tb, 1, -1 do
            if data == tb[i] then
                -- todo
                table.remove(tb, i)
            end
        end
    end
end

-- 判断两个时间是否在同一天
function common.IsSameDay(time1, time2)
	local temp1 = os.date("*t", time1)
	local temp2 = os.date("*t", time2)
	if temp1.year == temp2.year and temp1.month == temp2.month and temp1.day == temp2.day then
		return true
	end
	return false
end

-- 表格字符串数组分割,比如"s_100;d_220" ==> {s="100",d="220"}
function common.StringSplitTable(str)
    local tmp = {}
    if type(str) ~= "string" then
        return tmp
    end

    local args = string.split(str, ";")
    unilight.debug("")
    for k,v in pairs(args) do
        local _args = string.split(v, "_")
        tmp[_args[1]] = _args[2]
    end
    return tmp
end

--复制函数
function common.shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--深度复制
function common.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--- @brief 调试时打印变量的值
--- @param data 要打印的字符串
--- @param [max_level] table要展开打印的计数，默认nil表示全部展开
--- @param [prefix] 用于在递归时传递缩进，该参数不供用户使用于
function common.var_dump(data, max_level, prefix)  
    if type(prefix) ~= "string" then  
        prefix = ""  
    end  
    if type(data) ~= "table" then  
        unilight.debug(prefix .. tostring(data))  
    else  
        unilight.debug(data)  
        if max_level ~= 0 then  
            local prefix_next = prefix .. "    "  
            unilight.debug(prefix .. "{")  
            for k,v in pairs(data) do  
                io.stdout:write(prefix_next .. k .. " = ")  
                if type(v) ~= "table" or (type(max_level) == "number" and max_level <= 1) then  
                    print(v)  
                else  
                    if max_level == nil then  
                        var_dump(v, nil, prefix_next)  
                    else  
                        var_dump(v, max_level - 1, prefix_next)  
                    end  
                end  
            end  
            unilight.debug(prefix .. "}")  
        end  
    end  
end

function common.vd(data, max_level)
    var_dump(data, max_level or 5)
end