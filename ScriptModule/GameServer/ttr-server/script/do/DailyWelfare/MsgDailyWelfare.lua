
-- 获取每日礼包信息
Net.CmdGetDailyWelfareInfoCmd_C = function(cmd, laccount)
	local res = {}
	res["do"] = "Cmd.GetDailyWelfareInfoCmd_S"
	local uid = laccount.Id
    local userInfo = UserInfo.GetUserInfoById(uid)
	local ret, diamondQuickTime, watchVideoMinusMinuteCd = userInfo.dailyWelfare:GetDailyWelfareInfo()

	res["data"] = {
		resultCode 	= 0,
		desc 		= "成功",
		diamondQuickTime = diamondQuickTime,
		watchVideoMinusMinuteCd = watchVideoMinusMinuteCd,
		data 			= ret,
	}
	return res
end


 --领取每日礼包奖励
Net.CmdGetDailyWelfareRewardCmd_C = function(cmd, laccount)
	local res = {}
	res["do"] = "Cmd.GetDailyWelfareRewardCmd_S"
	local uid = laccount.Id
	local welfareId = cmd.data.id
	local doubleReward = cmd.data.doubleReward
	local userInfo = UserInfo.GetUserInfoById(uid)
	local  ret, desc, id, rewardInfo, nextGiftBagInfo = userInfo.dailyWelfare:GetDailyWelfareReward(welfareId, doubleReward)
	print("CmdGetDailyWelfareRewardCmd_S, uid="..uid..", welfareId="..welfareId..", id="..id..", rewardInfo="..rewardInfo)

	res["data"] = {
		resultCode 	= ret,
		desc 		= desc,
		id 	= id,
		doubleReward = doubleReward,
		rewardInfo = rewardInfo,
		nextGiftBagInfo = nextGiftBagInfo,
	}
	return res
end

--消耗钻石抵消礼包CD
Net.CmdCostDiamondToRemoveCdCmd_C = function(cmd, laccount)
	local res = {}
	res["do"] = "Cmd.CostDiamondToRemoveCdCmd_S"
	local uid = laccount.Id
	local welfareId = cmd.data.id
	local userInfo = UserInfo.GetUserInfoById(uid)
	local  ret, desc, id = userInfo.dailyWelfare:CostDiamondToRemoveCd(welfareId)

	res["data"] = {
		resultCode 	= ret,
		desc 		= desc,
		id 	= id,
	}
	return res
end


--玩家看视频减少礼包CD
Net.CmdWatchVideoToMinusCdCmd_C = function(cmd, laccount)
	local res = {}
	res["do"] = "Cmd.WatchVideoToMinusCdCmd_S"
	local uid = laccount.Id
	local welfareId = cmd.data.welfareId
	local userInfo = UserInfo.GetUserInfoById(uid)
	local  ret, desc, id, remainCd = userInfo.dailyWelfare:WatchVideoToMinusCd(welfareId)

	res["data"] = {
		resultCode 	= ret,
		desc 		= desc,
		id 	= id,
		remainCd = remainCd,
	}
	return res
end


--在主界面看视频或分享成功可以领取的奖励
Net.CmdGetMainInterfaceRewardCmd_C = function(cmd, laccount)
	local res = {}
	res["do"] = "Cmd.GetMainInterfaceRewardCmd_S"
	local uid = laccount.Id
	local userInfo = UserInfo.GetUserInfoById(uid)

	UserItems:useItem(userInfo, 1007, 1)
	userInfo.UserProps:AddDayLookMediaTimes(userInfo)

	res["data"] = {
		resultCode 	= 0,
		desc 		= "成功",
		itemId 		= 1007,
		num 		= 1,
	}
	return res
end






