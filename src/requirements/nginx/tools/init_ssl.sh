#!/bin/sh
mkdir -p /etc/nginx/ssl

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/inception.key \
  -out /etc/nginx/ssl/inception.crt \
  -subj "/C=MY/ST=KualaLumpur/L=KL/O=42Inception/OU=Student/CN=localhost"
