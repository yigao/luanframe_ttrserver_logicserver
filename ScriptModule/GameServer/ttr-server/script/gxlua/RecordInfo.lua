module('RecordInfo', package.seeall) -- 机器人信息

require "script/gxlua/class"

if RecordClass == nil then
	CreateClass("RecordClass")
end
RecordClass:SetClassName("Record")

GlobalRecordInfoMap = {}
recordLoopTimer = nil
function Init()
	if recordLoopTimer == nil then
		recordLoopTimer = unitimer.addtimermsec(RecordLoop, 100)
	end
end

function RecordLoop(room,userinfo)
	for k,v in pairs(GlobalRecordInfoMap) do
		local msg = table.remove(v.msglist,1) --用table.reverse优化
		if msg then
			if msg.uid == v.recorduid then
				--k.Debug("xxxxx:"..table.len(v.msglist) .. ":" .. msg.uid .. ":" .. k.Id .. ":" .. msg.msg)
			end
			if msg.brd or msg.uid == v.recorduid then
				k.SendString(msg.msg)
			end
		else
			RemoveRecord(k)
		end
	end
end

function CheckRecordUid(roomdata,recorduid)
	for k,v in pairs(roomdata.history.position) do
		if recorduid == k then
			return true
		end
	end
	return false
end
function AddRecord(laccount,roomdata,recorduid)
	if not recorduid or recorduid == 0 then
		recorduid = laccount.Id
	end
	laccount.Debug("开始播放录像:".. roomdata.roomid .. ":" .. roomdata.globalroomid)
	for k,v in pairs(roomdata.history.position) do
		roomdata.recorduid = roomdata.recorduid or k --这里暂时处理
		if recorduid == k then
			roomdata.recorduid = k --这里暂时处理
			break
		end
	end
	GlobalRecordInfoMap[laccount] = roomdata
end
function RemoveRecord(laccount)
	if GlobalRecordInfoMap[laccount] ~= nil then
		laccount.Debug("停止播放录像")
		GlobalRecordInfoMap[laccount] = nil
	end
end
