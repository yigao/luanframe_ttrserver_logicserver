function Net.CmdMailPullCmd_C(cmd, laccount)
	local res = {}
	res["do"] = "Cmd.MailPullCmd_S"
	res["data"] = {
		resultCode = 0
	}

	local userInfo = UserInfo.GetUserInfoById(laccount.Id)

	res.data["mails"] = userInfo.mailMgr:pull()

	return res
end

function Net.CmdMailReceiveCmd_C(cmd, laccount)
	local res = {}
	res["do"] = "Cmd.MailReceiveCmd_S"
	res["data"] = {}

	if cmd.data == nil or cmd.data.id == nil then
		return ERROR_CODE.ARGUMENT_ERROR
	end

	res.data["id"] = cmd.data.id

	local userInfo = UserInfo.GetUserInfoById(laccount.Id)

	res.data["resultCode"] = userInfo.mailMgr:receive(cmd.data.id)

	return res
end
