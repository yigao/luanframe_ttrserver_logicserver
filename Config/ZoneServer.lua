

--GameServer ��Ϸ������, һ��һ��С��ֻ��һ���� ������Ϸ��ս����ҵ�� �������������
Server[#Server+1] = {
		ServerName = "PublicServer_100_20",
		ServerType = NF_ST_GAME,
		ServerId = 20,			--��ÿһ����������˵����Ψһ�ģ� Ӧ�ó�����Ҫͨ�����ServerId����֪����Ҫ���ص���������
		MasterId = 1,			--��Ҫ��MasterServer��MasterId����һ��
		WorldId = 100,			--��Ҫ��һ�������������WorldIdһ��
		ServerIp = ZoneIP,
		ServerPort = MasterPort,
		MaxConnectNum = 100,
		WorkThreadNum = 1,
		Security = false,
		WebSocket = false,
	};
	
MasterPort = MasterPort + 1
	
--GameServer ��Ϸ������, һ��һ��С��ֻ��һ���� ������Ϸ��ս����ҵ�� �������������
Server[#Server+1] = {
		ServerName = "Gaoyi_100_21",
		ServerType = NF_ST_GAME,
		ServerId = 21,			--��ÿһ����������˵����Ψһ�ģ� Ӧ�ó�����Ҫͨ�����ServerId����֪����Ҫ���ص���������
		MasterId = 1,			--��Ҫ��MasterServer��MasterId����һ��
		WorldId = 100,			--��Ҫ��һ�������������WorldIdһ��
		ServerIp = ZoneIP,
		ServerPort = MasterPort,
		MaxConnectNum = 100,
		WorkThreadNum = 1,
		Security = false,
		WebSocket = false,
	};
	
