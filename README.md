# zls-docker

开箱即用的面向生产和开发环境的 Docker 镜像

[详细文档](https://docs.73zls.com/zls-docker/#/)

## 快速使用

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

# Windows 请执行
docker-compose up nginx mysql php72
```
