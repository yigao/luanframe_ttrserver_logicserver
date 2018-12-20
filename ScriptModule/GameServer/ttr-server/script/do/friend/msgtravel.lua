

-- 客户端获得旅行团信息
Net.CmdGetUserTravelInfo_C = function(cmd, laccount)
    local uid = laccount.Id

    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdGetUserTravelInfo_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

-- 打开好友雇佣界面信息
Net.CmdGetTravelEmployFriend_C = function(cmd, laccount)
    local uid = laccount.Id

    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdGetTravelEmployFriend_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

-- 打开推荐雇佣界面信息
Net.CmdGetTravelEmployRecommend_C = function(cmd, laccount)
    local uid = laccount.Id

    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdGetTravelEmployRecommend_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

-- 雇佣或抓捕玩家
Net.CmdEmployFriendToTravel_C = function(cmd, laccount)
    local uid = laccount.Id

    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    cmd.data.cmd_uid = uid
    cmd.data.cur_money = userInfo.money
    cmd.data.cur_diamond = userInfo.diamond
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdEmployFriendToTravel_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

Lby.CmdNotifyUserBuyShieldCount_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

Lby.CmdNotifyUserTravelCapture_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

-- 清楚雇佣CD时间
Net.CmdClearEmployFriendCD_C = function(cmd, laccount)
    local uid = laccount.Id

    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    cmd.data.cmd_uid = uid
    cmd.data.cur_money = userInfo.money
    cmd.data.cur_diamond = userInfo.diamond
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdClearEmployFriendCD_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

-- 解除雇佣关系
Net.CmdRescissionEmployFriendShip_C = function(cmd, laccount)
    local uid = laccount.Id

    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdRescissionEmployFriendShip_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

-- 团长升级
Net.CmdUserTravelLevelUp_C = function(cmd, laccount)
    local uid = laccount.Id

    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    cmd.data.cmd_uid = uid
    cmd.data.cur_money = userInfo.money
    cmd.data.cur_diamond = userInfo.diamond
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdUserTravelLevelUp_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end


--更改玩家的旅行团头像
Net.CmdChangeUserTravelHead_C = function(cmd, laccount)
    local uid = laccount.Id

    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdChangeUserTravelHead_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

--怒气值满了，点击
Net.CmdReleaseTravelAnger_C = function(cmd, laccount)
    local uid = laccount.Id

    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdReleaseTravelAnger_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end


--怒气值满了，点击后看视屏回调
Net.CmdReleaseAngerSeeSceen_C = function(cmd, laccount)
    local uid = laccount.Id

    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdReleaseAngerSeeSceen_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

