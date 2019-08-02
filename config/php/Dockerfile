ARG PHP_VERSION
ARG PHP_IMAGES
FROM ${PHP_IMAGES}

ARG PHP_EXTENSIONS
ARG MORE_EXTENSION_INSTALLER
ARG ALPINE_REPOSITORIES

COPY ./extensions /tmp/extensions
WORKDIR /tmp/extensions

ENV EXTENSIONS=",${PHP_EXTENSIONS},"
ENV MC="-j$(nproc)"

RUN export MC="-j$(nproc)" \
    #&& php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    #&& php composer-setup.php  \
    #&& php -r "unlink('composer-setup.php');"  \
    #&& mv composer.phar /usr/local/bin/composer \
    #&& composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ \
    && chmod +x install.sh \
    && chmod +x "${MORE_EXTENSION_INSTALLER}" \
    && sh install.sh \
    && sh "${MORE_EXTENSION_INSTALLER}" \
    && rm -rf /tmp/extensions

WORKDIR /var/www/html
