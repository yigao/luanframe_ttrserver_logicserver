require "gxlua/class"

CreateClass("LuaNFrame")

--用来存放加载函数
LuaNFrame.LoadScriptList = { }

function LuaNFrame:init(pluginManager)

    self.pluginManager = pluginManager
    if self.pluginManager == nil then
        self:error("初始化失败。。。。。。。。。")
    end

    self.kernelModule = self.pluginManager:GetKernelModule()
    self.logModule = self.pluginManager:GetLogModule()
    self.luaModule = self.pluginManager:GetLuaModule()
    self.serverModule = self.pluginManager:GetServerModule()
    self.clientModule = self.pluginManager:GetClientModule()
    self.httpClientModule = self.pluginManager:GetHttpClientModule()
    self.httpServerModule = self.pluginManager:GetHttpServerModule()
    self.mongoModule = self.pluginManager:GetMongoModule()
    self.serverNetEventModule = self.pluginManager:GetServerNetEventModule()

    --用来存放加载的module
    self.ScriptList = { }

    --加载应用程序的Lua  Module
    self:load_script_file()
end

function LuaNFrame:GetPluginManager()
    return self.pluginManager
end

--添加服务器定时器
function LuaNFrame:AddTimer(luaFunc, nInterVal, useData)
    return self.luaModule:AddTimer(luaFunc, nInterVal, useData)
end

--停止服务器定时器
function LuaNFrame:StopTimer(timerId)
    self.luaModule:StopTimer(timerId)
end

--执行定时函数
function LuaNFrame.RunTimer(luaFunc, timerId, useData)
    local param_table = json.decode(useData)
    local timerId = timerId
    local timer = {}
    timer.Stop = function()
        LuaNFrame:StopTimer(timerId)
    end
    LuaNFrame.RunStringFunction(luaFunc, table.unpack(param_table), timer)
end

function LuaNFrame:AddClocker(luaFunc, sec, intervalSec, useData)
    return self.luaModule:AddClocker(luaFunc, sec, intervalSec / (24*3600), useData)
end

function LuaNFrame:StopClocker(timerId)
    return self.luaModule:StopClocker(timerId)
end

--创建全局唯一的UUID
function LuaNFrame:GetUUID()
    return self.kernelModule:GetUUID()
end

--通过字符串获得MD5, 返回MD5字符串
function LuaNFrame:GetMD5(str)
    if type(str) ~= "string" then
        LuaNFrame:error("GetMD5 param error, not string:" .. str)
        return
    end
    return self.kernelModule:GetMD5(str)
end

--通过字符串获得对应的CRC32, 返回数字
function LuaNFrame:GetCRC32(str)
    if type(str) ~= "string" then
        LuaNFrame:error("GetCRC32 param error, not string:" .. str)
        return
    end
    return self.kernelModule:GetCRC32(str)
end

--通过字符串获得对应的CRC16, 返回数字
function LuaNFrame:GetCRC16(str)
    if type(str) ~= "string" then
        LuaNFrame:error("GetCRC16 param error, not string:" .. str)
        return
    end
    return self.kernelModule:GetCRC16(str)
end

--通过字符串获得对应的Base64Encode, 返回字符串
function LuaNFrame:Base64Encode(str)
    if type(str) ~= "string" then
        self:error("Base64Encode param error, not string:" .. str)
        return
    end
    return self.kernelModule:Base64Encode(str)
end

--通过字符串获得对应的Base64Decode, 返回字符串
function LuaNFrame:Base64Decode(str)
    if type(str) ~= "string" then
        self:error("Base64Decode param error, not string:" .. str)
        return
    end
    return self.kernelModule:Base64Decode(str)
end

--数据库

function LuaNFrame:initmongodb(url, dbname)
    return self.mongoModule:AddMongoServer(0, url, dbname)
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
function LuaNFrame:createdb(name, primary)
	return self.mongoModule:CreateCollection(0, name, primary)
end

--[[
    功能: 删除表
    参数：
        name   : string, 表名
    实例：
        LuaNFrame:droptable("userinfo") // 删除表"userinfo"
]]
function LuaNFrame:droptable(name)
    return self.mongoModule:DropCollection(name)
end

--[[
    功能：获取表中一条记录
    参数：
        name: string           , 表名
        id  : 根据存储类型一致 ，主键值
    实例：
        LuaNFrame:getdata("userinfo", 100000) // 获取表"userinfo"中主键值为100000的那条记录
]]
function LuaNFrame:getdata(name, key)
    local data = self.mongoModule:FindOneByKey(0, name, key)
    if data ~= nil and data ~= "" then
        return json2table(data)
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
function LuaNFrame:savedata(name, data)
    local json_data = table2json(data)
    if type(data.uid) == "number" or type(data.uid) == "string" then
        local uid = tonumber(data.uid)
        return self.mongoModule:UpdateOneByKey(0, name, json_data, uid)
    else
        return self.mongoModule:UpdateOne(0, name, json_data)
    end
end

--[[
    功能：获取条记录的指定字段数据
    参数：
        name      :string          , 表名
        id        :根据具体使用类型， 键值
        fieldpath :string          , 指定字段
    实例：
        unilight.getfield("userinfo", 100000, "base.property") // 获取表"userinfo"中，key为100000的"base.property"字段数据
]]
function LuaNFrame:getfield(name, id, fieldpath)
    local data = self.mongoModule:FindFieldByKey(0, name, fieldpath, id)

    if type(data) == "string" and data ~= "" then
        data = json2table(data)
    else
        return
    end

    local fields = string.split(fieldpath, ".")
    for index, name in ipairs(fields) do
        data = data[name]
    end
    return data
end

--[[
    功能：保存一条记录里的某部分字段
    参数：
        name     : string           , 表名
        id       : 根据存储类型一致 ，主键值
        fieldpath: string           , 保存的记录键名
        data     : table            , 需要保存据信息，如果表里已有记录冲空，替换整条记录
    返回： nil 表示成功
            string 表示失败
    实例：
    (1)	表"userinfo"原来有一条记录
        userInfo = {
            _id = 100000,
            chips = 200000,
            base = {
                headurl = "http://baidu.com",
                property = {
                    name = "zwl",
                    age = 27,
                },
            },
        }

    (2) 将userInfo.base.property修改成
        local property = {
            Name = "zhaowolong",
            age = 28,
            addr = "深圳",
        }
        unilight.savefield("userinfo", 100000, "base.property", property)

    (3) 表"userinfo" 中键值为：100000的最新记录为：
        userInfo = {
            _id = 100000,
            chips = 200000,
            base = {
                headurl = "http://baidu.com",
                property = {
                    Name = "zhaowolong",
                    age = 28,
                    addr = "深圳"
                },
            }
        }
]]
----------------------------------WARNNING-------------------------------------
-- data将覆盖指定的fieldpath，记得是覆盖
-----------------------------------------------------------------------
function LuaNFrame:savefield(name, id, fieldpath, data)
    if id == nil or type(id) == "userdata" or data == nil or type(data) == "userdata" then
        unilight.error("id or data is null or type() is userdata")
        return "datatype error "
    end

    local tmp = {}
    tmp[fieldpath] = data
    local json_str = table2json(tmp)
    return self.mongoModule:UpdateFieldByKey(0, name, json_str, id)
end

--[[
    功能： 获取表里的所有记录
    参数：
            name:string,表名
    实例：
        local res = unilight.getAll("userinfo")
]]
function LuaNFrame:getAll(name)
    local data = self.mongoModule:FindAll(0, name)
    return json2table(data)
end

--获得服务器开启时间，单位s
function LuaNFrame:GetInitTime()
    return self.pluginManager:GetInitTime()/1000
end

--获得服务器当前时间，单位s
function LuaNFrame:GetNowTime()
    return self.pluginManager:GetNowTime()/1000
end

--添加网络服务器
function LuaNFrame:addServer(server_type, server_id, max_client, port, websocket)
    return self.serverModule:AddServer(server_type, server_id, max_client, port, websocket)
end

--添加网络协议回调函数
function LuaNFrame:addRecvCallBack(serverType, nMsgId, luaFunc)
    self.serverModule:AddReceiveLuaCallBackByMsgId(serverType, nMsgId, luaFunc)
end

--添加网络协议回调函数
function LuaNFrame:addRecvCallBackToOthers(serverType, luaFunc)
    self.serverModule:AddReceiveLuaCallBackToOthers(serverType, luaFunc)
end

function LuaNFrame:addEventCallBack(serverType, luaFunc)
    self.serverModule:AddEventLuaCallBack(serverType, luaFunc)
end

function LuaNFrame:sendByServerID(unLinkId, nMsgId, strData, nPlayerId)
    self.serverModule:SendByServerID(unLinkId, nMsgId, strData, nPlayerId)
end

function LuaNFrame:sendToAllServer(nMsgId, strData, nPlayerId)
    self.serverModule:SendToAllServer(nMsgId, strData, nPlayerId)
end

function LuaNFrame:SendToAllServerByServerType(serverType, nMsgId, strData, nPlayerId)
    self.serverModule:SendToAllServerByServerType(serverType, nMsgId, strData, nPlayerId)
end

function LuaNFrame:sendByServerIDForClient(unLinkId, nMsgId, strData, nPlayerId)
    self.clientModule:SendByServerID(unLinkId, nMsgId, strData, nPlayerId)
end

function LuaNFrame:sendToAllServerForClient(nMsgId, strData, nPlayerId)
    self.clientModule:SendToAllServer(nMsgId, strData, nPlayerId)
end

function LuaNFrame:SendToAllServerByServerTypeForClient(serverType, nMsgId, strData, nPlayerId)
    self.clientModule:SendToAllServerByServerType(serverType, nMsgId, strData, nPlayerId)
end

function LuaNFrame:addServerForClient(serverType, ip, port)
    return self.clientModule:AddServer(serverType, ip, port)
end

--添加网络协议回调函数
function LuaNFrame:addRecvCallBackForClient(serverType, nMsgId, luaFunc)
    self.clientModule:AddReceiveLuaCallBackByMsgId(serverType, nMsgId, luaFunc)
end

--添加网络协议回调函数
function LuaNFrame:addRecvCallBackToOthersForClient(serverType, luaFunc)
    self.clientModule:AddReceiveLuaCallBackToOthers(serverType, luaFunc)
end

function LuaNFrame:addEventCallBackForClient(serverType, luaFunc)
    self.clientModule:AddEventLuaCallBack(serverType, luaFunc)
end

--执行加载函数
function LuaNFrame:load_script_file(  )
    for i, fun in ipairs(self.LoadScriptList) do
        fun()
    end
end

function LuaNFrame:InsertLoadFunc(func)
    table.insert(self.LoadScriptList, func)
end

-- log --

--设置LOG等级
function LuaNFrame:SetLogLevel(level)
    self.logModule:SetLogLevel(level)
end

--设置LOG立马刷新等级
function LuaNFrame:SetFlushOn(level)
    self.logModule:SetFlushOn(level)
end

function LuaNFrame:debug(...)
	self.logModule:LuaDebug(...)
end

function LuaNFrame:info(...)
	self.logModule:LuaInfo(...)
end

function LuaNFrame:warn(...)
	self.logModule:LuaWarn(...)
end

function LuaNFrame:error(...)
    self.logModule:LuaError(...)
end

--http client接口

--[[
	向指定url请求GET http服务
	resFunc:http请求回调函数
	url:请求http服务器的url
	para:请求的数据,这时里是一个lua的table
    heads 在这里是一个 map[string]string 选定对应参考与值
    
    return bool
]]

function LuaNFrame:HttpClientRequestGet(url, resFunc, heads, para)
    heads = heads or {}
    para = para or {}
	if type(resFunc) ~= "string" or type(url) ~= "string" or type(heads) ~= "table" then
		unilight.error("unilight.HttpRequestGet params error" .. resFunc .. url)
		return
    end

    local jsonHeaders = table2json(heads)
	local callbackpara = table2json(para)
    self.httpClientModule:HttpRequestGet(url, resFunc, jsonHeaders, callbackpara)
end

--[[
	向指定url请求POS http服务
	resFunc:http请求回调函数
	url:请求http服务器的url
	msg:请求的数据,这时里是一个lua的table
	heads 在这里是一个 map[string]string 选定对应参考与值
]]
function LuaNFrame:HttpClientRequestPost(url, resFunc, body, heads, para)
    para = para or {}
	heads = heads or {}
	if type(resFunc) ~= "string" or type(url) ~= "string" or type(heads) ~= "table" or type(body) ~= "table" then
		unilight.error("unilight.HttpClientRequestPost params error" .. resFunc .. url)
		return
	end
    local jsonHeaders = table2json(heads)
    local callbackpara = table2json(para)
    local jsonbody = table2json(body)
    self.httpClientModule:HttpRequestPost(url, jsonbody, resFunc, jsonHeaders, callbackpara)
end

function LuaNFrame:HttpServerAddRequestHandler(serverType, urlPath, requestType, resFunc)
	if type(serverType) ~= "number" or type(resFunc) ~= "string" or type(urlPath) ~= "string" or type(requestType) ~= "number"then
		unilight.error("HttpServerAddRequestHandler params error" .. resFunc .. urlPath)
		return
    end
    self.httpServerModule:AddRequestHandler(serverType, urlPath, requestType, resFunc)
end

function LuaNFrame:HttpServerInitServer(serverType, port)
    if type(serverType) ~= "number" or type(port) ~= "number" then
        unilight.error("HttpServerInitServer failed, port is not number:"..port)
    end

    self.httpServerModule:InitServer(port)
end

function LuaNFrame:HttpServerResponseMsg(serverType, req, strMsg, code, reason)
    if type(serverType) ~= "number" or type(strMsg) ~= "string" or type(code) ~= "number" or type(reason) ~= "string" then
        unilight.error("HttpServerResponseMsg failed")
    end

    self.httpServerModule:ResponseMsg(req, strMsg, code, reason)
end

--serverNetEventModule 注册服务器与服务器之间的网络回调，主要有连接回调，断线回调
--比如说，luaFuncStr格式：luaFuncStr（eMsgType nEvent, uint32_t unLinkId, NF_SHARE_PTR<NFServerData> pServerData）
--
function LuaNFrame:AddServerEventCallBack(eSourceType, eTargetType, luaFuncStr)
    self.serverNetEventModule:AddEventCallBack(eSourceType, eTargetType, luaFuncStr)
end

--执行函数, 函数被字符串表达出来
--比如说，要执行LoginModule.Init函数，
--LuaNFrame.RunStringFunction("LoginModule.Init")
function LuaNFrame.RunStringFunction(strFunction,...)
    local v = _G;
    for w in string.gmatch(strFunction,"[%[%]%w_\"]+") do
      local index = string.find(w, "%[");
      if index == nil then
          v = v[w]
          if v == nil then
            break
          end
      else
          local key = string.match(w, "([%w_]+)%[")
          if key == nil then
              return;
          else
              v = v[key]
              for val in string.gmatch(w, "%[[\"%w_]+%]") do
                  local value = string.match(val, "%[([\"%w_]+)%]")
                  local value_str = string.match(value,"\"([%w_]+)\"");
                  if value_str ~= nil then
                      v = v[value_str];
                  else
                      local value_num = tonumber(value);
                      if value_num ~= nil then
                          v = v[value_num];
                      else
                        LuaNFrame:error("strFunction:", strFunction, " is not a function");
                      end
                  end
              end
          end
      end
    end
    if type(v) == "function" then
      return v(...);
    else
        LuaNFrame:error(strFunction .. " is not function");
    end
  end
