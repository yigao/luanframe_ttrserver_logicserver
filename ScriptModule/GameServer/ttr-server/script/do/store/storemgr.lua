local StoreData = StoreData
local ItemData = ItemData
local ProfitAddData = ProfitAddData
local TreasureBoxData = TreasureBoxData

--玩家商品
UserItems =
{
    owner = nil,
	buyitems = {},
	rechargeitems = {},
}

function UserItems:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function UserItems:init(owner)
    self.owner = owner
	self.buyitems = {}
	self.rechargeitems = {}
end

function UserItems:setDBTable(data)
	if data == nil then
		unilight.warn("No UserItems")
		return false
	end
	self.buyitems = data.buyitems
	self.rechargeitems = data.rechargeitems
end

function UserItems:GetDBTable()
        local data = {}
        data.buyitems = self.buyitems
        data.rechargeitems = self.rechargeitems
        return data
end

function UserItems:checkIsFirstRecharge(goodsid)
	for k, v in pairs(self.rechargeitems) do
		if v == goodsid then
			return false
		end
	end
	return true
end

function UserItems:addRechargeItems(goodsid)
	for k, v in pairs(self.rechargeitems) do
		if v == goodsid then
			return 
		end
	end
	if goodsid then
		table.insert(self.rechargeitems, goodsid)
		unilight.savefield("userinfo", self.owner.uid, "UserItems.rechargeitems", self.rechargeitems)	
	end
end


function UserItems:checkUserHadItem(goodsid)
	for k, v in pairs(self.buyitems) do
		if v == goodsid then
			return true
		end
	end
	return false
end

function UserItems:addUserItems(goodsid)
	for k, v in pairs(self.buyitems) do
		if v == goodsid then
			return 
		end
	end
	if goodsid then
		table.insert(self.buyitems, goodsid)
		unilight.savefield("userinfo", self.owner.uid, "UserItems.buyitems", self.buyitems)	
		return true
	end
	return false
end

function UserItems:removeUserItems(goodsid)
	if goodsid then
		table.remove(self.buyitems, goodsid)
		return true
	end
	return false
end
function UserItems:getUserHadBuyGoods()
	return self.buyitems
end

function UserItems:useItem(userinfo,itemid,itemnum)
--	unilight.debug("userItem-001" .. " itemid:" .. itemid .. " itemnum:" .. itemnum)
	if userinfo == nil or itemid == nil or itemid == 0 then
		return false
	end
	if itemnum == 0 then
		itemnum = 1
	end
	local itemdata = ItemData[itemid]
	if not itemdata then
		unilight.debug("2222" .. " itemid:" .. itemid .. " itemnum:" .. itemnum)
		return false
	end
	local itemtype = tonumber(itemdata.itemtype)
	--这里是玩家购买了旅行团头像后的回调
	if itemtype == static_const.Static_ItemType_Clothes then
		UserTravel.AddTravelHeadBackupCallBack(userinfo.uid,itemid,itemnum)
	end

	--旅行团护盾
	if itemtype == static_const.Static_ItemType_ProtectTimes then
		UserTravel.BuyShieldCountCallBack(userinfo.uid,itemid,itemnum)
	end
	
	userinfo.UserProps:setUserProp(userinfo,itemtype, itemnum, tonumber(itemdata.paraone), tonumber(itemdata.paratwo))
	unilight.debug("2221" .. " itemid:" .. itemid .. " itemnum:" .. itemnum .. " itemtype" .. itemtype)
	--处理打开获得道具
	local items = itemdata.openitems
	local args = string.split(items, ';')
	for k,v in pairs(args) do
		local aargs = string.split(v, '_')
		local aitemid = aargs[1]
		local aitemnum = aargs[2]
		UserItems:useItem(userinfo,tonumber(aitemid),tonumber(aitemnum))
	end
	unilight.debug("userItem-009" .. " itemid:" .. itemid .. " itemnum:" .. itemnum)
end

--玩家属性
UserProps =
{
        owner = nil,
	props = {
		pProtectTimes = 0, --护盾次数
		pPower = 0,	   --能量值	
		pGoldPerSecond = 0,	--每秒当前金币产量
		pBuildingProduceRate = 0,	--建筑生产速度
		pClickGoldAdd = 0,		--每次点击增加金币
		pWorldGoldAdd = 0,		--世界每秒增加金币
		pAutoClickTimes_Time = 0, 	--世界每秒增加金币的时间
		pAutoClickTimes_Times = 0,	--世界每秒增加金币的次数
		pWeekCardEndTime = 0,		--周卡结束时间
		pMonthCardEndTime = 0,		--月卡结束时间
		pClothes = {},			--时装
		pClickGoldAddRatio = 0,		--点击金币加成
		pWorldGoldAddRatio = 0,		--世界金币加成
		pGoldRainTimeAdd = 0,		--金币雨时间加成
		pOfflineGoldAddRatio = 0,	--离线金币加成
		pHasLifelongCard = 0,		--是否有月卡	
	},
	bprops = {
		dayLookMediaTimes = 0, --观看广告次数
		dayLookMediaLevel = 0, --观看广告等级
		
		pClickGoldAddRatioValue = 0,	--点击加成值
		pClickGoldAddRatioTime	= 0,	--点击加成时间
		pWorldGoldAddRatioValue = 0,	--世界加成值
		pWorldGoldAddRatioTime = 0,	--世界加成时间
		pOfflineGoldAddRatioValue = 0,	--离线加成值
		pOfflineGoldAddRatioTime = 0,   --离线加成时间
		
	},
	ponline = {
		bOnlineTime = 0,
		bOnlinePrize = {},
	}
}

function UserProps:new(o)
        o = o or {}
        setmetatable(o, self)
        self.__index = self
        return o
end

function UserProps:init(owner)
        self.owner = owner
	self.props = {	
		pProtectTimes = 0, --护盾次数
		pPower = 0,	   --能量值	
		pGoldPerSecond = 0,	--每秒当前金币产量
		pBuildingProduceRate = 0,	--建筑生产速度
		pClickGoldAdd = 0,		--每次点击增加金币
		pWorldGoldAdd = 0,		--世界每秒增加金币
		pAutoClickTimes_Time = 0, 	--世界每秒增加金币的时间
		pAutoClickTimes_Times = 0,	--世界每秒增加金币的次数
		pWeekCardEndTime = 0,		--周卡结束时间
		pMonthCardEndTime = 0,		--月卡结束时间
		pClothes = {},			--时装
		pClickGoldAddRatio = 0,		--点击金币加成
		pWorldGoldAddRatio = 0,		--世界金币加成
		pGoldRainTimeAdd = 0,		--金币雨时间加成
		pOfflineGoldAddRatio = 0,	--离线金币加成
		pHasLifelongCard = 0,		--是否有月卡	
	}
	self.bprops = {
		dayLookMediaTimes = 0, --观看广告次数
		dayLookMediaLevel = 0, --观看广告等级

		pClickGoldAddRatioValue = 0,	--点击加成值
		pClickGoldAddRatioTime	= 0,	--点击加成时间
		pWorldGoldAddRatioValue = 0,	--世界加成值
		pWorldGoldAddRatioTime = 0,	--世界加成时间
		pOfflineGoldAddRatioValue = 0,	--离线加成值
		pOfflineGoldAddRatioTime = 0,	--离线加成时间

	}
	self.ponline = {
		bOnlineTime = 0,
		bOnlinePrize = {},
	}
	if self.ponline.bOnlinePrize == nil or #self.ponline.bOnlinePrize == 0 then
		--UserProps:initRandBoxPrize()--用UserProps:作用不到self
		self:initRandBoxPrize()
	end
end

function UserProps:setDBTable(data)
	if data == nil then
		unilight.warn("No UserProps")
		return false
	end

	if data.props ~= nil then
		self.props.pProtectTimes = data.props.pProtectTimes or self.props.pProtectTimes --护盾次数
		self.props.pPower = data.props.pPower or self.props.pPower	   --能量值	
		self.props.pGoldPerSecond = data.props.pGoldPerSecond or self.props.pGoldPerSecond	--每秒当前金币产量
		self.props.pBuildingProduceRate = data.props.pBuildingProduceRate or self.props.pBuildingProduceRate	--建筑生产速度
		self.props.pClickGoldAdd = data.props.pClickGoldAdd or self.props.pClickGoldAdd		--每次点击增加金币
		self.props.pWorldGoldAdd = data.props.pWorldGoldAdd or self.props.pWorldGoldAdd		--世界每秒增加金币
		self.props.pAutoClickTimes_Time = data.props.pAutoClickTimes_Time or self.props.pAutoClickTimes_Time 	--世界每秒增加金币的时间
		self.props.pAutoClickTimes_Times = data.props.pAutoClickTimes_Times or self.props.pAutoClickTimes_Times	--世界每秒增加金币的次数
		self.props.pWeekCardEndTime = data.props.pWeekCardEndTime or self.props.pWeekCardEndTime		--周卡结束时间
		self.props.pMonthCardEndTime = data.props.pMonthCardEndTime or self.props.pMonthCardEndTime		--月卡结束时间
		self.props.pClothes = data.props.pClothes or self.props.pClothes			--时装
		self.props.pClickGoldAddRatio = data.props.pClickGoldAddRatio or self.props.pClickGoldAddRatio		--点击金币加成
		self.props.pWorldGoldAddRatio = data.props.pWorldGoldAddRatio or self.props.pWorldGoldAddRatio		--世界金币加成
		self.props.pGoldRainTimeAdd = data.props.pGoldRainTimeAdd or self.props.pGoldRainTimeAdd		--金币雨时间加成
		self.props.pOfflineGoldAddRatio = data.props.pOfflineGoldAddRatio or self.props.pOfflineGoldAddRatio	--离线金币加成
		self.props.pHasLifelongCard = data.props.pHasLifelongCard or self.props.pHasLifelongCard		--是否有月卡
	end

	--self.bprops = data.bprops
	if data.bprops ~= nil then
		self.bprops.dayLookMediaTimes =  data.bprops.dayLookMediaTimes or self.bprops.dayLookMediaTimes
		self.bprops.dayLookMediaLevel =  data.bprops.dayLookMediaLevel or self.bprops.dayLookMediaLevel
		self.bprops.pClickGoldAddRatioValue =  data.bprops.pClickGoldAddRatioValue or self.bprops.pClickGoldAddRatioValue
		self.bprops.pClickGoldAddRatioTime =  data.bprops.pClickGoldAddRatioTime or self.bprops.pClickGoldAddRatioTime
		self.bprops.pWorldGoldAddRatioValue = data.bprops.pWorldGoldAddRatioValue or self.bprops.pWorldGoldAddRatioValue 
		self.bprops.pWorldGoldAddRatioTime =  data.bprops.pWorldGoldAddRatioTime or self.bprops.pWorldGoldAddRatioTime
		self.bprops.pOfflineGoldAddRatioValue =  data.bprops.pOfflineGoldAddRatioValue or self.bprops.pOfflineGoldAddRatioValue
		self.bprops.pOfflineGoldAddRatioTime = data.bprops.pOfflineGoldAddRatioTime or self.bprops.pOfflineGoldAddRatioTime 
	end

	self.ponline = data.ponline
	if self.ponline.bOnlinePrize == nil or #self.ponline.bOnlinePrize == 0 then
		--UserProps:initRandBoxPrize()--用UserProps:作用不到self
		self:initRandBoxPrize()
	end
end

function UserProps:GetDBTable()
        local data = {}
        data.props = self.props
	data.bprops = self.bprops
	data.ponline = self.ponline
        return data
end

function UserProps:GetUserProps(userinfo)
	local aprops = userinfo.UserProps
	if aprops ~= nil then
		local res = {
			pProtectTimes = aprops.props.pProtectTimes,			
			pPower = aprops.props.pPower,			
			pGoldPerSecond = aprops.props.pGoldPerSecond,			
			pBuildingProduceRate = aprops.props.pBuildingProduceRate,			
			pClickGoldAdd = aprops.props.pClickGoldAdd,			
			pWorldGoldAdd = aprops.props.pWorldGoldAdd,			
			pAutoClickTimes_Time = aprops.props.pAutoClickTimes_Time,			
			pAutoClickTimes_Times = aprops.props.pAutoClickTimes_Times,			
			pWeekCardEndTime = aprops.props.pWeekCardEndTime,			
			pMonthCardEndTime = aprops.props.pMonthCardEndTime,			
			pClothes = aprops.props.pClothes,			
			pClickGoldAddRatio = aprops.props.pClickGoldAddRatio,			
			pWorldGoldAddRatio = aprops.props.pWorldGoldAddRatio,			
			pGoldRainTimeAdd = aprops.props.pGoldRainTimeAdd,			
			pOfflineGoldAddRatio = aprops.pOfflineGoldAddRatio,
			pHasLifelongCard = aprops.props.pHasLifelongCard,		

			dayLookMediaTimes = aprops.bprops.dayLookMediaTimes, 
			dayLookMediaLevel = aprops.bprops.dayLookMediaLevel, 
			pClickGoldAddRatioValue = aprops.bprops.pClickGoldAddRatioValue,
			pClickGoldAddRatioTime	= aprops.bprops.pClickGoldAddRatioTime,
			pWorldGoldAddRatioValue = aprops.bprops.pWorldGoldAddRatioValue,
			pWorldGoldAddRatioTime = aprops.bprops.pWorldGoldAddRatioTime,
			pOfflineGoldAddRatioValue = aprops.bprops.pOfflineGoldAddRatioValue,
			pOfflineGoldAddRatioTime = aprops.bprops.pOfflineGoldAddRatioTime,
			
			desc = "属性返回",
		}
		return res
	end
end

function UserProps:sendUserProps(userinfo)
	local aprops = userinfo.UserProps
	local res = { }
	res["do"] = "Cmd.SendUserPropertyOnUseItemCmd_S"
	if aprops ~= nil then
		res["data"] = {
			pProtectTimes = aprops.props.pProtectTimes,			
			pPower = aprops.props.pPower,			
			pGoldPerSecond = aprops.props.pGoldPerSecond,			
			pBuildingProduceRate = aprops.props.pBuildingProduceRate,			
			pClickGoldAdd = aprops.props.pClickGoldAdd,			
			pWorldGoldAdd = aprops.props.pWorldGoldAdd,			
			pAutoClickTimes_Time = aprops.props.pAutoClickTimes_Time,			
			pAutoClickTimes_Times = aprops.props.pAutoClickTimes_Times,			
			pWeekCardEndTime = aprops.props.pWeekCardEndTime,			
			pMonthCardEndTime = aprops.props.pMonthCardEndTime,			
			pClothes = aprops.props.pClothes,			
			pClickGoldAddRatio = aprops.props.pClickGoldAddRatio,			
			pWorldGoldAddRatio = aprops.props.pWorldGoldAddRatio,			
			pGoldRainTimeAdd = aprops.props.pGoldRainTimeAdd,			
			pOfflineGoldAddRatio = aprops.pOfflineGoldAddRatio,
			pHasLifelongCard = aprops.props.pHasLifelongCard,		

			dayLookMediaTimes = aprops.bprops.dayLookMediaTimes, 
			dayLookMediaLevel = aprops.bprops.dayLookMediaLevel, 
			pClickGoldAddRatioValue = aprops.bprops.pClickGoldAddRatioValue,
			pClickGoldAddRatioTime	= aprops.bprops.pClickGoldAddRatioTime,
			pWorldGoldAddRatioValue = aprops.bprops.pWorldGoldAddRatioValue,
			pWorldGoldAddRatioTime = aprops.bprops.pWorldGoldAddRatioTime,
			pOfflineGoldAddRatioValue = aprops.bprops.pOfflineGoldAddRatioValue,
			pOfflineGoldAddRatioTime = aprops.bprops.pOfflineGoldAddRatioTime,
			
			desc = "属性返回",
		}
	else
		res["data"] = {
			desc = "属性返回",
		}
	end
	unilight.response(userinfo.laccount, res)		
end

function UserProps:dealBuffProps()
	local time = os.time()
	if self.bprops.pClickGoldAddRatioTime~= 0 and self.bprops.pClickGoldAddRatioTime < time then
		self.bprops.pClickGoldAddRatioValue = 0
		self.bprops.pClickGoldAddRatioTime = 0
	elseif self.bprops.pWorldGoldAddRatioTime ~=0 and self.bprops.pWorldGoldAddRatioTime < time then	
		self.bprops.pWorldGoldAddRatioValue = 0
		self.bprops.pWorldGoldAddRatioTime = 0
	elseif self.bprops.pWorldGoldAddRatioTime~=0 and self.bprops.pWorldGoldAddRatioTime < time then	
		self.bprops.pOfflineGoldAddRatioValue = 0
		self.bprops.pOfflineGoldAddRatioTime = 0
	end
end

--用userinfo调
function UserProps:dealZeroInitProps()
	unilight.debug("处理零点属性清理--------------------".. self.owner.uid)
	--处理 周卡 月卡 永久卡
	--local time = os.time()
	--if self.props.pWeekCardEndTime ~= 0 and self.props.pWeekCardEndTime < time then
	--	self.props.pWeekCardEndTime = 0
	--else
	--	--发邮件
	--	self.owner.mailMgr:addNew(8)
	--end
	--
	--if self.props.pMonthCardEndTime ~= 0 and self.props.pMonthCardEndTime < time then
	--	self.props.pMonthCardEndTime = 0
	--else
	--	--发邮件
	--	self.owner.mailMgr:addNew(9)
	--end
	--
	--if self.props.pHasLifelongCard then
	--	--发邮件
	--	self.owner.mailMgr:addNew(10)
	--end
	--现在没有周卡 月卡 永久卡

	self.bprops.dayLookMediaTimes = 0
	
	self.ponline.bOnlineTime = 0
	for k,v in pairs(self.ponline.bOnlinePrize) do
		self.ponline.bOnlinePrize[k].status = 0
	end 	
end

function UserProps:dealLoginInitProps(userinfo)
	if userinfo == nil then
		return
	end
	unilight.debug("处理登录属性清理--------------------".. userinfo.uid)
	local time = os.time()
	if userinfo.lastlogintime == nil or userinfo.lastlogintime == 0 then
		userinfo.lastlogintime = time
		return 
	end	
	local lastlogintime =  userinfo.lastlogintime
	if ttrutil.IsSameDay(lastlogintime,time) == false then
		userinfo.UserProps:dealZeroInitProps()	
	end
end


function UserProps:dealLookMediaOK(userinfo)
	if userinfo == nil then
		return ERROR_CODE.UNKNOWN_ERROR 
	end
	if self.bprops.dayLookMediaLevel == nil then
		self.bprops.dayLookMediaLevel = 0	
	end
	if self.bprops.dayLookMediaTimes == nil then
		self.bprops.dayLookMediaTimes = 0	
	end
	local id = self.bprops.dayLookMediaLevel + 1
	local profitAddData = ProfitAddData[id]
	if profitAddData == nil then
		return ERROR_CODE.TABLE_ERROR
	end
	self.bprops.pWorldGoldAddRatioValue = profitAddData.para
	local curtime = os.time()
	if self.bprops.pWorldGoldAddRatioTime == nil or self.bprops.pWorldGoldAddRatioTime == 0 then
		self.bprops.pWorldGoldAddRatioTime = curtime
	end
	self.bprops.pWorldGoldAddRatioTime = self.bprops.pWorldGoldAddRatioTime + GlobalConst.Add_RangeIncome_Time*3600
	if curtime + GlobalConst.Max_RangeIncome_Time*3600 < self.bprops.pWorldGoldAddRatioTime then
		 self.bprops.pWorldGoldAddRatioTime = curtime + GlobalConst.Max_RangeIncome_Time*3600
	end
	self.bprops.dayLookMediaTimes = self.bprops.dayLookMediaTimes + 1
	print("dealLookMediaOK, uid="..userinfo.uid..", self.bprops.dayLookMediaTimes="..self.bprops.dayLookMediaTimes..", userinfo.bprops.dayLookMediaTimes="..userinfo.UserProps.bprops.dayLookMediaTimes)
	UserProps:sendUserLookMediaInfo(userinfo)
	return ERROR_CODE.SUCCESS
end


function UserProps:AddDayLookMediaTimes(userinfo)
	if userinfo == nil then
		return ERROR_CODE.UNKNOWN_ERROR
	end
	if GlobalConst.Max_Adviertisement_Times <= self.bprops.dayLookMediaTimes then
		return
	end
	if self.bprops.dayLookMediaTimes == nil then
		self.bprops.dayLookMediaTimes = 0
	end
	self.bprops.dayLookMediaTimes = self.bprops.dayLookMediaTimes + 1
	UserProps:sendUserLookMediaInfo(userinfo)
	return ERROR_CODE.SUCCESS
end

function UserProps:dealLookMediaLevel(userinfo)
	if userinfo == nil then
		return ERROR_CODE.UNKNOWN_ERROR 
	end
	if self.bprops.dayLookMediaLevel == nil then
		self.bprops.dayLookMediaLevel = 0	
	end
	local id = self.bprops.dayLookMediaLevel + 1 + 1
	local profitAddData = ProfitAddData[id]
	if profitAddData == nil then
		return ERROR_CODE.TABLE_ERROR
	end
	--检测货币
	local cost = profitAddData.prices
	local args = string.split(cost, '_')
	if #args == 0 then 
		return ERROR_CODE.TABLE_ERROR
	end 
	local moneytype = tonumber(args[1])
	local moneynum = tonumber(args[2])
	if UserInfo.CheckUserMoney(userinfo, moneytype, moneynum) == false then
		if moneytype == static_const.Static_ItemType_Gold then
			return ERROR_CODE.MONEY_NOT_ENOUGH
		elseif moneytype == static_const.Static_ItemType_Diamond then
			return ERROR_CODE.DIAMOND_NOT_ENOUGH
		else 
			return ERROR_CODE.UNKNOWN_ERROR
		end
	end
	UserInfo.SubUserMoney(userinfo, moneytype, moneynum)	
	self.bprops.dayLookMediaLevel = self.bprops.dayLookMediaLevel + 1
	self.bprops.pWorldGoldAddRatioValue = profitAddData.para
	UserProps:sendUserLookMediaInfo(userinfo)
	return ERROR_CODE.SUCCESS
end

function UserProps:initRandBoxPrize()
	for k,v in pairs(TreasureBoxData) do
		local aa = math.random(v.mintime, v.maxtime)	
		unilight.debug("initRandBoxPrize" .. " k:" .. k .. "   aa:" .. aa )
		local value = { onlinetime = aa, status = 0}
		self.ponline.bOnlinePrize[k] = value	
	end
end

function UserProps:addOnlineTime()
	self.ponline.bOnlineTime = self.ponline.bOnlineTime + 1
end
	
function UserProps:sendOnlineRandBoxInfo(userinfo)
	if userinfo == nil then
		return
	end
	local ponline = userinfo.UserProps.ponline
	local res = {} 
        res["do"] = "Cmd.SendUserOnlineRandBoxCmd_S"                                                                                     
        res["data"] = {
		onlinetime = ponline.bOnlineTime,
                onlineprize = ponline.bOnlinePrize,
                desc = "在线奖励数据返回",                                                                                    
        }
	unilight.response(userinfo.laccount, res)	
end

function UserProps:getOnlineRandBoxPrize(ptimeid,ctype,ptype)

	unilight.debug("getOnlineRandBoxPrize, uid="..self.owner.uid..", ptimeid:" .. ptimeid .." ctype:"..ctype.." ptype:"..ptype..", len="..#self.ponline.bOnlinePrize)

	for k, v in pairs(self.ponline.bOnlinePrize) do
		print("getOnlineRandBoxPrize, uid="..self.owner.uid..", key="..k..", value.status="..v.status..", value.onlinetime="..v.onlinetime)
	end

	if ptimeid < 1 or ptimeid > #self.ponline.bOnlinePrize then
		return ERROR_CODE.UNKNOWN_ERROR
	end
	local pinfo = self.ponline.bOnlinePrize[ptimeid] 
	if pinfo == nil then
		return ERROR_CODE.UNKNOWN_ERROR
	end
	print("getOnlineRandBoxPrize, self.ponline.bOnlineTime="..self.ponline.bOnlineTime..", pinfo.onlinetime="..pinfo.onlinetime)
	if self.ponline.bOnlineTime < pinfo.onlinetime then
		return ERROR_CODE.ONLINE_PRIZE_OUTTIME
	end
	local mul = 1
	if ctype == 1 then
		if  UserInfo.CheckUserMoney(self.owner,static_const.Static_MoneyType_Diamond, GlobalConst.OffLine_Doubling_Diamond) == true then
			UserInfo.SubUserMoney(self.owner,static_const.Static_MoneyType_Diamond, GlobalConst.OffLine_Doubling_Diamond)
			mul = 2	
		end
	elseif ctype == 2 then
		mul = 2
	end
	--发奖励
	local treasureBoxData = TreasureBoxData[ptimeid] 
	if treasureBoxData == nil then
		return ERROR_CODE.TABLE_ERROR 
	end
	if ptype == 1 then
		--直接增加金币
		UserInfo.AddUserMoney(self.owner,static_const.Static_MoneyType_Gold, math.floor(mul * treasureBoxData.time * self.owner.product) )		
	elseif ptype == 2 then
		--增加点击金币buff
		if self.bprops.pWorldGoldAddRatioValue == nil or self.bprops.pWorldGoldAddRatioValue == 0 then
			self.bprops.pWorldGoldAddRatioTime = os.time()
		end
		self.bprops.pClickGoldAddRatioValue = self.bprops.pClickGoldAddRatioValue + mul*treasureBoxData.multiple
		--self.bprops.pWorldGoldAddRatioValue =	self.bprops.pClickGoldAddRatioTime + mul*treasureBoxData.duration
		self.bprops.pClickGoldAddRatioTime =	self.bprops.pClickGoldAddRatioTime + treasureBoxData.duration
	end
	self.ponline.bOnlinePrize[ptimeid].status = 1
	return ERROR_CODE.SUCCESS
end

function UserProps:sendUserLookMediaInfo(userinfo)
	if userinfo == nil then
		return
	end

	local aprops = userinfo.UserProps
	local res = {}
        res["do"] = "Cmd.SendUserMediaInfoCmd_S"                                                                                     
        res["data"] = {
		level = aprops.bprops.dayLookMediaLevel,
		mtimes = aprops.bprops.dayLookMediaTimes,
		endtime = aprops.bprops.pWorldGoldAddRatioTime,
		desc = "视频数据返回",                                                                                      
        }
	unilight.response(userinfo.laccount, res)

	local res2 = { }
	res2["do"] = "Cmd.SendUserPropertyOnUseItemCmd_S"
	res2["data"] = {
		dayLookMediaTimes = aprops.bprops.dayLookMediaTimes, 
		dayLookMediaLevel = aprops.bprops.dayLookMediaLevel, 
		pClickGoldAddRatioValue = aprops.bprops.pClickGoldAddRatioValue,
		pClickGoldAddRatioTime	= aprops.bprops.pClickGoldAddRatioTime,
		pWorldGoldAddRatioValue = aprops.bprops.pWorldGoldAddRatioValue,
		pWorldGoldAddRatioTime = aprops.bprops.pWorldGoldAddRatioTime,
		pOfflineGoldAddRatioValue = aprops.bprops.pOfflineGoldAddRatioValue,
		pOfflineGoldAddRatioTime = aprops.bprops.pOfflineGoldAddRatioTime,
		
		desc = "属性返回",
	}
	unilight.response(userinfo.laccount, res2)
end

function UserProps:setUserProp(userinfo,itemtype,itemnum,paraone,paratwo)
	unilight.debug("3330" .. " itemtype:" .. itemtype .. " paraone:" .. paraone .. " paratwo" .. paratwo)
	if userinfo == nil then
		return 
	end
	if tonumber(paraone) == 0 then
		paraone = 1
	end

	--local mailid = 0
	local res = { }
	res["do"] = "Cmd.SendUserPropertyOnUseItemCmd_S"
	if itemtype == tonumber(static_const.Static_ItemType_Diamond) then
		UserInfo.AddUserMoney(userinfo, static_const.Static_MoneyType_Diamond, itemnum*paraone)
	elseif itemtype == tonumber(static_const.Static_ItemType_Gold) then
		UserInfo.AddUserMoney(userinfo, static_const.Static_MoneyType_Gold, itemnum*paraone)
	elseif itemtype == tonumber(static_const.Static_ItemType_Rmb) then

	elseif itemtype == tonumber(static_const.Static_ItemType_ProtectTimes) then
		self.props.pProtectTimes = self.props.pProtectTimes + itemnum*paraone  
		res["data"] = {
			pProtectTimes = self.props.pProtectTimes			
		}
	elseif itemtype == tonumber(static_const.Static_ItemType_Power) then
		self.props.pPower = self.props.pPower + itemnum*paraone  
		res["data"] = {
			pPower = self.props.pPower			
		}
	elseif itemtype == tonumber(static_const.Static_ItemType_GoldPerSecond) then
		local earning = userinfo.product;
		earning = math.ceil(earning * itemnum * paraone)
		UserInfo.AddUserMoney(userinfo, static_const.Static_MoneyType_Gold, earning)
		res["data"] = {
			goldCardValue  = earning
		}
	elseif itemtype == tonumber(static_const.Static_ItemType_BuildingProduceRate) then
		self.props.pBuildingProduceRate = self.props.pBuildingProduceRate + itemnum*paraone  
		res["data"] = {
			pBuildingProduceRate = self.props.pBuildingProduceRate			
		}
	elseif itemtype == tonumber(static_const.Static_ItemType_ClickGoldAdd) then
		self.props.pClickGoldAdd = self.props.pClickGoldAdd + itemnum*paraone  
		res["data"] = {
			pClickGoldAdd = self.props.pClickGoldAdd			
		}
	elseif itemtype == tonumber(static_const.Static_ItemType_WorldGoldAdd) then
		self.props.pWorldGoldAdd = self.props.pWorldGoldAdd + itemnum*paraone  
		res["data"] = {
			pWorldGoldAdd = self.props.pWorldGoldAdd			
		}
	elseif itemtype == tonumber(static_const.Static_ItemType_AutoClick) then
		self.props.pAutoClickTimes_Time = self.props.pAutoClickTimes_Time + itemnum*paraone*60
		self.props.pAutoClickTimes_Times = self.props.pAutoClickTimes_Times + itemnum*paratwo
		res["data"] = {
			pAutoClickTimes_Time = self.props.pAutoClickTimes_Time,			
			pAutoClickTimes_Times = self.props.pAutoClickTimes_Times			
		}
	elseif itemtype == tonumber(static_const.Static_ItemType_WeekCard) then
		if self.props.pAutoClickTimes_Times then
			self.props.pWeekCardEndTime = self.props.pWeekCardEndTime + itemnum*paraone*86400  
		else	
			self.props.pWeekCardEndTime = os.time() + itemnum*paraone*86400	
		end
		res["data"] = {
			pWeekCardEndTime = self.props.pWeekCardEndTime			
		}
		--mailid=8
	elseif itemtype == tonumber(static_const.Static_ItemType_MonthCard) then
		if self.props.pAutoClickTimes_Times then
			self.props.pMonthCardEndTime = self.props.pMonthCardEndTime + itemnum*paraone*86400 
		else	
			self.props.pMonthCardEndTime = os.time() + itemnum*paraone*86400	
		end
		res["data"] = {
			pMonthCardEndTime = self.props.pMonthCardEndTime			
		}
		--mailid=9
	elseif itemtype == tonumber(static_const.Static_ItemType_LifelongCard) then
		self.props.pHasLifelongCard = 1 
		res["data"] = {
			hasLifelongCard = self.props.pHasLifelongCard		
		}
		--mailid=10
	elseif itemtype == tonumber(static_const.Static_ItemType_Clothes) then
		table.insert(self.props.pClothes, itemid)
		res["data"] = {
			pClothes = self.props.pClothes			
		}
	elseif itemtype == tonumber(static_const.Static_ItemType_ClickGoldAddRatio) then
		self.props.pClickGoldAddRatio = self.props.pClickGoldAddRatio + itemnum*paraone  
		res["data"] = {
			pClickGoldAddRatio = self.props.pClickGoldAddRatio			
		}
	elseif itemtype == tonumber(static_const.Static_ItemType_WorldGoldAddRatio) then
		self.props.pWorldGoldAddRatio = self.props.pWorldGoldAddRatio + itemnum*paraone  
		res["data"] = {
			pWorldGoldAddRatio = self.props.pWorldGoldAddRatio			
		}
	elseif itemtype == tonumber(static_const.Static_ItemType_GoldRainTimeAdd)  then
		self.props.pGoldRainTimeAdd = self.props.pGoldRainTimeAdd + itemnum*paraone  
		res["data"] = {
			 pGoldRainTimeAdd = self.props.pGoldRainTimeAdd			
		}
	elseif itemtype == tonumber(static_const.Static_ItemType_OfflineGoldAddRatio) then
		self.props.pOfflineGoldAddRatio = self.props.pOfflineGoldAddRatio + itemnum*paraone  
		res["data"] = {
			pOfflineGoldAddRatio = self.props.pOfflineGoldAddRatio			
		}
	end
	--同步下
	unilight.response(userinfo.laccount, res)	
	UserProps:sendUserProps(userinfo)
	--发送邮件	
	--if mailid ~= 0 then
	--	userinfo.mailMgr:addNew(mailid, "", "")
	--end
	unilight.savefield("userinfo", userinfo.uid, "UserProps", self.props)	
	
end
function UserProps:getUserProp(userinfo,prop)
	--unilight.debug("00000获取props:" .. prop)
	if userinfo == nil then
		return 0
	end
	prop = tostring(prop)
	local value = 0.0
	local aprops = userinfo.UserProps
	if aprops == nil then
		return value
	end
	--unilight.debug("11111获取props:" .. prop)
	if prop == tostring("pProtectTimes") then
		value = aprops.props.pProtectTimes			
	elseif prop == tostring("pPower") then
		value = aprops.props.pPower
	elseif prop == tostring("pGoldPerSecond")  then
		value = aprops.props.pGoldPerSecond   
	elseif prop == tostring("pBuildingProduceRate") then
		value = aprops.props.pBuildingProduceRate  
	elseif prop == tostring("pClickGoldAdd") then
		value = aprops.props.pClickGoldAdd 
	elseif prop == tostring("pWorldGoldAdd") then
		value = aprops.props.pWorldGoldAdd   
	elseif prop == tostring("pAutoClickTimes_Time") then
		value = aprops.props.pAutoClickTimes_Time 
	elseif prop == tostring("pAutoClickTimes_Times") then
		value = aprops.props.pAutoClickTimes_Times
	elseif prop == tostring("pWeekCardEndTime") then
		value = aprops.props.pWeekCardEndTime 		
	elseif prop == tostring("pMonthCardEndTime") then
		value = aprops.props.pMonthCardEndTime
	elseif prop == tostring("pClothes") then
		value = aprops.props.pClothes
	elseif prop == tostring("pClickGoldAddRatio") then
		if aprops.props.pClickGoldAddRatio == nil then
			aprops.props.pClickGoldAddRatio = 0
		end
		if aprops.bprops.pClickGoldAddRatioValue == nil then
			aprops.bprops.pClickGoldAddRatioValue = 0
		end
		value = aprops.props.pClickGoldAddRatio + aprops.bprops.pClickGoldAddRatioValue 
	elseif prop == tostring("pWorldGoldAddRatio") then
		if aprops.props.pWorldGoldAddRatio == nil then
			aprops.props.pWorldGoldAddRatio = 0
		end
		if aprops.bprops.pWorldGoldAddRatioValue == nil then
			aprops.bprops.pWorldGoldAddRatioValue = 0
		end
		value = aprops.props.pWorldGoldAddRatio + aprops.bprops.pWorldGoldAddRatioValue
	elseif prop == tostring("pGoldRainTimeAdd")  then
		value = aprops.props.pGoldRainTimeAdd 
	elseif prop == tostring("pOfflineGoldAddRatio") then
		if aprops.props.pOfflineGoldAddRatio == nil then
			aprops.props.pOfflineGoldAddRatio = 0
		end
		if aprops.bprops.pOfflineGoldAddRatioValue == nil then
			aprops.bprops.pOfflineGoldAddRatioValue = 0
		end
		value = aprops.props.pOfflineGoldAddRatio + aprops.bprops.pOfflineGoldAddRatioValue 
	elseif prop == tostring("pHasLifelongCard") then
		value = aprops.props.pHasLifelongCard
	elseif prop == tostring("dayLookMediaTimes") then
		if aprops.bprops.dayLookMediaTimes == nil then
			aprops.bprops.dayLookMediaTimes = 0
		end
		value = aprops.bprops.dayLookMediaTimes
		print("getUserProp-1, uid="..userinfo.uid..", dayLookMediaTimes="..value..", GlobalConst.Max_Adviertisement_Times="..GlobalConst.Max_Adviertisement_Times)
	end
	if value == nil then
		value = 0
	end
	--unilight.debug("获取props:" .. prop)
	--unilight.debug("获取value:" .. value)
	return value 
end

--商城类
CreateClass("StoreMgr") 
--获得所有商品ID
StoreMgr = 
{
	goodsmap = {}
}
function StoreMgr:new(o)
        o = o or {}
        setmetatable(o, self)
        self.__index = self
        return o
end

function StoreMgr:init()
	for i, v in pairs(StoreData) do
		table.insert(self.goodsmap, v);
	--	unilight.debug("111", v.id)
	end
end

function StoreMgr:getAllStoreGoods()
	return self.goodsmap  
end

local MoneyType_Diamond = 1
local MoneyType_Gold = 2

--购买商品
function StoreMgr:buyGoods(laccount, goodsid, storeid)
	local uid = laccount.Id
	local userinfo = UserInfo.GetUserInfoById(uid)
	unilight.debug("购买商品" .. " uid:" .. uid .. " goodsid:" .. goodsid .. " storeid:".. storeid)
	if userinfo == nil then
		return false, ERROR_CODE.USER_NOT_EXIST
	end 

	local storedata = StoreData[goodsid]
	if not storedata then
		return false, ERROR_CODE.ITEM_NOT_EXIST
	end
	
	if storedata.storeid ~= storeid then
		return false, ERROR_CODE.STORE_ERR
	end
	
	--检测物品是否在item表	
	local items = storedata.sellitems
	local args = string.split(items, '_')
	if #args == 0 then 
		return false,ERROR_CODE.STORE_ITEMS_ERR
	end 
	local itemid = tonumber(args[1])
	local itemnum = tonumber(args[2])
	local itemdata = ItemData[itemid]
	if not itemdata then
		return false, ERROR_CODE.ITEM_NOT_EXIST
	end

	local itemtype = tonumber(itemdata.itemtype)

	--检测前置
	local beforeid = storedata.beforeid
	if beforeid ~= 0 then
		local buyitems = userinfo.UserItems:getUserHadBuyGoods()
		if buyitems then
			if userinfo.UserItems:checkUserHadItem(beforeid) == true then
			
			else
				return false,ERROR_CODE.STORE_ITEM_CANT_BUY	
			end
		else
		
		end
	end
	--检测货币
	local price = storedata.price
	local pargs = string.split(price, '_')	
	if #pargs == 0 then 
		return false,ERROR_CODE.STORE_PRICE_ERR
	end 
	local moneytype = tonumber(pargs[1])	
	local moneynum = tonumber(pargs[2])
	local ret = UserInfo.CheckUserMoney(userinfo,moneytype,moneynum)	
	if ret == false then
		if moneytype == static_const.Static_MoneyType_Diamond then
			return false, ERROR_CODE.STORE_DIAMOND_LACK
		end
		if moneytype == static_const.Static_MoneyType_Gold then
			return false, ERROR_CODE.STORE_GOLD_LACK
		end
	end
	--检测开启状态
	local openflag = storedata.openvalue
	if openf1ag == 0 then
		return false, ERROR_CODE.STORE_TIME_LOCKED
	end
	if tonumber(storedata.opentime) ~= 0  and tonumber(storedata.endtime) then
		local opentime = ttrutil.TimeByNumberDateGet(tonumber(storedata.opentime))
		local endtime = ttrutil.TimeByNumberDateGet(tonumber(storedata.endtime))
		local curtime = os.time() 
		if not (opentime < curtime and curtime < endtime) then
			return false,ERROR_CODE.STORE_TIME_LOCKED
		end
	end
	--扣货币
	if storeid == static_const.Static_StoreType_Items or storeid == static_const.Static_StoreType_User then
		--ret = UserInfo.CheckUserMoney(moneytype,moneynum)
		ret = UserInfo.CheckUserMoney(userinfo,moneytype,moneynum)
		if ret == false then
			if moneytype == static_const.Static_MoneyType_Diamond then
				return false, ERROR_CODE.STORE_DIAMOND_LACK
			end
			if moneytype == static_const.Static_MoneyType_Gold then
				return false, ERROR_CODE.STORE_GOLD_LACK
			end
		end
	end
	--处理购买逻辑	
	if storeid == static_const.Static_StoreType_Gift or storeid == static_const.Static_StoreType_Recharge then
		--走创单流程	
		local orderinfo = {}
		orderinfo["goodid"] = goodsid
		orderinfo["goodnum"] = 1
		orderinfo["rmb"] = moneynum*100
		orderinfo["extdata"] = 0	
		orderinfo["platplatid"] = global_plat_array["weixin_plat"]["platplatid"]
		orderinfo["payplatid"] = global_plat_array["weixin_plat"]["payplatid"]
		orderinfo["goodname"] = itemdata.name
		orderinfo["redirecturl"] = ""
		local bOk, desc = rechargemgr.CmdCreatePlatOrderRequest(laccount, orderinfo)
		if bOK == fa1se then
			unilight.error(desc)
			return true, ERROR_CODE.STORE_CREAT_ORDER	
		end
		unilight.debug("创建订单" .. " uid:" .. uid .. " goodsid:" .. goodsid .. " storeid:".. storeid)
		return true, ERROR_CODE.STORE_WAIT_ORDER	
	elseif storeid == static_const.Static_StoreType_Items or storeid == static_const.Static_StoreType_User then
		UserInfo.SubUserMoney(userinfo,moneytype,moneynum)
		userinfo.UserItems:addUserItems(goodsid)
	end
	
	--发货
	UserItems:useItem(userinfo,tonumber(itemid),tonumber(itemnum))
	unilight.debug("购买物品结束" .. " uid:" .. uid .. " goodsid:" .. goodsid .. " storeid:".. storeid)

	return true, ERROR_CODE.SUCCESS
end

StoreMgr:init()
