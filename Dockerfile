FROM php:8.1-apache
RUN apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update \
    && apt-get install -y --no-install-recommends git zlib1g-dev libzip-dev zip unzip libpng-dev default-mysql-client libjpeg-dev libfreetype6-dev

RUN docker-php-ext-configure gd --with-jpeg --with-freetype

RUN docker-php-ext-install pdo_mysql gd opcache

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN a2enmod rewrite

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && { \
    echo "zend_extension=xdebug"; \
    echo "xdebug.mode=debug"; \
    echo "xdebug.start_with_request=yes"; \
    echo "xdebug.client_host=host.docker.internal"; \
    echo "xdebug.client_port=9001"; \
    echo "xdebug.idekey=phpstorm"; \
    echo "xdebug.log_level=0"; \
    } > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini;

RUN echo "memory_limit=512M" > /usr/local/etc/php/conf.d/docker-php-ext-custom.ini \
    && echo "upload_max_filesize=100M" > /usr/local/etc/php/conf.d/docker-php-ext-custom.ini \
    && echo "post_max_size=100M" > /usr/local/etc/php/conf.d/docker-php-ext-custom.ini

COPY vhost.conf /etc/apache2/sites-enabled/000-default.conf

RUN mkdir /home/www-data \
    && usermod  --uid 1000 -d /home/www-data www-data \
    && groupmod --gid 1000 www-data \
    && chown www-data:www-data -R /home/www-data

USER www-data

EXPOSE 80