unilight = unilight or { }

NFWebStatus = {
	WEB_OK = 200,
	WEB_AUTH = 401,
	WEB_ERROR = 404,
	WEB_INTER_ERROR = 500,
	WEB_TIMEOUT = 503,
}

NFHttpType =
{
	NF_HTTP_REQ_GET = 1,
	NF_HTTP_REQ_POST = 2,
	NF_HTTP_REQ_HEAD = 4,
	NF_HTTP_REQ_PUT = 8,
	NF_HTTP_REQ_DELETE = 16,
	NF_HTTP_REQ_OPTIONS = 32,
	NF_HTTP_REQ_TRACE = 64,
	NF_HTTP_REQ_CONNECT = 128,
	NF_HTTP_REQ_PATCH = 256,
}

-- HttpServerDo.*简化Do.*的消息处理，可直接收发lua table消息 --
HttpServerDo = HttpServerDo or {}
HttpServer = {}
setmetatable(HttpServer,
{
	__index = HttpServerDo,
	__newindex = function(t, k, handle)
		if handle == nil then
			HttpServerDo[k] = nil
		else
			HttpServerDo[k] = function(req)
				unilight.debug("Http Server | " .. k)
				handle(req)
			end
		end
	end,
})

function unilight.HttpServerAddRequestHandler(serverType, urlPath, requestType, resFunc)
    return LuaNFrame:HttpServerAddRequestHandler(serverType, urlPath, requestType, resFunc)
end

function unilight.HttpServerInitServer(serverType, port)
    return LuaNFrame:HttpServerInitServer(serverType, port)
end

function unilight.HttpServerResponseMsg(serverType, req, strMsg, code, reason)
    return LuaNFrame:HttpServerResponseMsg(serverType, req, strMsg, code, reason)
end

--C++将调用这个函数作为httpserver回调
--req是一个userdata数据结构，C++中是NFHttpRequest
--包含一下属性:
--url
--path
--remoteHost
--type
--body
--params
--headers
--params
--headers
function unilight.HttpServerRequestCallBack(luaFunc, req)
	if HttpServer[luaFunc] ~= nil then
		HttpServer[luaFunc](req)
	end
end