
Guide =
{
    owner = nil,
    guideId = nil,
}

local G_DIAMOND = 1
local G_MONEY = 2

function Guide:new(o)
    o = o or {}
    self.owner = {}
    self.guideId = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Guide:init(owner)
    self.owner = owner
    self.guideId = {}
end

function Guide:GetData()
    return {["guideId"] = self.guideId}
end

function Guide:loadFromDb(data)
    if data == nil or data["guideId"] == nil then
        unilight.warn("No guideId")
        return false
    end

    self.guideId = data["guideId"]
    return true
end



--保存引导信息
function Guide:SaveGuideInfo(guideId)

    if guideId <= 0 then
         return 1, "引导id错误"
    end

    for i, v in pairs(self.guideId) do
        if v == guideId then
            return 2, "已经存在该引导id"
        end
    end

    --self.guideId = guideId
    table.insert(self.guideId, guideId)

    return 0, "引导id保存成功"
end

--获取引导信息
function Guide:GetGuideInfo(guideId)
    return 0, "获取引导id成功", self.guideId
end




















