unilobby = unilobby or {}


--逻辑服发送消息给中心服
function unilobby.SendCmdToLobby(doinfo,data,no_log,lobby,lobbyid)
    --local lobby = nil--go.lobby --这个go.lobby不能用了,WHJ
    lobby = lobby or unilobby.getlobbytask(lobbyid or 0)
    if lobby == nil then
        return false
    end
    local send = {}
    send["do"] = doinfo
    send["data"] = data
    local s = table2json(send)
    local ret = lobby.SendString(s)
    if not no_log then
        unilight.debug("SendCmdToLobby:" .. s)
    end
    return ret
end

--大厅服务器链接进来的回调
Lby.lobby_connect = function(cmd, lobbytask) 
    unilight.info("区服务器回调：新的大厅链接成功 " .. lobbytask.GetGameId() .. ":" .. lobbytask.GetZoneId())
end 
--]]

--大厅服务器断开的回调
Lby.lobby_disconnect = function(cmd, lobbytask) 
    unilight.info("区服务器回调：与大厅失联了" .. lobbytask.GetGameId() .. ":" .. lobbytask.GetZoneId())
end 


---[[获取大厅的lobbytask
unilobby.getlobbytask = function(id)
    id = id or 0
    return go.lobbymgr.GetLobbyClientTaskById(id)
end
--]]

unilobby.getzoneinfo = function()
    for i, v in pairs(go.gamezoneinfo) do
        unilight.info("gameid:" .. v.GetGameid() .. " zoneid: "..v.GetZoneid() .."  onlinenum: ".. v.GetOnlineNum() .."  maxonlinenum:".. v.GetMaxonlinenum() .. " Priority:"..v.GetPriority())
    end
    return go.gamezoneinfo
end
