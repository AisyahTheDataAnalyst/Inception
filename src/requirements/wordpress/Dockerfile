FROM debian:bullseye

RUN apt update && apt install -y php7.4 php7.4-fpm php7.4-mysqli wget mariadb-client && apt clean

# Install WordPress CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

COPY ./tools/setup.sh /tmp/setup.sh
RUN chmod +x /tmp/setup.sh

WORKDIR /var/www/html

CMD ["sh", "/tmp/setup.sh"]

EXPOSE 9000
CMD ["php-fpm7.4", "-F"]
