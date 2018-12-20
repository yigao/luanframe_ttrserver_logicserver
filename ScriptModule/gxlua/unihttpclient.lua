unilight = unilight or { }

-- HttpClientDo.*简化Do.*的消息处理，可直接收发lua table消息 --
HttpClientDo = HttpClientDo or {}
HttpClient = {}
setmetatable(HttpClient,
{
	__index = HttpClientDo,
	__newindex = function(t, k, handle)
		if handle == nil then
			HttpClientDo[k] = nil
		else
			HttpClientDo[k] = function(state_code, respData, strUseData)
				handle(state_code, respData, strUseData)
			end
		end
	end,
})

--[[
	向指定url请求GET http服务
	resFunc:http请求回调函数
	url:请求http服务器的url
	msg:请求的数据,这时里是一个lua的table
    heads 在这里是一个 map[string]string 选定对应参考与值
    
    return bool
]]

function unilight.HttpClientRequestGet(uri, resFunc, strUseData)
    return LuaNFrame:HttpClientRequestGet(uri, resFunc, {}, strUseData)
end

--[[
	向指定url请求POS http服务
	resFunc:http请求回调函数
	url:请求http服务器的url
	msg:请求的数据,这时里是一个lua的table
	heads 在这里是一个 map[string]string 选定对应参考与值
]]
function unilight.HttpClientRequestPost(url, resFunc, body, heads, para)
	return LuaNFrame:HttpClientRequestPost(url, resFunc, body, heads, para)
end


--C++将调用这个函数作为httpclient回调
function unilight.HttpClientRequestCallBack(luaFunc, state_code, respData, strUseData)
	if state_code == 200 then
		local data = json2table(respData)
		local callbackpara = json2table(strUseData)
		unilight.debug("Http Client | " .. luaFunc .. " | recv:" .. respData)
		if HttpClient[luaFunc] ~= nil then
			HttpClient[luaFunc](state_code, data, callbackpara)
		end
	else
		unilight.error("Http Client | " .. luaFunc .. " | state_code:" .. state_code .. " | error:" .. respData)
	end
end