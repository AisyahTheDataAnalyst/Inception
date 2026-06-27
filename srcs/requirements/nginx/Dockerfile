# Build from the penultimate stable version of Alpine; :latest is forbidden
FROM alpine:3.23

# Install NGINX and OpenSSL using apk without caching the index locally to save space
RUN apk update && apk add --no-cache \
    nginx \
    openssl

# Alpine Gotcha: NGINX will crash if the runtime PID directory doesn't exist
RUN mkdir -p /run/nginx

# Copy your custom NGINX configuration into the container
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy and permission the initialization script
COPY tools/nginx_setup.sh /usr/local/bin/nginx_setup.sh
RUN chmod +x /usr/local/bin/nginx_setup.sh

# NGINX must be the only entrypoint into the infrastructure via port 443
EXPOSE 443

# Start the container using the entrypoint script
# ENTRYPOINT ["/usr/local/bin/nginx_setup.sh"]
ENTRYPOINT ["nginx_setup.sh"]