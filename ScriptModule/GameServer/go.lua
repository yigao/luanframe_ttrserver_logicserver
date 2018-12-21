go = go or {}
go.roomusermgr = {}
go.accountInfoMap = {}

function go.roomusermgr.GetRoomUserById(uid)
    return go.accountInfoMap[uid]
end