FROM ubuntu:18.04
MAINTAINER Benjamin Brandt <benjamin.brandt@startnext.com>

ENV DEBIAN_FRONTEND noninteractive

# Always required for myty
RUN apt-get update && apt-get install -y \
        mariadb-client \
        php-fpm \
        php-cli \
        php-gd \
        php-imagick \
        php-apcu \
        php-igbinary \
        php-tidy \
        php-mysql \
        php-yaml \
        php-zip \
        php-intl \
        php-bcmath \
        php-memcached \
        php-curl \
        php-mbstring \
        php-opcache \
        php-json \
        php-readline \
        php-xmlrpc \
        php-http-request2 \
        locales \
        jpegoptim \
        optipng \
        wget \
	curl \
    && rm /etc/php/7.2/cli/php.ini \
    && rm /etc/php/7.2/fpm/pool.d/www.conf \
    && apt-get autoremove --purge -y \
        php7.2-phpdbg \
        xauth \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /run/php/

RUN echo "$(curl -sS https://composer.github.io/installer.sig) -" > composer-setup.php.sig \
        && curl -sS https://getcomposer.org/installer | tee composer-setup.php | sha384sum -c composer-setup.php.sig \
        && php composer-setup.php && rm composer-setup.php* \
        && chmod +x composer.phar && mv composer.phar /usr/bin/composer

# Copy PHP config
COPY etc/ /etc/

# Copy Sourceguardian
COPY ext /usr/local/sourceguardian

RUN ln -s /etc/php/7.2/mods-available/myty_php_cli.ini /etc/php/7.2/fpm/myty_php_cli.ini  \
    && ln -s /etc/php/7.2/mods-available/myty_php_fpm.ini /etc/php/7.2/fpm/myty_php_fpm.ini \
    && locale-gen \
    && phpdismod\
        memcached \
    && phpenmod \
        myty \
        sourceguardian

WORKDIR /var/www/web

EXPOSE 9001

CMD ["php-fpm7.2", "--nodaemonize"]
