-- json
--json = cjson.new()

if Do == nil then
	Do = {}
end

-- Tcp.*简化Do.*的消息处理，可直接收发lua table消息 --
Tcp = Tcp or {}

-- 样例:房间广播
Tcp.roomBroadcast = function (jsRequest, roomuser)
	local s = json.encode(encode_repair(jsRequest))
	room = go.roommgr.GetRoomById(roomuser.RoomCur.Id)			--获取用户所在的房间
	room.BroadcastString(s)										--用户所在房间广播消息
	roomuser.Debug(s)											--打印日志
end

-- 样例:房间广播，不包括自己
Tcp.roomBroadcastExceptMe = function (jsRequest, roomuser)
	local s = json.encode(encode_repair(jsRequest))
	room = go.roommgr.GetRoomById(roomuser.RoomCur.Id)
	room.BroadcastStringExceptMe(s, roomuser.Id)				--用户所在房间广播消息，不向用户自己广播
	roomuser.Debug(s)
end

-- 样例:给所有房间里的所有用户发消息
Tcp.worldBroadcast = function (jsRequest)
	local s = json.encode(encode_repair(jsRequest))
	go.roommgr.BroadcastString(s)
	unilight.Debug(s)
end

-- 样例:登陆大厅,非肯定消息
-- 增加一个回调，给lua逻辑层，通知tcp链接进来了
Tcp.init_lobby_account = function(roomuser)
	if Tcp.account_connect ~= nil then
		Tcp.account_connect(roomuser)
		unilight.info("TCP建立成功，玩家可以进入游戏了" .. roomuser.Id)
	end
end
-- 样例:停机公告
-- 停机公告
Tcp.server_shutdown_notify = function(roomuser,servertime,lefttime,desc)
	unilight.warn("Tcp.server_shutdown_notify")
end

-- 当tcp上线时
Tcp.account_connect = function(roomuser)
     --local uid = roomuser.Id
end

-- 当tcp掉线时
 Tcp.account_disconnect = function(roomuser)
      --local uid = roomuser.Id
 end

-- 主动t人
-- laccount.Kickout("服务器t人下线")
-- 
--
Tcp.reconnect_login_ok = function(roomuser)
	unilight.info("reconnect_login_ok:" .. roomuser.Id)
end
Tcp.ping_change_account = function(laccount,oldping,newping)
	--unilight.info("ping_change_account:" .. laccount.Id)
end
Tcp.online_state_change_account = function(laccount,oldstate,newstate)
	--unilight.info("online_state_change_account:" .. laccount.Id)
end

-- 样例:创建房间
Tcp.createroom = function (cmd, roomuser)
	room = go.roommgr.CreateRoom()
	room.Owner = roomuser
	roomuser.RoomCur = room
	roomuser.Debug("创建房间成功:" .. room.Id)
end

-- 样例:申请进入房间
Tcp.intoroom = function (cmd, roomuser)
	room = go.roommgr.GetRoomById(cmd.data.roomid)
	if room == nil then
		roomuser.SendMessageBox("","","","未找到房间:" .. cmd.data.roomid)
		roomuser.SendString("未找到房间:" .. cmd.data.roomid)
		roomuser.Error("未找到房间:" .. cmd.data.roomid)
		return
	end
	roomuser.RoomCur = room
	room.Rum.AddRoomUser(roomuser)
	room.BroadcastMessageBox("","","","有人进入房间")
	roomuser.Debug("进入房间成功:" .. cmd.data.roomid)
end

-- 客户端主动断线 | 长连接断开的调用接口
Tcp.account_logout = function (roomuser)
    if nil == roomuser then return end
    --以下各游戏自行处理对应逻辑
    if TcpRoomUserLogout ~= nil then 
        TcpRoomUserLogout(roomuser)
    end
end

-- zwl增加一个主动被踢掉的一个接口
-- account.Kickout("测试服务器主动剔除玩家")   
--
setmetatable(Tcp,
{
	__index = Do,
	__newindex = function(t, k, handle)
		if handle == nil then
			Do[k] = nil
		else
			Do[k] = function(jsreq, roomuser)
				local req = unilight.getreq(jsreq)
				local r0, r1 = handle(req,roomuser)

				if roomuser == nil then
					return r0									-- return r0 for server test
				elseif r0 == nil then
					return										-- return nil?
				elseif type(r0) == "table" then
					unilight.success(roomuser, r0)				-- return {data}
				elseif r0 == unilight.DB_ERROR then
					unilight.faildb(roomuser, r1 or {})			-- return unilight.DB_ERROR, {data}?
				elseif r0 == unilight.SCRIPT_ERROR then
					unilight.scripterror(roomuser, r1 or {})	-- return unilight.SCRIPT_ERROR, {data}?
				elseif r0 == unilight.SUCCESS then
					unilight.success(roomuser, r1 or {}) 		-- return unilight.SUCCESS, {data}?
				elseif type(r0) == "string" then
					unilight.fail(roomuser, req, r0, r1) 		-- return "errno", "reason"
				else
					unilight.error("unsupported return type")
				end
			end
		end
	end,
})
