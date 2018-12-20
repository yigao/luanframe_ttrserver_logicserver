TaskConditionEnum = 
{
	LoginEvent = 0,						--登录
	BuildingLevelUpEvent = 1,			--升级建筑（的次数）
	BuildingChangeEvent = 2,			--建筑改造（的次数）
	TravelLevelUpEvent = 3,				--旅行团等级提升
	OpenMapEvent = 4,					--开启地图
	ClickEvent = 5,						--点击次数事件(点击旅行团)
	EmployFriendEvent = 6,				--雇佣好友事件
	CaptureFriendEvent = 7,				--抓捕好友事件
	StopCaptureEvent = 8,				--防御抓捕
	CostDiamondEvent  = 9,				--累积消耗砖石
	ApplyFriendEvent = 10,				--申请好友
	AskFriendEvent = 11,				--邀请好友玩游戏
	SharedGameEvent = 12,				--分享好友
	AllBuildingStarEvent = 13,			--建筑要达到的的总星级
	SpecifyBuildingLevelUpEvent = 14,	--升级指定建筑
	SpecifyBuildingStar = 15,			--指定建筑要达到的星级
	TravelLevelValueEvent = 16,			--旅行团要达到的等级
	AddFriendEvent = 17,				--添加好友
	VisitFriendEvent = 18,				--访问好友
	InspireFriendEvent = 19,			--鼓舞好友
	MischiefFriendEvent = 20,			--捣蛋好友
	OpenSpecifyMapEvent = 21,			--开启指定地图
}

TaskStatusEnum =
{
	Finish = 1,							--任务已完成，但未领取奖励
	Begin = 2,							--所有的任务都是自动开启，也没有开启任务的条件。主线任务中的任务是一个一个开启的
	Receive = 3,						--奖励已领取
	NotStarted = 4,						--任务未开始
}

OpenTypeEnum =
{
	Counting	= 1,					--逐步型，任务开启后才算次数
	Total 		= 2,					--累计型，任务未开始时就可计算进度，但要等任务开启后才能领奖, 是不是也算是计算进度？
}

CreateClass("TaskData")
function TaskData:init(id, event, times, status)
	self.id = id
	self.times = times
	self.status = status
	self.event = event
end

function TaskData:SetDBTable(data)
	self.id = data.id or self.id
	self.times = data.times or self.times
	self.status = data.status or self.status
	self.event = data.event or self.event
end

function TaskData:GetDBTable()
	local data = {}
	data.id = self.id
	data.times = self.times
	data.status = self.status
	data.event = self.event
	return data
end

function  TaskData:GetId()
	return self.id
end

function TaskData:GetTimes()
	return self.times
end

function TaskData:SetTimes(t)
	self.times = t
end

function TaskData:GetEvent()
	return self.event
end

function TaskData:GetStatus()
	self.status = self.status or 4
	return self.status
end

function TaskData:SetStatus(status)
	self.status = status
end

function TaskData:AddTimes(times)
	if times <= 0 then
		times = 0
	end
	self.times = self.times + times
end
