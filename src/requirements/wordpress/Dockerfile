FROM debian:bullseye

# Install dependencies
RUN apt-get update && apt-get install -y \
    php-fpm php-mysqli php-cli wget tar curl \
    && apt-get clean

# Download and extract WordPress
RUN mkdir -p /var/www/html
WORKDIR /var/www/html

RUN wget https://wordpress.org/latest.tar.gz \
    && tar -xzf latest.tar.gz --strip-components=1 \
    && rm latest.tar.gz

# Copy configuration (to be created next)
COPY ./conf/wp-config.php /var/www/html/wp-config.php

# Set permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000

# Start PHP-FPM in foreground
CMD ["php-fpm7.4", "-F"]
