if mongo_data_cache == nil then
	mongo_data_cache={}
end
mongo_data_cache_save_time = 30
unimongodb_debug = false

unilight.initmongodb = function()
	unilight.get_mongodb = function()
		unilight.MONGODB.Refresh()
		return unilight.MONGODB
	end
	
	--[[
		功能：创建表
		参数：
			name   : string, 表名
			primary: string, 主键名
		实例：
			unilight.createdb("userinfo", "_id") // 创建一个"userinfo"表，主键为"_id"
	]]
	unilight.createdb = function(name, primary)
		unilight.get_mongodb().EnsureCollection(name, primary)
	end
	unilight.createtable = unilight.createdb

	--[[
		功能: 删除表
		参数：
			name   : string, 表名
		实例：
			unilight.droptable("userinfo") // 删除表"userinfo"
    ]]
	unilight.droptable = function(name)
		unilight.get_mongodb().DropCollection(name)
	end

	--[[
		功能：创建索引
		参数：
			name   : string, 表名
			index  : string, 索引名, 支持嵌套,不同层次的字段名之间有"."链接
		实例：
	  	   表"userinfo"里有json对象格式：
			"outer":{"inner": "abc"}}
	    	对outer.inner建立索引：unilight.createindex("userinfo", "outer.inner")
	]]
	unilight.createindex = function(name, index)
		unilight.get_mongodb().EnsureCollectionIndexKey(name, index)
	end

	--[[
		功能: 清空表数据
		参数：
			name  : string, 表名
		实例：
			unilight.cleardb("userinfo") // 删除表"userinfo"

		WARNNING: 前方高能接口，千万慎重使用!!
	]]
	unilight.cleardb = function(name)
		unilight.get_mongodb().ClearCollection(name)
	end
	unilight.cleartable = unilight.cleardb

	--[[
        功能：删除表中的符合条件的记录
		参数：
			name: string           , 表名
			flter  : 根据存储类型一致 ，主键值
	        filter: mongodb判断结构体，当为nil时，不进行筛选
		
    --]]
	unilight.remove= function(name, filter)
        if name == nil or filter == nil then
            unilight.error("name or filter is null error")
            return nil
        end
		if type(name) == "userdata" then
            unilight.error("name or filter type is userdata  error")
            return nil
        end
		return unilight.get_mongodb().Remove(name, filter.M)
    end
	--[[
		功能：删除表中的一条记录
		参数：
			name: string           , 表名
			id  : 根据存储类型一致 ，主键值
		实例：
			unilight.delete("userinfo", 100000) // 删除表"userinfo", 主键值为100000的那条记录
	]]
	unilight.delete = function(name, id)
		if id == nil then
			return nil
		end
		if type(id) == "userdata" then
			unilight.error("getdata type(key) is userdata")
			return nil
		end
		local r = unilight.get_mongodb().RemoveCollectionById(name, id)
		if r ~= nil then
			unilight.error("delete error  tablename " .. tostring(name) .. "  id" .. id)
		end
		if name == "data" and mongo_data_cache[id] ~= nil then 
			mongo_data_cache[id] = nil 
			--unilight.debug("unilight.delete  同时删除数据库缓存")
		end 
	end

	--[[
		功能：获取表中一条记录
		参数：
			name: string           , 表名
			id  : 根据存储类型一致 ，主键值
		实例：
			unilight.getdata("userinfo", 100000) // 获取表"userinfo"中主键值为100000的那条记录
	]]
	unilight.getdata = function(name, key, force)
		if key == nil then
			return nil
		end
		if type(key) == "userdata" then
			unilight.error("getdata type(key) is userdata")
			return nil
		end

		local cache = mongo_data_cache[key]

		if name == "data" then
			local uid = tonumber(key)
			if uid == nil or uid == 0 then
				unilight.error("uid can't change to number")
				return 
			end

			local uidZoneid = math.floor(uid/0xffffffff)
			if uidZoneid ~= go.gamezone.Zoneid and uidZoneid ~= 0 then
				mongo_data_cache[key] = nil 
				cache = nil
			end
		end

		if name ~= "data" or cache == nil or force then
			local r = unilight.get_mongodb().GetCollectionById(name, key)
			if r.E ~= nil then
				unilight.error(r.E)
				return nil
			end
			if name == "data" then
			--	unilight.debug("unilight.getdata 读取缓存命中失败")
			end
			local resData = decode_repair(luar.map2table(r.R)) 
			if table.empty(resData) then
				return nil
			end
			if name == "data" then
				--local str = table2json(resData)
				--mongo_data_cache[key] = {["data"]=resData,["str"]=str,["updatetime"]=os.time()}
				mongo_data_cache[key] = {["data"]=resData,["updatetime"]=os.time(),["lastsavetime"]=0}
				unilight.debug("unilight.getdata uid: ".. key .."缓存命中失败,增加缓存")
			end
				return resData
		end
		unilight.debug("unilight.getdata 读取缓存命中成功")
		return  cache.data
	end

	--[[
		功能：保存一条记录
		参数：
			 name: string, 表名
			 data: table , 需要保存的数据的全部信息，如果和表里已有的记录冲突，替换整条记录,
		实例：
			local userInfo = {
				_id = 100000,
				chips = 200000,
				base = {
					headurl = "http://baidu.com"
				}
			}
			unilight.savedata("userinfo", userInfo)
	]]
	unilight.savedata = function(name, data,force)
		if name == "data" and data.uid ~= nil then 
			local need_save = true
			if mongo_data_cache[data.uid] ~= nil and os.time() - mongo_data_cache[data.uid].lastsavetime < mongo_data_cache_save_time then
				need_save = false
			end

			local uid = tonumber(data.uid)
			if uid == nil or uid == 0 then
				unilight.error("uid can't change to number")
				return 
			end

			local uidZoneid = math.floor(uid/0xffffffff)
			if uidZoneid ~= go.gamezone.Zoneid and uidZoneid ~= 0 then
				force = true
			end
			--[[local str = table2json(data)
			if mongo_data_cache[data.uid] ~= nil and str == mongo_data_cache[data.uid].str then
			unilight.debug("unilight.savedata 缓存命中成功")
			return nil
			end
			unilight.debug("unilight.savedata: uid:".. data.uid .." 缓存命中失败,增加缓存")
			mongo_data_cache[data.uid] = {["data"]=data,["str"]=str,["updatetime"]=os.time()}
			]]
			local tmptime = 0
			if mongo_data_cache[data.uid] ~= nil then
				tmptime = mongo_data_cache[data.uid].lastsavetime
			end
			mongo_data_cache[data.uid] = {["data"]=data,["updatetime"]=os.time()}
			mongo_data_cache[data.uid].lastsavetime = tmptime
			if need_save == false and not force then
				unilight.debug("unilight.savedata: uid:".. data.uid ..",存档优化 跳过1")
				return nil
			end
			if mongo_data_cache[data.uid] ~= nil and mongo_data_cache[data.uid].updatetime == 0 then
				unilight.debug("unilight.savedata: uid:".. data.uid ..",存档优化 跳过2")
				return nil
			end
			mongo_data_cache[data.uid].lastsavetime=os.time()
			mongo_data_cache[data.uid].updatetime=0
			unilight.debug("unilight.savedata: uid:".. data.uid ..",存档成功")
		end
		--unilight.info("存档优化 执行")
		local r = unilight.get_mongodb().SaveCollectionById(name, encode_repair(data))
		if r == nil then
			unilight.error("unilight.get_mongodb().SaveCollectionById err:"..name )
		end
		if r.E ~= nil then
			unilight.error("unilight.savedata"..name)
			unilight.error(r.E)
		else if data._id == nil then
			data._id = r.R._id
		end
	end
		return r.E, data._id
	end

	--[[
		功能：保存一条记录里的某部分字段
		参数：
			name     : string           , 表名
			id       : 根据存储类型一致 ，主键值
			fieldpath: string           , 保存的记录键名
			data     : table            , 需要保存据信息，如果表里已有记录冲空，替换整条记录
		返回： nil 表示成功
			   string 表示失败
		实例：
		(1)	表"userinfo"原来有一条记录
			userInfo = {
				_id = 100000,
				chips = 200000,
				base = {
					headurl = "http://baidu.com",
					property = {
						name = "zwl",
						age = 27,
					},
				},
			}

		(2) 将userInfo.base.property修改成
			local property = {
				Name = "zhaowolong",
				age = 28,
				addr = "深圳",
			}
			unilight.savefield("userinfo", 100000, "base.property", property)

		(3) 表"userinfo" 中键值为：100000的最新记录为：
			userInfo = {
				_id = 100000,
				chips = 200000,
				base = {
					headurl = "http://baidu.com",
					property = {
						Name = "zhaowolong",
						age = 28,
						addr = "深圳"
					},
				}
			}
	]]
	----------------------------------WARNNING-------------------------------------
	-- data将覆盖指定的fieldpath，记得是覆盖
	-----------------------------------------------------------------------
	unilight.savefield = function(name, id, fieldpath, data)
		if id == nil or type(id) == "userdata" or data == nil or type(data) == "userdata" then
			unilight.error("id or data is null or type() is userdata")
			return "datatype error "  
		end

		if name == "data" and id ~= nil then
			mongo_data_cache[id] = nil	
		end

		local r = {}
		if type(data) == "table" then
			r = unilight.get_mongodb().SaveCollectionFieldById(name, id,fieldpath,encode_repair(data))

		else
			r =unilight.get_mongodb().SaveCollectionFieldById(name, id,fieldpath,data)
		end

		if r ~= nil then
			local errorInfo = "unilight.savefield:" .. tostring(r) 
			if id ~= nil then
				errorInfo = errorInfo .. " _id:" .. id .. "   type is" .. type(id)
			end
			unilight.error(errorInfo)
		end
		return r
	end

	-- 定时清除过期缓存
	unilight.check_data_cache_timeout = function(text,clocker)
		unilight.debug("unilight.check_data_cache_timeout:"..text)
		local now = os.time()
		local timeout = 86400
		for k,v in pairs(mongo_data_cache) do
			if table.len(v) > 10000 then
				timeout = 3600*3
				break
			end
		end

		for k,v in pairs(mongo_data_cache) do
			if now - v.lastsavetime >= timeout then
				 mongo_data_cache[k] = nil
			end
		end
	end
	unilight.check_data_cache_saveall = function()

		for k,v in pairs(mongo_data_cache) do
			if v.updatetime ~= 0 then
				unilight.savedata("data", v.data,true)
			end
		end
	end

	--[[
		功能: 保多条数据
		参数：
			name  : string , 表名
			array : array  , 用table保存的连续数组
		实例：
			local data1 = {
				_id = "zwl",
				age   = 27,
			}
			local data2 = {
				_id = "zhaowolong",
				age = 28,	
			}
			local data = {}
			table.insert(data, data1)
			table.insert(data, data2)
			unilight.savebatch("userinfo", data) // 保存了两条记录
	]]

    unilight.savebatch = function(name, array)
        if type(array) ~= "table" or type(name) ~= "string" then
            unilight.error("savebatch type error")
            return "savebatch type error "
        end
        local r = unilight.get_mongodb().SaveBatchCollectionById(name,array) 
        if r.E ~= nil then
            unilight.error(r.E)
        end
        return r.E
    end
    --[[
		功能：生成mongo查询等组装的结构体
		参数：
			fieldpath: string           , 记录键名
		实例：
			unilight.field("base.chips")
	]]
	unilight.field = function(fieldpath)
		if type(fieldpath) ~= "string" then
			return nil
		end
		local self = unilight.MONGODB.Field(fieldpath) 
		return self
	end

	--[[
		功能：包装生成判断mongodb中字段值是否"=="的结构体
		参数：
			a: string     , 比较字段名，不同层次之间用"."链接
			b: 根据具体值 , 比较字段值
		实例：
			unilight.eq("base.chips", 10000) // 包装生成判断base.chips是否相等的结构体
	]]
	unilight.eq = function(a, b)
		if type(a) == "string" then
			a = unilight.field(a)
		end
		return a.Eq(b)
	end

	unilight.neq = function(a, b)
		if type(a) == "string" then
			a = unilight.field(a)
		end
		return a.Ne(b)
	end
	-- 参考uniligt.eq
	-- 大于等于(>=)
	unilight.ge = function(a, b)
		if type(a) == "string" then
			a = unilight.field(a)
		end
		return a.Ge(b)
	end

	-- 参考uniligt.eq
	-- 大于(>)
	unilight.gt = function(a, b)
		if type(a) == "string" then
			a = unilight.field(a)
		end
		return a.Gt(b)
	end

	-- 参考uniligt.eq
	-- 小于等于(<=)
	unilight.le = function(a, b)
		if type(a) == "string" then
			a = unilight.field(a)
		end
		return a.Le(b)
	end

	-- 参考uniligt.eq
	-- 小于(<)
	unilight.lt = function(a, b)
		if type(a) == "string" then
			a = unilight.field(a)
		end
		return a.Lt(b)
	end

    -- 正则匹配
	unilight.re = function(a, b)
		if type(a) == "string" then
			a = unilight.field(a)
		end
		return a.Re(b)
	end


	--[[
		功能：包装生成判断mongodb中and结构体
		参数：
			... : 不定长参数,每个参数类型需要是unilight.filed生成的结构体
		实例：
			查找uid > 0 and property.chips>0 , 对结果以uid为排序的降序数据, 跳过前100个数据且只返回10个

			local filter1 = unilight.gt("uid", 1)
			local filter2 = unilight.gt("property.chips", 1)
			local filtera = unilight.a(filter2, filter1)
			local complexQuery = unilight.startChain().Table("userinfo").Filter(filtera).OrderBy(unilight.desc("uid")).Skip(100).Limit(10)
			local seq = unilight.chainResponseSequence(complexQuery)
	]]

	unilight.group = function(...)
		local where = unilight.field("")
		return	where.Group(...)
	end

	unilight.match = function(...)
		local where = unilight.field("")
		return	where.Match(...)
	end

	unilight.a = function(...)
		a = unilight.field("")
		return	a.And(...)
	end
	
	-- 参考unilight.a
	-- 包装生成逻辑或的结构体
	unilight.o = function(...)
		a = unilight.field("")
		return	a.Or(...)
	end

	-- 参考unilight.a
	-- 包装生成逻辑非的结构体
	unilight.n = function(filter)
		return filter.Not() 
	end

	--[[
		功能: 对索引asc
		参数：
			index: string, 表中的index字段
		实例：
			unilight.ascWithIndex("userinfo.uid") 
	]]
	unilight.ascWithIndex = function(index)
		return index
	end
	
	-- 参考unilight.ascWithIndex
	-- 对index生成索引降序
	unilight.descWithIndex = function(index)
		return "-"..index
	end

	-- 参考unilight.ascWithIndex
	-- 对字段生成升序结构体
	unilight.asc = function(a)
		return a 
	end

	-- 参考unilight.ascWithIndex
	-- 对字段生成降序结构体
	unilight.desc = function(a)
		return "-"..a 
		--return unilight.get_mongodb().Desc(unilight.field(a))
	end

	-- 对表进行排序和筛选后，获取几条记录
	-- name: string, 表名
	-- limit: number, 个数
	-- orderby: mongodb排序结构体，必须是unlight.asc, unilight.desc, unilight.ascWithIndex, unilight.descWithIndex其中一个的返回值
	-- filter: mongodb判断结构体，当为nil时，不进行筛选
	--[[
		功能：对表进行排序筛选后，获取前几条记录
		参数：
			name   : string, 表名
			limit  : number, 个数
			orderby: mongo排序结构体,in {unilight.asc, unilight.desc, unilight,ascWithIndex, unilight.descWithIndex}其中一个返回值
			where  : mongo判断结构体，当为nil时，不进行筛选
		实例：
			查找表中的platid为67或68，以降序排列金币，前20名金币排行
			local orderby = unilight.desc("property.chips")
			local filt1 = unilight.eq("platid", 67)
			local filt2 = unilight.eq("platid", 68)
			local filter = unilight.o(filt1, filt2)
			local usrgroup = unilight.topdata("userinfo", 20, orderby, filter)
	]]
	unilight.topdata = function(name, limit, orderby, filter)
		local debug_time_start = nil
		if unimongodb_debug then
			debug_time_start = os.clock()
		end
		
		filter = filter or { M = {}}
		local r = unilight.get_mongodb().GetSortFields(name,  filter.M,  limit, orderby)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		local ret = unilight.repairslice(r.R)
		
		if unimongodb_debug then 
			local debug_time_end = os.clock()
			unilight.info("[unimongodb_debug] unilight.topdata: " .. tostring(debug_time_end - debug_time_start) .. "s")
		end
		
		return ret
	end

	--[[
		功能：获取条记录的指定字段数据
		参数：
			name      :string          , 表名
			id        :根据具体使用类型， 键值
			fieldpath :string          , 指定字段
		实例：
			unilight.getfield("userinfo", 100000, "base.property") // 获取表"userinfo"中，key为100000的"base.property"字段数据
	]]
	unilight.getfield = function(name, id, fieldpath)
		local r = unilight.get_mongodb().GetCollectionFieldById(name, id,fieldpath)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end

		local data = r.R
		data = decode_repair(luar.map2table(data))
		local fields = string.split(fieldpath, ".")
		for index, name in ipairs(fields) do
			data = data[name]
		end
		return data
	end

	-- 参考uniligt.savefield()
	----------------------------------WARNNING-------------------------------------
	-- data将覆盖 args根目录字段 ，记得是覆盖
	-----------------------------------------------------------------------
	unilight.update = function(name, id, args)
		if id == nil or type(id) == "userdata" or args == nil or type(args) == "userdata" then
			unilight.error("id or data is null or type() is userdata")
			return "data type error "  
		end

		if name == "data" then
			mongo_data_cache[id]=nil
		end

		local r = unilight.get_mongodb().SaveCollectionFieldById(name, id,"", encode_repair(args))
		if r ~= nil and id ~= nil then
			local errorInfo = "unilight.update :" .. tostring(r) 
			if id ~= nil then
				errorInfo = errorInfo .. " _id:" .. id .. "   type is" .. type(id)
			end
			unilight.error(errorInfo)
		end
		return r
	end

	--[[
		功能:更新一个表里所有记录的某个属性字段
		参数：
			name : string, 表名
			args : 基本类型, 需要更新的数据 
		实例：
			local addr = {
				addr = "方东深圳"
			}
			unilight.updatetable("userinfo", addr) // 统一将表里所有的addr字段替换
		 WARNNING: 前方高能接口，千万慎重使用!!
	]]
	unilight.updatetable = function(name, args)
		local r = unilight.get_mongodb().UpdateCollection(name, args)
		if r ~= nil then
			unilight.error(r)
		end
		return r
	end

	--[[
		功能：获取排序后,获取某个键值的排名
		参数：
			name :string     , 表名
			field:string     ，键名
			value:根据具体值 , 键值
			orderby: mongo排序结构体,in {unilight.asc, unilight.desc, unilight,ascWithIndex, unilight.descWithIndex}其中一个返回值
		实例：
			unilight.getindex("userinfo", "_id", 100000, unilight.desc("property.chips")) // 获取在userinfo表中，"_id" = 100000 的金币排行中的排名
	]]
	unilight.getindex = function(name, field, value, orderby)
		--where[field]["gt"]=value

		local debug_time_start = nil
		if unimongodb_debug then
			debug_time_start = os.clock()
		end

		local where = {}
		where[field]= value
		local r = unilight.get_mongodb().IndexOf(name, where, orderby)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		local res = r.N - 1
		if unimongodb_debug then 
			local debug_time_end = os.clock()
			unilight.info("[unimongodb_debug] unilight.getindex: " .. tostring(debug_time_end - debug_time_start) .. "s")
		end

		return res
	end

	unilight.getaround = function(name, field, value, size, orderby)
		local where = {}
		where[field]= value
		local r = unilight.get_mongodb().Around(name, where, size, orderby)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return {data=unilight.repairslice(r.R), skip=r.S, index=r.I}
	end
	
	unilight.getmax = function(name, field, default)
		local orderby = unilight.desc(field)
		local r = unilight.get_mongodb().Max(name, orderby)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return decode_repair(luar.map2table(r.R))[field]
	end

	unilight.getByIndex = function(name, index, ...)
		local args = {...}
		local r = unilight.get_mongodb().GetAllByIndex(name, index, args)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return unilight.repairslice(r.R)
	end

	--[[
		功能：获取指定数量的已能过filter筛选后的记录
		参数：
			name   :string           , 表名
			filter :montodb判断结构体, filter
			limit  :number           , 指定数量
		实例：
			local res = unilight.getByFilter("userinfo", unilight.gt("property.chips", 80000), 10) // 获取表userinfo中，金币大于80000的10条记录
	]]
	unilight.getByFilter = function(name, filter, limit)
		local r = unilight.get_mongodb().GetCollectionByFilter(name, filter.M, limit)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return unilight.repairslice(r.R)
	end

	--[[
	    功能： 获取表里所有符合筛选条件的记录的数量
		参数：
			name    :string,表名
			filter :montodb判断结构体, filter
			
		实例：
			local num = unilight.getCountByFilter("userinfo", unilight.gt("property.chips", 80000)) // 获取表userinfo中，金币大于80000的记录数
	]]
	unilight.getCountByFilter = function(name, filter)
		local r = unilight.get_mongodb().FilterCount(name, filter.M)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return r.N
	end

	--[[
		功能： 获取表里的所有记录
		参数：
			 name:string,表名
		实例：
			local res = unilight.getAll("userinfo")
	]]
	unilight.getAll = function(name)
		local r = unilight.get_mongodb().GetCollection(name)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return unilight.repairslice(r.R)
	end

	-- 自定义查询数据库语句的起始
	-- 举例说明用法
	-- -- 如果在网页上的查询接口是r.db("project_dbname").table("test").filter(r.row("uid").gt(0)).count()
	-- -- 那么在这里应该写成rql = unilight.startChain().Table("test").Filter(unilight.field("uid").Gt(0)).Count()
	-- -- 那么在这里应该写成rql = unilight.startChain().C("test").Find(unilight.field("uid").Gt(0)).Count()
	-- -- 那么在这里应该写成rql = unilight.get_mongodb().C("test").Find(unilight.field("uid").Gt(0)).Count()
	-- -- r.db("project_dbname")后面用"."串起来的函数名的首字母变成大写，就能直接串到unilight.startChain()后面
	-- -- r.row对应unilight.field，之后的函数名的处理和上面一样
	-- -- 生成rql就是自定义的查询语句
	-- -- 然后用下面unilight.chainResponse...(rql)到数据库做查询，获取查询的结果
	-- -- 选择用哪个unilight.chainResponse...，要根据查询语句来判断
	-- --  比如现在的rql是获取记录的数量，结果应该是number，所以用
	-- --  unilight.chainResponseNumber(rql)来获取结果
	--[[
		参数：
		实例：
	]]
	unilight.startChain = function()
		return unilight.get_mongodb()
	end

	unilight.chainResponseSequence = function(chain)
		local r = unilight.get_mongodb().ChainResponseSlice(chain)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return unilight.repairslice(r.R)
	end

	unilight.chainResponseObject = function(chain)
		local r = unilight.get_mongodb().ChainResponseFetch(chain)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return decode_repair(luar.map2table(r.R))
	end

	unilight.chainResponseWrite = function(chain)
		local r = unilight.get_mongodb().ChainResponseWrite(chain)
		if r.E ~= nil then
			unilight.error(r.E)
		end
		return r.E
	end

	unilight.chainResponseNumber = function(chain, err)
		local r = unilight.get_mongodb().ChainResponseNumber(chain)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return r.N
	end
end
