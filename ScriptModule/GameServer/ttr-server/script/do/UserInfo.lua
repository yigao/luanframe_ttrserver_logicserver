
UserInfo = {}

UserInfo.GlobalUserInfoMap = {} -- 玩家在线信息全局管理

--玩家系统初始化函数
function UserInfo.Init()
	unilight.addtimer("UserInfo.SaveUserInfoToDB",static_const.Static_Const_User_Save_Data_DB_Time)
end

--每天零点定时器
function UserInfo.ZeroTimer()
	--清理玩家
	UserInfo.AllUserZeroClear()
end

--玩家每天零点清理数据
function UserInfo.AllUserZeroClear()
	unilight.debug("每天零点开始清理玩家数据了.................")
	for uid, userInfo in pairs(UserInfo.GlobalUserInfoMap) do
		UserInfo.UserZeroClear(userInfo)
	end
end

--玩家每天零点清理数据
function UserInfo.UserZeroClear(userInfo)
	userInfo.UserProps:dealZeroInitProps()
	userInfo.dailyWelfare:dealZeroReset()
end

--定时保存玩家数据到DB
function UserInfo.SaveUserInfoToDB()
	unilight.debug("1分钟保存一次玩家在线数据.................")
	for uid, userInfo in pairs(UserInfo.GlobalUserInfoMap) do
		UserInfo:SaveUserInfoToDb(userInfo)
	end
end

--获取玩家的在线信息
function UserInfo.GetUserInfoById(uid)
	return UserInfo.GlobalUserInfoMap[uid]
end

function UserInfo.UpdateQqData(uid, head, name, sex)
	local userInfo = UserInfo.GetUserInfoById(uid)

	if userInfo ~= nil then
		userInfo.head = head
		userInfo.nickName = name
		userInfo.sex = sex
	end
end

function UserInfo.CreateTempUserInfo(uid)
	unilight.debug("Create new user info")

	local userInfo = {
		uid			= uid,
		nickName	= "测试员" .. uid,
		money		= GlobalConst.Initial_Gold,
		product		= 0,
		diamond		= GlobalConst.Initial_Diamond,
		star		= 0,
		settings	= {},
		sex			= 1,
		head		= "",
		firstLogin  = 1,--首次登陆
		friendAddontion = 0,
		online = fasle,
	}

	local world = World:new()
	world:init(userInfo)
	world:create()
	userInfo["world"] = world

	--日常任务数据
	local dailyTask = DailyTaskMgr:New()
	dailyTask:init(userInfo)
	userInfo["dailyTask"] = dailyTask

	--成就任务数据
	local achieveTask = AchieveTaskMgr:New()
	achieveTask:init(userInfo)
	userInfo["achieveTask"] = achieveTask

	--主线任务数据
	local mainTask = MainTaskMgr:New()
	mainTask:init(userInfo)
	userInfo["mainTask"] = mainTask

	--玩家商品
	local items = UserItems:new()
	items:init(userInfo)	
	userInfo["UserItems"] = items
	--玩家属性
	local props = UserProps:new()
	props:init(userInfo)
	userInfo["UserProps"] = props

	local mailMgr = MailMgr:new()
	mailMgr:init(userInfo)
	userInfo["mailMgr"] = mailMgr

	local dailySharing = DailySharing:new()
	dailySharing:init(userInfo)
	userInfo["dailySharing"] = dailySharing

	local collect = Collect:new()
	collect:init(userInfo)
	userInfo["collect"] = collect

	local dailyWelfare = DailyWelfare:new()
	dailyWelfare:init(userInfo)
	userInfo["dailyWelfare"] = dailyWelfare

    local dailyLogin = DailyLogin:new()
    dailyLogin:init(userInfo)
    userInfo["dailyLogin"] = dailyLogin

	local guide = Guide:new()
	guide:init(userInfo)
	userInfo["guide"] = guide

	local dailyDiamondReward = DailyDiamondReward:new()
	dailyDiamondReward:init(userInfo)
	userInfo["dailyDiamondReward"] = dailyDiamondReward

	local dailyLotteryDraw = DailyLotteryDraw:new()
	dailyLotteryDraw:init(userInfo)
	userInfo["dailyLotteryDraw"] = dailyLotteryDraw

	--玩家离线定时器，超过这个时间后，玩家离线，内存数据被删除
	userInfo["offline_timer"] = nil
	return userInfo
end

function UserInfo.CreateUserByDb(uid, dbUser)
	unilight.debug("Get user info from DB")

	local userInfo = {
		uid = uid,
		nickName = dbUser.nickName,
		money = dbUser.money,
		diamond = dbUser.diamond,
		friendAddontion = dbUser.friendAddontion or 0,
		star = dbUser.star or 0,
		head = dbUser.head or "",
		sex = dbUser.sex or 1,
		lastlogintime = dbUser.lastlogintime or 0,
		--firstLogin = dbUser.firstLogin or 1,
		firstLogin = 0, --只要走这里就不是第一次登陆
		product = dbUser.product or 0,
	}
	userInfo["settings"] = dbUser.settings or {}
--玩家商品
	local items = UserItems:new()
	items:init(userInfo)	
	userInfo["UserItems"] = items
	if dbUser.useritems ~= nil then
		items:setDBTable(dbUser.useritems)
	end
	--玩家属性
	local props = UserProps:new()
	props:init(userInfo)
	--userInfo["UserProps"] = props
	if dbUser.userprops ~= nil then
		props:setDBTable(dbUser.userprops)
	end
    userInfo["UserProps"] = props

	local world = World:new()
	world:init(userInfo)

	if dbUser["world"] == nil then
		unilight.warn("Load user info from DB, but there is no world data")
		world:create()
	elseif world:loadFromDb(dbUser.world) ~= true then
		unilight.warn("Can load world data from DB")
	end
	userInfo["world"] = world

	--Not to load data here
	local mailMgr = MailMgr:new()
	mailMgr:init(userInfo)
	userInfo["mailMgr"] = mailMgr

	--日常任务数据
	local dailyTask = DailyTaskMgr:New()
	dailyTask:init(userInfo)
	userInfo["dailyTask"] = dailyTask

	if dbUser.dailyTask ~= nil then
		dailyTask:SetDBTable(dbUser.dailyTask)
	end
	

	--成就任务数据
	local achieveTask = AchieveTaskMgr:New()
	achieveTask:init(userInfo)
	userInfo["achieveTask"] = achieveTask
	if dbUser.achieveTask ~= nil then
		achieveTask:SetDBTable(dbUser.achieveTask)
	end

	--主线任务数据
	local mainTask = MainTaskMgr:New()
	mainTask:init(userInfo)
	if dbUser.mainTask ~= nil then
		mainTask:SetDBTable(dbUser.mainTask)
	end
	userInfo["mainTask"] = mainTask

	local dailySharing = DailySharing:new()
	dailySharing:init(userInfo)
	if dbUser["dailySharing"] == nil then
		unilight.warn("Load user info from DB, but there is no dailySharing data")
		--DailySharing:create()
	elseif dailySharing:loadFromDb(dbUser.dailySharing) ~= true then
		unilight.warn("Can load dailySharing data from DB")
	end
	userInfo["dailySharing"] = dailySharing

	local collect = Collect:new()
	collect:init(userInfo)
	if dbUser["collect"] == nil then
		unilight.warn("Load user info from DB, but there is no collect data")
	elseif collect:loadFromDb(dbUser.collect) ~= true then
		unilight.warn("Can load collect data from DB")
	end
	userInfo["collect"] = collect

	local dailyWelfare = DailyWelfare:new()
	dailyWelfare:init(userInfo)
	if dailyWelfare:loadFromDb(dbUser.dailyWelfare) ~= true then
		unilight.warn("Can not load dailyWelfare data from DB")
	end
	userInfo["dailyWelfare"] = dailyWelfare

    local dailyLogin = DailyLogin:new()
    dailyLogin:init(userInfo)
    if dbUser["dailyLogin"] == nil then
        unilight.warn("Load user info from DB, but there is no dailyLogin data")
    elseif dailyLogin:loadFromDb(dbUser.dailyLogin) ~= true then
        unilight.warn("Can load dailyLogin data from DB")
    end
    userInfo["dailyLogin"] = dailyLogin

	local guide = Guide:new()
	guide:init(userInfo)
	if guide:loadFromDb(dbUser.guide) ~= true then
		unilight.warn("Can not load guide data from DB")
	end
	userInfo["guide"] = guide

	local dailyDiamondReward = DailyDiamondReward:new()
	dailyDiamondReward:init(userInfo)
	if guide:loadFromDb(dbUser.dailyDiamondReward) ~= true then
		unilight.warn("Can not load dailyDiamondReward data from DB")
	end
	userInfo["dailyDiamondReward"] = dailyDiamondReward

	local dailyLotteryDraw = DailyLotteryDraw:new()
	dailyLotteryDraw:init(userInfo)
	if dbUser.dailyLotteryDraw ~= nil and dailyLotteryDraw:loadFromDb(dbUser.dailyLotteryDraw) ~= true then
		unilight.warn("Can not load dailyLotteryDraw data from DB")
	end
	userInfo["dailyLotteryDraw"] = dailyLotteryDraw


    if userInfo.star == 0 then
		userInfo.star = world:recalcStar()
	end
	
	return userInfo
end

function UserInfo.DealOfflinePrize(userinfo, flag, ctype)
	if userinfo == nil then
		return
	end
	if ctype == nil or ctype == 0 then
		ctype = 0
	end
	
	local time = os.time()
	if userinfo.lastlogintime == nil then
		userinfo.lastlogintime = time
	end
	local earn = 0
	if userinfo.world ~= nil then
		earn = userinfo.product
	end

	time = time - userinfo.lastlogintime
	time = math.min(time, GlobalConst.Max_OffLine_Time)	

	local status = 0
	local mul = 1
	if flag == true then
		if ctype == 1 then 
			if  UserInfo.CheckUserMoney(userinfo,static_const.Static_MoneyType_Diamond, GlobalConst.OffLine_Doubling_Diamond) == true then
				UserInfo.SubUserMoney(userinfo,static_const.Static_MoneyType_Diamond, GlobalConst.OffLine_Doubling_Diamond)
				mul = 2	

			end
		elseif ctype == 2 then
			mul = 2	
		end
		
		status = 1
		userinfo.lastlogintime = time
	end	
	
	local earning = math.floor(mul * earn * time * GlobalConst.OffLine_Factor * (1 + userinfo.UserProps:getUserProp(userinfo,"pOfflineGoldAddRatio")))
	if flag == true and earning > 0 then
		UserInfo.AddUserMoney(userinfo, static_const.Static_MoneyType_Gold, earning)
	end
	
	local res = { }
	res["do"] = "Cmd.SendUserOfflinePrizeCmd_S"
	res["data"] = {
		offlinetime = time,
		earning = earning,
		mul = mul,
		status = status,
		desc = "离线奖励返回",		
	}
	unilight.response(userinfo.laccount, res)
end
function UserInfo.Update()
	for k,userInfo in pairs(UserInfo.GlobalUserInfoMap) do
		if userInfo.online == true then
			userInfo.world:update()
			userInfo.UserProps:addOnlineTime()
			userInfo.UserProps:dealBuffProps()
			UserInfo.SendUserMoney(userInfo)
		end
	end
end

function UserInfo.GetClientData(userInfo)
	local userInfoData = {
		uid = userInfo.uid,
		nickName = userInfo.nickName,
		money = userInfo.money,
		diamond = userInfo.diamond,
		star = userInfo.star,
		head = userInfo.head,
		sex = userInfo.sex,
		world = userInfo.world:sn(),
		approved = GlobalConst.Approved_or_not,
	}

	return userInfoData
end

function UserInfo.GetServerData(userInfo)
	local userInfoData = {
		uid = userInfo.uid,
		nickName = userInfo.nickName,
		money = userInfo.money,
		diamond = userInfo.diamond,
		star = userInfo.star,
		head = userInfo.head,
		sex = userInfo.sex,
		product = userInfo.product,
		lastlogintime = os.time(),
		world = userInfo.world:sn(),
		settings = userInfo.settings,
		dailySharing = userInfo.dailySharing:GetData(),
		collect = userInfo.collect:GetData(),
		dailyTask = userInfo.dailyTask:GetDBTable(),
		achieveTask = userInfo.achieveTask:GetDBTable(),
		mainTask = userInfo.mainTask:GetDBTable(),
		dailyWelfare = userInfo.dailyWelfare:GetData(),
		useritems = userInfo.UserItems:GetDBTable(),
		userprops = userInfo.UserProps:GetDBTable(),
        dailyLogin = userInfo.dailyLogin:GetData(),
		guide = userInfo.guide:GetData(),
		dailyDiamondReward = userInfo.dailyDiamondReward:GetData(),
		dailyLotteryDraw = userInfo.dailyLotteryDraw:GetData(),
		firstLogin = userInfo.firstLogin,
		friendAddontion = userInfo.friendAddontion,
	}

	return userInfoData
end

function UserInfo.Connected(uid)

end

function UserInfo.Disconnected(uid)
	local userInfo = UserInfo.GetUserInfoById(uid)

	if userInfo == nil then
		unilight.warn("User is nil")
		return
	end

	local data = {}
	data.cmd_uid = uid
	data.userInfo = {
		star = userInfo.star,
		money = userInfo.money,
		product = userInfo.product,
	}
	unilobby.SendCmdToLobby("Cmd.UserDisconnected_C", data)

	userInfo.online = false
	userInfo.firstLogin = 0
	userInfo.lastlogintime = os.time()

	UserInfo:SaveUserInfoToDb(userInfo)
	print("user Disconnected, uid="..userInfo.uid..", lastlogintime="..os.time())

	if userInfo["offline_timer"] == nil then
		userInfo["offline_timer"] = unilight.addtimer("UserInfo.offline_savedata", static_const.Static_Const_USER_INFO_MAX_ONLINE_TIME_AFTER_OFFLINE, userInfo.uid)
	end
end

function UserInfo.GetOrNewUserInfo(uid)
	local userInfo = UserInfo.GetUserInfoById(uid)

	if userInfo == nil then
		local dbUser = unilight.getdata("userinfo", uid)

		if dbUser == nil then
			userInfo = UserInfo.CreateTempUserInfo(uid)
			userInfo.firstLogin = 1
		else
			userInfo = UserInfo.CreateUserByDb(uid, dbUser)
			userInfo.firstLogin = 0
		end

		UserInfo.GlobalUserInfoMap[uid] = userInfo
	end

	return userInfo
end

function UserInfo:SaveUserInfoToDb(userInfo)
	if userInfo ~= nil then
		unilight.savedata("userinfo", UserInfo.GetServerData(userInfo))
		userInfo.mailMgr:saveToDb()
	end
end

function UserInfo.GetOfflineUserInfo(uid)
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
        local dbUser = unilight.getdata("userinfo", uid)

        if dbUser ~= nil then
			userInfo = UserInfo.CreateUserByDb(uid, dbUser)
			userInfo.online = false
			UserInfo.GlobalUserInfoMap[uid] = userInfo
			if userInfo["offline_timer"] == nil then
				userInfo["offline_timer"] = unilight.addtimer("UserInfo.offline_savedata", static_const.Static_Const_USER_INFO_MAX_ONLINE_TIME_AFTER_OFFLINE, userInfo.uid)

			end
        end
	end
	return userInfo
end

--玩家离线保存数据定时器
function UserInfo.offline_savedata(uid, timer)
	unilight.info("the user offline than ten then minute, del data...........")

	unilight.stoptimer(timer)

	local userInfo = UserInfo.GetUserInfoById(uid)

	if userInfo == nil then
		unilight.warn("User is nil")
		return
	end

	UserInfo:SaveUserInfoToDb(userInfo)

	UserInfo.GlobalUserInfoMap[uid] = nil

	--玩家数据被彻底删除，这个时候可惜需要改变中心服务器gameid zone
	local data = {}
	data.cmd_uid = uid
	unilobby.SendCmdToLobby("Cmd.UserInfoDateFromMemory_C", data)
end

--掉线重连
function UserInfo.ReconnectLoginOk(laccount)
	local uid 		= laccount.Id
	local userInfo = UserInfo.GetUserInfoById(uid)

	local isFirstLogin = false
	if userInfo == nil then
		local dbUser = unilight.getdata("userinfo", uid)

		if dbUser == nil then
			userInfo = UserInfo.CreateTempUserInfo(uid)
			isFirstLogin = true
		else
			userInfo = UserInfo.CreateUserByDb(uid, dbUser)
		end

		UserInfo.GlobalUserInfoMap[uid] = userInfo
	end

	--清理玩家定时器
	if userInfo["offline_timer"] ~= nil then
		unilight.stoptimer(userInfo["offline_timer"])
	end

	userInfo.online = true
	userInfo.firstLogin = 0

	--有可能需要重置每日任务数据
	userInfo.dailyTask:Reset()
	userInfo.achieveTask:LoadConfig()
	userInfo.mainTask:LoadConfig()

	--userInfo.nickName = name or userInfo.nickName
	--userInfo.head = head or userInfo.head
	--userInfo.sex = sex or userInfo.sex
	userInfo.laccount = laccount

	--只同步客户端需要的数据，UserInfo下面存有服务器需要的数据

	--处理属性重置
	UserProps:dealLoginInitProps(userInfo)

	UserInfo.DealOfflinePrize(userInfo, false, 0)

	--玩家产量初始化计算 依赖好友系统的加成计算
	userInfo.world:recalc()

	userInfo.dailyLogin:DealWithLogin()
	userInfo.dailySharing:DealWithLogin()
	userInfo.dailyDiamondReward:DealWithLogin()
	userInfo.dailyLotteryDraw:DealWithLogin()
	userInfo.dailyWelfare:DealWithLogin()

	local data = {}
	data.cmd_uid = uid
	data.userInfo = {
		star = userInfo.star,
		money = userInfo.money,
		product = userInfo.product,
	}
	unilobby.SendCmdToLobby("Cmd.UserReconncted_C", data)
end

--------------------------------------------------
--货币
function UserInfo.GetUserMoneyByUid(uid, moneytype)
	moneytype = tonumber(moneytype)
	local userinfo = UserInfo.GetUserInfoById(uid)
	if userinfo == nil then
		return 0
	end
	if moneytype == static_const.Static_MoneyType_Diamond then
		return userinfo.diamond
	end
	if moneytype == static_const.Static_MoneyType_Gold then
		return userinfo.money
	end
	return 0
end

function UserInfo.CheckUserMoneyByUid(uid, moneytype, moneynum)
	moneytype = tonumber(moneytype)
	moneynum = tonumber(moneynum)
	local userinfo = UserInfo.GetUserInfoById(uid)
	if userinfo == nil then
		return false
	end
	if moneytype == static_const.Static_MoneyType_Diamond then
		return userinfo.diamond >= moneynum
	end
	if moneytype == static_const.Static_MoneyType_Gold then
		return userinfo.money >= moneynum
	end
	return true
end
function UserInfo.AddUserMoneyByUid(uid, moneytype, moneynum)
	moneytype = tonumber(moneytype)
	moneynum = tonumber(moneynum)
	local userinfo = UserInfo.GetUserInfoById(uid)
	if userinfo == nil then
		return
	end
	if moneytype == static_const.Static_MoneyType_Diamond then
		userinfo.diamond = userinfo.diamond + moneynum
	end
	if moneytype == static_const.Static_MoneyType_Gold then
		userinfo.money = userinfo.money + moneynum
	end

	--同步下	
	UserInfo.SendUserMoney(userinfo)	
	return moneynum
end

function UserInfo.AddUserStar(userInfo, num)
	num = tonumber(num)
	if userInfo == nil or num <= 0 then
		return num
	end
	userInfo.star = userInfo.star + num
	userInfo.mainTask:addProgress(TaskConditionEnum.AllBuildingStarEvent, userInfo.star)
	return num
end

function UserInfo.SubUserMoneyByUid(uid, moneytype, moneynum)
	moneytype = tonumber(moneytype)
	moneynum = tonumber(moneynum)
	local userinfo = UserInfo.GetUserInfoById(uid)
	if userinfo == nil then
		return 0
	end
	local num = 0
	if moneytype == static_const.Static_MoneyType_Diamond then
		if userinfo.diamond > 0 then
			if userinfo.diamond > moneynum then
				userinfo.diamond = userinfo.diamond - moneynum
			else
				userinfo.diamond = 0
			end
			num = moneynum
			--任务系统，任务完成情况
			userinfo.achieveTask:addProgress(TaskConditionEnum.CostDiamondEvent,moneynum)
			userinfo.dailyTask:addProgress(TaskConditionEnum.CostDiamondEvent, moneynum)
			userinfo.mainTask:addProgress(TaskConditionEnum.CostDiamondEvent, moneynum)
		end
	end
	if moneytype == static_const.Static_MoneyType_Gold then
		if userinfo.money > 0 then
			if userinfo.money > moneynum then
				userinfo.money = userinfo.money - moneynum
			else
				userinfo.money = 0
			end
			num = moneynum
		end
	end
	if num then
		--同步下	
		UserInfo.SendUserMoney(userinfo)	
	end
	return num

end
function UserInfo.GetUserMoney(userinfo, moneytype)
	moneytype = tonumber(moneytype)
	if userinfo == nil then
		return 0
	end
	if moneytype == static_const.Static_MoneyType_Diamond then
		return userinfo.diamond
	end
	if moneytype == static_const.Static_MoneyType_Gold then
		return userinfo.money
	end
	return 0
end
function UserInfo.CheckUserMoney(userinfo, moneytype, moneynum)
	moneytype = tonumber(moneytype)
	moneynum = tonumber(moneynum)
	if userinfo == nil then
		return
	end
	if moneytype == static_const.Static_MoneyType_Diamond then
		return userinfo.diamond >= moneynum
	end
	if moneytype == static_const.Static_MoneyType_Gold then
		return userinfo.money >= moneynum
	end
	return true
end
function UserInfo.AddUserMoney(userinfo, moneytype, moneynum)
	moneytype = tonumber(moneytype)
	moneynum = tonumber(moneynum)
	if userinfo == nil then return 0 end
	if moneytype == static_const.Static_MoneyType_Diamond then
		userinfo.diamond = userinfo.diamond + moneynum
	end
	if moneytype == static_const.Static_MoneyType_Gold then
		userinfo.money = userinfo.money + moneynum
	end
	--同步下	
	UserInfo.SendUserMoney(userinfo)

	return moneynum
end

function UserInfo.SubUserMoney(userinfo, moneytype, moneynum)
	moneytype = tonumber(moneytype)
	moneynum = tonumber(moneynum)
	if userinfo == nil then
		return 0
	end
	local num = 0
	if moneytype == static_const.Static_MoneyType_Diamond then
		if (userinfo.diamond) > 0 then
			if (userinfo.diamond) > (moneynum) then
				userinfo.diamond = userinfo.diamond - moneynum
			else
				userinfo.diamond = 0
			end
			num = moneynum
			--任务系统，任务完成情况
			userinfo.achieveTask:addProgress(TaskConditionEnum.CostDiamondEvent, moneynum)
			userinfo.dailyTask:addProgress(TaskConditionEnum.CostDiamondEvent, moneynum)
			userinfo.mainTask:addProgress(TaskConditionEnum.CostDiamondEvent, moneynum)
		end
	end
	if moneytype == static_const.Static_MoneyType_Gold then
		if userinfo.money > 0 then
			if userinfo.money > moneynum then
				userinfo.money = userinfo.money - moneynum
			else
				userinfo.money = 0
			end
			
			num = moneynum
		end
	end
	unilight.debug("end, SubUserMoney-002, uid="..userinfo.uid..", moneytype="..moneytype..", moneyNum="..moneynum ..",num:" .. num)
	if num then
		--同步下	
		UserInfo.SendUserMoney(userinfo)	
	end
	return num
end

function UserInfo.SendUserMoney(userinfo)
--	unilight.debug("SendUserMoney-001")
	if userinfo == nil then
		return 0
	end
	local res = { }
	res["do"] = "Cmd.SendUserMoneyCmd_S"
	
	local diamond = userinfo.diamond
	local money = userinfo.money
	res["data"] = {
		diamond = userinfo.diamond,
		gold = userinfo.money,
		desc = "玩家货币返回",
	}
	unilight.response(userinfo.laccount, res)
--	unilight.debug("SendUserMoney-002")
	return res
end
------------------------------------------------------


--中心服务器通知加钱扣钱
Lby.CmdNotifyAddUserMoney_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetOfflineUserInfo(uid)
	if userInfo == nil then
        unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

	UserInfo.AddUserMoney(userInfo, cmd.data.moneytype, cmd.data.moneynum)
	if userInfo.online == false then
		UserInfo:SaveUserInfoToDb(userInfo)
	end
end

--中心服务器通知加钱扣钱
Lby.CmdNotifySubUserMoney_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetOfflineUserInfo(uid)
	if userInfo == nil then
        unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

	UserInfo.SubUserMoney(userInfo, cmd.data.moneytype, cmd.data.moneynum)
	if userInfo.online == false then
		UserInfo:SaveUserInfoToDb(userInfo)
	end
end

--中心服务器通知使用物品
Lby.CmdNotifyUseItem_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetOfflineUserInfo(uid)
	if userInfo == nil then
        unilight.error("userinfo is not exist,uid:"..uid)
		return
	end
	
	UserItems:useItem(userInfo, cmd.data.itemid, cmd.data.itemnum)
	if userInfo.online == false then
		UserInfo:SaveUserInfoToDb(userInfo)
	end
end

--中心服务器消息通知
Lby.CmdMsgNewCmd_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
        unilight.error("userinfo is not exist,uid:"..uid)
		return
	end
	
	unilight.response(userInfo.laccount, cmd)
end

Lby.CmdUserTravelAngerUpdate_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
        unilight.error("userinfo is not exist,uid:"..uid)
		return
	end
	
	unilight.response(userInfo.laccount, cmd)
end

Lby.CmdUpdateCalcAddontion_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
        unilight.error("userinfo is not exist,uid:"..uid)
		return
	end
	
	userInfo.friendAddontion = cmd.data.additon
end

--强制玩家离线,玩家可能已经登录别的服务器
Lby.CmdForceUserOffline_C = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid

    local userInfo = UserInfo.GetUserInfoById(uid)
	if userInfo == nil then
		return
	end

	--清理玩家定时器
	if userInfo["offline_timer"] ~= nil then
		unilight.stoptimer(userInfo["offline_timer"])
	end

	--UserInfo:SaveUserInfoToDb(userInfo)

	UserInfo.GlobalUserInfoMap[uid] = nil

	unilight.debug("user:"..uid.. " force offline..........")
end