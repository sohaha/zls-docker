--[[
Author: seekwe
Date: 2020-08-13 16:05:18
Last Modified by:: seekwe
Last Modified time: 2020-08-14 18:31:26
--]]

-- curl --request POST 'http://nginx:81/http?get=isGet' --form 'post=yesPost'

local request_method = ngx.var.request_method

local ua = ngx.var.http_user_agent

local ip = getClientIp()

ngx.say(os.date("%Y-%m-%d %H:%M:%S",os.time()),"  ",os.getenv("TZ"))
ngx.say("<br>")
ngx.say("IP: ",ip)
ngx.say("method: ",request_method)
ngx.say("<br>")
ngx.say("user_agent: ",ua)
ngx.say("<br>")

if ngx.req.get_uri_args()["jump"] == nil then
  ngx.say('没有 Get 参数，手动设置一个')
  ngx.say("<br>")
  ngx.req.set_uri_args({help = 'yes'});  
end

if request_method == "POST" then
    ngx.req.read_body() -- 解析 body 参数之前一定要先读取 body
    local arg = ngx.req.get_post_args()
    for k,v in pairs(arg) do
    ngx.say("[POST] ", k, ": ", v,"<br>")
    end
end

local arg = ngx.req.get_uri_args()
for k,v in pairs(arg) do
    ngx.say("[GET] ", k, ": ", v,"<br>")
end

for k,v in pairs(ngx.req.get_headers()) do
    ngx.say("[HEAD] ", k, ": ", v,"<br>")
end

ngx.exit(ngx.OK)