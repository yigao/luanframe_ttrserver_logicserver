


 --抽奖
 Net.CmdGetDailyLotteryDrawCmd_C = function(cmd, laccount)
	 local res = {}
	 res["do"] = "Cmd.GetDailyLotteryDrawCmd_S"
	 local uid = laccount.Id
	 local userInfo = UserInfo.GetUserInfoById(uid)

	 local resultCode, desc, drawNum, rewardId, isGotLuckyDraw = userInfo.dailyLotteryDraw:GetDailyLotteryDraw()

	 res["data"] = {
		 resultCode 	= resultCode,
		 desc 			= desc,
		 drawNum 		= drawNum,
		 rewardId		= rewardId,
		 isGotLuckyDraw = isGotLuckyDraw,
	 }
	 return res
 end


 --获取抽奖抽到的抽奖id
 Net.CmdGetLotteryDrawRewardIdCmd_C = function(cmd, laccount)
	 local res = {}
	 res["do"] = "Cmd.GetLotteryDrawRewardIdCmd_S"
	 local uid = laccount.Id
	 local userInfo = UserInfo.GetUserInfoById(uid)

	 local resultCode, desc, drawNum, rewardId, isGotLuckyDraw = userInfo.dailyLotteryDraw:GetLotteryDrawRewardId()

	 res["data"] = {
		 resultCode 	= resultCode,
		 desc 			= desc,
		 drawNum 		= drawNum,
		 rewardId		= rewardId,
		 isGotLuckyDraw = isGotLuckyDraw,
	 }
	 return res
 end

 --领取上次抽奖抽到的奖品
 Net.CmdGetLotteryDrawRewardCmd_C = function(cmd, laccount)
	 local res = {}
	 res["do"] = "Cmd.GetLotteryDrawRewardCmd_S"
	 local uid = laccount.Id
	 local userInfo = UserInfo.GetUserInfoById(uid)

	 local resultCode, desc, drawNum, rewardId, isGotLuckyDraw = userInfo.dailyLotteryDraw:GetLotteryDrawReward()

	 res["data"] = {
		 resultCode 	= resultCode,
		 desc 			= desc,
		 drawNum 		= drawNum,
		 rewardId		= rewardId,
		 isGotLuckyDraw = isGotLuckyDraw,
	 }
	 return res
 end