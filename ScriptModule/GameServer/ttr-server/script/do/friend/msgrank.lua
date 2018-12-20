Net.CmdReqGetWorldRankListInfo_C = function(cmd, laccount)
    local uid = laccount.Id

    if cmd.data == nil then
        cmd.data = {}
    end
    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdReqGetWorldRankListInfo_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end