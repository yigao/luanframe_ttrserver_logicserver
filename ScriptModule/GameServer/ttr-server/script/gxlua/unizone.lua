unizone = unizone or {}
--[[区服务器链接进来的回调
    Zone.zone_connect = function(cmd, zonetask) 
        unilight.info("大厅服务器回调：新的区连进来了 " .. zonetask.GetGameId() .. ":" .. zonetask.GetZoneId())
    end 
--]]

--[[区服务器断开的回调
    Zone.zone_disconnect = function(cmd, zonetask) 
        unilight.info("大厅服务器回调：区掉线了了 " .. zonetask.GetGameId() .. ":" .. zonetask.GetZoneId())
    end 
--]]
--
--[[区服务器属性变化
Zone.zone_change_props = function(cmd, zonetask)
    unilight.info("-----" .. cmd.GetMaxonlinenum() .. "" .. zonetask.GetGameId())
    unilight.info("-----" .. cmd.GetPriority() .. "" .. zonetask.GetZoneId())
end
--]]
--
---[[获取某个区的zonetask
unizone.getzonetaskbygameidzonid = function(gameid, zoneid)
    local zonetask = go.zonemgr.GetZoneTaskByGameIdZoneId(gameid, zoneid)
    if zonetask == nil then
        unilight.error("get zonetask error " .. gameid .."  "..zoneid)
        return nil 
    end
    return zonetask
end
--]]

--[[主动向某个区发送消息
    local zonetask = unizone.getzonetaskbygameidzoneid(1000, 301)
    if zonetask == nil then
        return 
    end
    local req = {
        ["do"] = "Cmd.RequestUserinfoLobbyCmd_C",
        ["data"] = {
            uid = 10000,
        },
    }
    unilight.success(zonetask, req)
--]]
