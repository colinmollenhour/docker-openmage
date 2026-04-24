FROM php:8.3-cli
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

ENV BIN_DIR="/usr/local/bin"
RUN apt-get update \
    && apt-get install -y cron git groff default-mysql-client rsyslog sudo unzip \
    && echo "* * * * * /var/www/html/cron.sh" | sudo -u www-data crontab - \
    && sed -i '/imklog/s/^/#/' /etc/rsyslog.conf \
    && arch="$(dpkg --print-architecture)" \
    && case "$arch" in \
        amd64) aws_arch="x86_64" ;; \
        arm64) aws_arch="aarch64" ;; \
        *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; \
    esac \
    && curl --retry 2 --retry-delay 3 -sSL https://awscli.amazonaws.com/awscli-exe-linux-${aws_arch}.zip -o awscliv2.zip && unzip -qq awscliv2.zip && ./aws/install && rm -rf ./aws \
    && curl --retry 2 --retry-delay 3 -sSL https://getcomposer.org/installer | php -- --install-dir=$BIN_DIR --filename=composer \
    && curl --retry 2 --retry-delay 3 -sSL https://github.com/punkstar/mageconfigsync/releases/download/0.4.0/mageconfigsync-0.4.0.phar -o $BIN_DIR/mageconfigsync && chmod +x $BIN_DIR/mageconfigsync \
    && curl --retry 2 --retry-delay 3 -sSL https://github.com/meanbee/magedbm/releases/download/v1.6.0/magedbm.phar -o $BIN_DIR/magedbm.phar && chmod +x $BIN_DIR/magedbm.phar \
    && curl --retry 2 --retry-delay 3 -sSL https://files.magerun.net/n98-magerun.phar -o $BIN_DIR/n98-magerun.phar && chmod +x $BIN_DIR/n98-magerun.phar \
    && curl --retry 2 --retry-delay 3 -sSL https://raw.githubusercontent.com/colinmollenhour/modman/master/modman -o $BIN_DIR/modman && chmod +x $BIN_DIR/modman \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY bin/* $BIN_DIR/
ADD run-cron.sh /run-cron.sh

CMD ["php", "-a"]
