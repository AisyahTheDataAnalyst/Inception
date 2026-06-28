# Build from the penultimate stable version of Alpine; :latest is forbidden
FROM alpine:3.23

# Install NGINX and OpenSSL using apk without caching the index locally to save space
# Install gettext too (required for envsubst, Alpine does not come with envsubst pre-installed)
RUN apk update && apk add --no-cache \
    nginx \
    openssl \
    gettext

# Alpine Gotcha: NGINX will crash if the runtime PID directory doesn't exist
RUN mkdir -p /run/nginx

# => using sed 
#   => you can modify your single nginx.conf directly in place using the -i flag.
# # # Copy your custom NGINX configuration into the container
# COPY conf/nginx.conf /etc/nginx/nginx.conf
# # # Copy and permission the initialization script
# COPY tools/nginx_setup.sh /usr/local/bin/nginx_setup.sh
# RUN chmod +x /usr/local/bin/nginx_setup.sh

# => using envsubst 
#   => you cannot overwrite a file with itself cleanly without destroying it (e.g., envsubst < file > file blanks the file out). You are forced to maintain two separate files: a .template file and a final .conf file.
#   => industry best-practice and making the configuration file look highly professional
# Copy your custom NGINX template file instead of a rigid conf
# DONT USE THIS ANYMORE => COPY conf/default.template /etc/nginx/http.d/default.template
# update: match changes in nginx.sh & default.template
COPY conf/default.template /etc/nginx/default.template
# default.template just need to be read, not executed, so no chmod +x upon it 


# Copy and permission the initialization script
COPY tools/nginx_setup.sh /usr/local/bin/nginx_setup.sh
RUN chmod +x /usr/local/bin/nginx_setup.sh

# NGINX must be the only entrypoint into the infrastructure via port 443
EXPOSE 443

# Start the container using the entrypoint script
# ENTRYPOINT ["/usr/local/bin/nginx_setup.sh"]
# ; in CMD => It's an Nginx rule, not a Docker rule
#   => In Nginx, every single configuration directive must end with a semicolon ;
# Absolte path in ENTRYPOINT => Alpine won't know where to find the script
ENTRYPOINT ["/usr/local/bin/nginx_setup.sh"]
CMD ["nginx", "-g", "daemon off;"]