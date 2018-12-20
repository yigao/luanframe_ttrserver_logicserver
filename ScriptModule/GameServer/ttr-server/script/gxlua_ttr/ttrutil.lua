ttrutil = {}

-- 通过日期(yyyy-mm-dd hh:mm:ss) 得到go.time.Sec()类型的秒
function ttrutil.TimeByDateGet(date)
	local a = ttrutil.StrSplit(date, " ")
	local b = ttrutil.StrSplit(a[1], "-")
	local c = ttrutil.StrSplit(a[2], ":")
	local time = os.time{year=tonumber(b[1]), month=tonumber(b[2]), day=tonumber(b[3]), hour=tonumber(c[1]), min=tonumber(c[2]), sec=tonumber(c[3])}
	return time
end

-- 通过日期(yyyy-mm-dd/hh:mm:ss) 得到go.time.Sec()类型的秒	仅用于GM命令时 空格被用于分割参数 因此不能正常传时间
function ttrutil.TimeBySpecialDateGet(date)
	local a = ttrutil.StrSplit(date, "/")
	local b = ttrutil.StrSplit(a[1], "-")
	local c = ttrutil.StrSplit(a[2], ":")
	local time = os.time{year=tonumber(b[1]), month=tonumber(b[2]), day=tonumber(b[3]), hour=tonumber(c[1]), min=tonumber(c[2]), sec=tonumber(c[3])}
	return time
end

-- 通过日期(yyyymmddhhmmss) 用number过来
function ttrutil.TimeByNumberDateGet(date)
    unilight.debug("date-----" .. date)
    local year = math.floor(date/10000000000)
    date = date%10000000000
    local month = math.floor(date/100000000)
    date = date%100000000
    local day = math.floor(date/1000000)
    date = date%1000000
    local hour = math.floor(date/10000)
    date = date%10000
    local min = math.floor(date/100)
    local sec = date%100
	unilight.debug("year:" .. year .. "-month" .. month .. "--day" .. day .. "--hour" .. hour .. "--min" .. min .. "--sec" .. sec)
	local time = os.time{year=year, month=month, day=day, hour=hour, min=min, sec=sec}
	return time
end

-- 通过日期(yyyymmdd) 用number过来
function ttrutil.TimeByNumberShortDateGet(date)
    local year = math.floor(date/10000)
    date = date%10000
    local month = math.floor(date/100)
    local day  = date%100
	local time = os.time{year=year, month=month, day=day, hour=0, min=0, sec=0}
	return time
end

function ttrutil.DateByFormatDateGet(date)
	local a = ttrutil.StrSplit(date, " ")
	local b = ttrutil.StrSplit(a[1], "-")
	local c = ttrutil.StrSplit(a[2], ":")
	local date = {year=b[1], month=b[2], day=b[3], hour=c[1], min=c[2], sec=c[3]}
	return date
end

--取得当前date，格式：(yyyy-mm-dd hh:mm:ss)
function ttrutil.FormatDateGet(seconds,dateformat)
	seconds = seconds or os.time()
	dateformat = dateformat or "%Y-%m-%d %H:%M:%S"
	seconds = tonumber(seconds)
	return os.date(dateformat, seconds)
end

-- date: yyyymmddhhmmss
function ttrutil.FormatDate2Get(time)
	local date = ttrutil.DateByFormatDateGet(ttrutil.FormatDateGet(time))
	return tostring(date.year) .. date.month .. date.day .. date.hour .. date.min .. date.sec
end

-- 取得当前日期(day)
function ttrutil.FormatDayGet3(time)
    -- 默认东八区
    local timeZoneOffset = go.config().GetConfigInt("timezone_offset")
    if timeZoneOffset == 0 then
        timeZoneOffset = 8
    end

	seconds = time or go.time.Sec()
    local curDay = math.floor((seconds+timeZoneOffset*3600)/(24*3600)) + 1
    return curDay
end

-- 取得当前日期2 "%Y%m%d"
function ttrutil.FormatDayGet2(time)
	seconds = time or go.time.Sec()
	dateFormat = "%Y%m%d"
	return os.date(dateFormat, seconds)
end

-- 取得当前日期 "%Y-%m-%d"
function ttrutil.FormatDayGet(time)
	seconds = time or go.time.Sec()
	dateFormat = "%Y-%m-%d"
	return os.date(dateFormat, seconds)
end

-- 获取指定时间 凌晨的时间戳
function ttrutil.ZeroTodayTimestampGetByTime(time)
	local zeroToday = time - (time+8*60*60)%(24*60*60)
	return zeroToday
end

-- 获取当天凌晨的时间戳
function ttrutil.ZeroTodayTimestampGet()
	local currentTime = os.time()
	local zeroToday = currentTime - (currentTime+8*60*60)%(24*60*60)
	return zeroToday
end

-- 获取当周第一天凌晨的时间戳
function ttrutil.ZeroWeekTimestampGet(currentTime)
	currentTime = currentTime or os.time()
	local currentWeek = tonumber(os.date("%w", currentTime))

	-- 默认获取到的是 周四的0点
	local zeroWeek = currentTime - (currentTime+8*60*60)%(7*24*60*60)

	if currentWeek >= 1 and currentWeek <= 3 then
		-- 如果当前时间为周四之前 则当前获取到的为上周的周四 则周一0点需要加上4天
		zeroWeek = zeroWeek + 4*24*60*60
	else
		-- 如果当前时间为周四之后 则当前获取到的为本周的周四 则周一0点需要减去3天
		zeroWeek = zeroWeek - 3*24*60*60
	end
	return zeroWeek
end

-- 判断两个时间相距天数
function ttrutil.DateDayDistanceByTimeGet(lasttime, current)
	current = current or go.time.Sec()
	local zeroLast = lasttime - (lasttime+8*60*60)%(24*60*60)
	local zeroCur = current - (current+8*60*60)%(24*60*60)
	return math.floor((math.abs(zeroCur-zeroLast))/(24*60*60))
end

function ttrutil.DateDayDistanceByDateGet(last, current)
	local lastTime = ttrutil.TimeByDateGet(last)
	local currentTime = ttrutil.TimeByDateGet(current)
	return ttrutil.DateDayDistanceByTimeGet(lastTime, currentTime)
end

function ttrutil.StrSplit(str, pat)
	local t = {}
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t, cap)
		end
		last_end = e + 1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end

	return t
end

-- 1到max之间生成n个随机数，返回的数组长度为0表示生成失败
-- 最终取出来的值 包含max
function ttrutil.RandNNumbers(max, n)
	local  retList = {}
	local  retMap = {}
	if max <= 0 or  n > max then
		unilight.error("机器人投注筹码生成有误  RandNNumbers：" .. max .. "," .. n)
		return retList
	end
	for i=1,n do
		for try=1,100 do
			local value = math.random(1, max)
			if retMap[value]  == nil then
				retMap[value] = true
				retList[i] = value
				break
			end
		end
		if retList[i] == nil then
			for value=1,max do
				if retMap[value]  == nil then
					retMap[value] = true
					retList[i] = value
					break
				end
			end
		end
	end
	return retList
end

-- 是否同一年
function ttrutil.IsSameYear(oldTime, newTime)
    local old = os.date("*t", oldTime) 
    local new = os.date("*t", newTime)
    return old.year == new.year
end

-- 是否同一个月
function ttrutil.IsSameMonth(oldTime, newTime)
    local old = os.date("*t", oldTime) 
    local new = os.date("*t", newTime)
    return old.month == new.month
end

-- 是否同一天
function ttrutil.IsSameDay(oldTime, newTime)
    return ttrutil.DateDayDistanceByTimeGet(oldTime, newTime) == 0
end
