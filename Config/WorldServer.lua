local ZoneIP = "127.0.0.1"
--local ZoneIP = "45.32.39.90"


function InitGame3010()
	RegisterServer(WorldServer_3010_10)
	RegisterServer(GameServer_3010_11)
	RegisterServer(GameServer_3010_12)
	RegisterServer(WorldServer_3010_30)
end

	
--WorldServer 世界服务器，负责一个大区， 可能会有很多小区
WorldServer_3010_10 = {
		ServerName = "WorldServer_3010_10",
		ServerType = NF_ST_WORLD,
		ServerId = 10,		--对每一个服务器来说都是唯一的， 应用程序需要通过这个ServerId才能知道需要加载的配置是他
		ServerIp = ZoneIP,
		ServerPort = GetNewPort(),
		GameId = 3010,
		GameName = "ttrserver",
		MongoIp = "14.17.104.12",
		MongoPort = 28900,
		MongonName = "ttr-1",
		MaxConnectNum = 100,
		WorkThreadNum = 1,
		Security = false,
		WebSocket = false,
	};
	
	--WorldServer 世界服务器，负责一个大区， 可能会有很多小区
WorldServer_3010_30 = {
		ServerName = "WorldServer_3010_30",
		ServerType = NF_ST_WORLD,
		ServerId = 30,		--对每一个服务器来说都是唯一的， 应用程序需要通过这个ServerId才能知道需要加载的配置是他
		ServerIp = ZoneIP,
		ServerPort = GetNewPort(),
		GameId = 3010,
		GameName = "ttrserver",
		MongoIp = "14.17.104.12",
		MongoPort = 28900,
		MongonName = "ttr-1",
		MaxConnectNum = 100,
		WorkThreadNum = 1,
		Security = false,
		WebSocket = false,
	};


--GameServer 游戏服务器, 一般一个小区只有一个， 负责游戏非战斗的业务， 连接世界服务器
GameServer_3010_11 = {
		ServerName = "GameServer_3010_11",
		ServerType = NF_ST_GAME,
		ServerId = 11,			--对每一个服务器来说都是唯一的， 应用程序需要通过这个ServerId才能知道需要加载的配置是他
		ServerIp = ZoneIP,
		ServerPort = GetNewPort(),
		GameId = 3010,
		GameName = "ttrserver",
		MongoIp = "14.17.104.12",
		MongoPort = 28900,
		MongonName = "ttr-1",
		MaxConnectNum = 100,
		WorkThreadNum = 1,
		Security = false,
		WebSocket = false,
	};
	
--GameServer 游戏服务器, 一般一个小区只有一个， 负责游戏非战斗的业务， 连接世界服务器
GameServer_3010_12 = {
		ServerName = "GameServer_3010_12",
		ServerType = NF_ST_GAME,
		ServerId = 12,			--对每一个服务器来说都是唯一的， 应用程序需要通过这个ServerId才能知道需要加载的配置是他
		ServerIp = ZoneIP,
		ServerPort = GetNewPort(),
		GameId = 3010,
		GameName = "ttrserver",
		MongoIp = "14.17.104.12",
		MongoPort = 28900,
		MongonName = "ttr-1",
		MaxConnectNum = 100,
		WorkThreadNum = 1,
		Security = false,
		WebSocket = false,
	};
	