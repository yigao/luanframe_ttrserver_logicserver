-- 客户端获得玩家任务详细
Net.CmdGetUserTaskInfo_C = function(cmd, laccount)
    local res = { }
    res["do"] = "Cmd.GetUserTaskInfo_S"

    local uid = laccount.Id
    local userInfo = UserInfo.GetUserInfoById(uid)

    if userInfo == nil then
        res["data"] = {
            resultCode = 1,
            desc = "数据出错"
        }
        return res
    end

    --每日数据可能需要重置
    userInfo.dailyTask:Reset()

    res["data"] = {
        active = userInfo.dailyTask:GetActivity(),
        daily_task = {},
        achieve_task = {},
        main_task = {
            taskIdInProgress = 0,
            taskData = {},
        },
        active_info = {},
        map_count = userInfo.world:StateCount(),
    }

    userInfo.dailyTask.tasks:ForEach(
        function(taskId, taskInfo)
            local tmp = {
                taskid = taskInfo:GetId(),
                times = taskInfo:GetTimes(),
                status = taskInfo:GetStatus(),
            }
            table.insert(res["data"].daily_task, tmp)
        end
    )

    userInfo.dailyTask.activityReward:ForEach(
        function(id, value)
            local tmp = {
                id = id,
                isRecv = (value == 1),
            }
            table.insert(res["data"].active_info, tmp)
        end
    )

    userInfo.achieveTask.tasks:ForEach(
        function(taskId, taskInfo)
            local tmp = {
                taskid = taskInfo:GetId(),
                times = taskInfo:GetTimes(),
                status = taskInfo:GetStatus(),
            }
            table.insert(res["data"].achieve_task, tmp)
        end
    )

    local reward = ""
    local needTimes = 0
    local taskIdInProgress = userInfo.mainTask:GetTaskIdInProgress()
    if taskTable[taskIdInProgress] ~= nil then
        if taskTable[taskIdInProgress].reward ~= nil and taskTable[taskIdInProgress].reward ~= "" then
            reward = taskTable[taskIdInProgress].reward
        else
            reward = taskTable[taskIdInProgress].reward2
        end
        needTimes = taskTable[taskIdInProgress].param
    end

    local temp
    local taskInfo = userInfo.mainTask.tasks:Find(taskIdInProgress)
    if taskInfo ~= nil then
        temp = {
            taskid = taskInfo:GetId(),
            times = taskInfo:GetTimes(),
            status = taskInfo:GetStatus(),
            needTimes = needTimes,
            reward = reward
        }
    end

    res["data"].main_task.taskIdInProgress = taskIdInProgress
    res["data"].main_task.taskData = temp

    return res
end

-- 客户端获得领取任务奖励,包括每日、成就、主线
Net.CmdReqGetRewardDailyTask_C = function(cmd, laccount)
    local res = { }
    res["do"] = "Cmd.ReqGetRewardDailyTask_S"

    local uid = laccount.Id
    local userInfo = UserInfo.GetUserInfoById(uid)

    if userInfo == nil then
        res["data"] = {
            resultCode = 1,
            desc = "数据出错"
        }
        return res
    end

    local taskId = cmd["data"].task_id;

    unilight.debug("领取任务奖励..." .. taskId)

    local taskConf = taskTable[taskId]
    if taskConf == nil then
        res["data"] = {
            resultCode = 1,
            desc = "数据出错, 任务在表格里不存在"
        }
        return res
    end

    local isMainTask = false
    local taskInfo = userInfo.dailyTask.tasks:Find(taskId);
    if taskInfo == nil then
        taskInfo = userInfo.achieveTask.tasks:Find(taskId);
        if taskInfo == nil then
            taskInfo = userInfo.mainTask.tasks:Find(taskId);
            if taskInfo == nil then
                res["data"] = {
                    resultCode = 1,
                    desc = "数据出错, 任务在玩家身上不存在"
                }
                return res
            end
            isMainTask = true
        end 
    end

    if taskInfo:GetStatus() ~= TaskStatusEnum.Finish then
        res["data"] = {
            resultCode = ERROR_CODE.TASK_NOT_FINISH,
            desc = "任务未完成或奖励已经领取"
        }
        return res
    end

    taskInfo:SetStatus(TaskStatusEnum.Receive)

    userInfo.dailyTask.activity = userInfo.dailyTask.activity + taskConf.activeValue

    --获得任务金钱奖励
    local money_table = common.StringSplitTable(taskConf.reward)
    for money_type, money in pairs(money_table) do
        UserInfo.AddUserMoney(userInfo, tonumber(money_type), tonumber(money))
    end

    --获得任务物品奖励
    local item_table = common.StringSplitTable(taskConf.reward2)
    for item_id, item_count in pairs(item_table) do
        userInfo.UserItems:useItem(userInfo, tonumber(item_id), tonumber(item_count))
    end

    local tmp
    if isMainTask == true then
        print("CmdReqGetRewardDailyTask_C, uid="..uid..", rewardTaskId="..taskId..", isMainTask=true")
        local nextMainTaskInfo = userInfo.mainTask:SetNextTaskIdInProgress()
        if nextMainTaskInfo ~= nil then
            local taskIdInProgress = nextMainTaskInfo:GetId()
            local reward
            if taskTable[taskIdInProgress].reward ~= nil and taskTable[taskIdInProgress].reward ~= "" then
                reward = taskTable[taskIdInProgress].reward
            else
                reward = taskTable[taskIdInProgress].reward2
            end
            tmp = {
                taskid = nextMainTaskInfo:GetId(),
                times = nextMainTaskInfo:GetTimes(),
                status = nextMainTaskInfo:GetStatus(),
                needTimes = taskTable[taskIdInProgress].param,
                reward = reward
            }
            print("CmdReqGetRewardDailyTask_C, tem.taskid="..tmp.taskid..", times="..tmp.times..", status="..tmp.status..", needTimes="..tmp.needTimes)
        end
    end

    res["data"] = {
        resultCode = 0,
        desc = "",
        task_id = taskId,
        nextMainTaskInfo = tmp
    }

    return res
end

-- 客户端获得领取日常任务活跃度奖励
Net.CmdReqGetActiveReward_C = function(cmd, laccount)
    local res = { }
    res["do"] = "Cmd.ReqGetActiveReward_S"

    local uid = laccount.Id
    local userInfo = UserInfo.GetUserInfoById(uid)

    if userInfo == nil then
        res["data"] = {
            resultCode = 1,
            desc = "数据出错"
        }
        return res
    end

    local id = cmd["data"].id;

    local activitConf = taskActivity[id]
    if activitConf == nil then
        res["data"] = {
            resultCode = 1,
            desc = "参数错误"
        }
        return res
    end

    if userInfo.dailyTask:IsExistActivityReward(id) == false then
        res["data"] = {
            resultCode = 1,
            desc = "数据不存在"
        }
        return res
    end

    if userInfo.dailyTask:IsRecvActivityReward(id) == true then
        res["data"] = {
            resultCode = ERROR_CODE.TASK_REWARD_HAS_RECV,
            desc = "奖励已经领取",
        }
        return res     
    end

    if userInfo.dailyTask:GetActivity() < activitConf.cond then
        res["data"] = {
            resultCode = ERROR_CODE.TASK_ACTIVITY_NOT_ENOUGH,
            desc = "活动值不够,不能领取",
        }
        return res   
    end

    userInfo.dailyTask:SetActivityRewardRecv(id)

    local money_table = common.StringSplitTable(activitConf.reward)
    for money_type, money in pairs(money_table) do
        UserInfo.AddUserMoney(userInfo, tonumber(money_type), tonumber(money))
    end

    res["data"] = {
        resultCode = 0,
        desc = "",
        id = id,
    }
    return res  
end

Lby.CmdNotifyDailyTaskAddProgress_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetOfflineUserInfo(uid)
	if userInfo == nil then
        unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    userInfo.dailyTask:addProgress(cmd.data.event, cmd.data.times)        
end

Lby.CmdNotifyAchieveTaskAddProgress_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetOfflineUserInfo(uid)
	if userInfo == nil then
        unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    userInfo.achieveTask:addProgress(cmd.data.event, cmd.data.times)       
end

Lby.CmdNotifyMainTaskAddProgress_S = function(cmd, lobbyClientTask)
    local uid = cmd.data.cmd_uid
    
    local userInfo = UserInfo.GetOfflineUserInfo(uid)
	if userInfo == nil then
        unilight.error("userinfo is not exist,uid:"..uid)
		return
    end

    userInfo.mainTask:addProgress(cmd.data.event, cmd.data.times)       
end