MasterIP = "45.32.39.90"
--MasterIP = "127.0.0.1"
MasterPort = 5501

--�����������б� ServerId, ServerType �������ã�MasterServer, LoginServer, ProxyServerΪ������������ ��������gameid�� 
--worldserver, gameserver�߼�����������Ҫ����gameid,�����Լ�ѡ�� 
ServerList = {}


--��������ᱻ����ִ��
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

--MasterServer ����������������¼�������� һ���������������
MasterServer = {
		ServerName = "MasterServer_1",
		ServerType = NF_ST_MASTER,
		ServerId = 1,		--��ÿһ����������˵����Ψһ�ģ� Ӧ�ó�����Ҫͨ�����ServerId����֪����Ҫ���ص���������
		ServerIp = MasterIP,
		ServerPort = GetNewPort(),
		MaxConnectNum = 100,
		WorkThreadNum = 1,
		Security = false,
		WebSocket = false,
		HttpPort = 3000,
};

--LoginServer ��¼�������������¼����
LoginServer_2 = {
		ServerName = "LoginServer_2",
		ServerType = NF_ST_LOGIN,
		ServerId = 2,			--��ÿһ����������˵����Ψһ�ģ� Ӧ�ó�����Ҫͨ�����ServerId����֪����Ҫ���ص���������
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
	
--ProxyServer ���ܷ������� �������ⲿ�Ŀͻ�������, ת������
ProxyServer_3 = {
		ServerName = "ProxyServer_3",
		ServerType = NF_ST_PROXY,
		ServerId = 3,			--��ÿһ����������˵����Ψһ�ģ� Ӧ�ó�����Ҫͨ�����ServerId����֪����Ҫ���ص���������
		ServerIp = MasterIP,
		ServerPort = GetNewPort(),
		ServerInnerPort = GetNewPort(),	--���ض��ڷ������ӿ�
		MaxConnectNum = 1000,
		WorkThreadNum = 5,
		Security = false,
		WebSocket = true,
	};
	
--ProxyServer ���ܷ������� �������ⲿ�Ŀͻ�������, ת������
ProxyServer_4 = {
		ServerName = "ProxyServer_4",
		ServerType = NF_ST_PROXY,
		ServerId = 4,			--��ÿһ����������˵����Ψһ�ģ� Ӧ�ó�����Ҫͨ�����ServerId����֪����Ҫ���ص���������
		ServerIp = MasterIP,
		ServerPort = GetNewPort(),
		ServerInnerPort = GetNewPort(),	--���ض��ڷ������ӿ�
		MaxConnectNum = 1000,
		WorkThreadNum = 5,
		Security = false,
		WebSocket = true,
	};


