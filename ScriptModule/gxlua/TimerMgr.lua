utils = require("gxlua/Utils")

TimerMgr = {}

local tbinsert  = table.insert
local ums2t     = utils.ms2t

function TimerMgr:Init(cycle)
    
    self.timerid    = 1;
    self._removemap = {};
    self._cycle = cycle
    self._slots = {}
    self._slots[1] = {}
    self._slots[2] = {}
    self._slots[3] = {}
    self._slots[4] = {}
    utils.tinsert_n(self._slots[1], {}, 24)
    utils.tinsert_n(self._slots[2], {}, 60)
    utils.tinsert_n(self._slots[3], {}, 60)
    utils.tinsert_n(self._slots[4], {}, 1000)
    
    --setmetatable(results,{__mode = "v"})
end

function TimerMgr:GetTime()
    return self._cycle;
end

function TimerMgr:Update(cycle)
	local h1, m1, s1, ms1 = ums2t(self._cycle)
	self._cycle = cycle
	local h2, m2, s2, ms2 = ums2t(self._cycle)


	self:__UpdateT__(24, 1, h1, h2, handler(self, self.__UpdateH__))
	self:__UpdateT__(60, 2, m1, m2, handler(self, self.__UpdateM__))
	self:__UpdateT__(60, 3, s1, s2, handler(self, self.__UpdateS__))
	self:__UpdateT__(1000, 4, ms1, ms2, handler(self, self.__UpdateMS__))

    --[[
	self:__UpdateT__(24, 1, h1, h2, utils.bind(self.__UpdateH__, self))
	self:__UpdateT__(60, 2, m1, m2, utils.bind(self.__UpdateM__, self))
	self:__UpdateT__(60, 3, s1, s2, utils.bind(self.__UpdateS__, self))
	self:__UpdateT__(1000, 4, ms1, ms2, utils.bind(self.__UpdateMS__, self))
    --]]
end

function TimerMgr:AddTimer(delay, obj, func)
    self.timerid = self.timerid + 1;
    local Handler = handler(obj, func);
	self:__Insert__(delay + 1, self.timerid, Handler )
    return self.timerid;
end

function TimerMgr:RemoveTimer( timerid )
    if timerid~=nil then
        self._removemap[timerid]=true;
    end
end

function TimerMgr:__Insert__(delay, timerid, func)
	if 0 == delay then
        if self._removemap[timerid]==nil then
            func()
        else
            self._removemap[timerid] = nil;
        end
	else
		local h1, m1, s1, ms1 = ums2t(delay)
		local h2, m2, s2, ms2 = ums2t(delay + self._cycle)
		local tick = {	func    = func, 
                        id      = timerid,
						time    = { h = h2, m = m2, s = s2, ms = ms2 } }
		if h1 ~= 0 then
			tbinsert(self._slots[1][h2 == 0 and 24 or h2], tick)
		elseif m1 ~= 0 then
			tbinsert(self._slots[2][m2 == 0 and 60 or m2], tick)
		elseif s1 ~= 0 then
			tbinsert(self._slots[3][s2 == 0 and 60 or s2], tick)
		elseif ms1 ~= 0 then
			tbinsert(self._slots[4][ms2 == 0 and 1000 or ms2], tick)
		end
	end
end

function TimerMgr:__UpdateT__(cycle, index, first, last, func)
	local slots = self._slots[index]
	while first ~= last do
		first = first + 1
        
        local func_cnt = #slots[first];
        if func_cnt>0 then
            for i = 1, func_cnt do
                func(slots[first][i])
            end
            slots[first] = {}
        end

		first = first % cycle
	end
end

function TimerMgr:__UpdateH__(v)
    local delay = v.time.m * 60000 + v.time.s * 1000 + v.time.ms;
	self:__Insert__(delay, v.id, v.func)
end

function TimerMgr:__UpdateM__(v)
    local delay = v.time.s * 1000 + v.time.ms;
	self:__Insert__(delay, v.id, v.func)
end

function TimerMgr:__UpdateS__(v)
	self:__Insert__(v.time.ms, v.id, v.func)
end

function TimerMgr:__UpdateMS__(v)
	self:__Insert__(0, v.id, v.func)
end

return TimerMgr
