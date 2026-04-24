FROM php:8.4-fpm
ENV PHP_EXT_APCU_VERSION="5.1.28"
ENV PHP_EXT_REDIS_VERSION="6.3.0"
ENV PHP_EXT_XDEBUG_VERSION="3.5.1"

ENV BUILD_PACKAGES="libpng-dev libfreetype6-dev libjpeg62-turbo-dev libonig-dev libxml2-dev libxslt1-dev libicu-dev libssl-dev libzip-dev"

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y $BUILD_PACKAGES \
    && yes "" | pecl install apcu-$PHP_EXT_APCU_VERSION && docker-php-ext-enable apcu \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install ftp \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install mysqli \
    && echo "no" | pecl -q install redis-$PHP_EXT_REDIS_VERSION && docker-php-ext-enable redis \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install soap \
    && yes | pecl -q install xdebug-$PHP_EXT_XDEBUG_VERSION && docker-php-ext-enable xdebug \
    && docker-php-ext-install xsl \
    && docker-php-ext-install zip \
    && docker-php-ext-install intl \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY php.ini /usr/local/etc/php/conf.d/zz-magento.ini

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

RUN rm /usr/local/etc/php-fpm.d/www.conf
COPY www.conf /usr/local/etc/php-fpm.d/www.conf.template

CMD ["php-fpm"]
