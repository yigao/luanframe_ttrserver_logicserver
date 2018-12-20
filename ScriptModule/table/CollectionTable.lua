-- FILE: welfare.xlsx SHEET: 收藏 KEY: id
CollectionTable = {
[1]={["id"]=1,["reward"]="1_100"},
}
setmetatable(CollectionTable, {__index = function(__t, __k) if __k == "query" then return function(id) return __t[id] end end end})
