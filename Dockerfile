FROM alpine:3.19

MAINTAINER Sasaya <sasaya@percussion.life>

ENV APP_ROOT /app
ENV PHP_INI_DIR /etc/php83
ENV APACHE_CONF_DIR /etc/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_DOCUMENT_ROOT ${APP_ROOT}/public

RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/v3.19/community" >> /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
    apk --no-cache add \
      make \
      git \
      curl \
      unzip \
      coreutils \
      apache2 \
      php83@community \
      php83-pdo_mysql@community \
      php83-pdo_sqlite@community \
      php83-redis@community \
      php83-mbstring@community \
      php83-tokenizer@community \
      php83-json@community \
      php83-bcmath@community \
      php83-zip@community \
      php83-gd@community \
      php83-pcntl@community \
      php83-exif@community \
      php83-sockets@community \
      php83-dom@community \
      php83-phar@community \
      php83-xmlwriter@community \
      php83-simplexml@community \
      php83-fileinfo@community \
      php83-posix@community \
      php83-xml@community \
      php83-ctype@community \
      php83-intl@community \
      php83-iconv@community \
      php83-xmlreader@community \
      php83-curl@community \
      php83-apache2@community \
      php83-opcache@community && \
    rm -rf /tmp/* /var/cache/apk/* /var/lib/apt/lists/*

RUN ln -s /usr/bin/php83 /usr/bin/php

ADD tweak.ini ${PHP_INI_DIR}/conf.d/00_tweak.ini
ADD opcache.ini ${PHP_INI_DIR}/conf.d/10_opcache.ini

RUN ln -sfT /dev/stderr ${APACHE_LOG_DIR}/error.log && \
    ln -sfT /dev/stdout ${APACHE_LOG_DIR}/access.log && \
    sed -ri -e 's!^#(LoadModule mpm_prefork_module)!\1!' ${APACHE_CONF_DIR}/httpd.conf && \
    sed -ri -e 's!^#(LoadModule session_module)!\1!' ${APACHE_CONF_DIR}/httpd.conf && \
    sed -ri -e 's!^#(LoadModule session_cookie_module)!\1!' ${APACHE_CONF_DIR}/httpd.conf && \
    sed -ri -e 's!^#(LoadModule session_crypto_module)!\1!' ${APACHE_CONF_DIR}/httpd.conf && \
    sed -ri -e 's!^#(LoadModule rewrite_module)!\1!' ${APACHE_CONF_DIR}/httpd.conf && \
    sed -ri -e 's!^(ServerTokens )OS!\1Prod!' ${APACHE_CONF_DIR}/httpd.conf && \
    sed -ri -e 's!^(ServerSignature )On!\1Off!' ${APACHE_CONF_DIR}/httpd.conf && \
    sed -ri -e 's!/var/www/localhost/htdocs!${APACHE_DOCUMENT_ROOT}!' ${APACHE_CONF_DIR}/httpd.conf && \
    sed -ri -e 's!(Options )Indexes (FollowSymLinks)!\1\2!' ${APACHE_CONF_DIR}/httpd.conf && \
    sed -ri -e 's!(AllowOverride )None!\1All!' ${APACHE_CONF_DIR}/httpd.conf

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

VOLUME ${APP_ROOT}
WORKDIR ${APP_ROOT}

EXPOSE 80

CMD ["/usr/sbin/httpd", "-DFOREGROUND"]
