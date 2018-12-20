GameServer = { }

function GameServer.load_script_file()
	register_module(GameServerModule, "GameServerModule")
end

--加载所有的module
unilight.InsertLoadFunc(GameServer.load_script_file)

return GameServer