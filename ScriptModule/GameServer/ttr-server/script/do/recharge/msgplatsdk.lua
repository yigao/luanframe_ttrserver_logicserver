
local StoreData = StoreData
-- 用来处理平台sdk
LoginClientTask = LoginClientTask or {}

-- 创建订单号返回
LoginClientTask.CreatePlatOrderReturnSdkPmd_S = function(task, cmd)
	local uid = cmd.GetData().GetMyaccid()
	local platId = cmd.GetData().GetPlatid()
	local gameOrder = cmd.GetGameorder()
	local roleId = cmd.GetRoleid()
	local originalMoney = cmd.GetOriginalmoney()
	local orderMoney = cmd.GetOrdermoney()
	local goodId = cmd.GetGoodid()
	local goodNum = cmd.GetGoodnum()
	local result = cmd.GetResult()
	local noticeUrl = cmd.GetNoticeurl()
	local platOrder = cmd.GetPlatorder()
	local sign = cmd.GetData().GetExtdata()
	local redirectUrl = cmd.GetRedirecturl()
	local payPlatId = cmd.GetPayplatid()
	local appGoodId= cmd.GetAppgoodid()
	local extData = cmd.GetExtdata()
	local createtime = cmd.GetCreatetime()
    	local platAppId = cmd.GetData().GetPlatappid()
	local rmb = orderMoney
		unilight.info("from sdk: CreatePlatOrderReturnSdkPmd_S,获取URL 订单号为：" .. gameOrder)
	if result ~= 0 then
		unilight.error("from sdk: CreatePlatOrderReturnSdkPmd_S,获取URL失败 订单号为：" .. gameOrder)
	else
		UserRechargeCreateOrderLog(gameOrder, platOrder, uid, payPlatId, rmb, "通过支付平台", goodId, goodNum)
	end
	local accountTcp = go.roomusermgr.GetRoomUserById(uid)
	if accountTcp == nil then
		unilight.error("accoutTcp is nil createplatorderReturn uid :" .. uid)
		return
	end
    if extData ~= nil and extData ~= "" then
        local temp = json2table(extData)
        if temp and temp.reissue == 1 then
            return
        end
    end
	res = {}
	res["do"] = "Pmd.CreatePlatOrderReturnSdkPmd_S"
	res.data = {
			data = {myaccid = uid, platappid = platAppId},
			gameorder	  = gameOrder,
			roleid		  = roleId,
			originalmoney = originalMoney,
			ordermoney	  = orderMoney,
			goodid		  = goodId,
			goodnum		  = goodNum,
			result		  = result,
			noticeurl	  = noticeUrl,
			platorder	  = platOrder,
			sign          = sign,
			redirecturl   = redirectUrl,
			payplatid     = payPlatId,
			appgoodid       = appGoodId,
			extdata       = extData, -- 暂时小程序填充 {offer_id, reissue}
            createtime    = createtime,
	}
	unilight.success(accountTcp, res)
end

-- sdk通知游戏服有玩家充值
LoginClientTask.NotifyRechargeRequestSdkPmd_S = function(task, cmd)
	local uid = cmd.GetData().GetMyaccid()
	local gameOrder = cmd.GetGameorder()
	local platOrder = cmd.GetPlatorder()
	local roleId = cmd.GetRoleid()
	local platId = cmd.GetData().GetPlatid()
	local rmb = cmd.GetOrdermoney()
	local originalmoney = cmd.GetOriginalmoney()
	local goodId = cmd.GetGoodid()
	local goodNum = cmd.GetGoodnum()
	local extData = cmd.GetExtdata()
	local result = cmd.GetResult()
	local bOk = 0
	local res = ""
	local remainderChips = 0
	local rechargeChips = 0
		unilight.info("支付: 订单号：" .. gameOrder .. "  支付金额： " .. rmb)
	if result ~= 0 then -- 失败
		unilight.error("支付失败: 订单号：" .. gameOrder .. "  支付金额： " .. rmb)
	else
		bOk, res, remainderChips, rechargeChips = RechargeReturnOk(uid, rmb, platId, gameOrder, platOrder, goodId, goodNum)
		if bOk ~= 0 then
			unilight.error(res)
            		return
		end
	end

	--返回吧
	local accountTcp = go.roomusermgr.GetRoomUserById(uid)
	if accountTcp == nil then
		unilight.error("laccount is null 但已充值到位rmb:" .. rmb .. "  uid: " .. uid)
		return
	end
--	local remainderChips = tostring(UserInfo.RoomDiamondGet(uid))

	res = {}
	res["do"] = "Pmd.NotifyRechargeRequestSdkPmd_S"
	res.data = {
		platorder = platOrder,
		gameorder = gameOrder,
		roleid = roleId,
		originalmoney = originalMoney,
		ordermoney = rmb,
		goodid = goodId,
		goodnum = goodNum,
		result = result,
--		extdata = remainderChips,
	}
	unilight.success(accountTcp, res)
end

function RechargeReturnOk(uid, rmb, platId, gameOrder, platOrder, goodId, goodNum)
    -- 校验订单是否异常
    	local order = unilight.getdata("gameorder", gameOrder)
        unilight.info("Rmb道具购买:".. gameOrder)
    	if order == nil then
		local res = "收到充值结果，但是找不到订单:" .. gameOrder
		return 1, res
    	else
        	if order.bok == 1 then
            		local res = "收到充值结果，该订单已发货 当前为重复推送:" .. gameOrder
            		return 2, res
        	end
   	 end
    	--发货
	local userinfo = UserInfo.GetUserInfoById(uid)
	if userinfo == nil then
		return 3
	end
 
	local storedata = StoreData[goodId]
	if not storedata then
		return 3
	end

	local items = storedata.sellitems
	local args = string.split(items, '_')
	if #args == 0 then 
		return 3
	end 
	local itemid = args[1]
	local itemnum = args[2]
	UserItems:useItem(userinfo,tonumber(itemid),tonumber(itemnum))
	local frecharge = 0
	--首充
	if userinfo.UserItems:checkIsFirstRecharge(goodId) == true then
		if storedata.firstdiamond then
			local fitems = storedata.firstdiamond
			local fargs = string.split(fitems, '_')
			if #fargs == 2 then
				local fitemid = fargs[1]
				local fitemnum = fargs[2]
        unilight.info("首充:" .. uid ..  ",itemid:" .. tonumber(fitemid) .. ",itemnum:" .. tonumber(fitemnum))
				UserItems:useItem(userinfo,tonumber(fitemid),tonumber(fitemnum))
			end
		end
		frecharge = 1 
	else 
		--附赠
		if storedata.otherdiamond then
			local oitems = storedata.otherdiamond
			local oargs = string.split(oitems, '_')
			if #oargs == 2 then
				local oitemid = oargs[1]
				local oitemnum = oargs[2]
        unilight.info("附赠:" .. uid ..  ",itemid:" .. tonumber(oitemid) .. ",itemnum:" .. tonumber(oitemnum))
				UserItems:useItem(userinfo,tonumber(oitemid),tonumber(oitemnum))
			end
		end
	end
        unilight.info("充值完成:")
	userinfo.UserItems:addRechargeItems(goodId)
	userinfo.UserItems:addUserItems(goodId)
	--通知客户端
	local res = { } 
	res["do"] = "Cmd.ReqBuyStoreGoodCmd_CS"
	res["data"] = { 
                goodsid = goodId,
		frecharge = frecharge,
                ret = 0, 
                desc = "充值购买返回",
        }
	unilight.response(userinfo.laccount, res)
	unilight.info("玩家发货成功：" .. uid .. "   gameorder " .. gameOrder .. "  goodId:" .. goodId)
--[[
	-- 从表格中 获取该商品的具体信息 (不直接从表格读的原因是： 表格以 id 索引 而不是以 shopid 索引)
	local tableShop = chessrechargemgr.MapTableShop[goodId]
	if tableShop.priceType ~= 1 then
		local res = "收到充值结果，但是该道具不是rmb道具   道具goodId为： " .. goodId
		return 3, res
	end
	if tableShop.price * goodNum ~= rmb then
		local res = "收到充值结果，但是购买道具需求金额:" .. tableShop.price * goodNum .. " 跟 充值金额:" .. rmb .. "不匹配"
		return 4, res
	end
    -- 从充值订单中获取对应lobbyId
	local info = string.split(gameOrder, "AAA")
	local lobbyId  = nil
	if info ~= nil and info[1] ~= nil then
        lobbyId  = tonumber(info[1])
	end
	lobbyId = lobbyId or GetLobbyId()

    local tempActualNum
    -- 购买道具
    if tableShop.shopType == 2 then
        unilight.info("Rmb道具购买")
        local summary = BackpackMgr.GetRewardGood(uid, tableShop.shopGoods.goodId, tableShop.shopGoods.goodNbr * goodNum, nil, nil, nil, ChessItemsHistory.ENUM_TYPE.REC, "Rmb道具购买")
    else
        local type2Item = nil
        -- 充值类型 存在三种 钻石、房卡、金币 4、5、1
        if tableShop.shopType == 1 then
            unilight.info("金币充值")
            type2Item = 32
        elseif tableShop.shopType == 4 then
            unilight.info("钻石充值")
            type2Item = 6
        elseif tableShop.shopType == 5 then
            unilight.info("房卡充值")
            type2Item = 1
        else
            unilight.error("充值类型有误")
            return 5, "充值类型有误"
        end

        -- 最终汇总出 收入多少货币 正常情况下 只能存在一种类型
        local summary = BackpackMgr.GetRewardGood(uid, tableShop.shopGoods.goodId, tableShop.shopGoods.goodNbr * goodNum, nil, nil, nil, ChessItemsHistory.ENUM_TYPE.REC, "官方充值:".. gameOrder)
    end

	UserRechargeOkLog(gameOrder, platOrder, uid, rmb,  "充值购买成功", tempActualNum)

    -- 更新充值次数和总金额
    UpdateRechargeInfo(uid, rmb, lobbyId)
]]--
	return 0, "充值购买成功", remainder, 0
end

function UserRechargeCreateOrderLog(gameOrder, platOrder, uid, payPlatId, rmb, marks, goodId, goodNbr)
	local rmbYuan = rmb/100
--[[	local platInfo = chessuserinfodb.RUserPlatInfoGet(uid)
	if platInfo == nil then
		unilight.error("UserRechargeCreateOrderLog玩家不存在" .. uid)
		return false
	end
	local userInfo = chessuserinfodb.RUserInfoGet(uid)
]]
	local log = {
		gameorder = gameOrder,
		platorder = platOrder,
		uid = uid,
--		nickname = userInfo.base.nickname,
--		platid = platInfo.platId,
	--	plataccount = platInfo.platAccount,
	--	subplatid = platInfo.subPlatId,
		payplatid = payPlatId,
		rmb = rmbYuan,
        	goodid = goodId, -- 订单加上购买的物品id
        	goodnbr= goodNbr,
		bok = 0,
		marks = marks,
		createtime = ttrutil.FormatDate2Get(),
        	sendtoagent = 0, -- 是否通知过代理商 0/1/2 未通知、成功、异常
	}
	unilight.savedata("gameorder", log)
	unilight.info("玩家创建订单成功：" .. uid .. "   gameorder " .. gameOrder .. "  rmb:" .. rmbYuan)
end

function UserRechargeOkLog(gameOrder, platOrder, uid, rmb, flag, actualNum)
	local rmbYuan = rmb/100
	local log = unilight.getdata("gameorder", gameOrder)
	if table.empty(log)then
		local filter = unilight.eq("platorder", platOrder)
		log = unilight.getByFilter("gameorder", filter, 1)
	end
	if table.empty(log)then
		unilight.error("遇见了未创建订单，但是支付成功的实例" .. gameOrder .. "UID" .. uid .. "  rmb:" .. rmb)
		return false
    end

	local userInfo = chessuserinfodb.RUserInfoGet(uid)

	log.bok = 1
	log.flag = flag
	log.rechargetime = ttrutil.FormatDate2Get()
	log.remainder = userInfo.property.chips
	log.timestamp = os.time()
	log.actualnum = actualNum
	unilight.savedata("gameorder", log)
	unilight.info("充值成功：" .. uid .. "   gameorder " .. gameOrder .. "  rmb:" .. rmbYuan)
end

--更新充值次数和充值金额
function UpdateRechargeInfo(uid, rmb, lobbyId)
	local userData = UserInfo.GetUserDataById(uid)
	--充值次数
	userData.recharge.rechargeTimes = (userData.recharge.rechargeTimes or 0) + 1
	--当天首次充值时间
	local curTime = os.time()
	local temp = os.date("*t", curTime)
    local percentToYuan = math.floor(rmb/100)
    -- local zeroTime = ttrutil.ZeroTodayTimestampGetByTime(curTime)
    if userData.recharge.firstTime == nil or ttrutil.DateDayDistanceByTimeGet(userData.recharge.firstTime, curTime) ~= 0 then
		userData.recharge.firstTime = curTime
        -- 操作太耗时，直接给0
		-- userData.recharge.dailyRmb = chessrechargemgr.CmdUserSumRechargeGetByUid(uid, zeroTime, curTime)*100 - rmb
		userData.recharge.dailyRmb = 0
        if userData.recharge.dailyRmb < 0 then
            userData.recharge.dailyRmb = 0
        end
        -- 操作太耗时，直接给0
		-- userData.recharge.dailyTopRmb = chessrechargemgr.CmdUserMaxRechargeGetByUid(uid, zeroTime, curTime)*100
		userData.recharge.dailyTopRmb = 0
	end
    --每月累计充值
    local lastDate = os.date("*t", (userData.recharge.dailyTime or 0))
    if userData.recharge.monthRmb == nil then
        -- local monthtime = ttrutil.ZeroTodayTimestampGetByTime(os.time({year=temp.year, month=temp.month, day=1, hour=0}))
        -- 操作太耗时，直接给0
        -- userData.recharge.monthRmb = chessrechargemgr.CmdUserSumRechargeGetByUid(uid, monthtime, curTime)*100 - rmb
        userData.recharge.monthRmb = 0
        if userData.recharge.monthRmb < 0 then
            userData.recharge.monthRmb = 0
        end
    end
    if not(temp.year == lastDate.year and temp.month == lastDate.month) then
        userData.recharge.monthRmb = 0
    end
    userData.recharge.monthRmb = userData.recharge.monthRmb + rmb
	--当天累计充值金额
	userData.recharge.dailyRmb = (userData.recharge.dailyRmb or 0) + rmb

	--当天单次充值最高金额
	if userData.recharge.dailyTopRmb == nil or rmb > userData.recharge.dailyTopRmb then
		userData.recharge.dailyTopRmb = rmb
	end
	--历史充值最高金额
	if userData.recharge.historyTopRmb == nil or rmb > userData.recharge.historyTopRmb then
		userData.recharge.historyTopRmb = rmb
	end
	--充值总金额
	if userData.recharge.rechargeRmb == nil then
        -- 操作太耗时，直接给0
		-- userData.recharge.rechargeRmb = chessrechargemgr.CmdUserSumRechargeGetByUid(uid, 0, curTime)*100
		userData.recharge.rechargeRmb = rmb
	else
		userData.recharge.rechargeRmb = userData.recharge.rechargeRmb + rmb
	end
    -- 更新摇钱树
    if CheckIsHaoCaiLobby(lobbyId) then
        if userData.recharge.firstTime == nil or userData.moneytree == nil then
            -- 创建摇钱树
            MoneyTreeMgr.CreateUserMoneyTreeData(userData, percentToYuan)
        else
            MoneyTreeMgr.UpdateUserMoneyTreeLevel(userData, percentToYuan)
        end
    end
    --每天最后一次充值时间记录
	userData.recharge.dailyTime = curTime
	-- 存档
	UserInfo.SaveUserData(userData)

    if CheckIsHaoCaiLobby(lobbyId) then
        UserInfo.SendUserInfoToLobbyClient(uid)
    end

	--更新每日充值任务
	DaysTaskMgr.CheckDailyRecharge(uid, lobbyId)
end
