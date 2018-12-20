dofile("script/gxlua/protobuf.lua")
require "protobuf"
local c = require "protobuf.c"


function initpbfile(pbname)
	local protoData = protobuf.register_file_c(pbname)
    return protoData
end

function registerpbfile(pbname, bycmd)
	local protoData = initpbfile(pbname) 
    unilight.registerpbcmd(protoData, bycmd)
end

function registepbdir(pbdir, headname, key)
    local pbfiles = luar.slice2table(go.getPbcFiles(pbdir))
    if table.empty(pbfiles) == true then
        return 
    end
    local cmdpath = pbdir.."/"..headname 
    local cmddata = initpbfile(cmdpath)    
    for _,v in ipairs(cmddata.enum_type) do
        if v.name == key then
            for _, command in ipairs(v.value) do
                local splitstr = string.split(command.name,"_")
                local filename = ""
                for i,v in ipairs(splitstr) do
                    if i ~= 1 then
                        if i == 2 then
                            filename = v
                        else
                            filename = filename .. "_" .. v
                        end
                    end
                end
                local name = string.lower(filename)
                local number = command.number
                for i, pbfile in ipairs(pbfiles) do
                    local location = string.find(string.lower(pbfile), name)
                    if location ~= nil then
                        registerpbfile(pbfile, number)
                        break
                    end
                end
            end
        end
    end
end


