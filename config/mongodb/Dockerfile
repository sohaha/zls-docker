ARG MONGODB_IMAGES
FROM ${MONGODB_IMAGES}

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone