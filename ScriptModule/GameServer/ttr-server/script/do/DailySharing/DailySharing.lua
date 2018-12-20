
local G_DIAMOND = 1
local G_MONEY = 2

DailySharing =
{
    owner = nil,
    dailyRewardNum = nil,
}

function DailySharing:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function DailySharing:init(owner)
    self.owner = owner
    self.dailyRewardNum = 0
    print("DailySharing:init(owner), dailyRewardNum = "..self.dailyRewardNum..", uid = "..self.owner.uid)
end

function DailySharing:GetData()
    print("DailySharing:GetData, dailyRewardNum = "..self.dailyRewardNum..", uid = "..self.owner.uid)
    return {["dailyRewardNum"] = self.dailyRewardNum}
end

function DailySharing:loadFromDb(data)
    if data["dailyRewardNum"] == nil then
        unilight.warn("No dailyRewardNum")
        return false
    end

    self.dailyRewardNum = data["dailyRewardNum"]
    return true
end

function SplitStrBySemicolon(str)

    local strTable = {}
    local count = 0
    local len = string.len(str)
    local beginPos = 1

    while beginPos < len do

        local index = string.find(str, ";", beginPos)
        count = count + 1
        if index == nil then
            strTable[count] = string.sub(str, beginPos, -1)
            return strTable
        end

        strTable[count] = string.sub(str, beginPos, index-1)
        beginPos = index + 1

    end

    return strTable
end

function DailySharing:GetDailySharingInfo()
    return self.owner.dailySharing.dailyRewardNum
end

function DailySharing:HandleReward(rewardStr)

    local rewardInfo = {}
    for i, v in ipairs(rewardStr) do
        local index = string.find(v, "_")
        local rewardType = string.sub(v,1, index-1)
        local rewardNum = tonumber(string.sub(v, index + 1, -1))
        if rewardInfo[rewardType] == nil then
            rewardInfo[rewardType] = 0
        end
        rewardInfo[rewardType] = rewardInfo[rewardType] + rewardNum
    end

    for i, v in pairs(rewardInfo) do
        if v > 0 then
            local rewardType = tonumber(i)
            print("HandleReward, i="..i..", v="..v..", rewardType="..rewardType)
            if rewardType <=2 then
                print("每日分享领取前, uid="..self.owner.uid..", money="..self.owner.money..", diamond="..self.owner.diamond..", rewardType="..i..", num="..v)
                UserInfo.AddUserMoney(self.owner, rewardType, v)
                print("每日分享领取后, uid="..self.owner.uid..", money="..self.owner.money..", diamond="..self.owner.diamond)
            else
                UserItems:useItem(self.owner, rewardType, v)
            end
        end
    end
end

--领取每日分享奖励
function DailySharing:GetDailySharingReward(sharingId)

    local userInfo = self.owner
    --if userInfo.dailyRewardNum >= #DailyShare then
       -- return 2, "已经领取过了", 0
    --end

    if (sharingId-userInfo.dailySharing.dailyRewardNum) ~= 1 then
        return 3, "非法领取", 0
    end

    if DailyShare[sharingId] == nil then
        return 4, "奖励信息为空", 0
    end

    local rewardStr = SplitStrBySemicolon(DailyShare[sharingId]["reward"])
    self:HandleReward(rewardStr)
    userInfo.dailySharing.dailyRewardNum = sharingId

    return 0, "领取成功", sharingId
end

function DailySharing:Login()
    if ttrutil.IsSameDay(self.owner.lastlogintime,os.time()) == false then
        self.dailyRewardNum = 0
    end
end






