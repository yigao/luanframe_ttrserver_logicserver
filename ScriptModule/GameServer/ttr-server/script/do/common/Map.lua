CreateClass("Map")

function Map:Init()
	self.map = {};
    self.count = 0
end


-- Map 插入新值
function Map:Insert(k,v)
    if nil == self.map[k] then
        self.map[k] = v
        self.count = self.count + 1
    end
end

-- Map 插入新值并且切换旧值
function Map:Replace(k,v)
	if nil == self.map[k] then
		self.map[k] = v;
		self.count = self.count + 1;
	else
		self.map[k] = v;
	end
end

function Map:Remove(k)
    if nil ~= self.map[k] then
        self.map[k] = nil
        if self.count >0 then
            self.count = self.count - 1
        end
    end
end

function Map:ForEachRemove(field, value)

    local newT = {} 
    
	for k,v in pairs(self.map) do
        if v[field]~=value then
            newT[k] = v;
        end
    end 
    
    self.map = newT;
end

function Map:Find(k)
    return self.map[k]
end

function Map:Clear()
    self.map = {};
    self.count = 0
end


-- 遍历所有成员
function Map:ForEach(fun, ...)
	-- body
	for k,v in pairs(self.map) do
		fun(k, v, ...)
	end
end

-- Map 获取字典的count
function Map:Count()
	return self.count;
end

return Map;


--local characters = Map:new()
--characters:Insert("name1"," this Name:123")
--characters:Replace("name1"," this Name:2" )
--local name2 = characters:Find("name1")
--nlinfo(name2)
--nlinfo(characters.count)
--for k,v in pairs(characters) do
--nlinfo(k,v)
--end