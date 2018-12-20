require "script/gxlua/unilight"
require "script/gxlua/unitcp"

print(_VERSION)

if Do == nil then Do = {} end

--breakSocketHandle,debugXpCall = require("LuaDebug")("localhost",7003)

local function init()
	for _,file in pairs(unilight.tablefiles()) do
		unilight.debug("正在加载脚本:"..file)
		dofile(file)
	end
	dofile("script/gxlua/class.lua")
	for _,file in pairs(unilight.scriptfiles()) do
		unilight.debug("正在加载脚本:"..file)
		dofile(file)
	end
	-----------------------------------------------
	-- 覆盖unilight.lua中的默认实现 说明
	-- 1. 默认有两种发送方式sendLuaProto和sendJSStr
	-- 2. 默认采用了encode_repair() 将k统一为string
	-----------------------------------------------
	unilight.response = function(w, req)
		req.st = os.time()
		local s = table2json(req)
		w.SendString(s)
		unilight.debug("[send] " .. s)
	end
    Zone = Zone or {}
    Zone.zone_connect = function(cmd, zonetask) 

    end 

    Zone.zone_disconnect = function(cmd, zonetask) 

    end 

    Zone.zone_change_props = function(cmd, zonetask)

    end

    --停机存档
	Server.ServerStop = function()
		UserInfo.SaveUserInfoToDB()
		unilight.info("Server.ServerStop:停机数据处理完成")
	end

	unitimer.init(25)
	unilight.addtimer("UserInfo.Update", 1)

	-- 当tcp上线时
	Tcp.account_connect = function(laccount)
		UserInfo.Connected(laccount.Id)
	end

	-- 当tcp掉线时
	Tcp.account_disconnect = function(laccount)
		UserInfo.Disconnected(laccount.Id)
	end

	Tcp.reconnect_login_ok = function(laccount)
		UserInfo.ReconnectLoginOk(laccount)
	end
	--unilight.addtimer("BreakUpdate", 1)
end

init()
