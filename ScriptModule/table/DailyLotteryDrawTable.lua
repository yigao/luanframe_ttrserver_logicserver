-- FILE: welfare.xlsx SHEET: 转盘 KEY: id
DailyLotteryDrawTable = {
[1]={["id"]=1,["reward"]="1_20",["PrimaryReward"]="1_20",["weight"]=25},
[2]={["id"]=2,["reward"]="1003_3600",["PrimaryReward"]="1003_3600",["weight"]=3},
[3]={["id"]=3,["reward"]="1_50",["PrimaryReward"]="1_50",["weight"]=10},
[4]={["id"]=4,["reward"]="1001_1",["PrimaryReward"]="1001_1",["weight"]=15},
[5]={["id"]=5,["reward"]="1003_7200",["PrimaryReward"]="2004_1",["weight"]=1},
[6]={["id"]=6,["reward"]="1003_180",["PrimaryReward"]="1003_180",["weight"]=30},
[7]={["id"]=7,["reward"]="1_100",["PrimaryReward"]="1_100",["weight"]=4},
[8]={["id"]=8,["reward"]="1003_1200",["PrimaryReward"]="1003_1200",["weight"]=12},
}
setmetatable(DailyLotteryDrawTable, {__index = function(__t, __k) if __k == "query" then return function(id) return __t[id] end end end})
