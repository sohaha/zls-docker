--[[
Author: seekwe
Date: 2019-10-27 18:24:58
Last Modified by:: seekwe
Last Modified time: 2020-08-14 14:21:42
--]]

--规则存放目录
RulePath = "/usr/local/openresty/nginx/conf/lua/waf/wafconf/"
 --是否开启攻击信息记录，需要配置logdir
Attacklog = "off"
--log存储目录，该目录需要用户自己新建，切需要nginx用户的可写权限
Logdir = "/var/log/nginx/"
 --是否拦截url访问
UrlDeny="on"
--是否拦截后重定向
Redirect="on"
--是否拦截cookie攻击
CookieMatch="on"
--是否拦截post攻击
PostMatch="off"
--是否开启URL白名单
WhiteModule="off"
--是否开启主机(对应nginx里面的server_name)白名单
WhiteHostModule="off"
--不可可上传文件后缀类型
BlackFileExt={"php","jsp"}
--ip白名单，多个ip用逗号分隔
IpWhitelist={"127.0.0.1","172.16.1.0-172.16.1.255"}
--ip黑名单，多个ip用逗号分隔
IpBlocklist={"1.0.0.1","2.0.0.0-2.0.0.255"}
--server_name白名单，多个用逗号分隔
HostWhiteList = {"blog.73zls.com"}
--是否开启拦截cc攻击(需要nginx.conf的http段增加lua_shared_dict limit 10m;)
CCDeny="on"
--设置cc攻击频率，单位为秒.默认1分钟同一个IP只能请求同一个地址70次
CCrate="70/60"
Html=[[
<html xmlns="http://www.w3.org/1999/xhtml"><head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title></title>
<body bgcolor="white">
<center><h1>503 Service Temporarily Unavailable</h1></center>
<hr><center>nginx</center>
</body>
</html>
]]

