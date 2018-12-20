--数据库

function unilight.initmongodb(url, dbname)
	return LuaNFrame:initmongodb(url, dbname)
end

--[[
    功能：创建表
    参数：
        name   : string, 表名
        primary: string, 主键名
    实例：
        LuaNFrame:createdb("userinfo", "_id") // 创建一个"userinfo"表，主键为"_id"

        returns its Collection handle. On error, returns nil and the error message.
]]
function unilight.createdb(name, primary)
    return LuaNFrame:createdb(name, primary)
end

--[[
    功能: 删除表
    参数：
        name   : string, 表名
    实例：
        LuaNFrame:droptable("userinfo") // 删除表"userinfo"
]]
function unilight.droptable(name)
    if type(name) == "string" then
        return LuaNFrame:droptable(name)
    else
        unilight.error("unilight.droptable param error........")
    end
end

--[[
    功能：获取表中一条记录
    参数：
        name: string           , 表名
        id  : 根据存储类型一致 ，主键值
    实例：
        LuaNFrame:getdata("userinfo", 100000) // 获取表"userinfo"中主键值为100000的那条记录
]]
function unilight.getdata(name, key)
    if type(name) == "string" and type(key) == "number" then
        return LuaNFrame:getdata(name, key)
    else
        unilight.error("unilight.getdata param error, name:"..name.." key:"..key)
    end
end

--[[
    功能：保存一条记录
    参数：
            name: string, 表名
            data: table , 需要保存的数据的全部信息，如果和表里已有的记录冲突，替换整条记录,
    实例：
        local userInfo = {
            _id = 100000,
            chips = 200000,
            base = {
                headurl = "http://baidu.com"
            }
        }
        unilight.savedata("userinfo", userInfo)
]]
function unilight.savedata(name, data)
	return LuaNFrame:savedata(name, data)
end

function unilight.savefield(name, id, fieldpath, data)
    if type(name) == "string" and type(id) == "number" and type(fieldpath) == "string" and type(data) == "table" then
        return LuaNFrame:savefield(name, id, fieldpath, data)
    else
        unilight.error("unilight.savefield param error")
    end
end

function unilight.getfield(name, id, field)
    if type(name) == "string" and type(id) == "number" and type(field) == "string" then
        return LuaNFrame:getfield(name, id, field)
    else
        unilight.error("unilight.getfield param error")
    end

end

--[[
    功能： 获取表里的所有记录
    参数：
            name:string,表名
    实例：
        local res = unilight.getAll("userinfo")
]]
 function unilight.getAll(name)
    return LuaNFrame:getAll(name)
end