go = go or {}
go.roomusermgr = {
    
}

function go.roomusermgr.GetRoomUserById(uid)
    local pluginManager = LuaNFrame:GetPluginManager()
    local gameClientModule = pluginManager:GetGameLogicModule()

    return gameClientModule:GetAccount(uid)
end