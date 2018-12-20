function Net.CmdGetSettingsCmd_C(cmd, laccount)
	local res = {}
	res["do"] = "Cmd.GetSettingsCmd_S"
	res["data"] = { resultCode = 0 }

	local userInfo = UserInfo.GetUserInfoById(laccount.Id)

	if userInfo == nil then
		res["data"].resultCode = ERROR_CODE.LOGICAL_ERROR
		return res
	end

	if userInfo.settings == nil then
		return res
	end

	res["data"].settings = userInfo.settings
	return res
end

function Net.CmdSaveSettingsCmd_C(cmd, laccount)
	local res = {}
	res["do"] = "Cmd.SaveSettingsCmd_S"
	res["data"] = { resultCode = 0 }
	

	local userInfo = UserInfo.GetUserInfoById(laccount.Id)

	if userInfo == nil then
		res["data"].resultCode = ERROR_CODE.LOGICAL_ERROR
		return res
	end

	--open save?
	if cmd.data == nil or cmd.data.settings == nil then
		res["data"].resultCode = ERROR_CODE.ARGUMENT_ERROR
	end

	userInfo.settings = cmd.data.settings

	local data = {}
	data.cmd_uid = laccount.Id
	data.userInfo = {
		star = userInfo.star, 
		gender = userInfo.gender, 
		signature = userInfo.settings.signature,
		area = userInfo.settings.area, 
		horoscope = userInfo.settings.horoscope,
	}
	unilobby.SendCmdToLobby("Cmd.SaveSettingsCmd_C", data)
	return res
end

