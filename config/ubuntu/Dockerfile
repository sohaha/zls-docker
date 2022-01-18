ARG UBUNTU_IMAGES
FROM ${UBUNTU_IMAGES}

WORKDIR /var/www/html

ENV GOUP_GO_HOST=golang.google.cn
ENV GOUP_UPDATE_ROOT=https://github.com/owenthereal/goup/releases/latest/download   
ENV GOPROXY=https://goproxy.cn

ENV PATH=$PATH:/root/.go/bin:/root/.go/current/bin

RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list && apt-get clean
# RUN apt update && apt install curl -y
# curl -sSf https://raw.githubusercontent.com/owenthereal/goup/master/install.sh | sh -s -- '--skip-prompt'

# apt install -y manpages-dev
# RUN tail -F /dev/null