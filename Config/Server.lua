MasterIP = "45.32.39.90"
--MasterIP = "127.0.0.1"
MasterPort = 5501

--服务器配置列表， ServerId, ServerType 必须配置，MasterServer, LoginServer, ProxyServer为公共服务器， 不用配置gameid， 
--worldserver, gameserver逻辑服务器，需要配置gameid,其余自己选择 
ServerList = {}


--这个函数会被程序执行
function InitServer()
	RegisterServer(MasterServer)
	RegisterServer(LoginServer_2)
	RegisterServer(ProxyServer_3)
	RegisterServer(ProxyServer_4)
	
	InitGame3010()
end

function GetNewPort()
	local port = MasterPort
	MasterPort = MasterPort + 1
	return port
end

function RegisterServer(server)
	table.insert(ServerList, server)
end

--MasterServer 服务器，管理多个登录服务器， 一个或多个世界服务器
MasterServer = {
		ServerName = "MasterServer_1",
		ServerType = NF_ST_MASTER,
		ServerId = 1,		--对每一个服务器来说都是唯一的， 应用程序需要通过这个ServerId才能知道需要加载的配置是他
		ServerIp = MasterIP,
		ServerPort = GetNewPort(),
		MaxConnectNum = 100,
		WorkThreadNum = 1,
		Security = false,
		WebSocket = false,
		HttpPort = 3000,
};

--LoginServer 登录服务器，负责登录连接
LoginServer_2 = {
		ServerName = "LoginServer_2",
		ServerType = NF_ST_LOGIN,
		ServerId = 2,			--对每一个服务器来说都是唯一的， 应用程序需要通过这个ServerId才能知道需要加载的配置是他
		ServerIp = MasterIP,
		ServerPort = GetNewPort(),
		MongoIp = "14.17.104.12",
		MongoPort = 28900,
		MongonName = "ttr-1",
		MaxConnectNum = 1000,
		WorkThreadNum = 5,
		Security = false,
		WebSocket = false,
		HttpPort = 80,
	};
	
--ProxyServer 网管服务器， 负责与外部的客户端连接, 转发数据
ProxyServer_3 = {
		ServerName = "ProxyServer_3",
		ServerType = NF_ST_PROXY,
		ServerId = 3,			--对每一个服务器来说都是唯一的， 应用程序需要通过这个ServerId才能知道需要加载的配置是他
		ServerIp = MasterIP,
		ServerPort = GetNewPort(),
		ServerInnerPort = GetNewPort(),	--网关对内服务器接口
		MaxConnectNum = 1000,
		WorkThreadNum = 5,
		Security = false,
		WebSocket = true,
	};
	
--ProxyServer 网管服务器， 负责与外部的客户端连接, 转发数据
ProxyServer_4 = {
		ServerName = "ProxyServer_4",
		ServerType = NF_ST_PROXY,
		ServerId = 4,			--对每一个服务器来说都是唯一的， 应用程序需要通过这个ServerId才能知道需要加载的配置是他
		ServerIp = MasterIP,
		ServerPort = GetNewPort(),
		ServerInnerPort = GetNewPort(),	--网关对内服务器接口
		MaxConnectNum = 1000,
		WorkThreadNum = 5,
		Security = false,
		WebSocket = true,
	};


