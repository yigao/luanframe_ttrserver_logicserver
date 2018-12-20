Net.CmdReqBuyStoreGoodCmd_CS = function(cmd, laccount)
	local res = { }
	res["do"] = "Cmd.ReqBuyStoreGoodCmd_CS"
	
	local uid = laccount.Id
	local goodsid = cmd["data"].goodsid 
	local storeid = cmd["data"].type
	local ret,retcode = StoreMgr:buyGoods(laccount, goodsid, storeid)
	res["data"] = {
		goodsid = goodsid,
		ret = retcode, 
		desc = "购买返回",
	}
	return res
end

Net.CmdReqGetCardDayPrizeCmd_CS = function(cmd, laccount)
	local res = { }
	res["do"] = "Cmd.ReqGetCardDayPrizeCmd_CS"
	
	local uid = laccount.Id
	local goodsid = cmd["data"].goodsid 
	local ret, retcode = StoreMgr:getDayCardPrize(uid, goodsid)
	res["data"] = {
		goodsid = goodsid,
		ret = retcode, 
		desc = "领取每日奖励返回",
	}
	return res
end

Net.CmdReqGetGHadBuyGoodsCmd_C = function(cmd, laccount)
	local res = { }
	res["do"] = "Cmd.SendHadBuyStoreGoodsCmd_S"
	
	local uid = laccount.Id
	local userinfo = UserInfo.GetUserInfoById(uid)
	if userinfo ~= nil then
		local buyitems = userinfo.UserItems:getUserHadBuyGoods()
		res["data"] = {
			stgoods = buyitems,
			desc = "玩家已购买商城物品返回",		
		}
		return res
	end
	res["data"] = {
		desc = "玩家已购买商城物品返回",		
	}
	return res
end

Net.CmdReqGetAllStoreGoodsCmd_C = function(cmd, laccount)
	local res = { }
	res["do"] = "Cmd.SendAllStoreGoodsCmd_S"
	
	local uid = laccount.Id
	local goodsmap = StoreMgr:getAllStoreGoods()
	res["data"] = {
		goodsids = goodsmap,
		ret = retcode, 
		desc = "所有商城物品",
	}
	return res
end
--[[
Net.PmdCreatePlatOrderRequestSdkPmd_C = function(cmd, laccount)
        local res = {}
        res["do"] = "Pmd.CreatePlatOrderReturnSdkPmd_S"
        if cmd.data == nil or cmd.data.goodid == nil then
                res.data = {
                        resultCode = 1,
                        desc = "参数缺少"
                }
                return res
        end

        local rev = cmd.data
        local uid = laccount.Id
        local bOk, desc = chessrechargemgr.CmdCreatePlatOrderRequest(laccount, rev)
        if bOk == false then
                unilight.error(desc)
        end
end
]]--
-- 苹果充值成功查询
Net.PmdRechargeQueryRequestIOSSdkPmd_C = function(cmd, laccount)
        local platData = {
                myaccid = laccount.Id,
                platid = laccount.JsMessage.GetPlatid(),
               -- session = laccount.JsMessage.GetSession(),
		session = cmd.data.openkey,
        }
        cmd.data.data = platData
        cmd.data.roleid = laccount.Id
	cmd.data.extdata = cmd.data.openid
    	local resStr = json.encode(encode_repair(cmd.data))
    	local bok = go.buildProtoFwdServer("*Pmd.RechargeQueryRequestIOSSdkPmd_C", resStr, "LS")
    	if bok == true then
        	unilight.info("支付查询转发sdkserver".. resStr)
    	else
        	unilight.error("支付查询转发失败sdkserver".. resStr)
    	end
end


Net.CmdReqUserOfflinePrizeCmd_C = function(cmd, laccount)
	local uid = laccount.Id
	local userinfo = UserInfo.GetUserInfoById(uid)
	local ctype = cmd.data.ctype
	if userinfo ~= nil and cmd.data ~= nil then 
		UserInfo.DealOfflinePrize(userinfo, true, ctype)
	end
end

Net.CmdUserLookMediaOKCmd_CS = function(cmd, laccount)
	local res = { }
	res["do"] = "Cmd.UserLookMediaOKCmd_CS"
	
	local uid = laccount.Id
	local userinfo = UserInfo.GetUserInfoById(uid) 
	local ret = userinfo.UserProps:dealLookMediaOK(userinfo)	
	res["data"] = {
		ret = ret, 
		desc = "观看广告返回",
	}
	return res
end

Net.CmdReqUserAddPropsCmd_CS = function(cmd, laccount)
	local res = { }
	res["do"] = "Cmd.CmdReqUserAddPropsCmd_CS"
	local uid = laccount.Id
	local userinfo = UserInfo.GetUserInfoById(uid) 
	local ttype = cmd.data.ttype
	if ttype == 1 then
		local ret = userinfo.UserProps:dealLookMediaLevel(userinfo)
		res["data"] = {
			ret = ret, 
			desc = "收益加成返回",
		}
	else
	end
	return res
end

Net.CmdReqGetUserOnlineRandBoxPrizeCmd_CS = function(cmd, laccount)
	local res = { }
	res["do"] = "Cmd.ReqGetUserOnlineRandBoxPrizeCmd_CS"
	
	local uid = laccount.Id
	local userinfo = UserInfo.GetUserInfoById(uid) 
	local ptimeid = cmd.data.ptimeid
	local ctype = cmd.data.ctype
	local ptype = cmd.data.ptype
	local ret = userinfo.UserProps:getOnlineRandBoxPrize(ptimeid,ctype,ptype)
	res["data"] = {
		ret = ret,
		ptimeid = ptimeid,
		ctype = ctype,
		ptype = ptype, 
		desc = "领取在线奖励返回",
	}

	local res2 = { }
	res2["do"] = "Cmd.SendUserPropertyOnUseItemCmd_S"
	res2["data"] = {
		pWorldGoldAddRatioValue = userinfo.UserProps.bprops.pWorldGoldAddRatioValue,
		pWorldGoldAddRatioTime = userinfo.UserProps.bprops.pWorldGoldAddRatioTime, 
		pClickGoldAddRatioValue = userinfo.UserProps.bprops.pClickGoldAddRatioValue,
		desc = "属性返回",
	}
	unilight.response(userinfo.laccount, res2)

	return res
end
