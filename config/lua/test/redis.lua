--[[
Author: seekwe
Date: 2020-08-13 17:45:02
Last Modified by:: seekwe
Last Modified time: 2020-08-13 18:24:22
--]]

-- curl 'http://nginx:81/redis'

-- redis config
local redis = require "resty.redis"
local red = redis:new()
local redis_passwd = "666666"
local redis_host = "172.0.0.40"

local ok, err = red:connect(redis_host, 6379)

if not ok then
    ngx.say("failed to connect: ", err)
    return
end

if redis_passwd then
    local count
    count, err = red:get_reused_times()
    if 0 == count then
        ok, err = red:auth(redis_passwd)
        if not ok then
            ngx.say("failed to auth: ", err)
            return
        end
    elseif err then
        ngx.say("failed to get reused times: ", err)
        return
    end
end

ok, err = red:set("dog", "an animal1")
if not ok then
    ngx.say("failed to set dog: ", err)
    return
end

ngx.say("set result: ", ok)

local res, err = red:get("dog")
if not res then
    ngx.say("failed to get dog: ", err)
    return
end

if res == ngx.null then
    ngx.say("dog not found.")
    return
end

ngx.say("dog: ", res)

