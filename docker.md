# docker 安装文档

## CentOS

请按顺序执行以下命令

```bash
# 安装依赖
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# 配置 repositories
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 安装 docker
sudo yum install docker-ce -y

# 检查 dokcer 是否安装成功
docker version

# 启动 docker
systemctl start docker

# 开机自动启动 docker
systemctl enable docker

# 安装 docker-compose

## 如果安装失败可以使用 py 的 pip 安装，方式自行谷歌
curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
## 国内建议使用国内源
curl -L "https://get.daocloud.io/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose


## 设置 docker-compose 权限
chmod +x /usr/local/bin/docker-compose

# 检查 docker-compose 是否安装成功
docker-compose --version
```

## Ubuntu

```bash
sudo curl -sSL https://get.docker.com | sh
sudo usermod pi -aG docker
curl -L "https://get.daocloud.io/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

## 更多问题

**权限问题**

如果不是 root 用户或提示权限问题，可将当前用户加入 docker 用户组

```bash
sudo groupadd docker
sudo gpasswd -a ${USER} docker
sudo service docker restart
```

**Pull 太慢**

如果是国内服务器请尝试更换 docker 源为国内源

```bash
vi /etc/docker/daemon.json

# {"registry-mirrors": ["https://registry.docker-cn.com"]}
```
