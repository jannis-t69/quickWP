FROM debian:bookworm-slim


# Install nginx and php8.3
ARG DEBIAN_FRONTEND=noninteractive

# Install Webserver of choice
RUN apt-get update && apt-get install -y nginx

#Install additional utilities    
RUN apt-get update && apt-get install -y nano \
    curl \
    wget \
    bash-completion

# Install php Repository, php and php-modules
RUN curl -sSL https://packages.sury.org/php/README.txt | bash -x
RUN apt-get -y update && \
    apt-get -y install php8.3 \
    php8.3-redis \
    php8.3-sqlite3 \
    php8.3-memcached \
    php8.3-opcache \
    php8.3-curl \
    php8.3-fpm \
    php8.3-gd \
    php8.3-intl \
    php8.3-imagick \
    php8.3-mysql \
    php8.3-mbstring \
    php8.3-zip \
    php8.3-xml \
    php8.3-xmlrpc \
    php8.3-bcmath \
    php8.3-bz2 \
    php8.3-calendar \
    php8.3-ctype \
    php8.3-ftp \
    php8.3-gettext \
    php8.3-iconv \
    php8.3-mysqli \
    php8.3-PDO \
    php8.3-Phar \
    php8.3-readline \
    php8.3-SimpleXML \
    php8.3-zip \
    php8.3-soap \
    php8.3-apcu

RUN apt-get update && apt-get -y install default-mysql-server
# Install mariadb (with empty root password)

# Remove everything that is no longer necessary.
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# Run nginx as daemon
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf

# Copy local plugins to image
COPY plugins /tmp/plugins

# Copy ssl directory with the ssl certificates to image
COPY ssl/* /etc/ssl/

# Copy nginx custom snippet files and config to image
COPY snippets/* /etc/nginx/snippets
COPY nginx.conf /etc/nginx/nginx.conf

# Add our local configs in.
ADD default-ssl.conf /etc/nginx/sites-available/
COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

# Enable nginx ssl configuration
RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/sites-available/default-ssl.conf /etc/nginx/sites-enabled/default-ssl.conf

# # Create fast-cgi cache directory
RUN mkdir -p /var/cache/nginx/cache/
RUN chown -R www-data:www-data /var/cache/nginx/cache

# Set the php options needed
RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 256M/g' /etc/php/8.3/fpm/php.ini
RUN sed -i 's/post_max_size = 8M/post_max_size = 256M/g' /etc/php/8.3/fpm/php.ini

# Install wp-cli
RUN bash -c "curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"
RUN bash -c "chmod +x wp-cli.phar"
RUN bash -c "mv wp-cli.phar /usr/local/bin/wp"

# Install composer
RUN bash -c "curl https://getcomposer.org/installer -o /composer-setup.php"
RUN bash -c "chmod +x /composer-setup.php"
RUN bash -c "php /composer-setup.php"
RUN bash -c "mv /composer.phar /usr/local/bin/composer"

WORKDIR /var/www/html/

# Start daemons.
ENTRYPOINT ["/bin/sh", "-c", "/entrypoint.sh"]


