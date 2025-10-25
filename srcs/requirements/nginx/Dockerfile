FROM debian:bullseye

# Update system and install nginx + openssl
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directory for SSL
RUN mkdir -p /etc/nginx/ssl

# Copy SSL initialization script
COPY ./tools/init_ssl.sh /tmp/init_ssl.sh
RUN chmod +x /tmp/init_ssl.sh && /tmp/init_ssl.sh

# Copy nginx configuration
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

# Copy your custom HTML
COPY ./tools/index.html /var/www/html/index.html

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 443 80

CMD ["nginx", "-g", "daemon off;"]