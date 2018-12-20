-- FILE: welfare.xlsx SHEET: 邀请 KEY: id
Invitation = {
[1]={["id"]=1,["inviteNum"]=1,["reward"]="1_100"},
[2]={["id"]=2,["inviteNum"]=2,["reward"]="1_100"},
[3]={["id"]=3,["inviteNum"]=3,["reward"]="1_100"},
[4]={["id"]=4,["inviteNum"]=4,["reward"]="1_100"},
[5]={["id"]=5,["inviteNum"]=5,["reward"]="1_100"},
[6]={["id"]=6,["inviteNum"]=6,["reward"]="1_100"},
[7]={["id"]=7,["inviteNum"]=7,["reward"]="1_100"},
[8]={["id"]=8,["inviteNum"]=8,["reward"]="1_100"},
[9]={["id"]=9,["inviteNum"]=9,["reward"]="1_100"},
[10]={["id"]=10,["inviteNum"]=10,["reward"]="1_100"},
[11]={["id"]=11,["inviteNum"]=11,["reward"]="1_100"},
[12]={["id"]=12,["inviteNum"]=12,["reward"]="1_100"},
[13]={["id"]=13,["inviteNum"]=13,["reward"]="1_100"},
[14]={["id"]=14,["inviteNum"]=14,["reward"]="1_100"},
[15]={["id"]=15,["inviteNum"]=15,["reward"]="1_100"},
[16]={["id"]=16,["inviteNum"]=16,["reward"]="1_100"},
[17]={["id"]=17,["inviteNum"]=17,["reward"]="1_100"},
[18]={["id"]=18,["inviteNum"]=18,["reward"]="1_100"},
[19]={["id"]=19,["inviteNum"]=19,["reward"]="1_100"},
[20]={["id"]=20,["inviteNum"]=20,["reward"]="1_100"},
}
setmetatable(Invitation, {__index = function(__t, __k) if __k == "query" then return function(id) return __t[id] end end end})
