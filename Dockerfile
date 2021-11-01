FROM neatous/phpbase:8.0
MAINTAINER Martin Venuš <martin.venus@neatous.cz>

ENV COMPOSER_HOME /composer
ENV COMPOSER_ALLOW_SUPERUSER 1

RUN echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/memory-limit.ini

RUN apt-get update && \
	apt-get -y install unzip && \
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
    && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
    && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { echo 'Invalid installer' . PHP_EOL; exit(1); }" \
    && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('/tmp/composer-setup.php');" \
    && php -r "unlink('/tmp/composer-setup.sig');"

ENV PATH /composer/vendor/bin:$PATH

RUN composer global require phpstan/phpstan "0.12.*" --prefer-dist \
    && composer global require phpstan/phpstan-nette "0.12.*" --prefer-dist \
    && composer global require phpstan/phpstan-doctrine "0.12.*" --prefer-dist \
    && composer global require phpstan/phpstan-phpunit "0.12.*" --prefer-dist \
    && composer global require phpstan/phpstan-deprecation-rules "0.12.*" --prefer-dist \
    && composer global show | grep phpstan

ENTRYPOINT ["phpstan"]
