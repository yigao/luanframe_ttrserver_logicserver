--玩家每日任务数据
CreateClass("DailyTaskMgr")

--初始化数据
function DailyTaskMgr:init(owner)
	--玩家指正
	self.owner = owner
	--任务数据
	self.tasks = Map:New()
	self.tasks:Init()
	--活动值
	self.activity = 0

	--上一次更新的时间值
	self.lastTime = 0

	--活跃值奖励情况 活跃值ID--0 or 1 1今天已经领取，0没有领取
	self.activityReward = Map:New()
	self.activityReward:Init()
end

function DailyTaskMgr:GetActivity()
	return self.activity
end

--从DB数据里加载数据
function DailyTaskMgr:SetDBTable(data)
	if type(data.tasks) == "table" then
		for taskId, taskInfo in pairs(data.tasks) do
			local task = TaskData:New()
			task:SetDBTable(taskInfo)
			self.tasks:Insert(taskId, task)
		end
	end

	self.activity = data.activity
	self.lastTime = data.lastTime

	if type(data.activityReward) == "table" then
		for k,v in pairs(data.activityReward) do
			self.activityReward:Insert(k,v)
		end
	end
end

--把数据存到一个table中
function DailyTaskMgr:GetDBTable()
	local data = { }
	data.tasks = { }
	self.tasks:ForEach(
		function(taskId, taskInfo)
			data.tasks[taskId] = taskInfo:GetDBTable()
		end
	)

	data.activity = self.activity
	data.lastTime = self.lastTime
	data.activityReward = {}

	self.activityReward:ForEach(
		function(id, v)
			data.activityReward[id] = v
		end
	)
	return data
end

--判断活跃奖励是否存在
function DailyTaskMgr:IsExistActivityReward(id)
	if self.activityReward:Find(id) == nil then
		return false
	else
		return true
	end
end

--判断活跃奖励是否领取
function DailyTaskMgr:IsRecvActivityReward(id)
	local tmp = self.activityReward:Find(id)
	if tmp ~= nil and tmp == 1 then
		return true
	end
	return false
end

function DailyTaskMgr:SetActivityRewardRecv(id)
	local tmp = self.activityReward:Find(id)
	if tmp ~= nil then
		self.activityReward:Replace(id, 1)
		return
	end
end

--判断lastTime是否过了一天，需要reset
function DailyTaskMgr:IsReset()
	if common.IsSameDay(self.lastTime, os.time()) == false then
		return true
	else
		return false
	end
end

function DailyTaskMgr:SetLastTime()
	self.lastTime = os.time()
end

--When 0:00, call
function DailyTaskMgr:Reset()
	self.tasks:ForEach(
		function(taskId, taskInfo)
			if taskInfo:GetStatus() == TaskStatusEnum.Begin then
				local taskConf = taskTable[taskId]
				if taskConf ~= nil then
					if taskInfo:GetTimes() >= taskConf.param then
						taskInfo:SetStatus(TaskStatusEnum.Finish)
					end
				end
			end
		end
	)

	--后来的玩家可能没有数据
	if self.activityReward:Count() <= 0 then
		for id, info in pairs(taskActivity) do
			self.activityReward:Insert(id, 0)
		end
	end

	if self:IsReset() == false then return end

	self.activity = 0
	self.tasks:Clear()
	self.activityReward:Clear()
	self.lastTime = os.time()

	for id, info in pairs(taskActivity) do
		self.activityReward:Insert(id, 0)
	end

	for taskId, info in pairs(taskTable) do
		if info.taskType == static_const.Static_Const_Task_TaskType_DailyTask then
			local task = TaskData:New()
			task:init(taskId, info.taskEvent, 0, TaskStatusEnum.Begin)
			self.tasks:Insert(taskId, task)
		end
	end

    --有些任务可能被策划干掉了，这里也删掉他
    local tmp = {}
    self.tasks:ForEach(
        function(taskId, taskInfo)
            if taskTable[taskId] == nil then
                table.insert(tmp, taskId)
            end
        end
    )

    for k, taskId in pairs(tmp) do
        self.tasks:Remove(taskId)
	end
end

--增加每日任务进度
function DailyTaskMgr:addProgress(event, times)
	self.tasks:ForEach(
		function(taskId, taskInfo)
			if taskInfo.event == event and taskInfo:GetStatus() == TaskStatusEnum.Begin then
				taskInfo:AddTimes(times)
				local taskConf = taskTable[taskId]
				if taskConf ~= nil then
					if taskInfo:GetTimes() >= taskConf.param then
						taskInfo:SetStatus(TaskStatusEnum.Finish)

						--通知客户端 每日任务完成
						local req = { }
						req["do"] = "Cmd.NotifyUserTaskFinish_S"
						req["data"] = { 
							task_id = taskId
						}
						req.errno = unilight.SUCCESS
						local laccount = go.roomusermgr.GetRoomUserById(self.owner.uid)
						if laccount == nil then
							unilight.debug("sorry, the laccount of the ask_uid:" .. self.owner.uid .. " is nil")
						else
							unilight.success(laccount, req)
						end
					end
				end
			end
		end
	)
end
