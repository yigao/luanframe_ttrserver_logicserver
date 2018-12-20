-- FILE: welfare.xlsx SHEET: 分享 KEY: id
DailyShare = {
[1]={["id"]=1,["reward"]="1_25"},
[2]={["id"]=2,["reward"]="1_25"},
[3]={["id"]=3,["reward"]="1_25"},
}
setmetatable(DailyShare, {__index = function(__t, __k) if __k == "query" then return function(id) return __t[id] end end end})
