FROM debian:bullseye

# Update system and install nginx + openssl
RUN apt-get update \
	&& apt-get install -y nginx openssl \
	&& apt-get clean

# Create directory for SSL
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
    -subj "/C=MY/ST=KL/L=KL/O=42School/CN=localhost" \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt

# Copy nginx configuration
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

# Copy your custom HTML
COPY ./html/index.html /var/www/html/index.html

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
