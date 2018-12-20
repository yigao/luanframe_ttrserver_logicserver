function Net.CmdStateOpenCmd_C(cmd, laccount)
	local res = {}
	res["do"] = "Cmd.StateOpenCmd_S"
	res["data"] = {
		id = cmd.data.id,
	}

	if cmd.data == nil or cmd.data.id == nil then
		res.data["resultCode"] = ERROR_CODE.ARGUMENT_ERROR
		return res
	end

	local userInfo = UserInfo.GetUserInfoById(laccount.Id)

	if userInfo == nil then
		res.data["resultCode"] = ERROR_CODE.LOGICAL_ERROR
		return res
	end

	res.data["resultCode"] = userInfo.world:openState(cmd.data.id)

	return res
end

function Net.CmdBuildingBuyCmd_C(cmd, laccount)
	local res = {}
	res["do"] = "Cmd.BuildingBuyCmd_S"
	res["data"] = {
		stateId = cmd.data.stateId,
		buildingId = cmd.data.buildingId,
	}

	if cmd.data == nil or cmd.data.stateId == nil or cmd.data.buildingId == nil then
		res.data["resultCode"] = ERROR_CODE.ARGUMENT_ERROR
		return res
	end

	local userInfo = UserInfo.GetUserInfoById(laccount.Id)

	res.data["resultCode"] = userInfo.world:buy(cmd.data.stateId, cmd.data.buildingId)

	return res
end

function Net.CmdBuildingLevelupCmd_C(cmd, laccount)
	local res = {}
	res["do"] = "Cmd.BuildingLevelupCmd_S"
	res["data"] = {
		stateId = cmd.data.stateId,
		buildingId = cmd.data.buildingId,
	}

	if cmd.data == nil or cmd.data.stateId == nil or cmd.data.buildingId == nil then
		res.data["resultCode"] = ERROR_CODE.ARGUMENT_ERROR
		return res
	end

	local userInfo = UserInfo.GetUserInfoById(laccount.Id)

	res.data["resultCode"] = userInfo.world:levelup(cmd.data.stateId, cmd.data.buildingId)

	return res
end

function Net.CmdBuildingRebuildCmd_C(cmd, laccount)
	local res = {}
	res["do"] = "Cmd.BuildingRebuildCmd_S"
	res["data"] = {
		stateId = cmd.data.stateId,
		buildingId = cmd.data.buildingId,
	}

	if cmd.data == nil or cmd.data.stateId == nil or cmd.data.buildingId == nil then
		res.data["resultCode"] = ERROR_CODE.ARGUMENT_ERROR
		return res
	end

	local userInfo = UserInfo.GetUserInfoById(laccount.Id)

	res.data["resultCode"] = userInfo.world:rebuild(cmd.data.stateId, cmd.data.buildingId)

	return res
end

function Net.CmdStateClickCmd_C(cmd, laccount)
	local res = {}
	res["do"] = "Cmd.StateClickCmd_S"
	res["data"] = {
		stateId = cmd.data.stateId,
	}

	if cmd.data == nil or cmd.data.stateId == nil then
		res.data["resultCode"] = ERROR_CODE.ARGUMENT_ERROR
		return res
	end

	local userInfo = UserInfo.GetUserInfoById(laccount.Id)

	res.data["resultCode"] = userInfo.world:click(cmd.data.stateId, tonumber(cmd.data.times), tonumber(cmd.data.critical))

	return res
end

function Net.CmdBuildingLevelupTenCmd_C(cmd, laccount)
	local res = {}
	res["do"] = "Cmd.BuildingLevelupTenCmd_S"
	res["data"] = {
		stateId = cmd.data.stateId,
		buildingId = cmd.data.buildingId,
	}

	if cmd.data == nil or cmd.data.stateId == nil or cmd.data.buildingId == nil then
		res.data["resultCode"] = ERROR_CODE.ARGUMENT_ERROR
		return res
	end

	local userInfo = UserInfo.GetUserInfoById(laccount.Id)

	res.data["resultCode"] = userInfo.world:levelupTen(cmd.data.stateId, cmd.data.buildingId)

	return res
end
