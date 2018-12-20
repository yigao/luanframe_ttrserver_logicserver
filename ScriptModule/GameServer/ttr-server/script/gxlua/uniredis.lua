unilight.initredisdb = function()
	db = 100 
	-- 切换db
	unilight.redis_select = function(dbnum)
		dbnum = dbnum or 0 
		if type(dbnum) ~= "number" then
			unilight.error("redis dbnum type is not number")
			return false
		end
		if dbnum ~= db then
			unilight.info("redis_select from " .. db .."   to " .. dbnum )
			db = dbnum
			unilight.REDISDB.Select(db)
		end
		return true
	end

	--给key设置过期时间
	unilight.redis_setexpire = function(key, seconds, dbnum)
		if type(key) ~= "string" or type(seconds) ~= "number" then
			return  "key or seconds type error"
		end
		if not unilight.redis_select(dbnum) then
			return "db number type err"
		end
		local _, err = unilight.REDISDB.Expire(key, seconds)
		if err ~= nil then
			unilight.error("redissetexpire err key " .. key.. err)
			return err 
		end
	end

	-- 移除key
	unilight.redis_rmkey = function(key, dbnum)
		if type(key) ~= "string" then
			return  "key type error"
		end
		if not unilight.redis_select(dbnum) then
			return "db number type err"
		end
		local _, err = unilight.REDISDB.Del(key)
		if err ~= nil then
			unilight.error("redisrmkey err key " .. key.. err)
			return err 
		end
	end

	-- 设置数据:String类型
	unilight.redis_setdata = function(key, value, dbnum)
		if type(key) ~= "string" or type(value) ~= "string" then
			return  "key or value type error"
		end
		if not unilight.redis_select(dbnum) then
			return "db number type err"
		end
		local err = unilight.REDISDB.Set(key, value, 0, 0, false, false)
		if err ~= nil then
			unilight.error("redissetdata err key " .. key .. "  value  " .. value .. "  ".. err)
			return err 
		end
		return nil
	end

	-- 获取数据:String类型
	unilight.redis_getdata = function(key, dbnum)
		if type(key) ~= "string"  then
			return nil, "key or value type error"
		end

		if not unilight.redis_select(dbnum) then
			return nil, "db number type err"
		end

		local value, err = unilight.REDISDB.GetRange(key, 0, -1)
		if err ~= nil then
			unilight.error("redis_getdata error " .. err)
			return nil, err 
		end
		return tostring(value)
	end

	-- 设置数据:hash类型
	unilight.redis_sethashdata = function(key, field, value, dbnum)
		if type(key) ~= "string"  or type(field) ~= "string"  then
			return "key or value type error"
		end

		if not unilight.redis_select(dbnum) then
			return  "db number type err"
		end
		local bok, err = unilight.REDISDB.HSet(key, field, value)
		if err ~= nil then
			unilight.error("redis sethash err " .. err)
			return err 
		end

		return nil
	end
	
	unilight.redis_sethashmultdata = function(key, values, dbnum)
		if type(key) ~= "string" or  type(values) ~= "table" then
			return "key or value type error"
		end

		if not unilight.redis_select(dbnum) then
			return  "db number type err"
		end
		local bok, err = unilight.REDISDB.HMSet(key, values)
		if err ~= nil then
			unilight.error("redis sethashmultfield err ") 
			return err 
		end
		return nil
	end

	-- 获取数据:hash类型
	unilight.redis_gethashdata = function(key, field, dbnum)
		if type(key) ~= "string" or type(field) ~= "string" then
			return nil, "key or value type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.HGet(key, field)
		if err ~= nil then
			unilight.error("redis gethashmultfield err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_gethashdata_Str = function(key, field, dbnum)
		if type(key) ~= "string" or type(field) ~= "string" then
			return nil, "key or value type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.HGet_Str(key, field)
		if err ~= nil then
			unilight.error("redis gethashmultfield err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_gethashmultdata = function(key, dbnum)
		if type(key) ~= "string" then
			return nil, "key or value type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end
		local values, err = unilight.REDISDB.HGetAll(key)
		if err ~= nil then
			unilight.error("redis gethashmultfield err " .. err)
			return nil, err 
		end
		return values 
	end

	unilight.redis_gethashmultdata_Str = function(key, dbnum)
		if type(key) ~= "string" then
			return nil, "key or value type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end
		local values, err = unilight.REDISDB.HGetAll_Str(key)
		if err ~= nil then
			unilight.error("redis gethashmultfield err " .. err)
			return nil, err 
		end
		return values 
	end

	--设置数据:list类型
	unilight.redis_setlistdata = function(key, value, dbnum)
		if type(key) ~= "string" or type(value) ~= "string" then
			return nil, "key or value type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.LPush(key, value)
		if err ~= nil then
			unilight.error("redis LPushmultfield err " .. err)
			return nil, err 
		end
		return value
	end

	--获取数据:list类型
	unilight.redis_getlistdata = function(key, index, dbnum)
		if type(key) ~= "string" then
			return nil, "key or value type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.LIndex(key,index)

		if err ~= nil then
			unilight.error("redis LIndexmultfield err " .. err)
			return nil, err 
		end
		--return value
		local len = #value
		local str = ""
		for i=1,len do
			local s = string.char(tonumber(value[i]))
			str = str..s
		end
		return str
	end

	--移除数据:list类型
	unilight.redis_rmlistdata = function(key, count, value, dbnum)
		if type(key) ~= "string" or type(value) ~= "string" then
			return nil, "key or value type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.LRem(key, count, value)

		if err ~= nil then
			unilight.error("redis LRemmultfield err " .. err)
			return nil, err 
		end
	end

	unilight.redis_ZAdd = function(key, pairs, dbnum)
		if type(key) ~= "string" then
			return nil, "key type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZAdd(key, pairs)

		if err ~= nil then
			unilight.error("redis ZAdd err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_ZCard = function(key, dbnum)
		if type(key) ~= "string" then
			return nil, "key type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZCard(key, pairs)

		if err ~= nil then
			unilight.error("redis ZCard err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_ZCount = function(key, min, max)
		if type(key) ~= "string" or type(min) ~= "string" or type(max) ~= "string" then
			return nil, "key or min or max type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZCount(key, min, max)

		if err ~= nil then
			unilight.error("redis ZCount err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_ZIncrBy = function(key, increment, member, dbnum)
		if type(key) ~= "string" or type(increment) ~= "number" or type(member) ~= "string" then
			return nil, "key or increment or member type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZIncrBy(key, increment, member)

		if err ~= nil then
			unilight.error("redis ZIncrBy err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_ZInterStore = function(destination, keys, weights, aggregate, dbnum)
		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZInterStore(destination, keys, weights, aggregate)

		if err ~= nil then
			unilight.error("redis ZInterStore err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_ZLexCount = function(key, min, max, dbnum)
		if type(key) ~= "string" or type(min) ~= "string" or type(max) ~= "string" then
			return nil, "key or min or max type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZLexCount(key, min, max)

		if err ~= nil then
			unilight.error("redis ZLexCount err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_ZRange = function(key, start, stop, withscores, dbnum)
		if type(key) ~= "string" or type(start) ~= "number" or type(stop) ~= "number" then
			return nil, "key or start or stop type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZRange(key, start, stop, withscores)

		if err ~= nil then
			unilight.error("redis ZRange err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_ZRangeByLex = function(key, min, max, limit, offset, count, dbnum)
		if type(key) ~= "string" then
			return nil, "key type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZRangeByLex(key, min, max, limit, offset, count)

		if err ~= nil then
			unilight.error("redis ZRangeByLex err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_ZRangeByScore = function(key, min, max, withscores, limit, offset, count, dbnum)
		if type(key) ~= "string" then
			return nil, "key type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZRangeByScore(key, min, max, withscores, limit, offset, count)

		if err ~= nil then
			unilight.error("redis ZRangeByScore err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_ZRank = function(key, member, dbnum)
		if type(key) ~= "string" or type(member) ~= "string" then
			return nil, "key or member type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZRank(key, member)

		if err ~= nil then
			unilight.error("redis ZRank err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_ZRem = function(key, member, dbnum, ...)
		if type(key) ~= "string" or type(member) ~= "string" then
			return nil, "key or member type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZRem(key, member, arg)

		if err ~= nil then
			unilight.error("redis ZRem err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_ZRemRangeByLex = function(key, min, max, dbnum)
		if type(key) ~= "string" or type(min) ~= "string" or type(max) ~= "string" then
			return nil, "key or min or max type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZRemRangeByLex(key, min, max)

		if err ~= nil then
			unilight.error("redis ZRemRangeByLex err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_ZRemRangeByRank = function(key, start, stop, dbnum)
		if type(key) ~= "string" then
			return nil, "key type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZRemRangeByRank(key, start, stop)

		if err ~= nil then
			unilight.error("redis ZRemRangeByRank err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_ZRemRangeByScore = function(key, min, max, dbnum)
		if type(key) ~= "string" then
			return nil, "key type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZRemRangeByScore(key, min, max)

		if err ~= nil then
			unilight.error("redis ZRemRangeByScore err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_ZRevRange = function(key, start, stop, withscores, dbnum)
		if type(key) ~= "string" then
			return nil, "key type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZRevRange(key, start, stop, withscores)

		if err ~= nil then
			unilight.error("redis ZRevRange err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_ZRevRangeByScore = function(key, max, min, withscores, limit, offset, dbnum)
		if type(key) ~= "string" then
			return nil, "key type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZRevRangeByScore(key, max, min, withscores, limit, offset)

		if err ~= nil then
			unilight.error("redis ZRevRangeByScore err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_ZRevRank = function(key, member, dbnum)
		if type(key) ~= "string" then
			return nil, "key type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZRevRank(key, member)

		if err ~= nil then
			unilight.error("redis ZRevRank err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_ZScore = function(key, member, dbnum)
		if type(key) ~= "string" then
			return nil, "key type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZScore(key, member)

		if err ~= nil then
			unilight.error("redis ZScore err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_ZUnionStore = function(destination, keys, weights, aggregate, dbnum)
		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZUnionStore(destination, keys, weights, aggregate)

		if err ~= nil then
			unilight.error("redis ZUnionStore err " .. err)
			return nil, err 
		end
		return value
	end

	unilight.redis_ZScan = function(key, cursor, pattern, count, dbnum)
		if type(key) ~= "string" then
			return nil, "key type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		local value, err = unilight.REDISDB.ZScan(key, cursor, pattern, count)

		if err ~= nil then
			unilight.error("redis ZScan err " .. err)
			return nil, err 
		end
		return value
	end

	--sort排序 未经测试暂时屏蔽
	--[[
	unilight.redis_Sort = function(key, dbnum)
		if type(key) ~= "string" then
			return nil, "key type error"
		end

		if not unilight.redis_select(dbnum) then
			return  nil, "db number type err"
		end

		return unilight.REDISDB.Sort(key)
	end

	unilight.redis_By = function(pattern)
		if type(pattern) ~= "string" then
			return nil, "pattern type error"
		end
		return unilight.REDISDB.By(pattern)
	end

	unilight.redis_Limit = function(offset, count)
		if type(offset) ~= "number" or type(count) ~= "number" then
			return nil, "offset or count type error"
		end
		return unilight.REDISDB.Limit(offset, count)
	end

	unilight.redis_Get = function(patterns, ...)
		return unilight.REDISDB.Get(patterns, arg)
	end

	unilight.redis_ASC = function()
		return unilight.REDISDB.ASC()
	end

	unilight.redis_DESC = function()
		return unilight.REDISDB.DESC()
	end

	unilight.redis_Alpha = function(b)
		return unilight.REDISDB.Alpha(b)
	end

	unilight.redis_Store = function(destination)
		if type(pattern) ~= "string" then
			return nil, "destination type error"
		end
		return unilight.REDISDB.Store(destination)
	end

	unilight.redis_run = function()
		local value, err = unilight.REDISDB.Run()

		if err ~= nil then
			unilight.error("redis sort run err " .. err)
			return nil, err 
		end
		return value
	end]]

end
