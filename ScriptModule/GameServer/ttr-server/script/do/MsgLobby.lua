-- 登录获取个人信息
Net.CmdUserInfoSynLobbyCmd_C = function(cmd, laccount)
	unilight.debug("First Login Center Server......")

	local uid 		= laccount.Id

	local userInfo = UserInfo.GetUserInfoById(uid)

	local isFirstLogin = false
	if userInfo == nil then
		local dbUser = unilight.getdata("userinfo", uid)

		if dbUser == nil then
			userInfo = UserInfo.CreateTempUserInfo(uid)
			isFirstLogin = true
		else
			userInfo = UserInfo.CreateUserByDb(uid, dbUser)
		end

		UserInfo.GlobalUserInfoMap[uid] = userInfo
	end

	--只有从中心服务器成功放回后才算登录成功
	userInfo.online = false

	--清理玩家离线定时器
	if userInfo["offline_timer"] ~= nil then
		unilight.stoptimer(userInfo["offline_timer"])
	end

	--有可能需要重置每日任务数据
	userInfo.dailyTask:Reset()
	userInfo.achieveTask:LoadConfig()
	userInfo.mainTask:LoadConfig()
	--userInfo.nickName = name or userInfo.nickName
	--userInfo.head = head or userInfo.head
	--userInfo.sex = sex or userInfo.sex
	userInfo.laccount = laccount
	userInfo.dailyTask:addProgress(TaskConditionEnum.LoginEvent, 1)
	userInfo.mainTask:addProgress(TaskConditionEnum.LoginEvent, 1)

	--只同步客户端需要的数据，UserInfo下面存有服务器需要的数据

	userInfo.dailyLogin:Login()
	userInfo.dailySharing:Login()

	--处理属性重置
	UserProps:dealLoginInitProps(userInfo)

	if userInfo.firstLogin ~= 1 then
		UserInfo.DealOfflinePrize(userInfo, false, 0)
	end

	--如果存在中心服务器的话，先登陆中心服务器
	local data = {}
	data.cmd_uid = uid
	data.userInfo = {
		star = userInfo.star,
		money = userInfo.money,
		product = userInfo.product,
		isFirstLogin = isFirstLogin,
	}
	unilobby.SendCmdToLobby("Cmd.UserInfoLoginCenter_C", data) 
end

-- 中心服务器登入返回
Lby.CmdUserInfoLoginCenter_S = function(cmd,lobbyClientTask)
	local uid = cmd.data.cmd_uid
	local friendAddontion = cmd.data.friendAddontion
	local shield_count = cmd.data.shield_count

	local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		unilight.error("userinfo is not exist,uid:"..uid)
		return
	end

	userInfo.online = true
	userInfo.friendAddontion = friendAddontion

	--玩家产量初始化计算 依赖好友系统的加成计算
	userInfo.world:recalc()

	local res = {}
	res["do"] = "Cmd.UserInfoSynLobbyCmd_S"
	res["data"] = {
		resultCode = 0,
		userInfo = UserInfo.GetClientData(userInfo),
		is_first_login = isFirstLogin,
		shield_count = shield_count,
		user_props = UserProps:GetUserProps(userInfo),
	}
	unilight.response(userInfo.laccount, res)

	--属性同步
	--UserProps:sendUserProps(userInfo)

	--下发广告信息  属性那块做好后 这里可以不发
	UserProps:sendUserLookMediaInfo(userInfo)
	--下发在线奖励信息
	UserProps:sendOnlineRandBoxInfo(userInfo)
	userInfo.dailyDiamondReward:DealWithLogin()
	userInfo.dailyLotteryDraw:DealWithLogin()
	userInfo.dailyWelfare:DealWithLogin()
end

function Net.CmdPing_C(cmd, laccount)
	--[
	local res = {}
	res["do"] = "Cmd.Ping_S"
	res["data"] = {
		resultCode = 0,
	}

	return res
end
