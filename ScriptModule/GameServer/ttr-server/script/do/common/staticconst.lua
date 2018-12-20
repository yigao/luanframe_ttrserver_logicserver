--静态常量， 临时放一些不便的值，方便修改

require "script/do/globalConst"

static_const = {}

--静态常量，好友系统，多次时间保存一次数据
static_const.Static_Const_Friend_Save_Data_To_DB_Time = 60

static_const.Static_Const_User_Save_Data_DB_Time = 60

static_const.Static_Const_Rank_List_Sort_time = 60

--静态常量，好友系统，玩家离线后最大数据最大在线时间
static_const.Static_Const_Friend_MAX_ONLINE_TIME_AFTER_OFFLINE = 600
static_const.Static_Const_USER_INFO_MAX_ONLINE_TIME_AFTER_OFFLINE = 60

--静态常量，好友系统，最大好友数量
static_const.Static_Const_Friend_MAX_Friend_Count = 20

--静态常量，好友系统，系统自动推荐好友时间
static_const.Static_Const_Friend_System_Auto_Recommend_Time = 1200

--静态常量，好友系统，系统每隔一段时间查看数据
static_const.Static_Const_Friend_System_Check_Data_Time = 600

--静态常量，旅行团，雇佣CD时间
static_const.Static_Const_TRAVEL_Employ_CD_Time = GlobalConst.Travel_CD

--静态常量，旅行团，团员跟团时间周期
static_const.Static_Const_TRAVEL_Employ_MAX_TIME = GlobalConst.Travel_Time

--静态常量，旅行团，旅行团初始化抓捕次数
static_const.Static_Const_TRAVEL_INIT_MAX_CAPTURE_TIMES = GlobalConst.Travel_Catch_Number

--静态常量，旅行团，旅行团初始化解锁的位置数目
static_const.Static_Const_TRAVEL_Init_UNLOCK_SLOT_COUNT = 3

--旅行团初始化防护罩数目
static_const.Static_Const_TRAVEL_Init_Shield_Count = GlobalConst.Travel_Shield_Number

--静态常量，旅行团，最大雇佣玩家数目
static_const.Static_Const_TRAVEL_MAX_EMPLOY_USER_COUNT = 10

--静态常量，旅行团，最大推荐雇佣好友数目
static_const.Static_Const_TRAVEL_MAX_RECOMMEND_COUNT = 5

--排行榜
static_const.Static_Const_RANK_LIST_MAX_COUNT = 200

--货币
static_const.Static_MoneyType_Diamond = 1		--钻石
static_const.Static_MoneyType_Gold = 2		--金币
static_const.Static_MoneyType_Rmb = 3		--rmb
--商城
static_const.Static_StoreType_Gift		= 1	--礼包
static_const.Static_StoreType_Recharge	= 2	--充值
static_const.Static_StoreType_Items		= 3	--道具
static_const.Static_StoreType_User		= 4	--角色
--道具类型
static_const.Static_ItemType_Diamond = 1		--钻石
static_const.Static_ItemType_Gold = 2		--金币
static_const.Static_ItemType_Rmb = 3			--RMB
static_const.Static_ItemType_ProtectTimes = 4	--护盾次数
static_const.Static_ItemType_Power = 5		--能量
static_const.Static_ItemType_GoldPerSecond = 6	--每秒当前金币产量
static_const.Static_ItemType_BuildingProduceRate = 7	--建筑生产速度
static_const.Static_ItemType_ClickGoldAdd	= 8	--每次点击增加金币
static_const.Static_ItemType_WorldGoldAdd = 9	--世界每秒增加金币
static_const.Static_ItemType_AutoClick = 10		--自动点击次数
static_const.Static_ItemType_WeekCard = 11		--周卡
static_const.Static_ItemType_MonthCard = 12		--月卡
static_const.Static_ItemType_Clothes = 13		--时装
static_const.Static_ItemType_ClickGoldAddRatio = 14	--点击金币加成
static_const.Static_ItemType_WorldGoldAddRatio = 15	--世界金币加成
static_const.Static_ItemType_GoldRainTimeAdd = 17	--金币雨时间加成
static_const.Static_ItemType_OfflineGoldAddRatio = 18 --离线金币加成
static_const.Static_ItemType_LifelongCard = 19	--永久卡
static_const.Static_ItemType_GiftBag = 20		--礼包

--任务
static_const.Static_Const_Task_TaskType_DailyTask = 1 --每日任务类型
static_const.Static_Const_Task_TaskType_AchieveTask = 2 --成就任务类型
static_const.Static_Const_Task_TaskType_MainTask = 3 --主线任务类型

--金牌客服
static_const.Static_Const_Friend_Travel_GOLD_GUEST_NAME = "旅行达人"
static_const.Static_Const_Friend_Travel_GOLD_GUEST_UID = 1111111111


