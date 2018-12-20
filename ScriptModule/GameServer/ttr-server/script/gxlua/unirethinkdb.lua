unilight.initrethinkdb = function()
	
	-- 创建表
	-- name: string, 表名
	-- primary: string, 主键名
	unilight.createdb = function(name, primary)
		unilight.RETHINKDB.EnsureTable(name, primary)
	end

	-- WARNNING: 前方高能接口，千万慎重使用!!
	-- 删除表
	-- name: string, 表名
	unilight.droptable = function(names)
		unilight.RETHINKDB.EnsureTableDrop(names)
	end

 	-- 创建索引
	-- name: string, 表名
	-- index: string, 索引的字段，支持嵌套字段，不同层次的字段名之间用"."链接
	-- -- 比如一个json对象{"outer":{"inner": "abc"}}，可以用
	-- -- unilight.createindex("table", "outer.inner")
	-- -- 对outer里面的inner字段做索引
	unilight.createindex = function(name, index)
		unilight.RETHINKDB.EnsureIndex(name, index, unilight.field(index))
	end

	-- WARNNING: 前方高能接口，千万慎重使用!!
	-- 清空一个表里的所有数据
	-- name: string, 表名
	unilight.cleardb = function(name)
		local r = unilight.RETHINKDB.DeleteAll(name)
		if r.E ~= nil then
			unilight.error(r.E)
		end
	end

	-- 删除一条记录
	-- name: string, 表名
	-- uid: 要删除的记录的主键值
	unilight.delete = function(name, uid)
		local r = unilight.RETHINKDB.Delete(name, uid)
		if r.E ~= nil then
			unilight.error(r.E)
		end
	end

	-- 获取一条记录
	-- name: string, 表名
	-- key: 要获取的记录的主键值
	-- 做一个缓存，防止数据库累死
	local data_cache={}
	unilight.getdata = function(name, key)
		if key == nil then
			return nil
		end
		if type(key) == "userdata" then
			unilight.error("getdata type(key) is userdata")
			return nil
		end
		local cache = data_cache[key]
		if name ~= "data" or cache == nil then
			local r = unilight.RETHINKDB.Get(name, key)
			if r.E ~= nil then
				unilight.error(r.E)
				return nil
			end
			if name == "data" then
				unilight.debug("unilight.getdata 读取缓存命中失败")
			end
			return decode_repair(luar.map2table(r.D))
		end
		unilight.debug("unilight.getdata 读取缓存命中成功")
		return  cache.data
	end

	-- 保存一条记录
	-- name: string, 表名
	-- data: table, 需要保存的数据的全部信息，如果和表里已有的记录冲突，替换整条记录
	unilight.savedata = function(name, data)
		if name == "data" and data.uid ~= nil then 
			local str = table2json(data)
			if data_cache[data.uid] ~= nil and str == data_cache[data.uid].str then
				 unilight.debug("unilight.savedata 缓存命中成功")
				return nil
			end
			unilight.debug("unilight.savedata 缓存命中失败,增加缓存")
			data_cache[data.uid] = {["data"]=data,["str"]=str,["time"]=os.time()}
		end
		local r = unilight.RETHINKDB.Save(name, encode_repair(data))
		if r.E ~= nil then
			unilight.error("unilight.savedata")
			unilight.error(r.E)
		end
		return r.E,r.R.GeneratedKeys
	end

	-- 定时清除过期缓存
	unilight.check_data_cache_timeout = function(text,clocker)
		unilight.debug("unilight.check_data_cache_timeout:"..text)
		local now = os.time()
		local timeout = 86400
		for k,v in pairs(data_cache) do
			if table.len(v) > 10000 then
				timeout = 3600*3
				break
			end
		end

		for k,v in pairs(data_cache) do
			if now - v.time >= timeout then
				 data_cache[k] = nil
			end
		end
	end

	-- 保存多条记录
	-- name: string, 表名
	-- array: array of tables, arry里面的每个table的处理方式和unilight.savedata相同
	unilight.savebatch = function(name, array)
		local data = {}
		for k, v in pairs(array) do
			table.insert(data, encode_repair(v))
		end

		local r = unilight.RETHINKDB.Save(name, data)
		if r.E ~= nil then
			unilight.error(r.E)
		end
		return r.E
	end

	-- 包装生成字段信息的rethinkdb结构体
	-- path: string, 字段名，支持嵌套字段，不同层次的字段名之间用"."链接
	unilight.field = function(path)
		local fields = string.split(path, ".")
		local term = nil
		for index, name in ipairs(fields) do
			if index == 1 then
				term = unilight.RETHINKDB.Row.Field(name)
			else
				term = term.Field(name)
			end
		end
		return term
	end

	-- 包装生成距离rethinkdb结构体
	-- a: string或unilight.field的返回值，如果是string，必须是表的字段名，支持嵌套字段，不同层次的字段名之间用"."链接
	-- b: number或unilight.field的返回值，用于和a所代表的字段的值做计算
	unilight.distance = function(a, b)
		if type(a) == "string" then
			a = unilight.field(a)
		end
		return a.Sub(b).Mul(a.Sub(b))
	end

	-- 包装生成判断有无字段的rethinkdb结构体
	-- path: string, 字段名，支持嵌套字段，不同层次的字段名之间用"."链接
	unilight.hasfield = function(path)
		local fields = string.split(path, ".")
		if #fields == 1 then
			return unilight.RETHINKDB.Row.HasFields(fields[1])
		else
			local path = table.concat(fields, ".", 1, #fields-1)
			return unilight.field(path).HasFields(fields[#fields])
		end
	end

	-- 包装生成判断是否相等的rethinkdb结构体
	-- a: string或unilight.field的返回值，如果是string，必须是表的字段名，支持嵌套字段，不同层次的字段名之间用"."链接
	-- b: 类型不定或unilight.field的返回值，代表类型需要和a代表的值的类型相对应
	unilight.eq = function(a, b)
		if type(a) == "string" then
			a = unilight.field(a)
		end
		return a.Eq(b)
	end

	-- 包装生成判断是否不相等的rethinkdb结构体
	-- a: string或unilight.field的返回值，如果是string，必须是表的字段名，支持嵌套字段，不同层次的字段名之间用"."链接
	-- b: 类型不定或unilight.field的返回值，代表类型需要和a代表的值的类型相对应
	unilight.neq = function(a, b)
		return unilight.n(unilight.eq(a, b))
	end

	-- 包装生成判断a是否大等于b的rethinkdb结构体
	-- a: string或unilight.field的返回值，如果是string，必须是表的字段名，支持嵌套字段，不同层次的字段名之间用"."链接
	-- b: 类型不定或unilight.field的返回值，代表类型需要和a代表的值的类型相对应
	unilight.ge = function(a, b)
		if type(a) == "string" then
			a = unilight.field(a)
		end
		return a.Ge(b)
	end

	-- 包装生成判断a是否大于b的rethinkdb结构体
	-- a: string或unilight.field的返回值，如果是string，必须是表的字段名，支持嵌套字段，不同层次的字段名之间用"."链接
	-- b: 类型不定或unilight.field的返回值，代表类型需要和a代表的值的类型相对应
	unilight.gt = function(a, b)
		if type(a) == "string" then
			a = unilight.field(a)
		end
		return a.Gt(b)
	end

	-- 包装生成判断a是否小等于b的rethinkdb结构体
	-- a: string或unilight.field的返回值，如果是string，必须是表的字段名，支持嵌套字段，不同层次的字段名之间用"."链接
	-- b: 类型不定或unilight.field的返回值，代表类型需要和a代表的值的类型相对应
	unilight.le = function(a, b)
		if type(a) == "string" then
			a = unilight.field(a)
		end
		return a.Le(b)
	end

	-- 包装生成判断a是否小于b的rethinkdb结构体
	-- a: string或unilight.field的返回值，如果是string，必须是表的字段名，支持嵌套字段，不同层次的字段名之间用"."链接
	-- b: 类型不定或unilight.field的返回值，代表类型需要和a代表的值的类型相对应
	unilight.lt = function(a, b)
		if type(a) == "string" then
			a = unilight.field(a)
		end
		return a.Lt(b)
	end

	-- 多个rethinkdb判断结构体的逻辑与
	unilight.a = function(...)
		local args = {...}
		local rql = nil
		for i, v in ipairs(args) do
			if i == 1 then
				rql = v
			else
				rql = rql.And(v)
			end
		end
		return rql
	end

	-- 多个rethinkdb判断结构体的逻辑或
	unilight.o = function(...)
		local args = {...}
		local rql = nil
		for i, v in ipairs(args) do
			if i == 1 then
				rql = v
			else
				rql = rql.Or(v)
			end
		end
		return rql
	end

	-- rethinkdb判断结构体的逻辑非
	unilight.n = function(a)
		return a.Not()
	end

	-- 包装生成基于索引排序参数的rethinkdb结构体
	-- index: string, 索引名
	unilight.orderByIndexOpts = function(index)
		return unilight.RETHINKDB.OrderByOpts(index)
	end

	-- 生成基于索引的升序的rethinkdb排序结构体，在这个文件中函数参数命名orderby，通常就是指这类结构体
	-- index: string, 索引名，需要和创建这个索引时的索引名相同
	unilight.ascWithIndex = function(index)
		return unilight.orderByIndexOpts(index)
	end

	-- 生成基于索引的降序的rethinkdb排序结构体，在这个文件中函数参数命名orderby，通常就是指这类结构体
	-- index: string, 索引名，需要和创建这个索引时的索引名相同
	unilight.descWithIndex = function(index)
		return unilight.orderByIndexOpts(unilight.RETHINKDB.Desc(index))
	end

	-- 生成基于字段名的升序的rethinkdb排序结构体，在这个文件中函数参数命名orderby，通常就是指这类结构体
	-- a: string, 字段名，支持嵌套字段，不同层次的字段名之间用"."链接
	unilight.asc = function(a)
		return unilight.field(a)
	end

	-- 生成基于字段名的升序的rethinkdb排序结构体，在这个文件中函数参数命名orderby，通常就是指这类结构体
	-- a: string, 字段名，支持嵌套字段，不同层次的字段名之间用"."链接
	unilight.desc = function(a)
		return unilight.RETHINKDB.Desc(unilight.field(a))
	end

	-- 对表进行排序和筛选后，获取几条记录
	-- name: string, 表名
	-- limit: number, 个数
	-- orderby: rethinkdb排序结构体，必须是unlight.asc, unilight.desc, unilight.ascWithIndex, unilight.descWithIndex其中一个的返回值
	-- filter: rethinkdb判断结构体，当为nil时，不进行筛选
	unilight.topdata = function(name, limit, orderby, filter)
		local r = nil
		if filter == nil then
			r = unilight.RETHINKDB.TopN(name, limit, orderby)
		else
			r = unilight.RETHINKDB.TopFilter(name, limit, orderby, filter)
		end
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return unilight.repairslice(r.D)
	end

	-- 获取一个记录里的若干字段的值
	-- name: string, 表名
	-- key: 记录的主键值
	-- fields: table of strings, 需要的字段名
	unilight.getfields = function(name, key, fields)
		local r = unilight.RETHINKDB.GetFields(name, key, fields)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return decode_repair(luar.map2table(r.D))
	end

	-- 获取一个记录里的一个字段的值
	-- name: string, 表名
	-- key: 记录的主键值
	-- field: string, 需要的字段名
	unilight.getfield = function(name, key, field)
		local d = unilight.getfields(name, key, {field})
		if d == nil then
			return nil
		end
		return d[field]
	end

	-- 更新一条记录
	-- name: string, 表名
	-- key: 记录的主键值
	-- args: table, 注意嵌套层次
	unilight.update = function(name, key, args)
		local r = unilight.RETHINKDB.Update(name, key, encode_repair(args))
		if r.E ~= nil then
			unilight.error(r.E)
		end
		return r.E
	end

	-- WARNNING: 前方高能接口，千万慎重使用!!
	-- 更新一个表里的所有记录
	-- name: string, 表名
	-- args: table, 注意嵌套层次
	unilight.updatetable = function(name, args)
		local r = unilight.RETHINKDB.UpdateTable(name, args)
		if r.E ~= nil then
			unilight.error(r.E)
		end
		return r.E
	end

	-- 根据主键值，如果该记录存在，更新这条记录，否则插入这条记录
	-- name: string, 表名
	-- primary: string, 这个表的主键名
	-- key: 记录的主键值
	-- values: table, 注意嵌套层次
	unilight.upsert = function(name, primary, key, values)
		local r = unilight.RETHINKDB.Upsert(name, primary, key, encode_repair(values))
		if r.E ~= nil then
			unilight.error(r.E)
		end
		return r.E
	end

	-- 对表进行排序后，获取某个键值对的排名
	-- name: string, 表名
	-- field: string, 字段名
	-- value: 字段值
	-- orderby: rethinkdb排序结构体，必须是unlight.asc, unilight.desc, unilight.ascWithIndex, unilight.descWithIndex其中一个的返回值
	unilight.getindex = function(name, field, value, orderby)
		local r = unilight.RETHINKDB.IndexOf(name, field, value, orderby)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return r.N
	end

	-- 对表进行排序后，获取某个键值对前后记录
	-- name: string, 表名
	-- field: string, 字段名
	-- value: 字段值
	-- size: number, 获取的记录条数
	-- orderby: rethinkdb排序结构体，必须是unlight.asc, unilight.desc, unilight.ascWithIndex, unilight.descWithIndex其中一个的返回值
	unilight.getaround = function(name, field, value, size, orderby)
		local r = unilight.RETHINKDB.Around(name, field, value, size, orderby)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return {data=unilight.repairslice(r.D), skip=r.S, index=r.I}
	end

	-- 获取表里一个字段的最大值
	-- name: string, 表名
	-- field: string, 字段名
	-- default: 如果表里不存在这个字段，返回的默认值
	unilight.getmax = function(name, field, default)
		local r = unilight.RETHINKDB.Max(name, field, {field}, {[field]=default})
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return decode_repair(luar.map2table(r.D))[field]
	end

	-- 过期接口，不要使用
	unilight.updateorder = function(name, orderby, key, index, start, update)
		local idx = table.reverse(string.split(index, "."))
		local err = unilight.RETHINKDB.UpdateOrder(name, orderby, key, idx, start, encode_repair(update))
		if err ~= nil then
			unilight.error(err)
		end
		return err
	end

	-- 根据索引获取索引值等于给定若个的值的记录
	-- name: string, 表名
	-- index: string, 索引名
	-- ...: 不定数量的给定值
	unilight.getByIndex = function(name, index, ...)
		local r = unilight.RETHINKDB.GetAllByIndex(name, index, ...)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return unilight.repairslice(r.D)
	end

	-- 对表进行筛选后，获取指定数量的记录
	-- name: string, 表名
	-- filter: rethinkdb判断结构体
	-- limit: 指定的数量
	unilight.getByFilter = function(name, filter, limit)
		local r = unilight.RETHINKDB.Filter(name, filter, limit)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return unilight.repairslice(r.D)
	end

	-- 获取表里所有符合筛选条件的记录的数量
	-- name: string, 表名
	-- filter: rethinkdb判断结构体
	unilight.getCountByFilter = function(name, filter)
		local r = unilight.RETHINKDB.FilterCount(name, filter)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return r.N
	end

	-- 获取表里的所有记录
	-- name: string, 表名
	unilight.getAll = function(name)
		local r = unilight.RETHINKDB.GetAll(name)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return unilight.repairslice(r.D)
	end

	-- 自定义查询数据库语句的起始
	-- 举例说明用法
	-- -- 如果在网页上的查询接口是r.db("project_dbname").table("test").filter(r.row("uid").gt(0)).count()
	-- -- 那么在这里应该写成rql = unilight.startChain().Table("test").Filter(unilight.field("uid").Gt(0)).Count()
	-- -- r.db("project_dbname")后面用"."串起来的函数名的首字母变成大写，就能直接串到unilight.startChain()后面
	-- -- r.row对应unilight.field，之后的函数名的处理和上面一样
	-- -- 生成rql就是自定义的查询语句
	-- -- 然后用下面unilight.chainResponse...(rql)到数据库做查询，获取查询的结果
	-- -- 选择用哪个unilight.chainResponse...，要根据查询语句来判断
	-- --  比如现在的rql是获取记录的数量，结果应该是number，所以用
	-- --  unilight.chainResponseNumber(rql)来获取结果
	unilight.startChain = function()
		return unilight.RETHINKDB.StartChain()
	end

	unilight.chainResponseSequence = function(chain)
		local r = unilight.RETHINKDB.ChainResponseSlice(chain)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return unilight.repairslice(r.D)
	end

	unilight.chainResponseObject = function(chain)
		local r = unilight.RETHINKDB.ChainResponseFetch(chain)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return decode_repair(luar.map2table(r.D))
	end

	unilight.chainResponseWrite = function(chain)
		local r = unilight.RETHINKDB.ChainResponseWrite(chain)
		if r.E ~= nil then
			unilight.error(r.E)
		end
		return r.E
	end

	unilight.chainResponseNumber = function(chain)
		local r = unilight.RETHINKDB.ChainResponseNumber(chain)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return r.N
	end

	-----------------------------------------
	-- 以下是过期接口，不要使用
	unilight.anysdk = {table="payment"}

	unilight.anysdk.ready = function(db)
		unilight.anysdk.db = db
		unilight.RETHINKDB.EnsureDB(unilight.anysdk.db)
		unilight.RETHINKDB.DBEnsureTable(unilight.anysdk.db, unilight.anysdk.table, "order_id")
		unilight.RETHINKDB.DBEnsureIndex(unilight.anysdk.db, unilight.anysdk.table, "game_user_id")
		unilight.info("anysdk payment ready")
	end

	unilight.anysdk.savepayment = function(form)
		form.processed = "0"
		local r = unilight.RETHINKDB.DBSave(unilight.anysdk.db, unilight.anysdk.table, form)
		if r.E ~= nil then
			unilight.error(r.E)
		else
			unilight.info("anysdk payment [%s-%s-%s] %s %s %s", form.server_id, form.private_data, form.game_user_id,
			form.order_id, form.product_id, form.product_name)
		end
	end

	unilight.anysdk.getpayment = function(gameid, zoneid, uid)
		local r = unilight.RETHINKDB.DBGetAllByIndex(unilight.anysdk.db, unilight.anysdk.table, "game_user_id",
													{"order_id", "product_id", "pay_status"},
													{server_id=gameid, private_data=zoneid, processed="0"}, uid)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return luar.slice2table(r.D)
	end

	unilight.anysdk.processed = function(orderid)
		local r = unilight.RETHINKDB.DBUpdate(unilight.anysdk.db, unilight.anysdk.table, orderid, {processed="1"})
		if r.E ~= nil then
			unilight.error(r.E)
		else
			unilight.info("anysdk processed " .. orderid)
		end
	end

	unilight.iapps = {table="payment"}

	unilight.iapps.ready = function(db)
		unilight.iapps.db = db
		unilight.RETHINKDB.EnsureDB(unilight.iapps.db)
		unilight.RETHINKDB.DBEnsureTable(unilight.iapps.db, unilight.iapps.table, "orderNo")
		unilight.RETHINKDB.DBEnsureIndex(unilight.iapps.db, unilight.iapps.table, "player")
		unilight.info("iapps payment ready")
	end

	unilight.iapps.savepayment = function(form)
		form.processed = "0"
		local r = unilight.RETHINKDB.DBSave(unilight.iapps.db, unilight.iapps.table, form)
		if r.E ~= nil then
			unilight.error(r.E)
		else
			unilight.info("iapps payment %s %s %s %s %s", form.player, form.orderNo, form.propId, form.fee, form.status)
		end
	end

	unilight.iapps.getpayment = function(gameid, zoneid, uid)
		local player = gameid .. ":" .. zoneid .. ":" .. uid
		local r = unilight.RETHINKDB.DBGetAllByIndex(unilight.iapps.db, unilight.iapps.table, "player",
											{"orderNo", "propId", "status"}, {processed="0"}, player)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return luar.slice2table(r.D)
	end

	unilight.iapps.processed = function(orderid)
		local r = unilight.RETHINKDB.DBUpdate(unilight.iapps.db, unilight.iapps.table, orderid, {processed="1"})
		if r.E ~= nil then
			unilight.error(r.E)
		else
			unilight.info("iapps processed " .. orderid)
		end
	end

	unilight.alipay = {table="payment"}

	unilight.alipay.ready = function(db)
		unilight.alipay.db = db
		unilight.RETHINKDB.EnsureDB(unilight.alipay.db)
		unilight.RETHINKDB.DBEnsureTable(unilight.alipay.db, unilight.alipay.table, "trade_no")
		unilight.RETHINKDB.DBEnsureIndex(unilight.alipay.db, unilight.alipay.table, "player")
		unilight.info("alipay payment ready")
	end

	unilight.alipay.savepayment = function(form)
		if form.trade_status ~= "TRADE_FINISHED" then
			unilight.info("alipay notify %s %s %s %s", form.out_trade_no, form.trade_no, form.subject, form.trade_status)
			return
		end
		form.processed = "0"
		form.player = table.concat(string.split(form.out_trade_no, "-"), "-", 1, 3)
		local r = unilight.RETHINKDB.DBSave(unilight.alipay.db, unilight.alipay.table, form)
		if r.E ~= nil then
			unilight.error(r.E)
		else
			unilight.info("alipay payment %s %s %s", form.out_trade_no, form.trade_no, form.subject)
		end
	end

	unilight.alipay.getpayment = function(gameid, zoneid, uid)
		local player = gameid .. "-" .. zoneid .. "-" .. uid
		local r = unilight.RETHINKDB.DBGetAllByIndex(unilight.alipay.db, unilight.alipay.table, "player",
											{"subject", "trade_status", "trade_no"}, {processed="0"}, player)
		if r.E ~= nil then
			unilight.error(r.E)
			return nil
		end
		return luar.slice2table(r.D)
	end

	unilight.alipay.processed = function(orderid)
		local r = unilight.RETHINKDB.DBUpdate(unilight.alipay.db, unilight.alipay.table, orderid, {processed="1"})
		if r.E ~= nil then
			unilight.error(r.E)
		else
			unilight.info("alipay processed " .. orderid)
		end
	end

end
