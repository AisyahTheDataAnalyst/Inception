#!/bin/sh

# Ensure the SSL directory exists
mkdir -p /etc/nginx/ssl

# Generate a self-signed SSL certificate using the domain name environment variable
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    echo "🔥NGINX SETUP🔥 [1/2] Generating SSL certificate for $WP_DOMAIN_URL..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=Inception/CN=$WP_DOMAIN_URL"
fi

# Substitute the placeholder WP_DOMAIN_URL with the actual environment variable in the nginx's conf file
sed -i "s/WP_DOMAIN_URL/$WP_DOMAIN_URL/g" /etc/nginx/nginx.conf

echo "🔥NGINX SETUP🔥 [2/2] Starting NGINX..."
# Execute NGINX as PID 1 in the foreground without an infinite loop
exec nginx -g "daemon off;"