#!/bin/sh
set -e

mkdir -p /etc/nginx/ssl

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/aimokhta.42.fr.key \
  -out /etc/nginx/ssl/aimokhta.42.fr.crt \
  -subj "/C=MY/ST=KualaLumpur/L=KualaLumpur/O=42/OU=Student/CN=localhost"


