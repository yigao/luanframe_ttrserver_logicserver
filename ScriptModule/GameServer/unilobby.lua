unilobby = unilobby or {}
unilobby.lobbytaskMap = {}

function unilobby.GetLobby(lobbyid)
    if lobbyid == nil then
        for k, v in pairs(unilobby.lobbytaskMap) do
            if v ~= nil then
                return v
            end
        end
    end
    return unilobby.lobbytaskMap[lobbyid]
end

--逻辑服发送消息给中心服
function unilobby.SendCmdToLobby(doinfo,data,no_log,lobbyid)
    local send = {}
    send["do"] = doinfo
    send["data"] = data
    local s = table2json(send)

    local lobby = unilobby.GetLobby(lobbyid)

    if lobby ~= nil then
        lobby.SendString(s)
    end

    if not no_log then
        if doinfo ~= "Cmd.UserUpdate_C" then
            unilight.debug("SendCmdToLobby:" .. s)
        end
    end
end

--大厅服务器链接进来的回调
Lby.lobby_connect = function(cmd, lobbytask)
    unilobby.lobbytaskMap[lobbytask.UnlinkId] = lobbytask

    unilight.info("区服务器回调：新的大厅链接成功 " .. lobbytask.GetGameId() .. ":" .. lobbytask.GetZoneId())
end 
--]]

--大厅服务器断开的回调
Lby.lobby_disconnect = function(cmd, lobbytask) 
    unilobby.lobbytaskMap[lobbytask.UnlinkId] = nil
    unilight.info("区服务器回调：与大厅失联了" .. lobbytask.GetGameId() .. ":" .. lobbytask.GetZoneId())
end
