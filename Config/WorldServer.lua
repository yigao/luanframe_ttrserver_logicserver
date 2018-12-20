

--MasterServer 服务器，管理多个登录服务器， 一个或多个世界服务器
Server[#Server+1] = {
		ServerName = "MasterServer_100_1",
		ServerType = NF_ST_MASTER,
		ServerId = 1,		--对每一个服务器来说都是唯一的， 应用程序需要通过这个ServerId才能知道需要加载的配置是他
		MasterId = 1,
		WorldId = 1,
		ServerIp = MasterIP,
		ServerPort = MasterPort,
		MaxConnectNum = 100,
		WorkThreadNum = 1,
		Security = false,
		WebSocket = false,
		HttpPort = 3000,
	};
	
MasterPort = MasterPort + 1
	
	--WorldServer 世界服务器，负责一个大区， 可能会有很多小区
Server[#Server+1] = {
		ServerName = "WorldServer_100_2",
		ServerType = NF_ST_WORLD,
		ServerId = 2,			--对每一个服务器来说都是唯一的， 应用程序需要通过这个ServerId才能知道需要加载的配置是他
		MasterId = 1,			--需要与MasterServer的MasterId保持一致
		WorldId = 100,		--代表一个世界服务器
		ServerIp = ZoneIP,
		ServerPort = MasterPort,
		MaxConnectNum = 100,
		WorkThreadNum = 1,
		Security = false,
		WebSocket = false,
	};
	
MasterPort = MasterPort + 1
	
--WorldServer 世界服务器，负责一个大区， 可能会有很多小区
Server[#Server+1] = {
		ServerName = "WorldServer_200_3",
		ServerType = NF_ST_WORLD,
		ServerId = 3,			--对每一个服务器来说都是唯一的， 应用程序需要通过这个ServerId才能知道需要加载的配置是他
		MasterId = 1,			--需要与MasterServer的MasterId保持一致
		WorldId = 200,		--代表一个世界服务器
		ServerIp = ZoneIP,
		ServerPort = MasterPort,
		MaxConnectNum = 100,
		WorkThreadNum = 1,
		Security = false,
		WebSocket = false,
	};
	
MasterPort = MasterPort + 1
	
	--LoginServer 登录服务器，负责登录连接
Server[#Server+1] = {
		ServerName = "LoginServer_100_4",
		ServerType = NF_ST_LOGIN,
		ServerId = 4,			--对每一个服务器来说都是唯一的， 应用程序需要通过这个ServerId才能知道需要加载的配置是他
		MasterId = 1,			--需要与MasterServer的MasterId保持一致
		WorldId = 100,			--需要与一个世界服务器的WorldId一样， 这样他下面的小服务器的连接才会发过来
		ServerIp = MasterIP,
		ServerPort = MasterPort,
		MaxConnectNum = 1000,
		WorkThreadNum = 5,
		Security = false,
		WebSocket = false,
		HttpPort = 80,
	};
	
MasterPort = MasterPort + 1
	
	--LoginServer 登录服务器，负责登录连接
Server[#Server+1] = {
		ServerName = "LoginServer_200_5",
		ServerType = NF_ST_LOGIN,
		ServerId = 5,			--对每一个服务器来说都是唯一的， 应用程序需要通过这个ServerId才能知道需要加载的配置是他
		MasterId = 1,			--需要与MasterServer的MasterId保持一致
		WorldId = 200,			--需要与一个世界服务器的WorldId一样， 这样他下面的小服务器的连接才会发过来
		ServerIp = MasterIP,
		ServerPort = MasterPort,
		MaxConnectNum = 1000,
		WorkThreadNum = 5,
		Security = false,
		WebSocket = false,
		HttpPort = 7001,
	};
	
MasterPort = MasterPort + 1
	
--ProxyServer 网管服务器， 负责与外部的客户端连接, 转发数据
Server[#Server+1] = {
		ServerName = "ProxyServer_100_10",
		ServerType = NF_ST_PROXY,
		ServerId = 10,			--对每一个服务器来说都是唯一的， 应用程序需要通过这个ServerId才能知道需要加载的配置是他
		MasterId = 1,			--需要与MasterServer的MasterId保持一致
		WorldId = 100,			--需要与一个世界服务器的WorldId一样
		ServerIp = MasterIP,
		ServerPort = MasterPort,
		ServerInnerPort = MasterPort+1,	--网关对内服务器接口
		MaxConnectNum = 1000,
		WorkThreadNum = 5,
		Security = false,
		WebSocket = true,
	};
	
MasterPort = MasterPort + 2
	
--ProxyServer 网管服务器， 负责与外部的客户端连接, 转发数据
Server[#Server+1] = {
		ServerName = "ProxyServer_100_11",
		ServerType = NF_ST_PROXY,
		ServerId = 11,			--对每一个服务器来说都是唯一的， 应用程序需要通过这个ServerId才能知道需要加载的配置是他
		MasterId = 1,			--需要与MasterServer的MasterId保持一致
		WorldId = 100,			--需要与一个世界服务器的WorldId一样
		ServerIp = MasterIP,
		ServerPort = MasterPort,
		ServerInnerPort = MasterPort+1,	--网关对内服务器接口
		MaxConnectNum = 1000,
		WorkThreadNum = 5,
		Security = false,
		WebSocket = true,
	};
	
MasterPort = MasterPort + 2