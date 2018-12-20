

DailyDiamondReward =
{
    owner = nil,
    dailyDiamondRewardNum = nil,
}

function DailyDiamondReward:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function DailyDiamondReward:init(owner)
    self.owner = owner
    self.dailyDiamondRewardNum = 0
    self.owner.lastlogintime = self.owner.lastlogintime or os.time()
    print("DailyDiamondReward:init(owner), dailyDiamondRewardNum = "..self.dailyDiamondRewardNum..", uid = "..self.owner.uid..", lastlogintime="..self.owner.lastlogintime)
end

function DailyDiamondReward:GetData()
    print("DailyDiamondReward:GetData, dailyDiamondRewardNum = "..self.dailyDiamondRewardNum..", uid = "..self.owner.uid)
    return {["dailyDiamondRewardNum"] = self.dailyDiamondRewardNum}
end

function DailyDiamondReward:loadFromDb(data)
    if data["dailyDiamondRewardNum"] == nil then
        unilight.warn("No dailyDiamondRewardNum")
        return false
    end

    self.dailyDiamondRewardNum = data["dailyDiamondRewardNum"]
    return true
end

--领取每日钻石奖励
function DailyDiamondReward:GetDailyDiamondRewardReward()

    local userInfo = self.owner
    if userInfo == nil then
        return 1,"信息错误", 0
    end
    local rewardNum = self.dailyDiamondRewardNum + 1
    if rewardNum > #GlobalConst.Diamonds_Number then
        return 2, "当天的奖励已经领取完了", 0
    end

    print("每日钻石领取前, uid="..self.owner.uid..", diamond="..self.owner.diamond)
    UserInfo.AddUserMoney(self.owner, static_const.Static_MoneyType_Diamond , GlobalConst.Diamonds_Number[rewardNum])
    print("每日钻石领取后, uid="..self.owner.uid..", diamond="..self.owner.diamond)

    self.dailyDiamondRewardNum = rewardNum
    return 0, "领取成功", rewardNum
end

function DailyDiamondReward:IsTheSameDay(time1, time2)

    local aDaySecondCount = 24*60*60
    local day1, x = math.modf(time1/aDaySecondCount)
    local day2, y = math.modf(time2/aDaySecondCount)

    local bb = day1 == day2
    return  day1 == day2
end

--if DailyDiamondReward:IsTheSameDay(1542957249,os.time()) == false then
--    local a = 0
--end



function DailyDiamondReward:DealWithLogin()
    if self.owner == nil then
        return
    end

    if DailyDiamondReward:IsTheSameDay(self.owner.lastlogintime, os.time()) == false then
        print("DailyDiamondReward:IsTheSameDay = false, lastlogintime="..self.owner.lastlogintime..", os.time="..os.time())
        self.dailyDiamondRewardNum = 0
    end

    local res = {}
    res["do"] = "Cmd.SendDailyDiamondRewardInfoCmd_S"
    res["data"] = {
        Number_Times = GlobalConst.Number_Times,
        Diamonds_Number = GlobalConst.Diamonds_Number,
        dailyDiamondRewardNum = self.dailyDiamondRewardNum,
        desc = "每日钻石奖励信息返回",
    }
    unilight.response(self.owner.laccount, res)
end

--When 0:00, call
function DailyDiamondReward:reset()
end

function DailyDiamondReward:addProgress(cond, times)
end
