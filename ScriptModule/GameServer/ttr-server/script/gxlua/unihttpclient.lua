unilight = unilight or {}

--[[
	向指定url请求GET http服务
	resFunc:http请求回调函数
	url:请求http服务器的url
	msg:请求的数据,这时里是一个lua的table
	heads 在这里是一个 map[string]string 选定对应参考与值
]]

unilight.HttpRequestGet = function(resFunc, url, heads, para)
	heads = heads or {}
    para = para or {}
	if type(resFunc) ~= "string" or type(url) ~= "string" or type(heads) ~= "table" then
		unilight.error("unilight.HttpRequestGet params error" .. resFunc .. url)
		return
	end
	reqMsg = json.encode(msg)
	callbackpara = json.encode(para)
	go.httpclient.HttpRequestGet(0, callbackpara, resFunc, url, heads)
end

--[[
	向指定url请求POS http服务
	resFunc:http请求回调函数
	url:请求http服务器的url
	msg:请求的数据,这时里是一个lua的table
	heads 在这里是一个 map[string]string 选定对应参考与值
]]

unilight.HttpRequestPost = function(resFunc, url, body, bodyType, heads, para)
    para = para or {}
	heads = heads or {}
	bodyType = bodyType or "application/x-www-form-urlencoded"
	if type(resFunc) ~= "string" or type(url) ~= "string" or type(body) ~= "table" or type(bodyType) ~= "string"or type(heads) ~= "table" then
		unilight.error("unilight.HttpRequestGet params error" .. resFunc .. url)
		return
	end
	local reqMsg = json.encode(body)
	local callbackpara = json.encode(para)
	go.httpclient.HttpRequestPost(0, callbackpara, resFunc, url, bodyType, reqMsg, heads)
end

-- deomo: 向指定url发送post请求，其中heads， bodytype都采用缺省方式
function testHttpRequest()
	local req = {
            data = {
                srcImage = "http://98pokerstatic-a.akamaihd.net/BJLSTATIC/head/woman/143.jpg"
            }
		}
	unilight.HttpRequestPost("Echo", "http://14.17.104.56:8888/exchangeurltomyserver", req, nil, nil, {para="1"})
end

Http.Echo = function (cmd, para)
	unilight.info("receive http res" .. table.tostring(cmd))
	unilight.info("receive http para " .. para)
end

unilight.RequetTencentOneMinOnlineNum = function(para)
    local url = "http://tencentonline.org/get_result_list"
    local body = "page_no=1&page_size=1"
    local heads = {
        ["Content-Type"] = "application/x-www-form-urlencoded; charset=UTF-8",
        ["Origin"] = "http://tencentonline.org",
        ["Host"] = "tencentonline.org",
        ["Referer"] = "http://tencentonline.org/video.html",
        ["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36",
        ["X-Requested-With"] = "XMLHttpRequest",
        ["Accept"] = "application/json, text/javascript, */*; q=0.01",
    }

    para = para or {}
    local resFunc = "ResponseTencentOneMinOnlineNum"
    local callbackpara = json.encode(para)
    local bodyType = "application/x-www-form-urlencoded"
    go.httpclient.HttpRequestPost(0, callbackpara, resFunc, url, bodyType, body, heads, true)
end
Http.ResponseTencentOneMinOnlineNum = function(cmd, para)
    unilight.info("这里可以在init.lua里面重写，自己处理逻辑 zwl")
    unilight.info("tencent: res time:"  ..cmd.data[1].time .. "  online: " .. cmd.data[1].count)
    unilight.info("tencent-----para" .. (para))
end
