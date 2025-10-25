FROM debian:bullseye

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    php-fpm \
    php-mysql \
    php-cli \
    php-curl \
    php-json \
    php-xml \
    php-mbstring \
    wget \
    curl \
    mariadb-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create PHP-FPM run directory
RUN mkdir -p /run/php

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Create WordPress directory
RUN mkdir -p /var/www/html
WORKDIR /var/www/html

# Copy setup script
COPY ./tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Set permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000

CMD ["/usr/local/bin/setup.sh"]