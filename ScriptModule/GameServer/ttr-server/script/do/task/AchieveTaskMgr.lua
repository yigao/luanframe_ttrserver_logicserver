
--成就任务

CreateClass("AchieveTaskMgr")

--初始化数据
function AchieveTaskMgr:init(owner)
	--玩家指正
	self.owner = owner
	--任务数据
	self.tasks = Map:New()
	self.tasks:Init()
end

--从DB数据里加载数据
function AchieveTaskMgr:SetDBTable(data)
	if type(data.tasks) == "table" then
		for taskId, taskInfo in pairs(data.tasks) do
			local task = TaskData:New()
			task:SetDBTable(taskInfo)
			self.tasks:Insert(taskId, task)
		end
	end
end

--检查配置，并把没有的任务加载到配置中
function AchieveTaskMgr:LoadConfig()
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
	
    --检查配置，并把没有的任务加载到配置中
	for taskId, info in pairs(taskTable) do
		if info.taskType == static_const.Static_Const_Task_TaskType_AchieveTask and self.tasks:Find(taskId) == nil then
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

--把数据存到一个table中
function AchieveTaskMgr:GetDBTable()
	local data = { }
	data.tasks = { }
	self.tasks:ForEach(
		function(taskId, taskInfo)
			data.tasks[taskId] = taskInfo:GetDBTable()
		end
	)

	return data
end

--增加任务进度
function AchieveTaskMgr:addProgress(event, times)
	self.tasks:ForEach(
		function(taskId, taskInfo)
			if taskInfo.event == event and taskInfo:GetStatus() == TaskStatusEnum.Begin then
				--开启地图需要特殊处理
				if event == TaskConditionEnum.OpenMapEvent or 
				event == TaskConditionEnum.BuildingLevelUpEvent or
				event == TaskConditionEnum.TravelLevelUpEvent then
					local taskConf = taskTable[taskId]
					if taskConf ~= nil then
						if event ~= TaskConditionEnum.OpenMapEvent then
							taskInfo:SetTimes(times)
							if times >= taskConf.param then
								taskInfo:SetTimes(times)
								taskInfo:SetStatus(TaskStatusEnum.Finish)
		
								--通知客户端 任务完成
								local req = { }
								req["do"] = "Cmd.NotifyUserTaskFinish_S"
								req["data"] = { 
									task_id = taskId,
								}
								req.errno = unilight.SUCCESS
								local laccount = go.roomusermgr.GetRoomUserById(self.owner.uid)
								if laccount == nil then
									unilight.debug("sorry, the laccount of the ask_uid:" .. self.owner.uid .. " is nil")
								else
									unilight.success(laccount, req)
								end
							end
						else
							if times == taskConf.param then
								taskInfo:SetTimes(times)
								taskInfo:SetStatus(TaskStatusEnum.Finish)
		
								--通知客户端 任务完成
								local req = { }
								req["do"] = "Cmd.NotifyUserTaskFinish_S"
								req["data"] = { 
									task_id = taskId,
									map_count = self.owner.world:StateCount(),
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
				else 
					taskInfo:AddTimes(times)
					local taskConf = taskTable[taskId]
					if taskConf ~= nil then
						if taskInfo:GetTimes() >= taskConf.param then
							taskInfo:SetTimes(taskConf.param)
							taskInfo:SetStatus(TaskStatusEnum.Finish)
	
							--通知客户端 任务完成
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
		end
	)
end