require "script/do/common/staticconst"

-- 邀请游戏，发送邀请你玩着游戏的玩家UID
Net.CmdBeAskedPlayGame_C = function(cmd, laccount)
    local uid = laccount.Id

    if cmd.data == nil then
        cmd.data = {}
    end
    cmd.data.cmd_uid = uid
	unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end


Lby.CmdBeAskedPlayGame_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

    
-- 客户端建号时发送QQ好友消息
Net.CmdSendUserQQFriendDataCmd_C = function(cmd, laccount)
    local uid = laccount.Id

    if cmd.data == nil then
        cmd.data = {}
    end
    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])

    local data = cmd["data"]
    UserInfo.UpdateQqData(uid, data.self_data.head, data.self_data.name, data.self_data.sex)
end

Lby.CmdSendUserQQFriendDataCmd_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

    
-- 获取玩家游戏好友信息
Net.CmdGetUserFriendDataCmd_C = function(cmd, laccount)
    local uid = laccount.Id

    if cmd.data == nil then
        cmd.data = {}
    end
    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdGetUserFriendDataCmd_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

--获得玩家被邀请为好友的列表
Net.CmdGetUserAskedAddFriends_C = function(cmd, laccount)
    local uid = laccount.Id

    if cmd.data == nil then
        cmd.data = {}
    end
    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdGetUserAskedAddFriends_S  = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

Lby.CmdSendReqBeAddFriendCmd_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

-- 发送好友请求
Net.CmdSendReqAddFriendCmd_C = function(cmd, laccount)
    local uid = laccount.Id

    if cmd.data == nil then
        cmd.data = {}
    end
    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdSendReqAddFriendCmd_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

Lby.CmdSendReqBeAddFriendCmd_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

-- 同意或拒绝好友请求
Net.CmdSendReqAgreeAddFriendCmd_C = function(cmd, laccount)
    local uid = laccount.Id

    if cmd.data == nil then
        cmd.data = {}
    end
    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdSendReqAgreeAddFriendCmd_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

-- 删除好友
Net.CmdSendReqDeleteFriendCmd_C = function(cmd, laccount)
    local uid = laccount.Id

    if cmd.data == nil then
        cmd.data = {}
    end
    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdSendReqDeleteFriendCmd_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end

--推荐好友
Net.CmdSendReqRecommendFriendCmd_C = function(cmd, laccount)
    local uid = laccount.Id

    if cmd.data == nil then
        cmd.data = {}
    end
    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end

Lby.CmdSendReqRecommendFriendCmd_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end
    
--通过UID获得对方信息
Net.CmdGetUserInfoByUid_C = function(cmd, laccount)
    local uid = laccount.Id

    if cmd.data == nil then
        cmd.data = {}
    end
    cmd.data.cmd_uid = uid
    unilobby.SendCmdToLobby(cmd["do"], cmd["data"])
end
    
Lby.CmdGetUserInfoByUid_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    unilight.response(userInfo.laccount, cmd)
end