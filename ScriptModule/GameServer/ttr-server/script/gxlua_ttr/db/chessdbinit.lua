ChessDbInit = {}
ChessDbInit.isNotStatistics = true
-- 全局的数据库相关初始化  针对单独游戏的 则各自初始化 
function ChessDbInit.Init()
--[[	-- 基础信息
	local startAgentSystem = go.getconfigint("start_agent")
	if go.getconfigint("isNotStatistics") == 0 then
		isNotStatistics = false
	end
	unilight.createdb("userinfo","uid")						-- 玩家个人信息
	unilight.createindex("userinfo", "nickName")					-- 玩家姓名添加索引
	
	--玩家订单
	unilight.createdb("gameorder", "gameorder")]]--
end
