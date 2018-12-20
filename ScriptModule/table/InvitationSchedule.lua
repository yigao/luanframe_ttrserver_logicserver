-- FILE: welfare.xlsx SHEET: 邀请进度 KEY: id
InvitationSchedule = {
[1]={["id"]=1,["scheduleVal"]=3,["reward"]="1_300"},
[2]={["id"]=2,["scheduleVal"]=10,["reward"]="1_500"},
[3]={["id"]=3,["scheduleVal"]=20,["reward"]="1_1000"},
}
setmetatable(InvitationSchedule, {__index = function(__t, __k) if __k == "query" then return function(id) return __t[id] end end end})
