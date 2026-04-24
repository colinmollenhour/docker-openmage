#!/bin/bash
set -e

[ "$DEBUG" = "true" ] && set -x


# Configure Xdebug
if [ "$XDEBUG_CONFIG" ]; then
    echo "" > /usr/local/etc/php/conf.d/zz-xdebug.ini
    for config in $XDEBUG_CONFIG; do
        echo "xdebug.$config" >> /usr/local/etc/php/conf.d/zz-xdebug.ini
    done
fi

# Configure PHP-FPM using environment variables
if test -f /usr/local/etc/php-fpm.d/www.conf.template && ! test -f /usr/local/etc/php-fpm.d/www.conf; then
    export PM_MAX_CHILDREN=${PM_MAX_CHILDREN:-5}
    export PM_START_SERVERS=${PM_START_SERVERS:-2}
    export PM_MIN_SPARE_SERVERS=${PM_MIN_SPARE_SERVERS:-1}
    export PM_MAX_SPARE_SERVERS=${PM_MAX_SPARE_SERVERS:-3}
    while read -r line; do eval echo \"$line\"; done < /usr/local/etc/php-fpm.d/www.conf.template > /usr/local/etc/php-fpm.d/www.conf
fi

# Execute the supplied command
exec "$@"
