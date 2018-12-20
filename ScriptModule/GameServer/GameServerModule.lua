GameServerModule = {}

Tcp = Tcp or {}

GameServerModule.gameserver_linkid = 0

StartOver = StartOver or function()

end

InitTimer = InitTimer or function()
    -- body
end

UserInfo = UserInfo or {}

UserInfo.Update = UserInfo.Update or function()

end

function GameServerModule.Init()
    unilight.initmongodb('mongodb://14.17.104.12:28900', "ttr-1")
    Do.dbready()
    
    TcpClient.addRecvCallBack(NF_SERVER_TYPES.NF_ST_PROXY, 0, "GameServerModule.NetServerRecvHandleJson")
    TcpClient.addRecvCallBack(NF_SERVER_TYPES.NF_ST_WORLD, 0, "GameServerModule.WorldServerRecvHandleJson")
    TcpClient.addEventCallBack(NF_SERVER_TYPES.NF_ST_WORLD, "GameServerModule.WorldServerNetEvent")

    unilight.addtimer("UserInfo.Update", 1)

    unilight.response = function(w, req)
		req.st = os.time()
		local s = table2json(req)
        w.SendString(s)
        
        if type(req["do"]) == "string" then
            if req["do"] == "Cmd.SendUserMoneyCmd_S" then
                return
            elseif req["do"] == "Cmd.UserTravelAngerUpdate_S" then
                return
            elseif req["do"] == "Cmd.Ping_S" then
                return
            end
        end
		unilight.debug("[send] " .. s)
    end
    
    -- 当tcp上线时
	Tcp.account_connect = function(laccount)
		UserInfo.Connected(laccount.Id)
	end

	-- 当tcp掉线时
	Tcp.account_disconnect = function(laccount)
		UserInfo.Disconnected(laccount.Id)
	end

	Tcp.reconnect_login_ok = function(laccount)
		unilight.debug("游戏玩家断线重连了。。。。。。。。。。。。。")
        UserInfo.ReconnectLoginOk(laccount)
    end
    
    --StartOver()
    --初始化玩家系统
    if UserInfo ~= nil then
        UserInfo.Init()
    end

    InitTimer()
end

GameServerModule.LobbyTask = {}
function GameServerModule.LobbyTask.GetGameId()
    return 0
end

function GameServerModule.LobbyTask.GetZoneId()
    return 0
end

function GameServerModule.LobbyTask.SendString(s)
    TcpClient.sendJsonMsgByServerType(NF_SERVER_TYPES.NF_ST_WORLD, s)
end

function GameServerModule.WorldServerNetEvent(nEvent, unLinkId)
    local cmd = {}
    if nEvent == NF_MSG_TYPE.eMsgType_CONNECTED then
        Lby.lobby_connect(cmd,GameServerModule.LobbyTask)
    end
    if nEvent == NF_MSG_TYPE.eMsgType_DISCONNECTED then
        Lby.lobby_disconnect(cmd, GameServerModule.LobbyTask)
    end
end

--特殊协议
function GameServerModule.WorldServerRecvHandleJson(unLinkId, valueId, nMsgId, strMsg)
    unilight.debug(tostring(valueId) .. " | recv world msg |" .. strMsg)
    local table_msg = json2table(strMsg)
    --协议规则
    if table_msg ~= nil then
        local cmd = table_msg["do"]
        if type(cmd) == "string" then
            local i, j = string.find(cmd, "Cmd.")
            local strcmd = string.sub(cmd, j+1, -1)
            if strcmd ~= "" then
                strcmd = "Cmd" .. strcmd
                if type(Lby[strcmd]) == "function" then
                    Lby[strcmd](table_msg, GameServerModule.LobbyTask)
                end
            end
        end
    end
    -- body
end

--特殊协议
function GameServerModule.NetServerRecvHandleJson(unLinkId, valueId, nMsgId, strMsg) 
    local table_msg = json2table(strMsg)
    if type(table_msg["do"]) == "string" then
        if table_msg["do"] ~= "Cmd.Ping_C" then
            unilight.debug(tostring(valueId) .. " | recv msg |" .. strMsg)
        end
    end
    --协议规则
    if table_msg ~= nil then
        local cmd = table_msg["do"]
        if type(cmd) == "string" then
            local i, j = string.find(cmd, "Cmd.")
            local strcmd = string.sub(cmd, j+1, -1)
            if strcmd ~= "" then
                strcmd = "Cmd" .. strcmd
                if type(Net[strcmd]) == "function" then
                    local laccount = go.roomusermgr.GetRoomUserById(valueId)
                    if laccount ~= nil then
                        Net[strcmd](table_msg, laccount)
                    end
                end
            end
        end
    end
    -- body
end

function GameServerModule.AfterInit()

end


function GameServerModule.Execute()

end

function GameServerModule.BeforeShut()

end

function GameServerModule.Shut()

end

--用来测试lobby服务器发消息过来
Lby.CmdTestLobbySenMsgCmd_S = function(cmd,lobbyClientTask)
	unilight.debug("Lby.TestLobbySenMsgCmd_S...........");

	local data = {}
	unilobby.SendCmdToLobby("Cmd.SendMsgToLobby2_S", data)
end