function Net.CmdPing_C(cmd, laccount)
    local res = {}
    res["do"] = "Cmd.Ping_S"
    res["data"] = {
        resultCode = 0,
    }

    return res
end