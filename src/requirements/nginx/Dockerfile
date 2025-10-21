FROM debian:bullseye

RUN apt update && apt install -y nginx && apt clean

# Remove default Nginx configs
RUN rm -f /etc/nginx/conf.d/default.conf /etc/nginx/sites-enabled/default

# Copy your custom configuration and HTML file
COPY ./conf/default.conf /etc/nginx/conf.d/default.conf
COPY ./tools/index.html /var/www/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
