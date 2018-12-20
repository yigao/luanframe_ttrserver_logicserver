-- json
dofile("script/gxlua/protobuf.lua")
pb = require "protobuf"

json = cjson.new()

--WHJ获得debug级别

--WHJ替换系统时间
--获取秒级时间戳
os.time = go.luatime
--获取毫秒级时间戳
os.msectime = go.systime.Msec
--获取纳秒级别的时间辍
os.nsectime = go.systime.Nsec

os.unilighttime = go.luatime
os.unilighmsecttime = go.systime.Msec

unilight = unilight or {}
local goversion = nil
local mahjong_new = nil
unilight.mahjong_new = function()
	if not mahjong_new then
		mahjong_new = go.config().GetConfigInt("mahjong_new")
	end
	return mahjong_new
end
unilight.goversion = function()
	if not goversion then
		goversion = go.version
	end
end
local gameid = 0
unilight.getgameid = function()
	if gameid == 0 then
		gameid = go.gamezone.Gameid
	end
	return gameid
end
local zoneid = 0
unilight.getzoneid = function()
	if zoneid == 0 then
		zoneid = go.gamezone.Zoneid
	end
	return zoneid
end

Do = Do or {}
LoginClientTask = LoginClientTask or {}

unilight.getdebuglevel = function()
	return go.config().GetConfigInt("debug_level")
end

unilight.getdebuguser = function()
	return go.config().GetConfigStr("debug_user")
end

gcinfo = function(s)
	local collectBefore = collectgarbage("count")
	collectgarbage("collect")
	local collectEnd = collectgarbage("count")
	unilight.info("luaCollectBefore:"  .. collectBefore .. "  luaCollectEnd: " .. collectEnd)
    return collectBefore - collectEnd
end
-- 聊天
Chat = Chat or {}

Chat.UniPmdCommonChatUserPmd_CS = function(info, laccount)
	if Chat.PmdCommonChatUserPmd_CS ~= nil then
		local res = Chat.PmdCommonChatUserPmd_CS(info, laccount)
		if type(res) == "string" then
			info = res
		end
	end
   return info 
end

Chat.UniPmdPrivateChatUserPmd_CS = function(info, laccount)
	if Chat.PmdPrivateChatUserPmd_CS ~= nil then
		local res = Chat.PmdPrivateChatUserPmd_CS(info, laccount)
		if type(res) == "string" then
			info = res
		end
	end
   return info
end

-- 房间函数
Room = Room or {}

--Room.CaculateResut = function(data, room)
--	unilight.info("需要完成函数: Room.CaculateResut")
--end

--[[
功能：处理公聊消息
参数：
	info: string, 返回的时候也必须是string，具体自行组装
实例：
Chat.PmdCommonChatUserPmd_CS = function(info, laccount)
	unilight.info(info)
   return info
end
]]
--[[
功能：处理私聊消息
参数：
	info: string, 返回的时候也必须是string，具体自行组装
实例：
Chat.PmdPrivateChatUserPmd_CS = function(info, laccount)
	info = info .. "UniprivateChat"
	unilight.info(info)
   return info
end
]] 

--[[
功能：构建proto结构消息 并转发指定服务器
参数： *包头.消息名, json格式proto数据, 目标服务器
       指定目标服务器可选 MS（Monitor) NS (Name) LS(Login) GS(Gateway)
实例:
local msg = {
		data = {
			userid 		= laccount.Id,
			username 	= userinfo.name ,
			accountname = laccount.JsMessage.GetAccountname(),
			accountid 	= laccount.JsMessage.GetAccountid(),
			platid      = laccount.JsMessage.GetPlatid(),
		},
		oldlevel 	= oldlev,
		newlevel 	= newlev,
		leveltime 	= costtime,
	}
	local ret = go.buildProtoFwdServer("*Smd.LevelUpUserDataMonotorSmd_C", table2json(msg), "MS")
-]]

-- constants --
unilight.reloadfile = function()
	dofile("reload.lua.tmp")
end
unilight.version = function() return 60 end

unilight.SUCCESS = "0"
unilight.DB_ERROR = "2"
unilight.SCRIPT_ERROR = "4"

unilight.RETHINKDB = nil
unilight.MYSQLDB = nil

-- timezone offset --

unilight.tzoffset = function()
	return go.timezone.Offset
end

-- timer & clocker --
unilight.stoptimer = function(timer)
	if timer == nil then
		return true
	end
	return timer.Stop()
end
--function testtimer(text,timer)
--	unilight.debug("testtimer:"..text)
--	timer.Stop()
--end
--每嗝1秒的定时器示例
--unilight.addtimer("testtimer",1,"wanghaijun")
unilight.addtimer = function(name, sec, ...)
	return go.addTimer(name, sec, ...)
end

--每嗝1毫秒的定时器示例
--unilight.addtimer("testtimer",1,"wanghaijun")
unilight.addtimermsec = function(name, msec, ...)
	return go.addTimerMsec(name, msec, ...)
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
unilight.addclocker = function(name, sec, intervalSec, ...)
	return go.addClocker(name, sec,intervalSec, ...)
end
--关于日历
--function testcalender(text,clocker)
--	unilight.debug("testcalender:"..text)
--  clocker.Stop()
--unilight.addcalender("testcalender" , "2015-09-10 06:05:00","addcalender")
unilight.addcalender = function(name, interval, ...)
	return go.addCalender(name,interval, ...)
end
 
-- 当一个http玩家下线时，也设了一个回调
--[[
	local loginTime = laccount.LoginTime
	local logoutTime = os.time()
]]
if Cmd == nil then Cmd = {} end
Cmd.HttpAccountLogout = function(laccount)
	local uid = tostring(laccount.Id)
	local cdata = mongo_data_cache[uid]
	if cdata ~= nil and cdata.updatetime ~= 0 then
		--unilight.info("存档优化 执行 下线补档")
		unilight.savedata("data", cdata.data,true)
	end
end

-- 推送给google服务器消息实例
--[[
调用：
	go.accountmgr.PushMsgToGoogle(platid uint32, msgid uint32, tokens []string, title, message, extdata string)
返回：
	有类类似于支付
	LoginClientTask.PushMsgReturnSdkPmd_S = function(task, cmd)
		local msgId = cmd.GetMsgid()
		local ret = cmd.GetRet()
		local retdesc = cmd.GetRetdesc()
	end
]]
unilight.tablefiles = function()
	return luar.slice2table(go.getLuaFiles(go.tablePath))
end

unilight.pbfiles = function()
	return luar.slice2table(go.getLuaFiles(go.pbPath))
end

unilight.scriptfiles = function()
	return luar.slice2table(go.getLuaFiles(go.scriptPath))
end

-- log --

unilight.debug = function(...)
	go.logging.Debug(...)
end

unilight.info = function(...)
	go.logging.Info(...)
end

unilight.warn = function(...)
	go.logging.Warning(...)
end

unilight.error = function(...)
	local arg = {...}
	if next(arg) == nil then
		unilight.error(debug.traceback())
	end
	go.logging.Error(...)
end

--堆栈打印
unilight.stack = function(...)
	unilight.error(... , go.stacktrace())
end

-- 覆盖全局print,方便开发
_G._print = _G.print
_G.print = unilight.debug

-- request --

unilight.getreq = function(jsreq)
	if type(jsreq) == "table" then
		return jsreq
	end
	if type(jsreq) == "userdata" then
		go.logging.Error("unilight.getreq err")
		return ""
	end
	if jsreq == "" or (string.sub(jsreq,1,1) ~="{" and string.sub(jsreq,1,1) ~="[") then
		go.logging.Error("unilight.getreq err:"..jsreq)
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

unilight.broadcast = function(req)
	req.st = os.time() + unilight.tzoffset()
	local s = json.encode(req)
    local msgname = req["do"]
    local nu = unilight.getmsgnu(msgname)
    if nu ~= nil then 
        local msgname = req["do"]
        local msgdata = req["data"]
        msgdata.errno = nil
        local rawdata = pb.encode(msgname,msgdata)
        go.accountmgr.BroadcastLuaProtoRawdata(nu.bycmd, nu.byparam, rawdata)
    else
        go.accountmgr.BroadcastString(s)
    end
end

unilight.response = function(w, req)
	local s = json.encode(encode_repair(req))
    local msgname = req["do"]
    local nu = unilight.getmsgnu(msgname)
    if nu ~= nil then 
        local msgname = req["do"]
        local msgdata = req["data"]
        msgdata.errno = nil
        local rawdata = pb.encode(msgname,msgdata)
        w.SendLuaProtoRawdata(nu.bycmd, nu.byparam, rawdata)
	    unilight.debug("[proto send] " .. s)
        return true
    else
		req.st = os.time() + unilight.tzoffset()
		if w ~= nil then
			w.SendString(s)
			unilight.debug("[js send] " .. s)
		end
    end

	if req["do"] == "win-pve-battle" or req["do"] == "sweep-pve-battle" or req["do"] == "lose-pve-battle"  or req["do"] == "end-battle" then
		if req["data"]["userData"] ~= nil then
			local level = req["data"]["userData"].level
			local gold = req["data"]["userData"].gold
			local diamond = req["data"]["userData"].diamond
			local tmp = req["data"]["userData"]
			req["data"]["userData"] = {}
			req["data"]["userData"].level = level
			req["data"]["userData"].gold = gold
			req["data"]["userData"].diamond = diamond
			s = json.encode(encode_repair(req))
			unilight.debug("[send] " .. s)
			req["data"]["userData"] = tmp
			return 
		end
	elseif req["do"] == "get-activity-rank-list" then
		if req["data"] ~= nil then
			local errno = req["data"].errno
			local tmp = req["data"]
			req["data"] = {}
			req["data"].errno = errno
			s = json.encode(encode_repair(req))
			unilight.debug("[send] " .. s)
			req["data"] = tmp
			return 
		end
	end
end

-- rand --

-- 得到以时间作为前缀的随机字符串，并非标准GUID格式
unilight.getuuid = function()
	return go.rand.GetUUid()
end

-- 以时间为前缀的随机字符串，类似与36进制，但支持了大小写字母的伪62进制方式，可以指定字符长度，但是最少为9
unilight.getuuid62hex = function(n)
	n = tonumber(n)
	if n == nil then
		n = 9
	end
	return go.rand.GetUUid62Hex(n)
end

-- 产生指定个数的随机字节
unilight.getrandbytes = function(n)
	n = tonumber(n)
	if n == nil then
		return nil
	end
	if n>0 then
		return go.rand.RandBytes(n)
	end
	return nil	
end

-- 产生指定个数的随机字符
-- 算法实现上限定了n必须为偶数，且产生的字符只在[0-9a-f]范围内
unilight.getrandstring = function(n)
	n = tonumber(n)
	if n == nil then
		return nil
	end
	if n>0 and n%2==0 then
		return go.rand.RandString(n)
	end
	return nil	
end

-- 产生指定个数的随机字符
-- 算法实现上产生了[0~9a~zA~Z]范围内的指定长度的字符串
unilight.getrandstring2 = function(n)
	n = tonumber(n)
	if n == nil then
		return nil
	end
	if n>0 then
		return go.rand.RandString2(n)
	end
	return nil	
end

-- 从汉字转换成拼音
unilight.convertchinesetospell= function(chinese, splitflag)
    if type(chinese) ~= "string" or type(splitflag) ~= "string" then
        unilight.error("convertchinesetospell err type error ")
        return ""
    end
    return go.rand.ConvertChineseToSpell(chinese, splitflag)
end

-- 从汉字转换繁体汉字
unilight.convertchinesetotraditional = function(chinese)
    if type(chinese) ~= "string"  then
        unilight.error("convertchinesetotraditional err type error ")
        return ""
    end
    return go.rand.ConvertToTraditionalChinese(chinese)
end

-- crypto --

unilight.verifyRsa = function(publicKey, msg, sig)
	return go.crypto.VerifyRsa(publicKey, msg, sig)
end

-- 专用于http通信的简单加密
-- param: data 原文
-- param: sceretkey 密钥
-- return 密文
unilight.httpCryptoEncode = function(data, sceretkey)
	return go.crypto.HttpCryptoEncode(data, sceretkey)
end

-- 专用于http通信的简单解密
-- param: data 密文
-- param: sceretkey 密钥
-- return 原文
unilight.httpCryptoDecode = function(data, sceretkey)
	return go.crypto.HttpCryptoDecode(data, sceretkey)
end

-- helper --

unilight.repairslice = function(slice)
	local s = luar.slice2table(slice)
	local r = {}
	for i, d in ipairs(s) do r[i] = decode_repair(d) end
	return r
end

-- db --

unilight.rethinkdbready = function(handler)
	unilight.RETHINKDB = handler
	unilight.initrethinkdb()
	if type(Do.dbready) == "function" then
		Do.dbready()
	end
end

unilight.mysqldbready = function(handler)
	unilight.MYSQLDB = handler
	unilight.initmysqldb()
	if type(Do.dbready) == "function" then
		Do.dbready()
	end
end

unilight.mongodbready = function(handler)
	unilight.MONGODB = handler
	unilight.initmongodb()
	if type(Do.dbready) == "function" then
		Do.dbready()
	end
end

unilight.ismongodbinit = function()
    if unilight.MONGODB then
        return true
    end
    return false
end

unilight.redisdbready = function(handler)
	unilight.info("-------")
	unilight.REDISDB = handler
	unilight.initredisdb()
	-- 这里不需要去创建表
end

unilight.getserverlist = function(key)
    return go.getserverlist(key)
end
-- httpclient --
-- 发送无需关心返回的http请求
-- param: data json结构字符串
-- param: data example
-- {
-- 	"urlStr" : "http:\/\/s.notify.live.net", --URL地址
-- 	"heads" : {								 --头部信息
-- 		"X-WindowsPhone-Target" : "toast",
-- 		"NotificationClass" : "2"
-- 	},
-- 	"method" : "POST",						  --请求方式
-- 	"body" : "testBody"						  --需发送的数据
-- }
--
unilight.sendNoResponse = function(data)
	go.httpClient.SendNoResponse(data)
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
                
                local stT = os.msectime()
				local r0, r1 = handle(req,w)
                local endT = os.msectime()
                if endT - stT > 80 then
                    local msg=req["do"]
                    msg = msg or ""
                    unilight.error("NetMsgProcessTime:" .. endT-stT ..  " msgName:" .. msg) 
                end
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
-- GmCommand指令 --
if GmCommand == nil then GmCommand = {} end
GmCommand.LuaHelp  = function (account,params)
	unilight.debug("luagmhelp:".. params)
	uid = 0
	if account ~= nil then
		uid = account.Id
	end
	go.dogmfunc(uid,"help","")
end
--go.gmcommand.AddLuaCommand(GmCommand.LuaHelp,"luagmhelp","wanghaijun",true)
--go.dogmfunc(0,"help","")
--go.dogmfunc(0,"luagmhelp","")

-- Gm消息返回 --
if GmCmd == nil then GmCmd = {} end
Gm = {}
setmetatable(Gm,
{
	__index = GmCmd,
	__newindex = function(t, k, handle)
		if handle == nil then
			GmCmd[k] = nil
		else
			GmCmd[k] = function(w, ...)
				local req = {}
				local r0, r1 = handle(...)
				req.msgtype = "gmmessage"
				if w == nil then
					return r0							-- return r0 for server test
				elseif r0 == nil then
					return								-- return nil?
				elseif type(r0) == "table" then
					req.data = r0
					unilight.success(w, req)				-- return {data}
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
                if msgname ~= nil and 0 == w.GetMsgType() then
                    local data =  pb.decode(msgname, reqdata)
                    req = {
                        ["do"] = msgname, 
                        ["data"] = data,
                    }
                else
                    if reqdata ~= nil then
                        req = unilight.getreq(reqdata)
                    end
                end

                local stT = os.msectime()
				local r0, r1 = handle(req, w)
				req.msgtype = "lobbymessage"

                local endT = os.msectime()
                if endT - stT > 80 then
                    local msg=req["do"]
                    msg = msg or ""
                    unilight.error("NetMsgProcessTime:" .. endT-stT .. " msgName:" .. msg) 
                end
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
                if msgname ~= nil and 0 == w.GetMsgType() then
                    local data =  pb.decode(msgname, reqdata)
                    req = {
                        ["do"] = msgname, 
                        ["data"] = data,
                    }
			req.msgtype = "lobbymessage"
                else
                    if reqdata ~= nil and type(reqdata) == "string" then
                        req = unilight.getreq(reqdata)
			req.msgtype = "lobbymessage"
                    end
                end
                local stT = os.msectime()
				local r0, r1 = handle(req, w)

                local endT = os.msectime()
                if endT - stT > 80 then
                    local msg= req and req["do"]
                    msg = msg or ""
                    unilight.error("NetMsgProcessTime:" .. endT-stT ..  " msgName:" .. msg) 
                end

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
               
GmServer = GmServer or {}
GmSvr = GmSvr or {}
setmetatable(GmSvr,
{
    __index = GmServer,
    __newindex = function(t, k, handle)
        if handle == nil then
            GmServer[k] = nil
        else
            GmServer[k] = function(jsreq, w)
			jsreq = string.gsub(tostring(jsreq),"\\", "")
			jsreq = string.gsub(jsreq,"\"{", "{")
			jsreq = string.gsub(jsreq,"}\"", "}")
                local req = unilight.getreq(jsreq)
                local r0, r1 = handle(req, w)

                if w == nil then
                    unilight.error("unsupported w is null")
                    local s = json.encode((r0))
                    return s -- return r0 for server test
                elseif r0 == nil then
                    return nil
                else
                    local s = json.encode((r0))
					unilight.info("send:" ..s)
                    return s
                end
            end
        end
    end
})

-- 处理http的回调
HttpRes = HttpRes or {}
Http = Http or {} 
setmetatable(Http,
{
	__index = HttpRes,
	__newindex = function(t, k, handle)
		if handle == nil then
			HttpRes[k] = nil
		else
			HttpRes[k] = function(jsres, jspara)
				local res = unilight.getreq(jsres)
				local r0, r1 = handle(res, jspara)	
				return r0
			end
		end
	end
})
	
-- http请求大厅登陆消息
Net.PmdWebSocketForwardUserPmd_C = function (cmd, account)
	local res = {["data"] = {}}
	res["do"] = "Pmd.WebSocketForwardUserPmd_S"
	res.data.gameid = cmd.gameid
	res.data.zoneid = cmd.zoneid
	res.data.accountid = cmd.data.accountid
	res.data.logintempid = 0
	res.data.tokenid = go.time.Msec()
	res.data.gatewayurl = account.GetGetwayUrl()
	res.data.jsongatewayurl = account.GetGetwayUrl() .. "/json"
	res.data.gatewayurltcp = account.GetGetwayUrlTcp()
	account.ReturnLoginLobby(res.data.tokenid)
	return res
end

--重新加载数据
function KillHup()
	if MyKillHup then
		MyKillHup()
	else
		dofile("table/TableProtectUser.lua")
	end
	unilight.debug("KillHup ok:")
end
