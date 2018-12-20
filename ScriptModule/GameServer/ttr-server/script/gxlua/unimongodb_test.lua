mongodbtest = {}
--Do.dbReadTest = function()
--	go.startdbtest("mongodbtest.get_mongodb")
--	go.startdbtest("mongodbtest.createdb","UserData",1000,2000)
--end
mongodbtest.get_mongodb = function()
	unilight.debug("mongodbtest.get_mongodb")
end
mongodbtest.createdb = function(name, first,last)
	for i = 1,100 do
		unilight.debug("mongodbtest.createdb")
	end
end
mongodbtest.droptable = function(name)
end
mongodbtest.createindex = function(name, index)
end
mongodbtest.cleardb = function(name)
end
mongodbtest.delete = function(name, id)
end
mongodbtest.getdata = function(name, key)
end
mongodbtest.savedata = function(name, data)
end
mongodbtest.savefield = function(name, id, fieldpath, data)
end
mongodbtest.check_data_cache_timeout = function(text,clocker)
end
mongodbtest.savebatch = function(name, array)
end
mongodbtest.topdata = function(name, limit, orderby, filter)
end
mongodbtest.update = function(name, id, args)
end
mongodbtest.updatetable = function(name, args)
end
mongodbtest.getindex = function(name, field, value, orderby)
end
mongodbtest.getaround = function(name, field, value, size, orderby)
end
mongodbtest.getmax = function(name, field, default)
end
mongodbtest.getByIndex = function(name, index, ...)
end
mongodbtest.getByFilter = function(name, filter, limit)
end
mongodbtest.getCountByFilter = function(name, filter)
end
mongodbtest.getAll = function(name)
end
mongodbtest.startChain = function()
end
