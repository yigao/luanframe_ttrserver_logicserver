unilobby = unilobby or {}


--逻辑服发送消息给中心服
function unilobby.SendCmdToLobby(doinfo,data,no_log,lobby,lobbyid)
    local send = {}
    send["do"] = doinfo
    send["data"] = data
    local s = table2json(send)
    TcpClient.sendJsonMsgByServerType(NF_SERVER_TYPES.NF_ST_WORLD, s)
    if not no_log then
        if doinfo ~= "Cmd.UserUpdate_C" then
            unilight.debug("SendCmdToLobby:" .. s)
        end
    end
end

--大厅服务器链接进来的回调
Lby.lobby_connect = function(cmd, lobbytask) 
    unilight.info("区服务器回调：新的大厅链接成功 " .. lobbytask.GetGameId() .. ":" .. lobbytask.GetZoneId())

    --测试给lobby服务器发送消息
    local req = {
        ["do"] = "Cmd.TestZoneConnectSendMsg_S",
        ["data"] = {
            resultCode   = 1, 
            desc = "ok"
        }

    }
    unilight.success(lobbytask, req)
end 
--]]

--大厅服务器断开的回调
Lby.lobby_disconnect = function(cmd, lobbytask) 
    unilight.info("区服务器回调：与大厅失联了" .. lobbytask.GetGameId() .. ":" .. lobbytask.GetZoneId())
end
