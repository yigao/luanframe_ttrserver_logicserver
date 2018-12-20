module('random', package.seeall)


--添加的随机概率函数---------
----小数点概率---
function selectByPoint(value)
    if value == nil or value <= 0 then
        return false
    end
    local value = math.ceil(1 / value)
    return selectByRegion(1, value)
end


----百分比概率---
function selectByPercent(value)
    if value < 1 then
        return false
    end
    return selectByRegion(value, 100)
end
    
----万分比概率---
function selectByTenTh(value)
    if value < 1 then
        return false
    end
    return selectByRegion(value, 10000)
end

function selectByRegion(down, up)
    if down >= up then
         return true
    end
    local random = math.random(1, up)    
    return random <= down    
end
