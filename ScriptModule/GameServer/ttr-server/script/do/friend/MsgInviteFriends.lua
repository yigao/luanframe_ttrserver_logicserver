

-- 获取玩家邀请到的好友信息
Net.CmdGetInviteFriendInfoCmd_C = function(cmd, laccount)
    local uid = laccount.Id

    if cmd.data == nil then
        cmd.data = {}
    end
    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdGetInviteFriendInfoCmd_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

-- 获取5人领取奖励
Net.CmdGetAskFriendFiveReward_C = function(cmd, laccount)
    local uid = laccount.Id

    if cmd.data == nil then
        cmd.data = {}
    end
    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdGetAskFriendFiveReward_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

Lby.CmdNotifyAddUserTravelHead_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

 --领取 邀请好友 获得的奖励
Net.CmdGetInviteFriendRewardCmd_C = function(cmd, laccount)
    local uid = laccount.Id

    if cmd.data == nil then
        cmd.data = {}
    end
    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdGetInviteFriendRewardCmd_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end


--领取 邀请好友进度 获得的奖励
Net.CmdGetProgressRewardCmd_C = function(cmd, laccount)
    local uid = laccount.Id

    if cmd.data == nil then
        cmd.data = {}
    end
    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdGetProgressRewardCmd_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end