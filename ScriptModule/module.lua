function register_module(tbl, name)
	local tmp = {tbl = tbl, tblName = name}
	table.insert(LuaNFrame.ScriptList, tmp)
	unilight.debug("load module:" .. name)
end


ScriptModule = {}
function ScriptModule.Init(...)
	for i=1, #(LuaNFrame.ScriptList) do
		if (type(LuaNFrame.ScriptList[i].tbl.Init) == "function") then
			LuaNFrame.ScriptList[i].tbl.Init(...);
		end
	end
end

function ScriptModule.AfterInit(...)
	for i=1, #(LuaNFrame.ScriptList) do
		if (type(LuaNFrame.ScriptList[i].tbl.AfterInit) == "function") then
			LuaNFrame.ScriptList[i].tbl.AfterInit(...);
		end
	end
end

function ScriptModule.Execute(...)
	for i=1, #(LuaNFrame.ScriptList) do
		if (type(LuaNFrame.ScriptList[i].tbl.Execute) == "function") then
			LuaNFrame.ScriptList[i].tbl.Execute(...);
		end
	end
end

function ScriptModule.BeforeShut(...)
	for i=1, #(LuaNFrame.ScriptList) do
		if (type(LuaNFrame.ScriptList[i].tbl.BeforeShut) == "function") then
			LuaNFrame.ScriptList[i].tbl.BeforeShut(...);
		end
	end
end

function ScriptModule.Shut(...)
	for i=1, #(LuaNFrame.ScriptList) do
		if (type(LuaNFrame.ScriptList[i].tbl.Shut) == "function") then
			LuaNFrame.ScriptList[i].tbl.Shut(...);
		end
	end
end