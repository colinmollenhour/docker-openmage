FROM dunglas/frankenphp:1-php8.5-bookworm
ENV PHP_EXT_APCU_VERSION="5.1.28"
ENV PHP_EXT_REDIS_VERSION="6.3.0"
ENV PHP_EXT_XDEBUG_VERSION="3.5.1"

RUN install-php-extensions \
  apcu \
  bcmath \
  ftp \
  gd \
  mbstring \
  mysqli \
  redis \
  pcntl \
  pdo_mysql \
  soap \
  xdebug \
  xsl \
  zip \
  intl

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# set recommended PHP.ini settings
COPY php.ini /usr/local/etc/php/conf.d/zz-magento.ini

# see https://secure.php.net/manual/en/opcache.installation.php
RUN set -eux; \
  { \
  echo 'opcache.memory_consumption=128'; \
  echo 'opcache.interned_strings_buffer=8'; \
  echo 'opcache.max_accelerated_files=4000'; \
  echo 'opcache.revalidate_freq=2'; \
  } > $PHP_INI_DIR/conf.d/opcache-recommended.ini

# https://wordpress.org/support/article/editing-wp-config-php/#configure-error-logging
RUN { \
  # https://www.php.net/manual/en/errorfunc.constants.php
  # https://github.com/docker-library/wordpress/issues/420#issuecomment-517839670
  echo 'error_reporting = E_ERROR | E_WARNING | E_PARSE | E_CORE_ERROR | E_CORE_WARNING | E_COMPILE_ERROR | E_COMPILE_WARNING | E_RECOVERABLE_ERROR'; \
  echo 'display_errors = Off'; \
  echo 'display_startup_errors = Off'; \
  echo 'log_errors = On'; \
  echo 'error_log = /dev/stderr'; \
  echo 'log_errors_max_len = 1024'; \
  echo 'ignore_repeated_errors = On'; \
  echo 'ignore_repeated_source = Off'; \
  echo 'html_errors = Off'; \
  } > $PHP_INI_DIR/conf.d/error-logging.ini

#RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp

ENV FRANKENPHP_CONFIG="worker ./public/index.php"
ENV SERVER_NAME=:80

CMD ["frankenphp"]
