FROM php:7.2-apache

WORKDIR /var/www/

COPY xdebug-toggle /usr/local/sbin/
RUN /bin/bash -c 'chmod +x /usr/local/sbin/xdebug-toggle'

RUN mkdir -p /var/tmp/php/
RUN mkdir -p /usr/local/lib/php/extensions/
RUN mkdir -p /var/log/mysql/

# Add mysql client to web container
RUN apt-get update && apt-get install -y default-mysql-client

# Use the default development environment.
# 6-11-19: WAS NOT IN USE IN OLDER VERSIONS OF THIS REPO - may cause some weird behaviors.
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# Changing the Document Root of Apache
# https://docs.docker.com/samples/library/php/#changing-documentroot-or-other-apache-configuration
ENV APACHE_DOCUMENT_ROOT /var/www/dealer-inspire/
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# DI Platform Environment Variables
# See contract with SysOps for what is maintained on Dev and Prod
# https://bitbucket.org/dealerinspire/development-and-systems-contracts/src/master/contracts/wordpress-pod-environment.md
RUN echo 'SetENV POD 0' >> /etc/apache2/sites-available/000-default.conf
RUN echo 'SetENV APPLICATION_ENV local' >> /etc/apache2/sites-available/000-default.conf
RUN echo 'SetENV RESQUE_REDIS_HOST redis' >> /etc/apache2/sites-available/000-default.conf
RUN echo 'SetENV CACHE_REDIS_HOST redis' >> /etc/apache2/sites-available/000-default.conf
RUN echo 'SetENV SHARED_CACHE_REDIS_HOST redis' >> /etc/apache2/sites-available/000-default.conf
RUN echo 'SetENV RESQUE_QUEUE_WORDPRESS wordpress_dev' >> /etc/apache2/sites-available/000-default.conf

# This one is pre-contract. Kept for backwards compatibility
RUN echo 'SetENV REDIS_HOST redis' >> /etc/apache2/sites-available/000-default.conf

RUN apt-get --allow-releaseinfo-change update && apt-get update -y && apt-get install -y \
    libpng-dev \
    vim \
    redis-server \
    libicu-dev

RUN docker-php-ext-install pdo pdo_mysql gd mysqli opcache calendar intl


# Grab NetSkope cert and update certificates
RUN curl -fsSL 'http://cars-corp-prod-jumpcloud-packages.s3.amazonaws.com/nscacert.pem' --output nscacert.pem && cp nscacert.pem /usr/local/share/ca-certificates/nscacert.crt && update-ca-certificates

# The next few steps are all for sassphp
# download/unzip/relocate sassphp from the repo
RUN cd /usr/local/lib/php/extensions \
    && curl -fsSL 'https://github.com/absalomedia/sassphp/tarball/master' -o sassphp.tar.gz \
    && mkdir sassphp \
    && tar -xf sassphp.tar.gz -C sassphp --strip-components=1 \
    && rm sassphp.tar.gz

# libsass is a submodule when getting sassphp from git
# since we're curling the repo, we need to do this manually.
RUN cd /usr/local/lib/php/extensions/sassphp/lib \
    && curl -fsSL 'https://github.com/sass/libsass/tarball/master' -o libsass.tar.gz \
    && tar -xf libsass.tar.gz -C libsass --strip-components=1 \
    && rm libsass.tar.gz \
    && make -C /usr/local/lib/php/extensions/sassphp/lib/libsass

# Make and enable sassphp
RUN cd /usr/local/lib/php/extensions/sassphp \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && docker-php-ext-enable sass \
    && rm -r /usr/local/lib/php/extensions/sassphp

RUN pecl install redis \
    && pecl install xdebug-3.1.6 \
    && docker-php-ext-enable redis

RUN a2enmod rewrite
RUN a2enmod headers
RUN service apache2 restart