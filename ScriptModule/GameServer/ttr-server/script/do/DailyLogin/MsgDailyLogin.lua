
-- 获取每日登录信息
Net.CmdGetDailyLoginInfoCmd_C = function(cmd, laccount)
	local res = {}
	res["do"] = "Cmd.GetDailyLoginInfoCmd_S"
	local uid = laccount.Id
    local userInfo = UserInfo.GetUserInfoById(uid)
	local loginInfo = userInfo.dailyLogin:GetDailyLoginInfo()

	res["data"] = {
		resultCode 	= 0,
		desc 		= "成功",
		data 			= loginInfo,
	}
	return res
end


 --领取每日登录奖励
Net.CmdGetDailyLoginRewardCmd_C = function(cmd, laccount)
	local res = {}
	res["do"] = "Cmd.GetDailyLoginRewardCmd_S"
	local uid = laccount.Id
	local loginId = cmd.data.id
	local doubleReward = cmd.data.doubleReward
	local userInfo = UserInfo.GetUserInfoById(uid)
	local  ret, desc = userInfo.dailyLogin:GetDailyLoginReward(loginId, doubleReward)

	res["data"] = {
		resultCode 	= ret,
		desc 		= desc,
		id 	= loginId,
		doubleReward = doubleReward,
	}
	return res
end








