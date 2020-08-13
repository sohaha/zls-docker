--[[
Author: seekwe
Date: 2020-08-13 16:05:18
Last Modified by:: seekwe
Last Modified time: 2020-08-13 17:43:27
--]]

-- curl --request POST 'http://nginx:81/http?get=isGet' --form 'post=yesPost'

local request_method = ngx.var.request_method

if request_method == "POST" then
    ngx.req.read_body() -- 解析 body 参数之前一定要先读取 body
    local arg = ngx.req.get_post_args()
    for k,v in pairs(arg) do
        ngx.say("[POST] key:", k, " v:", v)
    end
    ngx.say("The is POST")
end

local arg = ngx.req.get_uri_args()
for k,v in pairs(arg) do
    ngx.say("[GET ] key:", k, " v:", v)
end

