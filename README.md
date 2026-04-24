# OpenMage Docker

This is a collection of Docker images for running [OpenMage LTS](https://github.com/OpenMage/magento-lts).
The images are published only to [GitHub Container Registry](https://github.com/colinmollenhour/docker-openmage/pkgs/container/docker-openmage).

## Supported tags and respective `Dockerfile` links

PHP versions `8.2`, `8.3`, `8.4` and `8.5` are supported with `apache`, `cli`, `fpm` and `frankenphp`
flavours. See `<php-version>/<flavour>/Dockerfile` e.g. `8.2/fpm/Dockerfile`.

## Usage

See [OpenMage dev/openmage/docker-compose.yml](https://github.com/OpenMage/magento-lts/blob/main/dev/openmage/docker-compose.yml) for a sample configuration.

## Options

## Cron

The `cli` image supports running Magento's cron task automatically. This is disabled by default but can be enabled with
the following environment variable:

    ENABLE_CRON=true

*Note:* The cron container must be run as `root` (this is the default) and the cron task will automatically be run as the `www-data` user.

## Xdebug

Xdebug is installed and enabled on all the images by default. To configure it for remote debugging, start
the container with the following environment variable set (replacing the `{}` placeholders with appropriate values):

    XDEBUG_CONFIG="remote_connect_back=1 remote_enable=1 idekey={IDEKEY}"

Note: If you're using PhpStorm, your IDE Key is probably `phpstorm`.

## PHP-FPM

The PHP-FPM image uses the `[www]` pool by default which uses the "dynamic" process manager. The following
settings may be configured using environment variables which will update the template file at runtime.

```
[www]
user = www-data
group = www-data
pm = dynamic
pm.max_children = ${PM_MAX_CHILDREN}
pm.start_servers = ${PM_START_SERVERS}
pm.min_spare_servers = ${PM_MIN_SPARE_SERVERS}
pm.max_spare_servers = ${PM_MAX_SPARE_SERVERS}
```

The defaults are:

- PM_MAX_CHILDREN = 5
- PM_START_SERVERS = 2
- PM_MIN_SPARE_SERVERS = 1
- PM_MAX_SPARE_SERVERS = 3

To make more advanced changes to the pool settings you should either:

1. `COPY` or mount your own `/usr/local/etc/php-fpm.d/www.conf` file into the container
2. Overwrite `/usr/local/etc/php-fpm.d/www.conf.template` with your own modified version
3. Delete the `/usr/local/etc/php-fpm.d/www.conf.template` file and provide your own `.conf` file into `/usr/local/etc/php-fpm.d/` to use a different pool name altogether
4. Add a file like `/usr/local/etc/php-fpm.d/zz-www.conf.template` that is loaded after `www.conf`

# Command Line Tools

The `cli` images have a number of useful Magento tools pre-installed:

- [composer](https://getcomposer.org/) - Install and manage PHP package dependencies
- [mageconfigsync](https://github.com/punkstar/mageconfigsync) - Backup and restore Magento System Configuration
- [magedbm](https://github.com/meanbee/magedbm) - Create development backups of the Magento database using S3 and import them
- magemm - Sync media images from an S3 backup
- [modman](https://github.com/colinmollenhour/modman) - Install Magento extensions
- [magerun](https://github.com/netz98/n98-magerun) - Run command line commands in Magento

All installed tools run in the working directory of the container, so don't forget to set it using the `working_dir` service configuration option in `docker-compose.yml` or the `--workdir` parameter to `docker run`.

The `cli` image uses the same `php.ini` as the web-serving variants, including the default `memory_limit` of `512M`.
For memory-intensive commands, override this per command with PHP's `-d` option:

    docker run --rm -it ghcr.io/colinmollenhour/docker-openmage:8.4-cli php -d memory_limit=-1 /usr/local/bin/n98-magerun.phar

Alternatively, mount or copy a custom PHP configuration file into `/usr/local/etc/php/conf.d/` in the container.
The custom file name must sort after the image's `/usr/local/etc/php/conf.d/zz-magento.ini` file, for example:

    docker run --rm -v ./custom-memory.ini:/usr/local/etc/php/conf.d/zzz-custom-memory.ini ghcr.io/colinmollenhour/docker-openmage:8.4-cli php -i

Some commands use additional environment variables for configuration:

- `AWS_ACCESS_KEY_ID` *(magedbm, magemm)* Credentials for S3 connections
- `AWS_SECRET_ACCESS_KEY` *(magedbm, magemm)* Credentials for S3 connections
- `AWS_REGION` *(magedbm, magemm)* S3 region to use
- `AWS_BUCKET` *(magedbm)* S3 bucket to use for database backups
- `AWS_MEDIA_BUCKET` *(magemm)* S3 bucket to fetch media images from

# Building

A lot of the configuration for each image is the same, with the difference being the base image that they're extending from.
For this reason we use `php` to build the `Dockerfile` from a set of templates in `src/`.  The `Dockerfile` should still
be published to the repository so each image can be built directly from its version/flavour directory and the published
image definitions remain visible.

To build all `Dockerfile`s after editing the files in `src/`, run the `builder.php` script before committing any changes:

    docker run --rm -it -u $(id -u):$(id -g) -v "$(pwd):/src" php:8.2 php /src/builder.php

## Adding new images to the build config

The build configuration is controlled by the `config.json` file using the following syntax for each build target:

    "<target-name>": {
        "version": "<php-version>",
        "flavour": "<image-flavour>",
        "files": {
            "<target-file-name>": {
                "<template-variable-name>": "<template-variable-value>",
                ...
            },
    }

The target files will be rendered in the `<php-version>/<image-flavour>/` directory.

The source template for each target file is selected from the `src/` directory using the following fallback order:

1. `<target-file-name>-<php-version>-<image-flavour>`
2. `<target-file-name>-<php-version>`
3. `<target-file-name>-<image-flavour>`
4. `<target-file-name>`

Individual templates may include other templates as partials.

# Credit

This is a fork of [meanbee/docker-magento](https://github.com/meanbee/docker-magento) which appears to no longer be maintained.
