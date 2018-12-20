-- FILE: task.xlsx SHEET: 活跃 KEY: ID
taskActivity = {
[1]={["ID"]=1,["cond"]=20,["reward"]="1_15"},
[2]={["ID"]=2,["cond"]=50,["reward"]="1_25"},
[3]={["ID"]=3,["cond"]=80,["reward"]="1_40"},
}
setmetatable(taskActivity, {__index = function(__t, __k) if __k == "query" then return function(ID) return __t[ID] end end end})
