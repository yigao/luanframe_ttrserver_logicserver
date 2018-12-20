
--成就任务

CreateClass("MainTaskMgr")

--初始化数据
function MainTaskMgr:init(owner)
	--玩家指正
	self.owner = owner
	--任务数据
	self.tasks = Map:New()
	self.tasks:Init()
	--当前进行中的任务，领取了当前任务后，才触发下一个任务开始进行
	self.taskIdInProgress = 0
end

--从DB数据里加载数据
function MainTaskMgr:SetDBTable(data)
	if type(data.tasks) == "table" then
		for taskId, taskInfo in pairs(data.tasks) do
			local task = TaskData:New()
			task:SetDBTable(taskInfo)
			self.tasks:Insert(taskId, task)
		end
	end
	self.taskIdInProgress = data.taskIdInProgress or self.taskIdInProgress
end

--检查配置，并把没有的任务加载到配置中
function MainTaskMgr:LoadConfig()
	self.tasks:ForEach(
			function(taskId, taskInfo)
				--print("MainTaskMgr:LoadConfig, self.tasks, uid="..self.owner.uid..", taskId="..taskId..", event="..taskInfo.event..", times="
				--..taskInfo.times..", status="..taskInfo:GetStatus())
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


	--检查配置，并把没有的任务加载到配置中
	for taskId, info in pairs(taskTable) do
		if info.taskType == static_const.Static_Const_Task_TaskType_MainTask and self.tasks:Find(taskId) == nil then
			local task = TaskData:New()
			local taskStatus = TaskStatusEnum.NotStarted
			if info.openType == OpenTypeEnum.Total then
				taskStatus = TaskStatusEnum.Begin
			end
			task:init(taskId, info.taskEvent, 0, taskStatus)
			self.tasks:Insert(taskId, task)
			--print("self.tasks:Insert, self.tasks.taskId="..taskId..", event="..info.taskEvent)
		end
	end

	print("MainTaskMgr:LoadConfig, uid="..self.owner.uid..", taskIdInProgress="..self.taskIdInProgress)
	--如果当前没有进行中的id，找到最小的任务id设它为进行中
	if self.taskIdInProgress == 0 then
		local minTaskId = 0
		self.tasks:ForEach(
				function(taskId, taskInfo)
					if minTaskId == 0 then
						minTaskId = taskId
					end
					if taskId < minTaskId then
						minTaskId = taskId
					end
				end
		)

		local taskInfo = self.tasks:Find(minTaskId)
		if taskInfo ~= nil then
			taskInfo:SetStatus(TaskStatusEnum.Begin)
		end
		--self.tasks:Find(minTaskId).status = TaskStatusEnum.Begin
		self.taskIdInProgress = minTaskId
		print("LoadConfig, minTaskId="..minTaskId..", taskIdInProgress="..self.taskIdInProgress)
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

--把数据存到一个table中
function MainTaskMgr:GetDBTable()
	local data = { }
	data.tasks = { }
	data.taskIdInProgress = self.taskIdInProgress
	self.tasks:ForEach(
			function(taskId, taskInfo)
				data.tasks[taskId] = taskInfo:GetDBTable()
			end
	)

	return data
end

function MainTaskMgr:GetTaskIdInProgress()
	print("GetTaskIdInProgress, uid="..self.owner.uid..", taskIdInProgress="..self.taskIdInProgress)
	return self.taskIdInProgress
end

function MainTaskMgr:SetNextTaskIdInProgress()
	local taskInfo = self.tasks:Find(self.taskIdInProgress + 1)
	if taskInfo == nil then
		print("MainTaskMgr:SetNextTaskIdInProgress(), uid="..self.owner.uid..", nextTaskIdInProgress="..self.taskIdInProgress.."taskInfo is nil")
		return nil
	end

	self.taskIdInProgress = self.taskIdInProgress + 1
	taskInfo:SetStatus(TaskStatusEnum.Begin)
	if taskInfo:GetTimes() >= taskTable[taskInfo:GetId()].param then
		taskInfo:SetStatus(TaskStatusEnum.Finish)
	end
	print("MainTaskMgr:SetNextTaskIdInProgress(), uid="..self.owner.uid..", nextTaskIdInProgress="..self.taskIdInProgress..", event="..taskInfo.event
			..", times="..taskInfo.times..", status="..taskInfo:GetStatus())
	return taskInfo
end

--增加任务进度
function MainTaskMgr:addProgress(event, times, param2)
	param2 = param2 or 0
	print("MainTaskMgr:addProgress, uid="..self.owner.uid..", event="..event..", times="..times..", param2="..param2)
	self.tasks:ForEach(
			function(taskId, taskInfo)
				local taskConf = taskTable[taskId]
				if taskConf ~= nil then
					local tempParam2 = taskConf.param2
					local isOk = taskInfo.event == event and taskInfo:GetStatus() == TaskStatusEnum.Begin and param2 == tempParam2
					if isOk then
						local isLevelEvent = event == TaskConditionEnum.SpecifyBuildingStar or event == TaskConditionEnum.AllBuildingStarEvent
								or event == TaskConditionEnum.TravelLevelValueEvent
						if isLevelEvent then
							taskInfo:SetTimes(times) --此处的times为级数，直接赋值。其他的普通事件的times是次数的意思，用AddTimes
							if times >= taskConf.param then
								taskInfo:SetTimes(times)
								taskInfo:SetStatus(TaskStatusEnum.Finish)
								self:sendTaskFinish(taskId)
							end
						else
							taskInfo:AddTimes(times)
							if taskInfo:GetTimes() >= taskConf.param then
								taskInfo:SetTimes(taskConf.param)
								taskInfo:SetStatus(TaskStatusEnum.Finish)
								self:sendTaskFinish(taskId)
							end
						end
						if taskId == self.taskIdInProgress then
							self:sendTaskProgress(taskId, taskInfo:GetTimes(), taskConf.param)
						end
					end
				end
			end
	)
end

function MainTaskMgr:sendTaskFinish(taskId)
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

function MainTaskMgr:sendTaskProgress(taskId, times, needTimes)
	local req = { }
	req["do"] = "Cmd.NotifyUserTaskProgress_S"
	req["data"] = {
		taskId = taskId,
		times = times,
		needTimes = needTimes
	}
	req.errno = unilight.SUCCESS
	local laccount = go.roomusermgr.GetRoomUserById(self.owner.uid)
	if laccount == nil then
		unilight.debug("sorry, the laccount of the ask_uid:" .. self.owner.uid .. " is nil")
	else
		unilight.success(laccount, req)
	end
end

