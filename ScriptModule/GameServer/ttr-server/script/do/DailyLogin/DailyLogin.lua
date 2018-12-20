
DailyLogin =
{
    owner = {},
    loginInfo = {},
    len = 0,
    lastLoginTime = 0,
}

local LoginInfo =
{
    id = 0,
    state = 0,
    rewardInfo = "",
}

function LoginInfo:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

local G_CAN_NOT_GET_REWARD = 1  --不可领取
local G_CAN_GET_REWARD = 2      --可以领取
local G_ALREADY_GET_REWARD = 3  --已经领取

function DailyLogin:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function DailyLogin:init(owner)

    self.owner = owner
    self.lastLoginTime = 0
    self:initLoginInfo()
    print("DailyLogin:init()")
    --self:initRewardInfo()
end

function DailyLogin:initLoginInfo()
    self.loginInfo = {}
    self.len = #DailyLoginTable
    for i = 1,  self.len do
        local temp = LoginInfo:new()
        temp.id = i
        temp.state = G_CAN_NOT_GET_REWARD
        temp.rewardInfo = DailyLoginTable[i]["reward"]
        self.loginInfo[i] = temp
    end
end

function DailyLogin:GetData()
    return {
        dailyLogin = self.loginInfo,
        lastLoginTime = self.lastLoginTime
    }
end

function DailyLogin:loadFromDb(data)
    if data["dailyLogin"] == nil or data["lastLoginTime"] == nil then
        unilight.warn("No DailyLogin or lastLoginTime")--
        return false
    end

    local temp = {}
    temp = data["dailyLogin"]
    if #temp == self.len  then
        self.loginInfo = data["dailyLogin"]
        unilight.warn("set loginInfo from db")
    end

    --以配置文件的奖励信息为准
    for i, v in pairs(DailyLoginTable) do
        self.loginInfo[i].rewardInfo = v.rewardInfo
    end

    self.lastLoginTime = data["lastLoginTime"]
    print("DailyLogin:loadFromDb(data), self.lastLoginTime="..self.lastLoginTime)
    self:SetMissingFieldFromDb()

    return true
end

function DailyLogin:SetMissingFieldFromDb()

    for i, v in ipairs(self.loginInfo) do
        v["id"] = v["id"] or 0
        v["state"] = v["state"] or 0
        v["rewardInfo"] = v["rewardInfo"] or DailyLoginTable[i]["reward"]
    end
end

function DailyLogin:IsTheSameDay()

    if self.lastLoginTime == nil then
        return false
    end

    local aDaySecondCount = 24*60*60
    local lastLoginDay, x = math.modf(self.lastLoginTime/aDaySecondCount)
    local today, y = math.modf(os.time()/aDaySecondCount)

    print("IsTheSameDay, lastLoginDay="..lastLoginDay..", today="..today..", self.lastLoginTime="..self.lastLoginTime..", nowTime="..os.time())

    return  lastLoginDay == today
end


function DailyLogin:DealWithLogin()

    if self.owner == nil then
        print("DailyLogin:Login(), self.owner=false")
        return
    end

    --if self:IsTheSameDay() == true then
    --    print("DailyLogin:Login(), IsTheSameDay=true, uid="..self.owner.uid)
    --    return
    --end

    if ttrutil.IsSameDay(self.owner.lastlogintime,os.time()) == true then
        print("DailyLogin:Login(), IsTheSameDay=true, uid="..self.owner.uid)
        return
    end

    local allGetReward = true
    local index = 0
    for i, v in ipairs(self.loginInfo) do
        if v.state ~= G_ALREADY_GET_REWARD  then
            allGetReward = false
        end
    end

    for i, v in ipairs(self.loginInfo) do
        if v.state == G_CAN_NOT_GET_REWARD then
            index = i
            break
        end
    end

    if allGetReward == true then
        self:initLoginInfo()
        self.loginInfo[1].state = G_CAN_GET_REWARD
    else
        if index ~= 0 then
            print("DailyLogin:Login, index="..index..", id="..self.loginInfo[index].id..", state="..self.loginInfo[index].rewardInfo..", index="..index)
            self.loginInfo[index].state = G_CAN_GET_REWARD
        end
    end

    self.lastLoginTime = os.time()
    print("DailyLogin:Login(), set self.lastLoginTime="..self.lastLoginTime)
end

function DailyLogin:GetDailyLoginInfo()
    for i, v in ipairs(self.loginInfo) do
        print("uid="..self.owner.uid..", len="..#self.loginInfo..", id="..v.id..", state="..v.state..", rewardInfo="..v.rewardInfo)
    end
    return self.loginInfo
end

function DailyLogin:HandleReward(rewardStr, doubleReward)

    local reward = SplitStrBySemicolon(rewardStr)
    local loginInfo = {}
    local times = 1 --奖励的倍数
    if doubleReward == 1 then
        times = 2
    end

    for i, v in ipairs(reward) do
        local index = string.find(v, "_")
        local rewardType = string.sub(v,1, index-1)
        local rewardNum = tonumber(string.sub(v, index + 1, -1))
        if loginInfo[rewardType] == nil then
            loginInfo[rewardType] = 0
        end
        loginInfo[rewardType] = loginInfo[rewardType] + rewardNum
    end

    for i, v in pairs(loginInfo) do
        if v > 0 then
            v = v*times
            local rewardType = tonumber(i)
            print("HandleReward, i="..i..", v="..v..", rewardType="..rewardType..", times="..times)
            if rewardType <=2 then
                print("每日登录领取前, uid="..self.owner.uid..", money="..self.owner.money..", diamond="..self.owner.diamond..", rewardType="..i..", num="..v)
                UserInfo.AddUserMoney(self.owner, rewardType, v)
                print("每日登录领取后, uid="..self.owner.uid..", money="..self.owner.money..", diamond="..self.owner.diamond)
            else
                UserItems:useItem(self.owner, rewardType, v)
            end
        end
    end
end

--领取每日登录奖励
function DailyLogin:GetDailyLoginReward(loginId, doubleReward)

    if self.loginInfo[loginId] == nil  then
        return 1, "不存在该奖励"
    end

    if self.loginInfo[loginId].state ~= G_CAN_GET_REWARD  then
        return 1, "该奖励不可领取"
    end

    --if doubleReward == 1 then
    --    local userInfo = self.owner
    --    local dayLookMediaTimes = userInfo.UserProps:getUserProp(userInfo, "dayLookMediaTimes")
    --    if dayLookMediaTimes >= GlobalConst.Max_Adviertisement_Times then
    --        return 2, "看广告次数超过限制"
    --    end
    --    userInfo.UserProps:dealLookMediaOK(userInfo)
    --    userInfo.UserProps:getUserProp(userInfo, "dayLookMediaTimes")
    --end
    local userInfo = self.owner
    userInfo.UserProps:AddDayLookMediaTimes(userInfo)

    self:HandleReward(self.loginInfo[loginId].rewardInfo, doubleReward)
    self.loginInfo[loginId].state = G_ALREADY_GET_REWARD

    return 0, "领取成功"
end


function DailyLogin:initRewardInfoForDebug()

    local userInfo = {
        uid			= 10086,
        nickName	= "测试员" .. 10086,
        money		= 1000,
        diamond		= 1000,
        star		= 1000,
        settings	= {},
        sex			= 1,
        head		= "",
        firstLogin  = 1,--首次登陆
    }

    self:init(userInfo)
    self:GetDailyLoginInfo()
    self:Login()
    self:GetDailyLoginReward(1)
    print("hello")
end

--DailyLogin:initRewardInfoForDebug()

--When 0:00, call
function DailyLogin:reset()
    self:initRewardInfo()
end

function DailyLogin:addProgress(cond, times)

end


--function DailyLogin:LoginForDebug()
--
--    DailyLoginTable = {
--        [1]={["id"]=1,["reward"]="1_20"},
--        [2]={["id"]=2,["reward"]="1_40"},
--        [3]={["id"]=3,["reward"]="1_60"},
--        [4]={["id"]=4,["reward"]="1_80"},
--        [5]={["id"]=5,["reward"]="1_100"},
--        [6]={["id"]=6,["reward"]="1_120"},
--        [7]={["id"]=7,["reward"]="1_150"},
--    }
--
--    local userInfo = {
--        uid			= 10086,
--        nickName	= "测试员" .. 10086,
--        money		= 1000,
--        diamond		= 1000,
--        star		= 1000,
--        settings	= {},
--        sex			= 1,
--        head		= "",
--        firstLogin  = 1,--首次登陆
--    }
--    self.owner = userInfo
--
--    self.loginInfo = {}
--    self.len = #DailyLoginTable
--    for i = 1,  self.len do
--        local temp = LoginInfo:new()
--        temp.id = i
--        temp.state = G_ALREADY_GET_REWARD
--        if i == self.len then
--            temp.state = G_CAN_GET_REWARD
--        end
--
--        temp.rewardInfo = DailyLoginTable[i]["reward"]
--        self.loginInfo[i] = temp
--    end
--
--    self:Login()
--end

--DailyLogin:LoginForDebug()