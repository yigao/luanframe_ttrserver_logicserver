rechargemgr = {}

-- 初始化
function rechargemgr.Init()
	-- 创建订单数据表，
	unilight.info("创建gameorder表格---------------------")
	unilight.createdb("gameorder", "gameorder")
	gameOrderIdx 	= 1
end

-- 订单创建 --麻将大厅由于存在vip系统 根据lobbyId区分 所以在订单号前 带个数据
function rechargemgr.CreateGameOrder(uid, lobbyId)
	local gameOrder = ""
	if lobbyId == nil or tonumber(lobbyId) == nil then
		-- 由gameid + uid + platid + os.timer + gameOrderIdx组成
		local strGameid = "AAA"
		local strUid = string.format("%08d", tonumber(uid))
		local strTimer = string.format("%010d", go.time.Sec())
		local strIdx = string.format("%05d", gameOrderIdx)
		gameOrder = tostring(strGameid) .. strUid .. strTimer .. strIdx
	else
		-- 由gameid + uid + platid + os.timer + gameOrderIdx组成
		lobbyId = string.format("%04d", tonumber(lobbyId))
		local strGameid = "AAA"
		local strUid = string.format("%08d", tonumber(uid))
		local strTimer = string.format("%010d", go.time.Sec())
		local strIdx = string.format("%05d", gameOrderIdx)
		gameOrder = tostring(lobbyId) .. tostring(strGameid) .. strUid .. strTimer .. strIdx
	end
	gameOrderIdx = gameOrderIdx + 1
	return gameOrder
end

-- 所有平台支付统一管理入口
function rechargemgr.CmdCreatePlatOrderRequest(laccount, rev)
	local uid = laccount.Id
	laccount = go.accountmgr.GetAccountById(uid)
	local platId = laccount.JsMessage.GetPlatid()
	local gameOrder = rechargemgr.CreateGameOrder(uid, rev.extdata)
	local goodId = tonumber(rev.goodid)
	local goodNum = tonumber(rev.goodnum) or 1

	local tempRmb 	= tonumber(rev.rmb)
	local rmb = tempRmb * 1
	if rmb == nil or rmb == 0 then
		local desc = "充值参数有误， goodid 找不到对应的充值参数 " .. table.tostring(rev)
		return false, desc
	end

	local payPlatId = tonumber(rev.payplatid) or 0
	local roleId = uid
	local roleName = laccount.JsMessage.GetNickname()
	local originalMoney = rmb
	local orderMoney = rmb
	local goodName = tostring(rev.goodname)or ""
	local goodDesc = tostring(rev.gooddesc) or ""
	local redirectUrl = tostring(rev.redirecturl) or ""
	local extData = tostring(rev.extdata) or ""
	local platAppId = ""
	if rev.data ~= nil and rev.data.platappid ~= nil then
platAppId = tostring(rev.data.platappid)
	end
	-- 充值
	local log = "创建订单： uid " .. uid .. "  platId: " .. platId .. "  以分为单位充值金额为： " .. rmb .. " payPlatId:" .. payPlatId .. " 订单号:" .. gameOrder
	unilight.info(log)
	local aaa = laccount.CreatePlatOrderByPayPlatidTemp(gameOrder, roleName, goodName, redirectUrl, goodDesc, extData, roleId, originalMoney, orderMoney, goodId, goodNum, payPlatId, platAppId)
	unilight.info("CreatePlatOrderByPayPlatidTemp " .. tostring(aaa))
	return true, "ok"
end

-- 查询玩家指定时间内共充值金额(单位 -- 元)
function rechargemgr.CmdUserSumRechargeGetByUid(uid, timestamp1, timestamp2)
	timestamp1 = timestamp1 or 0
	timestamp2 = timestamp2 or os.time()
	local sumRecharge = 0
	local resList = unilight.chainResponseSequence(unilight.startChain().Table("gameorder").Filter(unilight.a(unilight.eq("uid", uid), unilight.eq("bok", 1), unilight.gt("timestamp", timestamp1), unilight.lt("timestamp", timestamp2))))
	for i, v in ipairs(resList) do
		sumRecharge = sumRecharge + v.rmb
	end
	return sumRecharge
end

-- 查询玩家指定时间内最高充值金额(单位 -- 元)
function rechargemgr.CmdUserMaxRechargeGetByUid(uid, timestamp1, timestamp2)
	timestamp1 = timestamp1 or 0
	timestamp2 = timestamp2 or os.time()
	local maxRecharge = 0
	local resList = unilight.chainResponseSequence(unilight.startChain().Table("gameorder").Filter(unilight.a(unilight.eq("uid", uid), unilight.eq("bok", 1), unilight.gt("timestamp", timestamp1), unilight.lt("timestamp", timestamp2))))
	for i, v in ipairs(resList) do
		if v.rmb > maxRecharge then
			maxRecharge = v.rmb
		end
	end
	return maxRecharge
end

-- 查询玩家从某个时间开始充值次数
function rechargemgr.CmdUserRechargeNumberGetByUid(uid, timeStamp)
	if timeStamp == nil then
		timeStamp = 0
	end
	local filter = unilight.a(unilight.eq("uid", uid), unilight.eq("bok", 1), unilight.gt("timestamp", timeStamp))
	local number = unilight.startChain().Table("gameorder").Filter(filter).Count()
	return number
end
