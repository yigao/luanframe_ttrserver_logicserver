-- FILE: rangeincome.xlsx SHEET: 随机宝箱 KEY: id
TreasureBoxData = {
[1]={["id"]=1,["mintime"]=60,["maxtime"]=90,["probability"]=0.0,["time"]=90,["duration"]=30,["multiple"]=2},
[2]={["id"]=2,["mintime"]=180,["maxtime"]=240,["probability"]=0.1,["time"]=120,["duration"]=30,["multiple"]=2},
[3]={["id"]=3,["mintime"]=300,["maxtime"]=360,["probability"]=0.2,["time"]=150,["duration"]=30,["multiple"]=2},
[4]={["id"]=4,["mintime"]=480,["maxtime"]=600,["probability"]=0.3,["time"]=200,["duration"]=30,["multiple"]=2},
[5]={["id"]=5,["mintime"]=900,["maxtime"]=1200,["probability"]=0.4,["time"]=300,["duration"]=30,["multiple"]=2},
[6]={["id"]=6,["mintime"]=1800,["maxtime"]=2400,["probability"]=0.5,["time"]=480,["duration"]=30,["multiple"]=2},
[7]={["id"]=7,["mintime"]=2700,["maxtime"]=3600,["probability"]=0.5,["time"]=600,["duration"]=30,["multiple"]=2},
}
setmetatable(TreasureBoxData, {__index = function(__t, __k) if __k == "query" then return function(id) return __t[id] end end end})
