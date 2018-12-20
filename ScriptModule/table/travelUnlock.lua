-- FILE: travel.xlsx SHEET: 团员解锁 KEY: pos
travelUnlock = {
[1]={["pos"]=1,["level"]=0},
[2]={["pos"]=2,["level"]=0},
[3]={["pos"]=3,["level"]=0},
[4]={["pos"]=4,["level"]=2},
[5]={["pos"]=5,["level"]=5},
[6]={["pos"]=6,["level"]=10},
[7]={["pos"]=7,["level"]=15},
[8]={["pos"]=8,["level"]=20},
[9]={["pos"]=9,["level"]=25},
[10]={["pos"]=10,["level"]=30},
}
setmetatable(travelUnlock, {__index = function(__t, __k) if __k == "query" then return function(pos) return __t[pos] end end end})
