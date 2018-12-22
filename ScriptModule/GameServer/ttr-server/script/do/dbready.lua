local Index = 0
Do.dbready = function()
	unilight.info("创建表格---------------------")
	-- 初始化多个数据库 跑了多次
	if Index == 0 then
		Index = Index + 1

		unilight.createdb("userinfo","uid")						-- 玩家个人信息
		unilight.createdb(mailsys.MAIL_DB, "uid")

		if rechargemgr ~= nil then
			rechargemgr.Init()
		end
        -- 每次连上数据库都会跑该函数 所以只有index=0 才执行这里面的内容 可用于初始化一些要操作db的内容
	end
end
