-- FILE: travel.xlsx SHEET: 团员角色 KEY: itemid
travelHead = {
[2001]={["head"]=1,["itemid"]=2001},
[2002]={["head"]=2,["itemid"]=2002},
[2003]={["head"]=3,["itemid"]=2003},
[2004]={["head"]=4,["itemid"]=2004},
[2005]={["head"]=5,["itemid"]=2005},
[2006]={["head"]=6,["itemid"]=2006},
[2007]={["head"]=7,["itemid"]=2007},
[2008]={["head"]=8,["itemid"]=2008},
[2009]={["head"]=9,["itemid"]=2009},
[2010]={["head"]=10,["itemid"]=2010},
}
setmetatable(travelHead, {__index = function(__t, __k) if __k == "query" then return function(itemid) return __t[itemid] end end end})
