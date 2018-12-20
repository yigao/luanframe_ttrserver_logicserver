--全局配置
--
GlobalConst = {
    Initial_Gold = 20,                          --角色初始金币
    Initial_Diamond = 0,                        --角色初始钻石
    Travel_Shield_Number = 0,                   --防护盾初始数量

    Takt_Time = 1,                              --建筑生产时间间隔
    Add_Intimacy_Point = 1,                     --雇佣1次增加的亲密度点数
    Intimacy_MaxPoint = 100,                    --亲密度上限
    Intimacy_Plus = 0.04,                       --亲密度加成百分比

    Click_CD = 0.1,                             --点击CD
    Click_Factor = 0.01,                        --点击系数
    Click_Crit_Prob = 0.02,                     --点击暴击概率
    Click_Crit_Multiple = 10,                   --点击暴击倍数

    Max_OffLine_Time = 12*60*60,                --离线计算收益的最大时间(秒)
    OffLine_Factor = 0.3333,			        --离线收益只有在线收益的0.x倍
    
    Max_RangeIncome_Time = 24,                  --看广告的业务加成累计的最大时间(24小时)
    Add_RangeIncome_Time = 4,                   --单次看广告的增加的时间（4小时）   
	Max_Adviertisement_Times = 99,              --观看广告的最大次数，超过则变为分享
	OffLine_Doubling_Diamond = 100,		        --欢迎回来时，离线奖励直接翻倍所需要的钻石数

    Diamond_Quick_Time = 60,                    --1钻石能加速礼包的等待s
    WatchVideoMinusMinuteCd = 60,               --玩家每看一次视频减少对应礼包多少分钟的cd
	
    Invitation_Star_Awardse = 10,               --邀请有礼领取奖励星级
	Invitation_Role_Times = 3,               	--邀请豪礼需要新用户数
	Invitation_Role_Character = 2009,           --邀请豪礼送的角色id
	
	
	Unlock_Building_LevelUp = 10,               --建筑解锁分享直升10级
	
	Ranking_shows = 100,                        --排行榜排名显示数量
	
	Travel_Time = 21600,                        --旅行团团员雇佣时长（秒）
	Travel_CD = 3600,                           --旅行团团员CD时长（秒）
	Travel_CD_Diamond = 20,                     --旅行团团员清除CD所需要花费的钻石
	Travel_Catch_Number = 3,                    --每日免费抓捕次数上限
	Travel_Catch_COST = {20,20,50,50,100},      --花费钻石抓捕所需要的钻石（最后的数值为上限）

  	Tnspire_Number = 5,                         --好友捣乱每日次数上限
	Mischief_Number = 5,                        --好友鼓舞每日次数上限
	Encouraged_Number = 5,                      --好友被鼓舞每日次数上限
	Beteased_Number = 5,                        --好友被捣乱每日次数上限
	Mischief_Coefficient = 0.05,                --鼓舞获得金币系数	
	
	Remedial_Delay = 1.5,                       --改造延迟时间	

    Number_Times= 5,                            --免费钻石次数上限
    Diamonds_Number = {20,20,20,20,20},               --免费钻石奖励
    DailyLotteryDrawNum = 5,                    --每日抽奖次数上限
	
	DailyGift_Times=6,                    --每日免费送礼人数上限
	DailyGift=600,                    --每日免费送礼的x秒金币奖励（600秒金币，物品id1003），新用户加倍
	
	Reward_Reform=300,                --每次改造的x秒金币奖励（300秒金币，物品id1003），分享加倍

	Approved_or_not=1,                --是否通过审核？0没有，1是（考试作弊专用，通过审核后，要改为1）

	Doublerage_Time=1,                --每天前几次领取怒气奖励弹出翻倍界面
}