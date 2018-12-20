-- json
json = cjson.new()

Do = Do or {}

unilight = unilight or {}

-- Net.*简化Do.*的消息处理，可直接收发lua table消息 --
Net = Net or {}

function unilight.init(pluginManager)
	LuaNFrame:init(pluginManager)
end

--执行加载函数
function unilight.load_script_file()
	LuaNFrame:load_script_file()
end

function unilight.InsertLoadFunc(func)
    LuaNFrame:InsertLoadFunc(func)
end

--添加服务器秒定时器
function unilight.addtimer(luaFunc, sec, ...)
	local param_table = {...}
	local json_param = json.encode(param_table)
	local timerId = LuaNFrame:AddTimer(luaFunc, sec*1000, json_param)
	local timer = {}
	timer.Stop = function()
		LuaNFrame:StopTimer(timerId)
	end
	return timer
end

--每嗝1毫秒的定时器示例
--unilight.addtimer("testtimer",1,"wanghaijun")
function unilight.addtimermsec(luaFunc, msec, ...)
	local param_table = {...}
	local json_param = json.encode(param_table)
	local timerId = LuaNFrame:AddTimer(luaFunc, msec, json_param)
	local timer = {}
	timer.Stop = function()
		LuaNFrame:StopTimer(timerId)
	end
	return timer
end

--停止服务器定时器
function unilight.stoptimer(timer)
	if timer == nil then
		return true
	end
	return timer.Stop()
end

-- 关于闹钟实例：
--  原理解释：
	-- intervalSec 表示从1970年开始到现在，把所有的时间以intervalSec为单位划分用 “---”表示
	-- sec 表示，在intervalSec这个单位时间段内需要触发闹钟的时刻用"*"表示
	-- 所以要求sec < intervalSec
	-- 图示：1970开始｜-*---｜-*--｜-*--|.......|-*--|now
-- 实例：
-- （1）每隔物理10秒的第1秒时钟实例 ：unilight.addclocker("testclocker",1,10,"wanghaijun");
	--function testclocker(text,clocker)
	--	unilight.debug("testclocker:"..text)
	--  clocker.Stop()
	--end
--  (2) 每天上午8点触发闹钟实例：unilight.addclocker("OnClocker", 8*3600, 24*3600, "wanghaijun");
	--function OnClocker(text,clocker)
	--	unilight.debug("每日触发实列")
	--end
-- (3) 每周（7*24*3600）的第34个小时触发闹钟：unilight.addclocker("OnClocker", 34*3600, 7*24*3600, "wanghaijun");
-- 
function unilight.addclocker(luaFunc, sec, intervalSec, ...)
	local param_table = {...}
	local json_param = json.encode(param_table)
	local timerId = LuaNFrame:AddClocker(luaFunc, sec, intervalSec , json_param)
	local timer = {}
	timer.Stop = function()
		LuaNFrame:StopClocker(timerId)
	end
	
	return timer
end

--关于日历
--function testcalender(text,clocker)
--	unilight.debug("testcalender:"..text)
--  clocker.Stop()
--unilight.addcalender("testcalender" , "2015-09-10 06:05:00","addcalender")
unilight.addcalender = function(name, interval, ...)
	return go.addCalender(name,interval, ...)
end

--创建全局唯一的UUID
function unilight.GetUUID()
    return LuaNFrame:GetUUID()
end

--获得服务器开启时间，单位ms
function unilight.GetInitTime()
    return LuaNFrame:GetInitTime()
end

--获得服务器当前时间，单位ms
function unilight.GetNowTime()
    return LuaNFrame:GetNowTime()
end

--通过字符串获得MD5, 返回MD5字符串
function unilight.GetMD5(str)
    return LuaNFrame:GetMD5(str)
end

--通过字符串获得对应的CRC32, 返回数字
function unilight.GetCRC32(str)
    return LuaNFrame:GetCRC32(str)
end

--通过字符串获得对应的CRC16, 返回数字
function unilight.GetCRC16(str)
    return LuaNFrame:GetCRC16(str)
end

--通过字符串获得对应的Base64Encode, 返回字符串
function unilight.Base64Encode(str)
    return LuaNFrame:Base64Encode(str)
end

--通过字符串获得对应的Base64Decode, 返回字符串
function unilight.Base64Decode(str)
    return LuaNFrame:Base64Decode(str)
end

--设置LOG等级
function unilight.SetLogLevel(level)
    LuaNFrame:SetLogLevel(level)
end

--设置LOG立马刷新等级
function unilight.SetFlushOn(level)
    LuaNFrame:SetFlushOn(level)
end

unilight.debug = function(...)
	LuaNFrame:debug(...)
end

unilight.info = function(...)
	LuaNFrame:info(...)
end

unilight.warn = function(...)
	LuaNFrame:warn(...)
end

unilight.error = function(...)
    LuaNFrame:error(...)
end

unilight.SUCCESS = "0"
unilight.DB_ERROR = "2"
unilight.SCRIPT_ERROR = "4"

function unilight.getdebuglevel()
	return 0
end


--特殊协议
function unilight.NetServerRecvHandleJson(unLinkId, valueId, nMsgId, strMsg)
    unilight.debug("unLinkId:" .. unLinkId .. " valueId:" .. valueId .. " nMsgId:" .. nMsgId .. " strMsg:" .. strMsg)
    local table_msg = json2table(strMsg)
    --协议规则
    if table_msg ~= nil then
        local cmd = table_msg["do"]
        if type(cmd) == "string" then
            local i, j = string.find(cmd, "Cmd.")
            local strcmd = string.sub(cmd, j+1, -1)
            if strcmd ~= "" then
                strcmd = "Cmd" .. strcmd
				if type(Net[strcmd]) == "function" then
					local laccount = {}
					laccount.Id = valueId
					laccount.unLinkId = unLinkId
					laccount.SendString = TcpServer.sendJsonMsg
                    Net[strcmd](table_msg, laccount)
                end
            end
        end
    end
    -- body
end

-- request --

unilight.getreq = function(jsreq)
	if type(jsreq) == "table" then
		return jsreq
	end
	if type(jsreq) == "userdata" then
		unilight.error("unilight.getreq err")
		return ""
	end
	if jsreq == "" or (string.sub(jsreq,1,1) ~="{" and string.sub(jsreq,1,1) ~="[") then
		unilight.error("unilight.getreq err:"..jsreq)
		return {err=jsreq,}
	else
		return decode_repair(json.decode(jsreq))
	end
end

-- response --

unilight.success = function(w, req)
	req.errno = unilight.SUCCESS
	if req.data ~= nil then
		req.data.errno = unilight.SUCCESS
	end
	unilight.response(w, req)
end

unilight.faildb = function(w, req)
	req.errno = unilight.DB_ERROR
	unilight.response(w, req)
end

unilight.fail = function(w, req, errno, reason)
	if errno == nil or errno == unilight.SUCCESS then
		errno = "call unilight.fail with invalid errno"
	end
	req.data.errno = errno
	if reason ~= nil then
		req.data.reason = reason
	end
	unilight.response(w, req)
end

unilight.scripterror = function(w, err)
	unilight.error(err)
	unilight.response(w, {errno=unilight.SCRIPT_ERROR, data=nil})
end

unilight.response = function(w, req)
	local s = json.encode(encode_repair(req))
	w.SendString(s)
end

-- Net.*简化Do.*的消息处理，可直接收发lua table消息 --
Net = {}
setmetatable(Net,
{
	__index = Do,
	__newindex = function(t, k, handle)
		if handle == nil then
			Do[k] = nil
		else
			Do[k] = function(reqdata, w, msgname)
                local req = {}
                req = unilight.getreq(reqdata)
                
				local r0, r1 = handle(req,w)
				if w == nil then
					unilight.error("unsupported w is null")
					return r0							-- return r0 for server test
				elseif r0 == nil then
					--unilight.info("return is nil")
					--unilight.success(w, req)			-- return {data} by zwl
					return 
				elseif type(r0) == "table" then
					unilight.success(w, r0)				-- return {data}
				elseif r0 == unilight.DB_ERROR then
					unilight.faildb(w, r1 or {})		-- return unilight.DB_ERROR, {data}?
				elseif r0 == unilight.SCRIPT_ERROR then
					unilight.scripterror(w, r1 or {})	-- return unilight.SCRIPT_ERROR, {data}?
				elseif r0 == unilight.SUCCESS then
					unilight.success(w, r1 or {}) 		-- return unilight.SUCCESS, {data}?
				elseif type(r0) == "string" then
					unilight.fail(w, req, r0, r1) 		-- return "errno", "reason"
				else
					unilight.error("unsupported return type")
				end
			end
		end
	end,
})

-- 收到大厅的回调
Lobby = Lobby or {}
Lby = Lby or {}
setmetatable(Lby,
{
	__index = Lobby,
	__newindex = function(t, k, handle)
		if handle == nil then
			Lobby[k] = nil
		else
			Lobby[k] = function(reqdata, w, msgname)
                local req = {}

				if reqdata ~= nil then
					req = unilight.getreq(reqdata)
				end

				local r0, r1 = handle(req, w)
				req.msgtype = "lobbymessage"

				if w == nil then
					return r0							-- return r0 for server test
				elseif r0 == nil then
					return								-- return nil?
				elseif type(r0) == "table" then
					unilight.success(w, r0)				-- return {data}
				elseif r0 == unilight.DB_ERROR then
					unilight.faildb(w, r1 or {})		-- return unilight.DB_ERROR, {data}?
				elseif r0 == unilight.SCRIPT_ERROR then
					unilight.scripterror(w, r1 or {})	-- return unilight.SCRIPT_ERROR, {data}?
				elseif r0 == unilight.SUCCESS then
					unilight.success(w, r1 or {}) 		-- return unilight.SUCCESS, {data}?
				end
			end
		end
	end,
})
 
-- 收到区服务器的回调
Zone = Zone or {}
ZoneServer = ZoneServer or {}
setmetatable(Zone,
{
	__index = ZoneServer,
	__newindex = function(t, k, handle)
		if handle == nil then
			ZoneServer[k] = nil
		else
			ZoneServer[k] = function(reqdata, w, msgname)
                local req = {}
                local req = reqdata 

				if reqdata ~= nil and type(reqdata) == "string" then
					req = unilight.getreq(reqdata)
					req.msgtype = "lobbymessage"
				end
                
				local r0, r1 = handle(req, w)

				--req.msgtype = "lobbymessage"
				if w == nil then
					return r0							-- return r0 for server test
				elseif r0 == nil then
					return								-- return nil?
				elseif type(r0) == "table" then
					unilight.success(w, r0)				-- return {data}
				elseif r0 == unilight.DB_ERROR then
					unilight.faildb(w, r1 or {})		-- return unilight.DB_ERROR, {data}?
				elseif r0 == unilight.SCRIPT_ERROR then
					unilight.scripterror(w, r1 or {})	-- return unilight.SCRIPT_ERROR, {data}?
				elseif r0 == unilight.SUCCESS then
					unilight.success(w, r1 or {}) 		-- return unilight.SUCCESS, {data}?
				end
			end
		end
	end,
})
