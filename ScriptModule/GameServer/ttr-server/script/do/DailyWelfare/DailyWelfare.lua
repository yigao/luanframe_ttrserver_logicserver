
DailyWelfare =
{
    owner = {},
    giftBag = {},
}

local GiftBagInfo =
{
    id = 0,
    cd = 4294967295,
    state = 0,
    startTime = 0,
    watchVideoMinusMinute = 0 --看视频减少多少分钟的cd
}
function GiftBagInfo:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

local G_CAN_NOT_GET_REWARD = 1  --不可领取
local G_WAITING_TO_GET_REWARD = 2 --等待领取
local G_CAN_GET_REWARD = 3 --可以领取
local G_ALREADY_GET_REWARD = 4 --已经领取
local G_UINT32_MAX = 4294967295

function DailyWelfare:new(o)
    o = o or {}
    --for i, v in ipairs(self.giftBag) do --为什么此时self.giftBag已经有数据了？
    --    print("DailyWelfare:new(o), self.giftBag, i="..i..", uid="..v.uid..", id="..v.id..", cd="..v.cd..", state="..v.state)
    --end
    self.owner = {}
    self.giftBag = {}--赋空值，不然用的是上个玩家的数据!?
    setmetatable(o, self)
    self.__index = self
    return o
end

function DailyWelfare:init(owner)
    self.owner = owner
    print("DailyWelfare:init, uid="..self.owner.uid..", len="..#self.giftBag)
    self:initGiftBagInfo()
end

function DailyWelfare:initGiftBagInfo()

    local count = 0
    local star = self.owner.star

    --unilight.debug("DailyWelfare:initGiftBagInfo(), uid="..self.owner.uid..", star="..star)
    print("DailyWelfare:initGiftBagInfo(), uid="..self.owner.uid..", star="..star..", len="..#self.giftBag)
    for i, v in ipairs(DailyWelfareTable) do
        if  star >= v["minStar"] and star <= v["maxStar"] then
            count = count + 1
            local giftBagInfo = GiftBagInfo:new()
            giftBagInfo.id = i
            giftBagInfo.cd = v["cd"]
            if count == 1 then
                giftBagInfo.state = G_WAITING_TO_GET_REWARD
                if giftBagInfo.cd == 0 then
                    giftBagInfo.state = G_CAN_GET_REWARD
                end
                giftBagInfo.startTime = os.time()
            else
                giftBagInfo.state = G_CAN_NOT_GET_REWARD
                giftBagInfo.startTime = G_UINT32_MAX
            end

            self.giftBag[count] = giftBagInfo
            print("initGiftBagInfo, uid="..self.owner.uid..", id="..i..", state="..giftBagInfo.state..", cd="..v["cd"]..", startTime="..giftBagInfo.startTime
            ..", minStar="..v["minStar"]..", maxStar="..v["maxStar"]..", welfareId="..v.id)
        end
    end
end

function DailyWelfare:GetData()
    return {["dailyWelfare"] =self.giftBag}
end

function DailyWelfare:loadFromDb(data)
    if data["dailyWelfare"] == nil then
        unilight.warn("No dailyWelfare")
        return false
    end
    if #data["dailyWelfare"] == 0 then
        unilight.warn("data[dailyWelfare] empty")
        return false
    end

    local temp = {}
    temp = data["dailyWelfare"]

    if temp[1].startTime ~= nil and self:IsTheSameDay(temp[1].startTime) then
        self.giftBag = data["dailyWelfare"]
        self:SetMissingFieldFromDb()
        unilight.warn("set giftBag from db")
    end


    return true
end

function DailyWelfare:SetMissingFieldFromDb()

    for i, v in ipairs(self.giftBag) do
        if v["id"] == nil then
            v.id = 0
        end
        if v["cd"] == nil then
            v.cd = 0
        end
        if v["state"] == nil then
            v.state = 0
        end
        if v["startTime"] == nil then
            v.startTime = 0
        end
        if v["watchVideoMinusMinute"] == nil then
            v.watchVideoMinusMinute = 0
        end
    end
end

function DailyWelfare:IsTheSameDay(lastTime)

    if self.giftBag[1] == nil then
        return false
    end

    local aDaySecondCount = 24*60*60
    local lastTimeDay, x = math.modf(lastTime/aDaySecondCount)
    local today, y = math.modf(os.time()/aDaySecondCount)

    print("IsTheSameDay, lastTimeDay="..lastTimeDay..", today="..today)

    return  lastTimeDay == today
end

function DailyWelfare:GetDailyWelfareInfo()

    print("GetDailyWelfareInfo, uid="..self.owner.uid..", len="..#self.giftBag)

    if #self.giftBag == 0 then
        self:initGiftBagInfo()
    end

    local info = {}
    for i, v in ipairs(self.giftBag) do
        self:CalcAndJudgeCanGetReward(v.id, i)
        local temp = {}
        temp.id = v.id
        temp.state = v.state
        temp.cd = v.cd

        local dayInfo = self:GetDayOfTheWeek().."Reward"
        temp.rewardInfo = DailyWelfareTable[v.id][dayInfo]
        local descIndex = "desc"..self:GetNumDayOfTheWeek()
        temp.desc = DailyWelfareTable[v.id][descIndex]

        info[i] = temp

        print("GetDailyWelfareInfo, uid="..self.owner.uid..", id="..v.id..", state="..v.state..", cd="..v.cd
                ..", watchVideoMinusMinute="..v.watchVideoMinusMinute..", rewardInfo="..temp.rewardInfo..", desc="..temp.desc)
    end

    return info, GlobalConst.Diamond_Quick_Time, GlobalConst.WatchVideoMinusMinuteCd
end

function DailyWelfare:CalcAndJudgeCanGetReward(welfareId, index)

    if self:IsTheSameDay(self.giftBag[index].startTime) == false or self.giftBag[index] == nil then
        --self:initGiftBagInfo()
        return false
    end
    print("CalcAndJudgeCanGetReward, welfareId="..welfareId..", index="..index..", state=".. self.giftBag[index].state..", cd="..self.giftBag[index].cd)

    if self.giftBag[index].state ~= G_WAITING_TO_GET_REWARD and self.giftBag[index].state ~= G_CAN_GET_REWARD then
        return false
    end

    if self.giftBag[index].cd <= 0 then
        self.giftBag[index].state = G_CAN_GET_REWARD
        self.giftBag[index].cd = 0
        return true
    end

    local remainSecond = DailyWelfareTable[welfareId]["cd"] - (os.time() - self.giftBag[index].startTime) - self.giftBag[index].watchVideoMinusMinute*60
    --在用钻石或看视频抵消cd情况下，此时cd=0，但是remainSecond不为0
    self.giftBag[index].cd = remainSecond
    if remainSecond <= 0 then
        self.giftBag[index].state = G_CAN_GET_REWARD
        self.giftBag[index].cd = 0
        return true
    end

    return false
end

function DailyWelfare:HandleReward(welfareId, doubleReward)

    local day = self:GetDayOfTheWeek().."Reward"
    local reward = SplitStrBySemicolon(DailyWelfareTable[welfareId][day])
    local rewardInfo = {}

    for i, v in ipairs(reward) do
        local index = string.find(v, "_")
        local rewardType = string.sub(v,1, index-1)
        local rewardNum = tonumber(string.sub(v, index + 1, -1))
        if rewardInfo[rewardType] == nil then
            rewardInfo[rewardType] = 0
        end
        rewardInfo[rewardType] = rewardInfo[rewardType] + rewardNum
    end

    local times = 1
    if doubleReward == 1 then
         times = 2
    end
    for i, v in pairs(rewardInfo) do
        if v > 0 then
            local rewardType = tonumber(i)
            v = v*times
            print("HandleReward, i="..i..", v="..v..", rewardType="..rewardType..", times="..times)
            UserItems:useItem(self.owner, rewardType, v)
        end
    end
end

--领取每日礼包奖励
function DailyWelfare:GetDailyWelfareReward(welfareId, doubleReward)

    local userInfo = self.owner
    local isExist = false
    local index = -1
    local rewardStr = ""

    for i, v in ipairs(self.giftBag) do
        if welfareId == v.id then
            isExist = true
            index = i
            break
        end
    end

    if isExist == false  then
        return 1, "不存在该福利", 0, rewardStr, {}
    end

    if index > 1 and self.giftBag[1].state ~= G_ALREADY_GET_REWARD then
        return 1, "领取错误", 0, rewardStr, {}
    end

    if DailyWelfareTable[welfareId] == nil then
        return 3, "福利配置信息错误", 0, rewardStr, {}
    end

    if self:CalcAndJudgeCanGetReward(welfareId, index) == false then
        return 4, "该福利不是可领取状态", 0, rewardStr, {}
    end

    userInfo.UserProps:AddDayLookMediaTimes(userInfo)
    --if doubleReward == 1 then
    --    local userInfo = self.owner
    --    local dayLookMediaTimes = userInfo.UserProps:getUserProp(userInfo, "dayLookMediaTimes")
    --    if dayLookMediaTimes >= GlobalConst.Max_Adviertisement_Times then
    --        return 2, "看广告次数超过限制", 0, rewardStr, {}
    --    end
    --    userInfo.UserProps:dealLookMediaOK(userInfo)
    --    userInfo.UserProps:getUserProp(userInfo, "dayLookMediaTimes")
    --end

    self:HandleReward(welfareId, doubleReward)
    local day = self:GetDayOfTheWeek().."Reward"
    self.giftBag[index].state = G_ALREADY_GET_REWARD
    rewardStr = DailyWelfareTable[welfareId][day]
    --print("welfareId="..welfareId..", day="..day..", DailyWelfareTable[welfareId]="..DailyWelfareTable[welfareId])

    return 0, "领取成功",welfareId, rewardStr, self:GetNextGiftBagInfo(index)
end

function DailyWelfare:GetNextGiftBagInfo(currentIndex)
    if currentIndex >= 3 then
        return {}
    end

    local index = currentIndex + 1
    self.giftBag[index].state = G_WAITING_TO_GET_REWARD
    self.giftBag[index].startTime = os.time()
    self.giftBag[index].cd = DailyWelfareTable[self.giftBag[index].id]["cd"]

    local day = self:GetDayOfTheWeek().."Reward"
    local rewardInfo = DailyWelfareTable[self.giftBag[index].id][day]
    local descIndex = "desc"..self:GetNumDayOfTheWeek()
    local desc = DailyWelfareTable[self.giftBag[index].id][descIndex]

    local temp = {
        id = self.giftBag[index].id,
        cd = self.giftBag[index].cd,
        state = self.giftBag[index].state,
        rewardInfo = rewardInfo,
        desc = desc,
    }
    return temp
end

function DailyWelfare:CostDiamondToRemoveCd(welfareId)

    local currentWelfareId = 0
    local currentIndex = 0
    for i, v in ipairs(self.giftBag) do
        if v.state == G_WAITING_TO_GET_REWARD then
            currentIndex = i
            currentWelfareId = v.id
        end
    end
    if currentIndex == 0 then
         return 1, "不存在该礼包"
    end

    if GlobalConst.EverySecondCostDiamond == 0 then
        return 1, "配置信息错误"
    end

    local costDiamondNum = 0
    local x = math.ceil(self.giftBag[currentIndex].cd/60)
    if self.giftBag[currentIndex].cd%60 ~= 0 then
        costDiamondNum = x + 1
    else
        costDiamondNum = x
    end

    if costDiamondNum > self.owner.diamond then
        return 1, "钻石不足"
    end

    --self.owner.diamond = self.owner.diamond - costDiamondNum
    UserInfo.AddUserMoney(self.owner, static_const.Static_MoneyType_Diamond, -costDiamondNum)
    self.giftBag[currentIndex].cd = 0
    self.giftBag[currentIndex].state = G_CAN_GET_REWARD

    return 0, "抵消成功", welfareId
end


function DailyWelfare:WatchVideoToMinusCd(welfareId)

    local currentWelfareId = 0
    local currentIndex = 0
    for i, v in ipairs(self.giftBag) do
        if v.state == G_WAITING_TO_GET_REWARD then
            currentIndex = i
            currentWelfareId = v.id
        end
    end
    if currentIndex == 0 then
        return 1, "不存在该礼包"
    end

    if GlobalConst.WatchVideoMinusCd == 0 then
        return 1, "配置信息错误"
    end

    if self:CalcAndJudgeCanGetReward(welfareId, currentIndex) then
        return 1, "该奖励已经可领取", welfareId, 0
    end

    --local dayLookMediaTimes = UserProps:getUserProp(self.owner, "dayLookMediaTimes")
    --if dayLookMediaTimes >= GlobalConst.Max_Adviertisement_Times then
    --    return 2, "看广告次数超过限制"
    --end
    --UserProps:dealLookMediaOK(self.owner)

    --local userInfo = self.owner
    --local dayLookMediaTimes = userInfo.UserProps:getUserProp(userInfo, "dayLookMediaTimes")
    --if dayLookMediaTimes >= GlobalConst.Max_Adviertisement_Times then
    --    return 2, "看广告次数超过限制"
    --end
    --userInfo.UserProps:dealLookMediaOK(userInfo)
    --userInfo.UserProps:getUserProp(userInfo, "dayLookMediaTimes")
    local userInfo = self.owner
    userInfo.UserProps:AddDayLookMediaTimes(userInfo)

    self.giftBag[currentIndex].watchVideoMinusMinute = self.giftBag[currentIndex].watchVideoMinusMinute +  GlobalConst.WatchVideoMinusMinuteCd
    self:CalcAndJudgeCanGetReward(welfareId, currentIndex)

    return 0, "抵消成功", welfareId, self.giftBag[currentIndex].cd
end

function DailyWelfare:GetDayOfTheWeek()

    local aDaySecond = 24*60*60
    local dayCount =  os.time() /aDaySecond
    local remainder = dayCount%7

    --0-6分别对应周一到周日，这样好计算
    local day = ((4-1)+remainder)%7 + 1

    local x, y = math.modf(day/1)
    local dayString = ""

    if x == 1 then
        dayString = "monday"
    elseif x == 2 then
        dayString = "tuesday"
    elseif x == 3 then
        dayString = "wednesday"
    elseif x == 4 then
        dayString = "thursday"
    elseif x == 5 then
        dayString = "friday"
    elseif x == 6 then
        dayString = "saturday"
    elseif x == 7 then
        dayString = "weekday"
    end

    return dayString
end

function DailyWelfare:GetNumDayOfTheWeek()

    local aDaySecond = 24*60*60
    local dayCount =  os.time() /aDaySecond
    local remainder = dayCount%7

    --0-6分别对应周一到周日，这样好计算
    local day = ((4-1)+remainder)%7 + 1
    return math.ceil(day)
end

function DailyWelfare:DealWithLogin()
    if ttrutil.IsSameDay(self.owner.lastlogintime,os.time()) == false then
        self:initGiftBagInfo()
    end
end

--When 0:00, call
function DailyWelfare:dealZeroReset()
    self:initGiftBagInfo()
end
