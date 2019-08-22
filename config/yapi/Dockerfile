ARG NODE_IMAGES
FROM ${NODE_IMAGES}

ARG YAPI_VERSION
ARG YAPI_HOME
ARG YAPI_HOST_PORT

ENV VENDORS 	${YAPI_HOME}/vendors
ENV GIT_URL     https://github.com/YMFE/yapi.git
ENV GIT_MIRROR_URL     https://gitee.com/mirrors/YApi.git

COPY ./wait-for-it.sh /
COPY ./entrypoint.sh /bin

WORKDIR ${YAPI_HOME}/

RUN echo "https://mirror.tuna.tsinghua.edu.cn/alpine/v3.4/main/" > /etc/apk/repositories

RUN apk update \
        && apk upgrade \
        && apk add --no-cache git curl python make openssl tar gcc bash \
        && rm -rf /var/cache/apk/*

RUN rm -rf node && \
    ret=`curl -s  https://api.ip.sb/geoip | grep China | wc -l` && \
    if [ $ret -ne 0 ]; then \
        GIT_URL=${GIT_MIRROR_URL} && npm config set registry https://registry.npm.taobao.org; \
    fi; \
    echo ${GIT_URL} && \
	git clone --depth 1 ${GIT_URL} vendors && \
	cd vendors && \
	npm install -g node-gyp yapi-cli && \
	npm install --production && \
 	chmod +x /bin/entrypoint.sh && \
 	chmod +x /wait-for-it.sh

EXPOSE ${YAPI_HOST_PORT}
ENTRYPOINT ["entrypoint.sh"]
