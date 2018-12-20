State =
{
	owner = nil,
	world = nil,
	id = 0,
	buildings = nil,
}

function State:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function State:init(owner, world, id)
	self.owner = owner
	self.world = world
	self.id = id
	self.buildings = {}
	world.states[self.id] = self
end

function State:sn()
	local data = {
		id = self.id,
		buildings = {},
	}

	for i, building in pairs(self.buildings) do
		table.insert(data.buildings, building:sn())
	end
	
	return data
end

function State:PerProduct()
	local product = 0
	for i, building in pairs(self.buildings) do
		product = product + building.produce
	end
	return product
end

function State:recalc()
	for i, building in pairs(self.buildings) do
		building:recalc()
	end
end

function State:loadFromDb(data)
	if data["buildings"] == nil then
		unilight.debug("No buildings")
		return false
	end

	for i, db_building in pairs(data.buildings) do
		local building = Building:new()
		building:init(self.owner, self, db_building.id, db_building.lv, db_building.buildLv)
	end

	return true
end

function State:buy(id) -- building ID
	if self.buildings[id] ~= nil then
		return ERROR_CODE.BUY_AGAIN
	end

	local cost = TableLevelup.query(id, 1)["CostMoney"]

	if (cost == nil) then
		return ERROR_CODE.BUILDING_LEVEL_MAX
	end

	local money_table = string.split(cost, "_")
	local money_type, money =  money_table[1], money_table[2]
	if money_type == nil or money == nil then
		unilight.warn("Table[Levelup]'s CostMoney is error")
		return ERROR_CODE.TABLE_ERROR
	end

	if UserInfo.CheckUserMoney(self.owner, money_type, money) ~= true then
		if tonumber(money_type) == static_const.Static_MoneyType_Gold then
			return ERROR_CODE.MONEY_NOT_ENOUGH
		end
		if tonumber(money_type) == static_const.Static_MoneyType_Diamond then
			return ERROR_CODE.DIAMOND_NOT_ENOUGH
		end
	end

	UserInfo.SubUserMoney(self.owner, money_type, money)
	UserInfo.AddUserStar(self.owner, 1)

	local building = Building:new()
	building:init(self.owner, self, id, 1, 1)

	local data = {}
	data.cmd_uid = self.owner.uid
	data.userInfo = {
		star = self.owner.star,
		money = self.owner.money,
		mapid = self.id,
		buildid = id,
	}
	unilobby.SendCmdToLobby("Cmd.UserBuyBuild_C", data)

	--任务系统，任务完成情况
	self.owner.achieveTask:addProgress(TaskConditionEnum.BuildingLevelUpEvent, self.owner.star)
	self.owner.dailyTask:addProgress(TaskConditionEnum.BuildingLevelUpEvent, self.owner.star)
	self.owner.mainTask:addProgress(TaskConditionEnum.BuildingLevelUpEvent, 1)
	self.owner.mainTask:addProgress(TaskConditionEnum.SpecifyBuildingLevelUpEvent, 1, id)
	self.owner.mainTask:addProgress(TaskConditionEnum.SpecifyBuildingStar, 1, id)

	return ERROR_CODE.SUCCESS
end

function State:levelup(id) -- building ID
	if self.buildings[id] == nil then
		return ERROR_CODE.BUILDING_NOT_BUY
	end

	return self.buildings[id]:levelup()
end

function State:levelupTen(id) -- building ID
	if self.buildings[id] == nil then
		return ERROR_CODE.BUILDING_NOT_BUY
	end

	return self.buildings[id]:levelupTen()
end

function State:rebuild(id) -- building ID
	if self.buildings[id] == nil then
		return ERROR_CODE.BUILDING_NOT_BUY
	end

	return self.buildings[id]:rebuild()
end

function State:recalcStar()
	local star = 0

	for i, building in pairs(self.buildings) do
		star = star + building.lv
	end
	
	return star
end

function State:calcEarning()
	local money = 0

	for _,building in pairs(self.buildings) do
		building:recalcEverySec()
		local product = building:earn()
		--unilight.debug("\t id:".._..",product:"..product)
		money = money + product
	end

	return money
end
