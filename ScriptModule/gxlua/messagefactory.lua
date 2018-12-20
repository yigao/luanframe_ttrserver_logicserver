require "gxlua/unilight"

msgValueName = {}
msgNameValue = {}

unilight.registerpbcmd = function(pbdata, bycmd)
    local pkg = pbdata.package
    for _,v in ipairs(pbdata.message_type) do
        if table.empty(v.enum_type) == false and v.enum_type[1].name == "Param" then
            for _, v in ipairs(v.enum_type[1].value) do
                local name = pkg .."."..v.name
                local byparam = v.number
                unilight.registermsgcmd(name, bycmd, byparam)
            end
        end
    end
end

unilight.registermsgcmd = function(name, bycmd, byparam)
    if msgNameValue[name] ~= nil then
        unilight.error("registermsgcmd 重复注册" .. name .. " bycmd:" .. bycmd .. "  byparam:" .. byparam)
        return false
    end

    msgNameValue[name] = {
        bycmd = bycmd,
        byparam = byparam,
    }
    msgValueName[bycmd] = msgValueName[bycmd] or {} 
    msgValueName[bycmd][byparam] = name 
    unilight.debug("注册协议成功：" .. name .. " bycmd:" .. bycmd .. "  byparam:" .. byparam)
    return true
end

unilight.getmsgname = function(bycmd, byparam)
    if msgValueName[bycmd] ~= nil then
        return msgValueName[bycmd][byparam]
    end
    return nil
end

unilight.getmsgnu = function(name)
   return msgNameValue[name] 
end
