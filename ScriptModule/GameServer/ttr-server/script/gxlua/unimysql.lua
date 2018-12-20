local function parsefields(fields)
	if fields == nil then
		return "*"
	end
	if type(fields) == "table" then
		return table.concat(fields, ", ")
	end
	if type(fields) == "string" then
		return fields
	end
end

local function parsewhere(where)
	if type(where) == "table" then
		local s = {}
		local args = {}
		for k, v in pairs(where) do
			table.insert(s, k .. "=?")
			table.insert(args, v)
		end
		return {table.concat(s, " AND "), args}
	end
	if type(where) == "string" then
		return {where, {}}
	end
end

local function parseupdate(update)
	if type(update) == "table" then
		local s = {}
		local args = {}
		for k, v in pairs(update) do
			table.insert(s, k .. "=?")
			table.insert(args, v)
		end
		return {table.concat(s, ", "), args}
	end
	if type(update) == "string" then
		return {update, nil}
	end
end

local function parsegroup(gp)
	if type(gp) == "table" then
		return table.concat(gp, ", ")
	end
	if type(gp) == "string" then
		return gp
	end
end

local function parseorder(ord)
	if type(ord) == "table" then
		return table.concat(ord, ", ")
	end
	if type(ord) == "string" then
		return ord
	end
end

local function parsevalue(value)
	local s = {}
	local args = {}
	for i, v in ipairs(value) do
		table.insert(s, "?")
		table.insert(args, v)
	end
	return {table.concat(s, ","), args}
end

unilight.initmysqldb = function()

	unilight.execsql = function(sql, args)
		local r = unilight.MYSQLDB.Exec(sql, args)
		if r.E ~= nil then
			unilight.error("execsql mysql err  sql: " ..sql .. "para"..table.tostring(args) .. "   mysql return:".. r.E)
			return nil
		end
		return {LastInsertId=r.LastInsertId, RowsAffected=r.RowsAffected}
	end

	unilight.querysql = function(sql, args)
        args = args or {}
		local r = unilight.MYSQLDB.Query(sql, args)
		if r.E ~= nil then
			unilight.error("querysql mysql err  sql: " ..sql .. "para"..table.tostring(args) .. "   mysql return:".. r.E)
			return nil
		end
		return luar.slice2table(r.D)
	end

	unilight.startsql = function()
		local ql = {
			_op     = nil,
			_fields = nil,
			_table  = nil,
			_where  = nil,
			_group  = nil,
			_order  = nil,
			_offset = nil,
			_limit  = nil,
			_update = nil,
			_ignore = false,
			_value  = nil,
		}
		ql.table = function(name)
			ql._table = name
			return ql
		end
		ql.select = function(fields)
			ql._op = "SELECT"
			ql._fields = fields
			return ql
		end
		ql.update = function(up)
			ql._op = "UPDATE"
			ql._update = up
			return ql
		end
		ql.insert = function(fields)
			ql._op = "INSERT"
			ql._fields = fields
			return ql
		end
		ql.delete = function()
			ql._op = "DELETE"
			return ql
		end
		ql.ignore = function(b)
			if b == nil then
				ql._ignore = true
			else
				ql._ignore = b
			end
			return ql
		end
		ql.where = function(cond)
			ql._where = cond
			return ql
		end
		ql.group = function(gp)
			ql._group = gp
			return ql
		end
		ql.order = function(ord)
			ql._order = ord
			return ql
		end
		ql.offset = function(offset)
			ql._offset = offset
			return ql
		end
		ql.limit = function(limit)
			ql._limit = limit
			return ql
		end
		ql.value = function(v)
			ql._value = v
			return ql
		end
		ql.sql = function()
			local args = nil
			local s = ""
			if ql._op == "SELECT" then
				s = ql._op .. " " .. parsefields(ql._fields) .. " FROM " .. ql._table
				if ql._where ~= nil then
					local w = parsewhere(ql._where)
					s = s .. " WHERE " .. w[1]
					args = w[2]
				end
				if ql._group ~= nil then
					s = s .. " GROUP BY " .. parsegroup(ql._group)
				end
				if ql._order ~= nil then
					s = s .. " ORDER BY " .. parseorder(ql._order)
				end
				if ql._limit ~= nil then
					s = s .. " LIMIT " .. tostring(ql._limit)
					if ql._offset ~= nil then
						s = s .. " OFFSET " .. tostring(ql._offset)
					end
				end
			elseif ql._op == "UPDATE" then
				s = ql._op
				if ql._ignore then
					s = s .. " IGNORE"
				end
				s = s .. " " .. ql._table
				local u = parseupdate(ql._update)
				s = s .. " SET " .. u[1]
				args = u[2]
				if ql._where ~= nil then
					local w = parsewhere(ql._where)
					s = s .. " WHERE " .. w[1]
					table.extend(args, w[2])
				end
				if ql._order ~= nil then
					s = s .. " ORDER BY " .. parseorder(ql._order)
				end
				if ql._limit ~= nil then
					s = s .. " LIMIT " .. tostring(ql._limit)
				end
			elseif ql._op == "DELETE" then
				s = ql._op
				s = s .. " FROM " .. ql._table
				if ql._where ~= nil then
					local w = parsewhere(ql._where)
					s = s .. " WHERE " .. w[1]
					args = w[2]
				end
			elseif ql._op == "INSERT" then
				s = ql._op
				if ql._ignore then
					s = s .. " IGNORE"
				end
				s = s .. " INTO " .. ql._table
				if ql._fields ~= nil then
					s = s .. "(" .. table.concat(ql._fields, ",") .. ")"
				end
				local v = parsevalue(ql._value)
				s = s .. " VALUE (" .. v[1] .. ")"
				args = v[2]
			end
			return {s, args}
		end
		ql.run = function()
			local q = ql.sql()
			if ql._op == "SELECT" then
				return unilight.querysql(q[1], q[2])
			else
				return unilight.execsql(q[1], q[2])
			end
		end
		return ql
	end
	--local ql = unilight.startsql().select({"Host", "Password"}).table("user").where({Host={"localhost"}).group("Host").order("Password").limit(1)
	--unilight.debug(table.tostring(ql.run()))

	--local ql = unilight.startsql().select({"Host", "Password"}).table("user").where("id >1 AND id<10").group("Host").order("Password").limit(1)
	--unilight.debug(table.tostring(ql.run()))
    --
	--ql = unilight.startsql().update({Host="192.168.84.%"}).ignore().table("user").where({Host="ubuntu1404"}).order("Password").limit(1)
	--unilight.debug(table.tostring(ql.run()))

	--ql = unilight.startsql().table("user").insert({"Host", "Password"}).ignore().value({"localhost", "*"})
	--unilight.debug(table.tostring(ql.run()))
end
