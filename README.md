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
├── log                                    日志目录
├── docker-compose.yml                     docker-compose 编排文件
├── run.sh                                 执行脚本
└── www                                    站点目录
    └── localhost                          默认站点
```

## 快速上手

1. 安装git、 docker 和 docker-compose

```bash
# 如果不是root用户，需将当前用户加入docker用户组
sudo gpasswd -a ${USER} docker
```

2. clone项目：

```bash
git clone --depth=1 https://github.com/sohaha/zls-docker.git
```

3. 拷贝配置文件

```bash
cd zls-docker
cp .env.example .env
```

4. 启动

```bash
# 更多命令直接执行 run.sh 查看
./run.sh up

# Windows 请执行 docker-compose up nginx mysql php72
```

5. 访问在浏览器中访问 http://localhost/

## 配置设置

### php 扩展

```bash
# 编辑.env文件，
# 从扩展列表 PHP7.2 extensions 中选择相应的扩展，
# 添加（移除）到 PHP72_EXTENSIONS 中，英文逗号隔开
PHP72_EXTENSIONS=curl,opcache,redis

# 重新编译 PHP 镜像并启动
./run.sh build php72 && ./run.sh up php72
# Windows 请执行 docker-compose build php72 && docker-compose up php72 -d
```

## 日常使用

### 命令行

如要使用 composer，启动 swoole ，或 npm 安装等等

```bash
./run.sh composer install zls/wechat
./run.sh php test.php
./run.sh npm install zls-ui
./run.sh go build
...
```

### 重载 Nginx

```bash
./run.sh reload
```

### 进入容器

```bash
# ./run.sh bash 容器名称，如ph72
./run.sh bash php72
```

### 停止容器
```bash
# ./run.sh stop 容器名称（空表示停止全部）
./run.sh stop nginx
```
