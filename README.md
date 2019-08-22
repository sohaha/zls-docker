# zls-docker

开箱即用的面向生产和开发环境的 Docker 镜像

[详细文档](https://docs.73zls.com/zls-docker/#/)

## 目录结构

```
.
├── config
│   ├── mysql
│   │   └── mysql.cnf                      mysql.cnf 配置
│   ├── nginx
│   │   ├── conf.d                         vhost 配置目录
│   │   │   ├── localhost.conf             默认站点配置
│   │   │   └── localhost_https.conf       默认站点HTTPS配置
│   │   └── nginx.conf                     nginx.conf 配置
│   ├── php
│   │   ├── php-fpm.conf                   php-fpm.conf 配置
│   │   └── php.ini                        php.ini 配置
│   ├── redis
│   │   └── redis.conf                     redis.conf 配置
│   ├── golang
│   ├── mongodb
│   └── node
├── data                                   数据目录
├── logs                                   日志目录
├── docker-compose.yml                     docker-compose 编排文件
├── run.sh                                 执行脚本
└── www                                    站点目录
    └── localhost                          默认站点
```

## 快速上手

1. 安装git、 docker 和 docker-compose

docker >=19

docker-compose >= 3

系统自带的 yum、apt 安装版本可能会过低了，
如不清楚如果不熟悉怎么安装 docker，
执行可以拉取项目后执行 ./run.sh installDocker 查看相关安装命令。

2. 拉取项目

```bash
git clone --depth=1 https://github.com/sohaha/zls-docker.git
```

3. 启动

```bash
# 更多命令直接执行 run.sh 查看
./run.sh up

# Windows 请先复制配置再执行启动命令
copy .env.example .env
copy docker-compose.yml.example docker-compose.yml
docker-compose up nginx mysql php
```

5. 访问在浏览器中访问 http://localhost/ 。

## 配置设置

更多配置请打开 .env 文件查看。

### php 扩展

```bash
# 编辑.env文件，
# 从扩展列表 PHP extensions 中选择相应的扩展，
# 添加（移除）到 PHP_EXTENSIONS 中，英文逗号隔开
PHP_EXTENSIONS=swoole,redis

# 重新编译 PHP 镜像并启动
./run.sh buildUp php

# Windows 请执行 docker-compose build php && docker-compose up php -d
```

### 数据库密码

如需修改默认密码，编辑.env文件即可，

MySQL：`MYSQL_ROOT_PASSWORD=666666`，

mongo：`MONGODB_INITDB_ROOT_PASSWORD=666666`

必须在容器生成之前，如果容器已经生成过，

请使用bash进入容器内修改，具体方法请谷歌。


## 日常使用

### 安装脚本

建议把脚本命令安装至系统中，方便使用

```bash
./run.sh tools
# 输入1，自动安装至系统，然后就可以全局使用 zdocker

zdocker help
```


### 命令行

如要使用 composer，启动 swoole ，或 npm 安装等等。

```bash
./run.sh composer install zls/wechat
./run.sh php test.php
./run.sh npm install zls-ui
./run.sh go build
...
```

### 重新加载

nginx，php-fpm之类的修改了配置是需要重新加载的，可使用该命令

```bash
# 不值得容器默认为nginx，下面命令等同 ./run.sh reload nginx
./run.sh reload

./run.sh reload php
```

### 进入容器

```bash
# ./run.sh bash 容器名称，如ph
./run.sh bash php
```

### 停止容器

```bash
# ./run.sh stop 容器名称（空表示停止全部）
./run.sh stop nginx
```

### 辅助操作

一些常用的操作，如 php-fpm 优化，清理没用使用的容器等等

```bash
./run.sh tools
```

### 更多问题

**权限问题**

如果不是root用户或提示权限问题，可将当前用户加入docker用户组

```bash
sudo groupadd docker
sudo gpasswd -a ${USER} docker
sudo service docker restart
```

**Pull 太慢**

如果是国内服务器请尝试更换docker源为国内源

```bash 
vi /etc/docker/daemon.json

# {"registry-mirrors": ["https://registry.docker-cn.com"]}
```

**启动失败**

查看 logs 目录，参考日志信息处理。




**安装YAPI**

```bash
# 先启动 mongodb
./run.sh up mongodb

# 进入 mogodb 内 建立 Yapi 账号
./run.sh bash mongodb
# 进入 mongo 数据库
mongo -u root -p 666666
# 进入 Yapi 库
use yapi
# 添加一个用户 然后 Ctrl+c退出数据库 exit 退出容器
db.createUser({user: "yapi",pwd: "666666",roles: [{role: "dbOwner",db: "yapi"}]})
# 默认账号密码 admin@admin.com ymfe.org
# 启动 yapi (上面步骤只要执行一次)
./run.sh up yapi

```
