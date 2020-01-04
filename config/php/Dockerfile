ARG PHP_VERSION
ARG PHP_IMAGES
FROM ${PHP_IMAGES}

ARG PHP_EXTENSIONS
ARG MORE_EXTENSION_INSTALLER
ARG ALPINE_REPOSITORIES
ARG COMPOSER_VERSION
ARG COMPOSER_PACKAGIST

COPY ./extensions /tmp/extensions

WORKDIR /tmp/extensions

ENV EXTENSIONS=",${PHP_EXTENSIONS},"
ENV MC="-j$(nproc)"
ENV COMPOSER_HOME="/composer"
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_PACKAGIST="${COMPOSER_PACKAGIST}"

RUN export MC="-j$(nproc)" \
    && chmod +x install.sh \
    && chmod +x "${MORE_EXTENSION_INSTALLER}"\
    && sh install.sh \
    && sh "${MORE_EXTENSION_INSTALLER}" \
    && rm -rf /tmp/extensions \
    && php -v \
    && php -m \
    && echo "install composer" \
    && cd /tmp \
    # && wget https://mirrors.aliyun.com/composer/composer.phar \
    && wget https://github.com/composer/composer/releases/download/${COMPOSER_VERSION}/composer.phar \
    && chmod a+rwx composer.phar \
    && mv composer.phar /usr/local/bin/composer \
    && composer config -l -g

WORKDIR /var/www/html
