

DailyLotteryDraw =
{
    owner = nil,
    drawNum = nil,
    totalDrawNum = nil,
    isGotLuckyDraw = nil,
    rewardId = nil,
}

function DailyLotteryDraw:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function DailyLotteryDraw:init(owner)
    self.owner = owner
    self.drawNum = 0
    self.totalDrawNum = 0
    self.isGotLuckyDraw = 0
    self.rewardId = 0
    self.owner.lastlogintime = self.owner.lastlogintime or os.time()
    print("DailyLotteryDraw:init(owner), drawNum = "..self.drawNum..", uid = "..self.owner.uid..", lastlogintime="..self.owner.lastlogintime)
end

function DailyLotteryDraw:GetData()
    print("DailyLotteryDraw:GetData, drawNum = "..self.drawNum..", uid = "..self.owner.uid)
    return {
        drawNum = self.drawNum,
        totalDrawNum = self.totalDrawNum,
        isGotLuckyDraw = self.isGotLuckyDraw,
        rewardId = self.rewardId,
    }
end

function DailyLotteryDraw:loadFromDb(data)
    if data["drawNum"] == nil then
        unilight.warn("No drawNum")
        return false
    end

    self.drawNum = data["drawNum"] or self.drawNum
    self.totalDrawNum = data["totalDrawNum"] or self.isGotLuckyDraw
    self.isGotLuckyDraw = data["isGotLuckyDraw"] or self.isGotLuckyDraw
    self.rewardId = data["rewardId"] or self.rewardId
    return true
end

function DailyLotteryDraw:GetRewardId()
    local sum = 0
    local rewardId = 1
    for i, v in pairs(DailyLotteryDrawTable) do
        sum = sum + v.weight
    end

    --math.randomseed(os.time() + self.owner.uid + self.drawNum*3487)
    math.randomseed(tostring(os.time()):reverse():sub(1, 6)+ self.owner.uid + self.drawNum*3487 )
    local randomNum = math.random(1, sum)

    sum = 0
    for i, v in pairs(DailyLotteryDrawTable) do
        sum = sum + v.weight
        if sum >= randomNum then
            rewardId = i
            break
        end
    end

    if self.totalDrawNum <= 10 and rewardId == 5 then --前十次不能抽中百变小萝莉，定在id=5的地方
        rewardId = 1
    end

    --print("DailyLotteryDraw:GetRewardId(), uid="..self.owner.uid..", rewardId="..rewardId..", rewardStr="..DailyLotteryDrawTable[rewardId])
    print("DailyLotteryDraw:GetRewardId(), rewardId="..rewardId..", rewardStr="..DailyLotteryDrawTable[rewardId].reward)
    return rewardId
end

function DailyLotteryDraw:GetLotteryDrawRewardId()
    local rewardId = self:GetRewardId()
    self.rewardId = rewardId
    print("GetLotteryDrawRewardId, uid="..self.owner.uid..", rewardId="..self.rewardId)
    --return 0, "获取奖品id成功", rewardId
    return 0, "领取成功", self.drawNum, rewardId, self.isGotLuckyDraw
end

function DailyLotteryDraw:GetLotteryDrawReward()

    if self.rewardId == 0 then
        return 1, "无奖品信息", self.rewardId
    end
    --self.HandleReward(rewardStr)
    local rewardId = self.rewardId
    self:HandleReward(rewardId)

    return 0, "奖品领取成功", self.drawNum, rewardId, self.isGotLuckyDraw
end

function DailyLotteryDraw:HandleReward(rewardId)

    print("HandleReward, uid="..self.owner.uid..", rewardId="..self.rewardId)
    self.rewardId = 0
    self.drawNum = self.drawNum + 1

    local rewardStr
    if self.isGotLuckyDraw == 1 then
        rewardStr = DailyLotteryDrawTable[rewardId].reward
    else
        rewardStr = DailyLotteryDrawTable[rewardId].PrimaryReward
    end

    local rewardTable = SplitStrBySemicolon(rewardStr)
    local rewardInfo = {}
    for i, v in ipairs(rewardTable) do
        local index = string.find(v, "_")
        local rewardType = string.sub(v,1, index-1)
        local drawNum = tonumber(string.sub(v, index + 1, -1))
        if rewardInfo[rewardType] == nil then
            rewardInfo[rewardType] = 0
        end
        rewardInfo[rewardType] = rewardInfo[rewardType] + drawNum
    end

    for i, v in pairs(rewardInfo) do
        if v > 0 then
            local rewardType = tonumber(i)
            print("抽奖领取前, uid="..self.owner.uid..", money="..self.owner.money..", diamond="..self.owner.diamond..", rewardType="..i..", num="..v)
            UserItems:useItem(self.owner, rewardType, v)
            print("抽奖领取后, uid="..self.owner.uid..", money="..self.owner.money..", diamond="..self.owner.diamond)
        end
    end
end


--抽奖
function DailyLotteryDraw:GetDailyLotteryDraw()

    local userInfo = self.owner
    if userInfo == nil then
        return 1,"信息错误", 0
    end
    if self.drawNum >= 1 then
        userInfo.UserProps:AddDayLookMediaTimes(userInfo)
    end

    if self.rewardId ~= 0 then
        return 2, "上次的抽奖还没有领", 0
    end

    local drawNum = self.drawNum + 1
    --if drawNum > #DailyLotteryDrawTable then
    if drawNum > GlobalConst.DailyLotteryDrawNum then
        return 3, "当天的抽奖次数已经用完", 0
    end

    local rewardId = self:GetRewardId()
    --self.HandleReward(rewardStr)
    self:HandleReward(rewardId)

    if rewardId == 5 then
        self.isGotLuckyDraw = 1
    end
    self.totalDrawNum = self.totalDrawNum + 1
    self.drawNum = drawNum
    print("GetDailyLotteryDraw, rewardId="..rewardId..", reward="..DailyLotteryDrawTable[rewardId].reward..", rewardStr="..rewardStr..", isGotLuckyDraw="..self.isGotLuckyDraw
    .." totalDrawNum="..self.totalDrawNum)
    return 0, "领取成功", drawNum, rewardId, self.isGotLuckyDraw
end

function DailyLotteryDraw:IsTheSameDay(time1, time2)
    local aDaySecondCount = 24*60*60
    local day1, x = math.modf(time1/aDaySecondCount)
    local day2, y = math.modf(time2/aDaySecondCount)
    return  day1 == day2
end


function DailyLotteryDraw:DealWithLogin()
    if self.owner == nil then
    return
    end

    print("DealWithLogin, self.owner.lastlogintime="..self.owner.lastlogintime..", os.time="..os.time())
    if DailyLotteryDraw:IsTheSameDay(self.owner.lastlogintime, os.time()) == false then
        self.drawNum = 0
    end
    self.rewardId = 0

    local res = {}
    res["do"] = "Cmd.SendDailyLotteryDrawInfoCmd_S"
    res["data"] = {
    drawNum = self.drawNum, --玩家已经抽奖的次数
    isGotLuckyDraw = self.isGotLuckyDraw, --玩家是否已经抽到幸运奖（百变小萝莉），抽中后切换到奖励奖项
    dailyLotteryDrawNum = GlobalConst.DailyLotteryDrawNum, --每天抽奖次数上限
    desc = "每日抽奖信息返回",
    }
    unilight.response(self.owner.laccount, res)
end

--When 0:00, call
function DailyLotteryDraw:dealZeroReset()
    if self.owner == nil then
        return
    end

    self.drawNum = 0
    self.rewardId = 0

    local res = {}
    res["do"] = "Cmd.SendDailyLotteryDrawInfoCmd_S"
    res["data"] = {
        drawNum = self.drawNum, --玩家已经抽奖的次数
        isGotLuckyDraw = self.isGotLuckyDraw, --玩家是否已经抽到幸运奖（百变小萝莉），抽中后切换到奖励奖项
        dailyLotteryDrawNum = GlobalConst.DailyLotteryDrawNum, --每天抽奖次数上限
        desc = "每日抽奖信息返回",
    }
    unilight.response(self.owner.laccount, res)
end


    --DailyLotteryDrawTable = {
    --    [1]={["id"]=1,["reward"]="1_30",["firstReward"]="1_30",["weight"]=30},
    --    [2]={["id"]=2,["reward"]="2_20000",["firstReward"]="2_20000",["weight"]=30},
    --    [3]={["id"]=3,["reward"]="1_50",["firstReward"]="1_50",["weight"]=10},
    --    [4]={["id"]=4,["reward"]="1001_1",["firstReward"]="1001_1",["weight"]=10},
    --    [5]={["id"]=5,["reward"]="1013_1",["firstReward"]="2004_1",["weight"]=2},
    --    [6]={["id"]=6,["reward"]="2_50000",["firstReward"]="2_50000",["weight"]=10},
    --    [7]={["id"]=7,["reward"]="1_100",["firstReward"]="1_100",["weight"]=5},
    --    [8]={["id"]=8,["reward"]="1012_1",["firstReward"]="1012_1",["weight"]=3},
    --}
    --local num = 0
    --local statistic = {}
    --function DailyLotteryDraw:GetRewardId()
    --
    --    local sum = 0
    --    local rewardId = 1
    --    for i, v in pairs(DailyLotteryDrawTable) do
    --        sum = sum + v.weight
    --    end
    --
    --    --math.randomseed(os.time() + self.owner.uid + self.drawNum*3487)
    --    --math.randomseed(tostring(os.time()):reverse():sub(1, 6)+ self.owner.uid + self.drawNum*3487 )
    --    --math.randomseed(tostring(os.time()):reverse():sub(1, 6) + num*3487 + 11921232)
    --    math.randomseed( num*3487 + 11921232)
    --    local randomNum = math.random(1, sum)
    --
    --    sum = 0
    --    for i, v in pairs(DailyLotteryDrawTable) do
    --        sum = sum + v.weight
    --        if sum >= randomNum then
    --            rewardId = i
    --            break
    --        end
    --    end
    --    --print("DailyLotteryDraw:GetRewardId(), uid="..self.owner.uid..", rewardId="..rewardId..", rewardStr="..DailyLotteryDrawTable[rewardId])
    --    print("DailyLotteryDraw:GetRewardId(), rewardId="..rewardId..", rewardStr="..DailyLotteryDrawTable[rewardId].reward)
    --    return rewardId
    --end
    --
    --for i = 1, 101 do
    --    local rewardId = DailyLotteryDraw:GetRewardId()
    --    if statistic[rewardId] == nil then
    --        statistic[rewardId] = 0
    --    end
    --    statistic[rewardId] = statistic[rewardId] +1
    --    num = num + 1
    --end
    --
    --for i, v in pairs(statistic) do
    --    print("statistic, i="..i..", v="..v)
    --end