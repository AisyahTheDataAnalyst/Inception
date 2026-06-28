# Base image - Debian is the industry standard for Wordpress
FROM debian:bookworm 

# Stop interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies (PHP-FPM, PHP-MySQL extension, and curl/wget to grab WordPress)
RUN apt-get update && apt-get install -y \
	php8.2-fpm \		
	php8.2-mysql \
	curl \
	mariadb-client \
	&& rm -rf /var/lib/apt/lists/*

# Install WP-CLI as a file named wp-cli.phar
# Make it executable as a command: chmod +x
# Make it global: moved to /usr/bin/
# Just a shorthand alias: renamed to /usr/bin/wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp-cli

# Pre-download wordpress core during build so runtime doesn't depend on internet speed
RUN curl -o /tmp/wordpress.tar.gz https://wordpress.org/wordpress-7.0.tar.gz \
    && tar -xzf /tmp/wordpress.tar.gz -C /tmp/ \
    && rm /tmp/wordpress.tar.gz

# # NO NEED MANUAL CONFIG FILE - Copy your custom PHP-FPM configuration into the container
# COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
# can either do this in Dockerfile or script file (i choose .sh file)
# 	=> Change PHP-FPM to listen on port 9000 instead of a local socket file
# RUN echo "listen = 9000" >> /etc/php/8.2/fpm/pool.d/www.conf

# Setup HTML directories and run paths for PHP runtime sockets
# Create the directory for PHP-FPM runtime files (sockets/pids) if needed
# Line 1 creates the folder for your WordPress website files and gives WordPress permission to read/write there.
# Line 2 creates a temporary runtime folder required by the PHP-FPM engine itself so it can boot up without crashing.
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html
RUN mkdir -p /run/php

# Set up the working directory where WordPress website files will be created & live
WORKDIR /var/www/html

# Listen internally to NGINX only, not to Host
EXPOSE 9000

# Copy your initialization/entrypoint script to be accessible from anywhere
COPY ./tools/wp_setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wp_setup.sh

# ('-F') Run PHP-FPM in the foreground so the container doesn't immediately exit
ENTRYPOINT ["/usr/local/bin/wp_setup.sh"]
CMD ["php-fpm8.2", "-F"]  
