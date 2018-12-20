
Collect =
{
    owner = nil,
    isCollect = nil,
}

local G_DIAMOND = 1
local G_MONEY = 2

function Collect:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Collect:init(owner)
    self.owner = owner
    self.isCollect = 0
    print("Collect:init(owner), isCollect = "..self.isCollect..", uid = "..self.owner.uid)
end

function Collect:GetData()
    print("Collect:GetData, isCollect = "..self.isCollect..", uid = "..self.owner.uid)
    return {["isCollect"] = self.isCollect}
end

function Collect:loadFromDb(data)
    if data["isCollect"] == nil then
        unilight.warn("No isCollect")
        return false
    end

    self.isCollect = data["isCollect"]
    return true
end

function Collect:GetCollectInfo()
end

function Collect:HandleReward(rewardStr)

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
                print("收藏领取前, uid="..self.owner.uid..", money="..self.owner.money..", diamond="..self.owner.diamond..", rewardType="..i..", num="..v)
                UserInfo.AddUserMoney(self.owner, rewardType, v)
                print("收藏领取后, uid="..self.owner.uid..", money="..self.owner.money..", diamond="..self.owner.diamond)
            else
                UserItems:useItem(self.owner, rewardType, v)
            end
        end
    end
end

--领取收藏奖励
function Collect:GetCollectReward()

    local userInfo = self.owner

    if self.isCollect == 1 then
        return 1, "已经领取收藏奖励"
    end
    
    if CollectionTable[1] == nil then
        return 2, "奖励信息为空"
    end

    unilight.debug("GetCollectReward, CollectionTable[1]="..CollectionTable[1]["reward"]..", uid="..self.owner.uid)

    local rewardStr = SplitStrBySemicolon(CollectionTable[1]["reward"])
    --Collect:HandleReward(rewardStr) 此处要用self, 用Collect作用不到self
    self:HandleReward(rewardStr)

    userInfo.collect.isCollect = 1

    return 0, "收藏奖励 领取成功"
end
