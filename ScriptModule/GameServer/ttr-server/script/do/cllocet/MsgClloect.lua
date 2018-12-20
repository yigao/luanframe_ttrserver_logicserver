
 --领取收藏有礼奖励
Net.CmdGetCollectRewardCmd_C = function(cmd, laccount)
	local res = {}
	res["do"] = "Cmd.GetCollectRewardCmd_S"
	local uid = laccount.Id
	print("CmdGetCollectRewardCmd_C, uid="..uid)
	local userInfo = UserInfo.GetUserInfoById(uid)
	local  ret, desc = userInfo.collect:GetCollectReward()
	print("CmdGetCollectRewardCmd_C, uid="..uid..", ret="..ret..", desc="..desc)

	res["data"] = {
		resultCode 	= ret,
		desc 		= desc
	}
	return res
end