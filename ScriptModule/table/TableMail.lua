-- FILE: message.xlsx SHEET: 邮件 KEY: Id
TableMail = {
[1]={["Id"]=1,["Attachments"]=""},
[2]={["Id"]=2,["Attachments"]="2_10000"},
[3]={["Id"]=3,["Attachments"]="1_100;2_10000"},
[4]={["Id"]=4,["Attachments"]="1_100;2_10000;1001_1"},
[5]={["Id"]=5,["Attachments"]="1001_1"},
[6]={["Id"]=6,["Attachments"]=""},
[7]={["Id"]=7,["Attachments"]="1_100;2_10000"},
[8]={["Id"]=8,["Attachments"]="1_200"},
[9]={["Id"]=9,["Attachments"]="1_500"},
[10]={["Id"]=10,["Attachments"]="1_300"},
}
setmetatable(TableMail, {__index = function(__t, __k) if __k == "query" then return function(Id) return __t[Id] end end end})
