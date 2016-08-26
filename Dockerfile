FROM ubuntu:16.04
MAINTAINER Jason Burns <jburns@gocontec.com>

RUN apt-get update \
    && apt-get install -yq \
    apache2 \
    apt-transport-https \
    curl \
    git \
    git-core \
    libapache2-mod-php7.0 \
    libsasl2-dev \
    nano \
    nginx \
    openssl \
    wget \
    varnish \
    php7.0 \
    php-curl \
    php-gd \
    php-imagick \
    php-mcrypt \
    php-mysql \
    php-odbc \
    php-dev \
    php-cli \
    php-http-request \
    php-pear \
    php-soap \
    php7.0-sybase \
    php7.0-zip \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Mongo Extension
RUN mkdir -p /usr/local/openssl/include/openssl/ \
    && ln -s /usr/include/openssl/evp.h /usr/local/openssl/include/openssl/evp.h \
    && mkdir -p /usr/local/openssl/lib/ \
    && ln -s /usr/lib/x86_64-linux-gnu/libssl.a /usr/local/openssl/lib/libssl.a \
    && ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/local/openssl/lib/ \
    && pecl install mongodb \
    && echo "extension=mongodb.so" >> `php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||"`

# Install and Configure New Relic
RUN wget -O - https://download.newrelic.com/548C16BF.gpg | apt-key add - \
    && echo "deb http://apt.newrelic.com/debian/ newrelic non-free" > /etc/apt/sources.list.d/newrelic.list \
    && apt-get update \
    && echo newrelic-php5 newrelic-php5/application-name string "DeepBlu API" | debconf-set-selections \
    && echo newrelic-php5 newrelic-php5/license-key string "066ba6e83472e9adf8132787fea9b9470d89fbc5" | debconf-set-selections \
    && apt-get install -yq newrelic-php5

# Configure Apache
RUN a2enmod headers \
    && a2enmod rewrite \
    && a2enmod ssl

ADD etc/apache/vhost.conf /etc/apache2/sites-available/000-default.conf
ADD etc/apache/ports.conf /etc/apache2/ports.conf
RUN rm -rf /var/www/html/*
ADD . /var/www/html/
RUN chown -R www-data:www-data /var/www/html

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2

RUN usermod -u 1000 www-data

# Configure Nginx
ADD etc/nginx/default /etc/nginx/sites-enabled/default

# Configure Varnish
ADD etc/varnish/default.vcl /etc/varnish/default.vcl
ADD etc/varnish/varnish /etc/default/varnish

WORKDIR /var/www/html

RUN sed -i 's/\r//' etc/symfony/symfonize.sh \
    && chmod a+x etc/symfony/symfonize.sh \
    && sed -i 's/\r//' etc/symfony/develop.sh \
    && chmod a+x etc/symfony/develop.sh

# Open up ports to traffic between host and container
EXPOSE 80 443

CMD ["etc/symfony/symfonize.sh"]