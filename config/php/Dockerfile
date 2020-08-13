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
    && chmod +x install-composer.sh \
    && chmod +x "${MORE_EXTENSION_INSTALLER}"\
    && sh install.sh \
    && sh "${MORE_EXTENSION_INSTALLER}" \
    && php -v \
    && php -m \
    && bash install-composer.sh \
    && rm -rf /tmp/extensions 

WORKDIR /var/www/html
