function Net.CmdMsgPullCmd_C(cmd, laccount)
    local uid = laccount.Id

    if cmd.data == nil then
        cmd.data = {}
    end
    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdMsgPullCmd_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

function Net.CmdMsgSkipCmd_C(cmd, laccount)
    local uid = laccount.Id

    if cmd.data == nil then
        cmd.data = {}
    end
    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdMsgSkipCmd_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

Lby.CmdMsgNewCmd_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end