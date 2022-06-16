FROM php:7.4.30-fpm

LABEL maintainer="Ricardo Aranha"

# Set working directory
WORKDIR /var/www

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    git \
    zip \
    unzip \
    nginx \
    supervisor \
    libpq-dev \
    && apt-get clean \
    && chmod g+w -R /var/www \
    && docker-php-ext-install \
    pdo_pgsql \
    #change uid and gid of apache to docker user uid/gid
    && usermod -u 1000 www-data && groupmod -g 1000 www-data \
    && chown -R www-data:www-data /var/www   

# Copy code to /var/www
COPY --chown=www-data:www-data . /var/www

# Copy nginx/php/supervisor configs
RUN cp docker/supervisor.conf /etc/supervisord.conf \
    && cp docker/php.ini /usr/local/etc/php/conf.d/app.ini \
    && cp docker/nginx.conf /etc/nginx/sites-enabled/default

# PHP Error Log Files
RUN mkdir /var/log/php \
    && touch /var/log/php/errors.log \
    && chmod 777 /var/log/php/errors.log 

# Deployment steps
RUN cp docker/run.sh /var/run.sh \
    && chmod +x /var/run.sh    

ENTRYPOINT ["/var/run.sh"]