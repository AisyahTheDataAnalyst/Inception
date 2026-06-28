#!/bin/sh

# Ensure the SSL directory exists
mkdir -p /etc/nginx/ssl

# Generate a self-signed SSL certificate using the domain name environment variable
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    echo "🔥NGINX SETUP🔥 [1/3] Generating SSL certificate for $WP_DOMAIN_URL..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=Inception/CN=$WP_DOMAIN_URL"
fi

# => using sed
# Substitute the placeholder WP_DOMAIN_URL with the actual environment variable in the nginx's conf file
# echo "🔥NGINX SETUP🔥 [2/3] Applying config file configurations..."
# sed -i "s/WP_DOMAIN_URL/$WP_DOMAIN_URL/g" /etc/nginx/nginx.conf

# => using envsubst (industry standard)
# When Alpine installs Nginx, it automatically drops a stock configuration file located at /etc/nginx/http.d/default.conf.
# However, if your script or paths change down the line, Nginx might read both configurations and conflict.
# To make your script bulletproof, explicitly delete the default file right before you generate your clean config:
# Add this right above your envsubst line inside nginx_setup.sh:
rm -f /etc/nginx/http.d/default.conf

# => using envsubst (industry standard)
# Substitute the placeholder with envsubst instead of sed
# Note the single quotes around '$WP_DOMAIN_URL' to protect internal Nginx variables!
# Warning: Nginx natively uses $ for its own internal variables (like $document_root and $fastcgi_script_name)
# If you use envsubst globally, it will overwrite those Nginx variables with empty strings! the line of envsubst to avoid this.
# envsubst '$WP_DOMAIN_URL' < /etc/nginx/http.d/default.template > /etc/nginx/http.d/default.conf
# Change the destination path from /etc/nginx/http.d/default.conf to this:
echo "🔥NGINX SETUP🔥 [2/3] Applying config file configurations..."
envsubst '$WP_DOMAIN_URL' < /etc/nginx/default.template > /etc/nginx/http.d/default.conf

echo "🔥NGINX SETUP🔥 [3/3] NGINX setup complete!"
echo "🔥NGINX EXECUTION🔥   Starting NGINX..."
# Execute NGINX as PID 1 in the foreground without an infinite loop
exec "$@"