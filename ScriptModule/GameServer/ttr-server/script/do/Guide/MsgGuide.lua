
 --保存引导信息
 Net.CmdSaveGuideInfoCmd_C = function(cmd, laccount)
	 local res = {}
	 res["do"] = "Cmd.SaveGuideInfoCmd_S"
	 local uid = laccount.Id
	 local guideId = cmd.data.guideId
	 local userInfo = UserInfo.GetUserInfoById(uid)
	 local  ret, desc = userInfo.guide:SaveGuideInfo(guideId)

	 res["data"] = {
		 resultCode 	= ret,
		 desc 		= desc
	 }
	 return res
 end

 --获取引导信息
 Net.CmdGetGuideInfoCmd_C = function(cmd, laccount)
	 local res = {}
	 res["do"] = "Cmd.GetGuideInfoCmd_S"
	 local uid = laccount.Id
	 local userInfo = UserInfo.GetUserInfoById(uid)
	 local  ret, desc, guideId = userInfo.guide:GetGuideInfo()

	 res["data"] = {
		 resultCode 	= ret,
		 desc 		= desc,
		 guideId = guideId
	 }
	 return res
 end