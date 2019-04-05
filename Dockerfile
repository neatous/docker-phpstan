FROM php:7.3-fpm
MAINTAINER Martin Venuš <martin.venus@neatous.cz>

ENV TERM xterm

# apt does not create these directories automatically during posgresql-client installation
RUN mkdir /usr/share/man/man1/ /usr/share/man/man7/

RUN apt-get update && apt-get install -y \
        curl \
        libc-client2007e-dev \
        libcurl4-gnutls-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libxml2-dev \
        libpq-dev \
        libvips-dev \
        libzip-dev \
        locales \
        locales-all \
        postgresql-client \
        tar \
        wget \
    && docker-php-ext-install -j$(nproc) opcache bcmath curl json mbstring zip \
	&& docker-php-ext-configure xml --with-libxml-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) xml \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) gd \
	&& docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
	&& docker-php-ext-install -j$(nproc) pdo pdo_pgsql pgsql \
	&& docker-php-ext-install -j$(nproc) soap \
	&& pecl install redis-4.3.0 \
    && docker-php-ext-enable redis \
    && pecl install vips \
    && docker-php-ext-enable vips \
    && docker-php-ext-install sockets

ENV COMPOSER_HOME /composer
ENV COMPOSER_ALLOW_SUPERUSER 1

RUN echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/memory-limit.ini

RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { echo 'Invalid installer' . PHP_EOL; exit(1); }" \
  && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer \
  && php -r "unlink('/tmp/composer-setup.php');" \
  && php -r "unlink('/tmp/composer-setup.sig');"

ENV PATH /composer/vendor/bin:$PATH

RUN composer global require nette/utils:^2.4.5

RUN composer global require phpstan/phpstan --prefer-dist \
&& composer global require phpstan/phpstan-nette --prefer-dist \
&& composer global require phpstan/phpstan-doctrine --prefer-dist \
&& composer global require phpstan/phpstan-phpunit --prefer-dist \
&& composer global show | grep phpstan

VOLUME ["/var/www/html/"]
WORKDIR /var/www/html/

ENTRYPOINT ["phpstan"]
