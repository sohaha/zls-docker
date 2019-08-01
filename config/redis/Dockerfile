ARG REDIS_IMAGES
FROM ${REDIS_IMAGES}

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone