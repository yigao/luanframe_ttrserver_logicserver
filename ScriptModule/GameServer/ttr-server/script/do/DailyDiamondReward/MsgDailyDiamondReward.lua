


 --领取每日钻石奖励
 Net.CmdGetDailyDiamondRewardCmd_C = function(cmd, laccount)
	 local res = {}
	 res["do"] = "Cmd.GetDailyDiamondRewardCmd_S"
	 local uid = laccount.Id
	 local userInfo = UserInfo.GetUserInfoById(uid)

	 local resultCode, desc, dailyDiamondRewardNum = userInfo.dailyDiamondReward:GetDailyDiamondRewardReward()

	 res["data"] = {
		 resultCode 	= resultCode,
		 desc 		= desc,
		 dailyDiamondRewardNum 		= dailyDiamondRewardNum
	 }
	 return res
 end
