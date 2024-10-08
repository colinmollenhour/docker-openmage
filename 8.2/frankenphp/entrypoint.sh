#!/bin/bash
set -e

[ "$DEBUG" = "true" ] && set -x


# Configure Sendmail if required
if [ "$ENABLE_SENDMAIL" == "true" ]; then
    /etc/init.d/sendmail start
fi

# Configure Xdebug
if [ "$XDEBUG_CONFIG" ]; then
    echo "" > /usr/local/etc/php/conf.d/zz-xdebug.ini
    for config in $XDEBUG_CONFIG; do
        echo "xdebug.$config" >> /usr/local/etc/php/conf.d/zz-xdebug.ini
    done
fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
        set -- frankenphp run "$@"
fi

# Execute the supplied command
exec "$@"
