NF_SERVER_TYPES = {
	NF_ST_NONE = 0, -- NONE
	NF_ST_MASTER = 1, --
	NF_ST_LOGIN = 2, --
	NF_ST_WORLD = 3, --
	NF_ST_GAME = 4, --
	NF_ST_PROXY = 5, --
	NF_ST_MATCH = 6,
	NF_ST_BATTLE = 7,
	NF_ST_UNION_MATCH = 8,
	NF_ST_PUBLIC_MATCH = 9,
	NF_ST_MAX = 10, --
};

NF_MSG_TYPE = {
	eMsgType_Num = 0,
	eMsgType_CONNECTED = 1,
	eMsgType_DISCONNECTED = 2,
	eMsgType_RECIVEDATA = 3,
};

NF_ACCOUNT_EVENT_TYPE = {
	eAccountEventType_Num = 0,
	eAccountEventType_CONNECTED = 1,
	eAccountEventType_DISCONNECTED = 2,
	eAccountEventType_RECONNECTED = 3,
}