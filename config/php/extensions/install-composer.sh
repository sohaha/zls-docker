#!/bin/sh

echo "---------- Install composer ----------"

isChina=$(curl --silent "cip.cc" | grep "中国")
isComposerURL="https://github.com/composer/composer/releases/download/${COMPOSER_VERSION}/composer.phar"
if [[ -n $isChina || "" == $COMPOSER_VERSION ]]; then
  isComposerURL="https://mirrors.aliyun.com/composer/composer.phar"
fi

wget ${isComposerURL} \
&& chmod a+rwx composer.phar \
&& mv composer.phar /usr/local/bin/composer \
&& composer config -l -g