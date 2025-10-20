# Use Debian (allowed by Inception). You can swap to 'alpine:3.16' if you prefer.
FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Install nginx, remove apt lists to keep image small
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

# Create web root and copy site + config
RUN mkdir -p /var/www/html
COPY index.html /var/www/html/index.html
COPY default.conf /etc/nginx/conf.d/default.conf

# Expose http port
EXPOSE 80

# Run nginx in foreground (no hacky tail -f)
CMD ["nginx", "-g", "daemon off;"]
